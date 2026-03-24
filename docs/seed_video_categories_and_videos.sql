-- Seed: video categories + programs + videos (idempotent)
-- Purpose: ensure home video section can show category cards and open category-specific videos
-- Safe to run multiple times

begin;

-- 1) Ensure video categories exist and are typed correctly
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

-- 2) Ensure default programs exist
insert into public.programs (name, description, order_index, is_active)
values
  ('على الطاولة', null, 1, true),
  ('لقاء خاص', null, 2, true),
  ('ستوريا', null, 3, true),
  ('بتوقيت سوريا', null, 4, true),
  ('إشراقة سورية', null, 5, true)
on conflict do nothing;

-- 3) Optional data hygiene: if a video is linked to a non-video category, detach it
update public.videos v
set category_id = null
from public.categories c
where v.category_id = c.id
  and coalesce(c.type, 'news') <> 'video';

-- 4) Seed sample videos mapped to video categories/programs (insert only if missing)
insert into public.videos (
  title,
  youtube_url,
  category_id,
  program_id,
  thumbnail_url,
  order_index,
  published_at,
  is_hidden
)
select
  s.title,
  s.youtube_url,
  c.id,
  p.id,
  null,
  s.order_index,
  s.published_at,
  false
from (
  values
    ('نشرة الأخبار الرئيسية - المسائية', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 'video-bulletins', 'بتوقيت سوريا', 1, now() - interval '1 day'),
    ('أبرز تقارير الاقتصاد اليوم', 'https://www.youtube.com/watch?v=3JZ_D3ELwOQ', 'video-reports', 'على الطاولة', 2, now() - interval '2 day'),
    ('مؤتمر صحفي حول المستجدات', 'https://www.youtube.com/watch?v=l482T0yNkeo', 'video-press-conference', 'لقاء خاص', 3, now() - interval '3 day'),
    ('المحتوى المتداول هذا الأسبوع', 'https://www.youtube.com/watch?v=Zi_XLOBDo_Y', 'video-trending', null, 4, now() - interval '4 day'),
    ('تغطية خاصة من الميدان', 'https://www.youtube.com/watch?v=fLexgOxsZu0', 'video-coverages', 'إشراقة سورية', 5, now() - interval '5 day')
) as s(title, youtube_url, category_slug, program_name, order_index, published_at)
join public.categories c
  on c.slug = s.category_slug and c.type = 'video'
left join public.programs p
  on p.name = s.program_name
where not exists (
  select 1
  from public.videos v
  where v.youtube_url = s.youtube_url
    and v.title = s.title
);

commit;
