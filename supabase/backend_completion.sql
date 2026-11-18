alter table public.profiles add column if not exists avatar_url text;

insert into public.profiles (id, email, full_name)
select u.id, u.email, u.raw_user_meta_data ->> 'full_name'
from auth.users u
on conflict (id) do nothing;

create or replace function public.format_pkr(p_amount numeric)
returns text
language sql
immutable
set search_path = public
as $$
  select 'Rs ' || to_char(coalesce(p_amount, 0) * 280, 'FM999,999,999,990.00');
$$;

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
  if new.role is distinct from old.role and old.id = auth.uid() and new.role <> 'admin' then
    raise exception 'You cannot remove your own admin access';
  end if;
  return new;
end;
$$;

drop policy if exists "profiles: insert own" on public.profiles;
create policy "profiles: insert own" on public.profiles
  for insert to authenticated with check (id = auth.uid() and role = 'customer');

alter table public.orders add column if not exists stock_restored boolean not null default false;

create or replace function public.restock_cancelled_order()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.status = 'cancelled'
     and old.status <> 'cancelled'
     and not coalesce(old.stock_restored, false) then
    update public.products p
    set stock = p.stock + x.qty
    from (
      select product_id, sum(quantity) as qty
      from public.order_items
      where order_id = new.id and product_id is not null
      group by product_id
    ) x
    where p.id = x.product_id;
    new.stock_restored := true;
  end if;
  return new;
end;
$$;

drop trigger if exists orders_restock on public.orders;
create trigger orders_restock
  before update of status on public.orders
  for each row execute function public.restock_cancelled_order();

create or replace function public.set_review_author_name()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.user_id is not null then
    select coalesce(nullif(trim(full_name), ''), split_part(email, '@', 1), 'Shopper')
    into new.author_name
    from public.profiles
    where id = new.user_id;
  end if;
  return new;
end;
$$;

drop trigger if exists reviews_set_author on public.reviews;
create trigger reviews_set_author
  before insert or update of user_id, author_name on public.reviews
  for each row execute function public.set_review_author_name();

create or replace function public.notify_order_placed()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.total > 0 and coalesce(old.total, 0) = 0 then
    if new.user_id is not null then
      insert into public.notifications (user_id, title, body, link, kind)
      values (
        new.user_id,
        'Order confirmed ✦',
        'We got your order ' || public.order_ref(new.id) || ' (' || public.format_pkr(new.total) || '). We''ll let you know when it moves.',
        '/account/orders/' || new.id,
        'order'
      );
    end if;

    perform public.notify_admins(
      'New order ' || public.order_ref(new.id),
      new.full_name || ' just spent ' || public.format_pkr(new.total) || '.',
      '/admin/orders'
    );
  end if;
  return new;
end;
$$;

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

drop policy if exists "avatars: public read" on storage.objects;
create policy "avatars: public read" on storage.objects
  for select using (bucket_id = 'avatars');

drop policy if exists "avatars: owner insert" on storage.objects;
create policy "avatars: owner insert" on storage.objects
  for insert to authenticated with check (
    bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "avatars: owner update" on storage.objects;
create policy "avatars: owner update" on storage.objects
  for update to authenticated using (
    bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text
  ) with check (
    bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "avatars: owner delete" on storage.objects;
create policy "avatars: owner delete" on storage.objects
  for delete to authenticated using (
    bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text
  );

update public.products set images = array[
  'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=900&q=80'
] where name = 'Y2K Baby Tee';
update public.products set images = array[
  'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?auto=format&fit=crop&w=900&q=80'
] where name = 'Wide Leg Cargo Pants';
update public.products set images = array[
  'https://images.unsplash.com/photo-1542272604-787c3835535d?auto=format&fit=crop&w=900&q=80'
] where name = 'Baggy Denim';
update public.products set images = array[
  'https://images.unsplash.com/photo-1549298916-b41d501d3772?auto=format&fit=crop&w=900&q=80'
] where name = 'Retro Court Sneakers';
update public.products set images = array[
  'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?auto=format&fit=crop&w=900&q=80'
] where name = 'Chunky Runner';
update public.products set images = array[
  'https://images.unsplash.com/photo-1594223274512-ad4803739b7c?auto=format&fit=crop&w=900&q=80'
] where name = 'Canvas Tote Bag';
update public.products set images = array[
  'https://images.unsplash.com/photo-1611652022419-a9419f74343d?auto=format&fit=crop&w=900&q=80'
] where name = 'Silver Chain Necklace';
update public.products set images = array[
  'https://images.unsplash.com/photo-1521369909029-2afed882baee?auto=format&fit=crop&w=900&q=80'
] where name = 'Washed Bucket Hat';
update public.products set images = array[
  'https://images.unsplash.com/photo-1544923246-77307dd654cb?auto=format&fit=crop&w=900&q=80'
] where name = 'Cloud Puffer Jacket';
update public.products set images = array[
  'https://images.unsplash.com/photo-1503341504253-dff4815485f1?auto=format&fit=crop&w=900&q=80'
] where name = 'Vintage Wash Tee';

update public.categories set image_url = 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=900&q=80' where name = 'Tops';
update public.categories set image_url = 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?auto=format&fit=crop&w=900&q=80' where name = 'Bottoms';
update public.categories set image_url = 'https://images.unsplash.com/photo-1551028719-00167b16eac5?auto=format&fit=crop&w=900&q=80' where name = 'Outerwear';
update public.categories set image_url = 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=900&q=80' where name = 'Sneakers';
update public.categories set image_url = 'https://images.unsplash.com/photo-1594223274512-ad4803739b7c?auto=format&fit=crop&w=900&q=80' where name = 'Accessories';

select
  (select count(*) from public.profiles) as profiles,
  (select count(*) from public.products) as products,
  (select count(*) from public.categories) as categories,
  (select count(*) from storage.buckets where id in ('product-images', 'avatars')) as buckets;
