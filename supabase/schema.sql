





create extension if not exists "pgcrypto";





create table if not exists public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  email       text,
  full_name   text,
  phone       text,
  address     text,
  city        text,
  postal_code text,
  country     text,
  role        text not null default 'customer' check (role in ('customer', 'admin')),
  created_at  timestamptz not null default now()
);

create table if not exists public.categories (
  id         uuid primary key default gen_random_uuid(),
  name       text not null unique,
  image_url  text,
  created_at timestamptz not null default now()
);

create table if not exists public.products (
  id               uuid primary key default gen_random_uuid(),
  name             text not null,
  description      text not null default '',
  price            numeric(10, 2) not null check (price >= 0),
  compare_at_price numeric(10, 2) check (compare_at_price is null or compare_at_price >= 0),
  stock            integer not null default 0 check (stock >= 0),
  category_id      uuid references public.categories (id) on delete set null,
  images           text[] not null default '{}',
  sizes            text[] not null default '{}',
  is_featured      boolean not null default false,
  is_active        boolean not null default true,
  rating_avg       numeric(3, 2) not null default 0,
  rating_count     integer not null default 0,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create index if not exists products_category_idx on public.products (category_id);
create index if not exists products_created_idx on public.products (created_at desc);

create table if not exists public.wishlist (
  user_id    uuid not null references public.profiles (id) on delete cascade,
  product_id uuid not null references public.products (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, product_id)
);

create table if not exists public.orders (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid references public.profiles (id) on delete set null,
  status         text not null default 'pending'
                 check (status in ('pending', 'processing', 'shipped', 'delivered', 'cancelled')),
  subtotal       numeric(10, 2) not null default 0,
  shipping_fee   numeric(10, 2) not null default 0,
  total          numeric(10, 2) not null default 0,
  full_name      text not null,
  phone          text not null,
  address        text not null,
  city           text not null,
  postal_code    text,
  country        text,
  notes          text,
  payment_method text not null default 'cod',
  created_at     timestamptz not null default now()
);

create index if not exists orders_user_idx on public.orders (user_id, created_at desc);

create table if not exists public.order_items (
  id            uuid primary key default gen_random_uuid(),
  order_id      uuid not null references public.orders (id) on delete cascade,
  product_id    uuid references public.products (id) on delete set null,
  product_name  text not null,
  product_image text,
  unit_price    numeric(10, 2) not null,
  quantity      integer not null check (quantity > 0),
  size          text
);

create index if not exists order_items_order_idx on public.order_items (order_id);

create table if not exists public.reviews (
  id          uuid primary key default gen_random_uuid(),
  product_id  uuid not null references public.products (id) on delete cascade,
  user_id     uuid not null references public.profiles (id) on delete cascade,
  rating      integer not null check (rating between 1 and 5),
  comment     text not null default '',
  author_name text,
  created_at  timestamptz not null default now(),
  unique (product_id, user_id)
);





create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role = 'admin');
$$;


create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name)
  values (new.id, new.email, new.raw_user_meta_data ->> 'full_name')
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();



create or replace function public.protect_profile_role()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.role is distinct from old.role and auth.uid() is not null and not public.is_admin() then
    raise exception 'Only admins can change roles';
  end if;
  return new;
end;
$$;

drop trigger if exists profiles_protect_role on public.profiles;
create trigger profiles_protect_role
  before update on public.profiles
  for each row execute function public.protect_profile_role();

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists products_touch_updated_at on public.products;
create trigger products_touch_updated_at
  before update on public.products
  for each row execute function public.touch_updated_at();


create or replace function public.refresh_product_rating()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_product uuid;
begin
  if tg_op = 'DELETE' then
    v_product := old.product_id;
  else
    v_product := new.product_id;
  end if;

  update public.products
  set rating_avg   = coalesce((select round(avg(rating)::numeric, 2) from public.reviews where product_id = v_product), 0),
      rating_count = (select count(*) from public.reviews where product_id = v_product)
  where id = v_product;

  return null;
end;
$$;

drop trigger if exists reviews_refresh_rating on public.reviews;
create trigger reviews_refresh_rating
  after insert or update or delete on public.reviews
  for each row execute function public.refresh_product_rating();


create or replace function public.restock_cancelled_order()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.status = 'cancelled' and old.status <> 'cancelled' then
    update public.products p
    set stock = p.stock + x.qty
    from (
      select product_id, sum(quantity) as qty
      from public.order_items
      where order_id = new.id and product_id is not null
      group by product_id
    ) x
    where p.id = x.product_id;
  end if;
  return new;
end;
$$;

drop trigger if exists orders_restock on public.orders;
create trigger orders_restock
  after update of status on public.orders
  for each row execute function public.restock_cancelled_order();






create or replace function public.place_order(p_items jsonb, p_shipping jsonb)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user     uuid := auth.uid();
  v_order    uuid;
  v_item     jsonb;
  v_product  public.products%rowtype;
  v_qty      integer;
  v_subtotal numeric := 0;
  v_shipping numeric;
