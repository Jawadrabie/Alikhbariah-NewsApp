-- Add category linkage for programs (for dashboard program creation flow)
-- Run in Supabase SQL Editor

begin;

alter table public.programs
  add column if not exists category_id bigint null references public.categories(id) on delete set null;

create index if not exists idx_programs_category_order
  on public.programs(category_id, order_index);

commit;
