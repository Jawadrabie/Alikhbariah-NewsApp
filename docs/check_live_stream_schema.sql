-- Diagnostic queries for live_stream schema
-- Run in Supabase SQL Editor (safe, read-only).

-- 1) List columns of live_stream
select
  c.ordinal_position,
  c.column_name,
  c.data_type,
  c.is_nullable,
  c.column_default
from information_schema.columns c
where c.table_schema = 'public'
  and c.table_name = 'live_stream'
order by c.ordinal_position;

-- 2) Quick existence checks for legacy/new title columns
select
  exists(
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'live_stream'
      and column_name = 'broadcast_title'
  ) as has_broadcast_title,
  exists(
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'live_stream'
      and column_name = 'title'
  ) as has_legacy_title;

-- 3) Preview current rows (adjust limit as needed)
select *
from public.live_stream
order by id desc
limit 20;
