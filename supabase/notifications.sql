














create table if not exists public.notifications (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.profiles (id) on delete cascade,
  title      text not null,
  body       text not null default '',
  link       text,
  kind       text not null default 'info' check (kind in ('info', 'order', 'admin', 'promo')),
  read_at    timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists notifications_user_idx on public.notifications (user_id, created_at desc);

alter table public.notifications enable row level security;



drop policy if exists "notifications: read own" on public.notifications;
create policy "notifications: read own" on public.notifications
  for select using (user_id = auth.uid());

drop policy if exists "notifications: update own" on public.notifications;
create policy "notifications: update own" on public.notifications
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "notifications: delete own" on public.notifications;
create policy "notifications: delete own" on public.notifications
  for delete using (user_id = auth.uid());





create or replace function public.order_ref(p_id uuid)
returns text
language sql
immutable
as $$
  select '#' || upper(left(replace(p_id::text, '-', ''), 8));
$$;

create or replace function public.notify_admins(p_title text, p_body text, p_link text)
returns void
language sql
security definer
set search_path = public
as $$
  insert into public.notifications (user_id, title, body, link, kind)
  select id, p_title, p_body, p_link, 'admin'
  from public.profiles
  where role = 'admin';
$$;

revoke execute on function public.notify_admins(text, text, text) from public, anon, authenticated;







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
        'We got your order ' || public.order_ref(new.id) || ' (' || '$' || to_char(new.total, 'FM999,999,990.00') || '). We''ll let you know when it moves.',
        '/account/orders/' || new.id,
        'order'
      );
    end if;

    perform public.notify_admins(
      'New order ' || public.order_ref(new.id),
      new.full_name || ' just spent ' || '$' || to_char(new.total, 'FM999,999,990.00') || '.',
      '/admin/orders'
    );
  end if;
  return new;
end;
$$;

drop trigger if exists orders_notify_placed on public.orders;
create trigger orders_notify_placed
  after update of total on public.orders
  for each row execute function public.notify_order_placed();

create or replace function public.notify_order_status()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_title text;
  v_body  text;
begin
  if new.status is not distinct from old.status or new.user_id is null then
    return new;
  end if;

  case new.status
    when 'processing' then
      v_title := 'We''re packing your order 📦';
      v_body  := 'Order ' || public.order_ref(new.id) || ' is being prepared.';
    when 'shipped' then
      v_title := 'Your order is on the way 🚚';
      v_body  := 'Order ' || public.order_ref(new.id) || ' has shipped. Keep an eye on your door.';
    when 'delivered' then
      v_title := 'Delivered ✦';
      v_body  := 'Order ' || public.order_ref(new.id) || ' has arrived. Enjoy — and leave a review!';
    when 'cancelled' then
      v_title := 'Order cancelled';
      v_body  := 'Order ' || public.order_ref(new.id) || ' was cancelled.';
    else
      v_title := 'Order update';
      v_body  := 'Order ' || public.order_ref(new.id) || ' is now ' || new.status || '.';
  end case;

  insert into public.notifications (user_id, title, body, link, kind)
  values (new.user_id, v_title, v_body, '/account/orders/' || new.id, 'order');

  if new.status = 'cancelled' then
    perform public.notify_admins(
      'Order ' || public.order_ref(new.id) || ' cancelled',
      new.full_name || '''s order was cancelled. Stock has been returned.',
      '/admin/orders'
    );
  end if;

  return new;
end;
$$;

drop trigger if exists orders_notify_status on public.orders;
create trigger orders_notify_status
  after update of status on public.orders
  for each row execute function public.notify_order_status();





create or replace function public.notify_low_stock()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.stock <= 5 and old.stock > 5 and new.is_active then
    perform public.notify_admins(
      'Low stock: ' || new.name,
      case when new.stock = 0 then 'Sold out — time to restock.'
           else 'Only ' || new.stock || ' left.' end,
      '/admin/products/' || new.id || '/edit'
    );
  end if;
  return new;
end;
$$;

drop trigger if exists products_notify_low_stock on public.products;
create trigger products_notify_low_stock
  after update of stock on public.products
  for each row execute function public.notify_low_stock();






create or replace function public.broadcast_notification(p_title text, p_body text, p_link text default null)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count integer;
begin
  if not public.is_admin() then
    raise exception 'Only admins can send notifications';
  end if;
  if coalesce(trim(p_title), '') = '' then
    raise exception 'Please add a title';
  end if;

  insert into public.notifications (user_id, title, body, link, kind)
  select id, trim(p_title), coalesce(trim(p_body), ''), nullif(trim(coalesce(p_link, '')), ''), 'promo'
  from public.profiles
  where role = 'customer';

  get diagnostics v_count = row_count;
  return v_count;
end;
$$;

revoke execute on function public.broadcast_notification(text, text, text) from public, anon;
grant execute on function public.broadcast_notification(text, text, text) to authenticated;





do $$
begin
  alter publication supabase_realtime add table public.notifications;
exception
  when duplicate_object then null;
  when undefined_object then null;
end;
$$;
