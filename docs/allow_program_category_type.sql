-- Migration: allow `program` as a valid category type
-- Run in Supabase SQL Editor

begin;

do $$
begin
  if exists (
    select 1
    from pg_constraint
    where conname = 'categories_type_check'
      and conrelid = 'public.categories'::regclass
  ) then
    alter table public.categories
      drop constraint categories_type_check;
  end if;

  alter table public.categories
    add constraint categories_type_check
    check (type in ('news', 'video', 'program'));
end $$;

commit;
