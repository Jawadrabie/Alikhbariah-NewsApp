-- Deletes all data from all tables in public schema while keeping table structures.
-- Use with caution.

begin;

do $$
declare
  stmt text;
begin
  select 'truncate table ' || string_agg(format('%I.%I', schemaname, tablename), ', ')
         || ' restart identity cascade;'
    into stmt
  from pg_tables
  where schemaname = 'public';

  if stmt is not null then
    execute stmt;
  end if;
end $$;

commit;
