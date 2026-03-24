-- Deferred dashboard/media migrations
-- Run once in Supabase SQL Editor

begin;

-- 1) Categories: bilingual + type + cover image
alter table public.categories
  add column if not exists name_en text,
  add column if not exists type text not null default 'news',
  add column if not exists cover_image_url text;

-- Ensure only supported category types are used
alter table public.categories
  drop constraint if exists categories_type_check;

alter table public.categories
  add constraint categories_type_check
  check (type in ('news', 'video', 'program'));

create index if not exists idx_categories_type_order
  on public.categories(type, order_index);

-- 2) Programs: link program to a category
alter table public.programs
  add column if not exists category_id bigint null references public.categories(id) on delete set null;

create index if not exists idx_programs_category_order
  on public.programs(category_id, order_index);

commit;
