-- Fix for legacy live_stream schemas that still use `title`
-- Safe to run multiple times.

alter table public.live_stream
  add column if not exists broadcast_title text null;

do $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'live_stream'
      and column_name = 'title'
  ) then
    update public.live_stream
    set broadcast_title = coalesce(broadcast_title, title)
    where coalesce(broadcast_title, '') = ''
      and coalesce(title, '') <> '';
  end if;
end $$;