begin
  if v_user is null then
    raise exception 'Please sign in to place an order';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'Your bag is empty';
  end if;
  if coalesce(trim(p_shipping ->> 'full_name'), '') = ''
     or coalesce(trim(p_shipping ->> 'phone'), '') = ''
     or coalesce(trim(p_shipping ->> 'address'), '') = ''
     or coalesce(trim(p_shipping ->> 'city'), '') = '' then
    raise exception 'Please complete your shipping details';
  end if;

  insert into public.orders (user_id, full_name, phone, address, city, postal_code, country, notes, payment_method)
  values (
    v_user,
    p_shipping ->> 'full_name',
    p_shipping ->> 'phone',
    p_shipping ->> 'address',
    p_shipping ->> 'city',
    p_shipping ->> 'postal_code',
    p_shipping ->> 'country',
    nullif(p_shipping ->> 'notes', ''),
    coalesce(p_shipping ->> 'payment_method', 'cod')
  )
  returning id into v_order;

  for v_item in select value from jsonb_array_elements(p_items)
  loop
    v_qty := (v_item ->> 'quantity')::integer;
    if v_qty is null or v_qty < 1 then
      raise exception 'Invalid quantity in your bag';
    end if;

    select * into v_product
    from public.products
    where id = (v_item ->> 'product_id')::uuid and is_active
    for update;

    if not found then
      raise exception 'A product in your bag is no longer available';
    end if;
    if v_product.stock < v_qty then
      raise exception 'Only % left of "%"', v_product.stock, v_product.name;
    end if;

    update public.products set stock = stock - v_qty where id = v_product.id;

    insert into public.order_items (order_id, product_id, product_name, product_image, unit_price, quantity, size)
    values (v_order, v_product.id, v_product.name, v_product.images[1], v_product.price, v_qty, nullif(v_item ->> 'size', ''));

    v_subtotal := v_subtotal + v_product.price * v_qty;
  end loop;

  v_shipping := case when v_subtotal >= 50 then 0 else 5 end;

  update public.orders
  set subtotal = v_subtotal, shipping_fee = v_shipping, total = v_subtotal + v_shipping
  where id = v_order;

  return v_order;
end;
$$;

create or replace function public.cancel_order(p_order_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.orders
  set status = 'cancelled'
  where id = p_order_id and user_id = auth.uid() and status = 'pending';

  if not found then
    raise exception 'This order can no longer be cancelled';
  end if;
end;
$$;

revoke execute on function public.place_order(jsonb, jsonb) from public, anon;
revoke execute on function public.cancel_order(uuid) from public, anon;
grant execute on function public.place_order(jsonb, jsonb) to authenticated;
grant execute on function public.cancel_order(uuid) to authenticated;





alter table public.profiles    enable row level security;
alter table public.categories  enable row level security;
alter table public.products    enable row level security;
alter table public.wishlist    enable row level security;
alter table public.orders      enable row level security;
alter table public.order_items enable row level security;
alter table public.reviews     enable row level security;


drop policy if exists "profiles: read own or admin" on public.profiles;
create policy "profiles: read own or admin" on public.profiles
  for select using (id = auth.uid() or public.is_admin());

drop policy if exists "profiles: update own or admin" on public.profiles;
create policy "profiles: update own or admin" on public.profiles
  for update using (id = auth.uid() or public.is_admin());


drop policy if exists "categories: public read" on public.categories;
create policy "categories: public read" on public.categories
  for select using (true);

drop policy if exists "categories: admin write" on public.categories;
create policy "categories: admin write" on public.categories
  for all using (public.is_admin()) with check (public.is_admin());


drop policy if exists "products: public read active" on public.products;
create policy "products: public read active" on public.products
  for select using (is_active or public.is_admin());

drop policy if exists "products: admin write" on public.products;
create policy "products: admin write" on public.products
  for all using (public.is_admin()) with check (public.is_admin());


drop policy if exists "wishlist: own rows" on public.wishlist;
create policy "wishlist: own rows" on public.wishlist
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());


drop policy if exists "orders: read own or admin" on public.orders;
create policy "orders: read own or admin" on public.orders
  for select using (user_id = auth.uid() or public.is_admin());

drop policy if exists "orders: admin update" on public.orders;
create policy "orders: admin update" on public.orders
  for update using (public.is_admin()) with check (public.is_admin());

drop policy if exists "orders: admin delete" on public.orders;
create policy "orders: admin delete" on public.orders
  for delete using (public.is_admin());


drop policy if exists "order_items: read own or admin" on public.order_items;
create policy "order_items: read own or admin" on public.order_items
  for select using (
    public.is_admin()
    or exists (select 1 from public.orders o where o.id = order_id and o.user_id = auth.uid())
  );


drop policy if exists "reviews: public read" on public.reviews;
create policy "reviews: public read" on public.reviews
  for select using (true);

drop policy if exists "reviews: insert own" on public.reviews;
create policy "reviews: insert own" on public.reviews
  for insert with check (user_id = auth.uid());

drop policy if exists "reviews: update own" on public.reviews;
create policy "reviews: update own" on public.reviews
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "reviews: delete own or admin" on public.reviews;
create policy "reviews: delete own or admin" on public.reviews
  for delete using (user_id = auth.uid() or public.is_admin());





insert into storage.buckets (id, name, public)
values ('product-images', 'product-images', true)
on conflict (id) do nothing;

drop policy if exists "product-images: public read" on storage.objects;
create policy "product-images: public read" on storage.objects
  for select using (bucket_id = 'product-images');

drop policy if exists "product-images: admin insert" on storage.objects;
create policy "product-images: admin insert" on storage.objects
  for insert to authenticated with check (bucket_id = 'product-images' and public.is_admin());

drop policy if exists "product-images: admin update" on storage.objects;
create policy "product-images: admin update" on storage.objects
  for update to authenticated using (bucket_id = 'product-images' and public.is_admin());

drop policy if exists "product-images: admin delete" on storage.objects;
create policy "product-images: admin delete" on storage.objects
  for delete to authenticated using (bucket_id = 'product-images' and public.is_admin());
