-- WARNING: This script permanently deletes ALL rows from ALL tables in schema public.
-- It also resets identity sequences.
-- Run in Supabase SQL Editor only when you are sure.

begin;

do $$
declare
  r record;
begin
  -- Truncate every base table in public schema
  for r in
    select tablename
    from pg_tables
    where schemaname = 'public'
  loop
    execute format('truncate table public.%I restart identity cascade', r.tablename);
  end loop;
end $$;

-- Optional: clear Storage objects too (uncomment if needed)
-- do $$
-- begin
--   if to_regclass('storage.objects') is not null then
--     delete from storage.objects;
--   end if;
-- end $$;

commit;
