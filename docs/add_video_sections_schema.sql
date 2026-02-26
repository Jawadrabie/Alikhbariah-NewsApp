-- Migration: support dedicated video sections + programs separation
-- Run in Supabase SQL editor

begin;

-- 1) Categorize categories by purpose: news vs video
alter table public.categories
  add column if not exists type text not null default 'news';

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'categories_type_check'
      and conrelid = 'public.categories'::regclass
  ) then
    alter table public.categories
      add constraint categories_type_check
      check (type in ('news', 'video'));
  end if;
end $$;

create index if not exists idx_categories_type_order
  on public.categories(type, order_index);

-- 2) Helpful indexes for filtering videos by category/program
create index if not exists idx_videos_category_id on public.videos(category_id);
create index if not exists idx_videos_program_id on public.videos(program_id);
create index if not exists idx_videos_published_created
  on public.videos(published_at desc, created_at desc);

-- 3) Seed suggested video categories (safe upsert by slug)
insert into public.categories (name, slug, order_index, type)
values
  ('نشرات الأخبار', 'video-bulletins', 1, 'video'),
  ('تقارير إخبارية', 'video-reports', 2, 'video'),
  ('مؤتمر صحفي', 'video-press-conference', 3, 'video'),
  ('متداول', 'video-trending', 4, 'video'),
  ('تغطيات', 'video-coverages', 5, 'video')
on conflict (slug) do update
set
  name = excluded.name,
  order_index = excluded.order_index,
  type = excluded.type;

-- 4) Seed suggested programs (safe upsert by name)
insert into public.programs (name, description, order_index, is_active)
values
  ('على الطاولة', null, 1, true),
  ('لقاء خاص', null, 2, true),
  ('ستوريا', null, 3, true),
  ('بتوقيت سوريا', null, 4, true),
  ('إشراقة سورية', null, 5, true)
on conflict do nothing;

commit;
