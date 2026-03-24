-- Reset + Seed bilingual content for:
-- - Main news
-- - Breaking news
-- - Videos
-- - Programs
--
-- WARNING:
-- This script deletes old data in related tables.

begin;

-- 1) Clear old content (child tables first)
truncate table public.breaking_news restart identity cascade;
truncate table public.videos restart identity cascade;
truncate table public.news restart identity cascade;
truncate table public.programs restart identity cascade;
truncate table public.categories restart identity cascade;
truncate table public.locations restart identity cascade;

-- 2) Seed locations
insert into public.locations (name, slug)
values
  ('دمشق', 'damascus'),
  ('حلب', 'aleppo'),
  ('حمص', 'homs');

-- 3) Seed categories (news + video) with bilingual names
insert into public.categories (name, name_en, slug, order_index, type)
values
  ('سياسة', 'Politics', 'politics', 1, 'news'),
  ('اقتصاد', 'Economy', 'economy', 2, 'news'),
  ('رياضة', 'Sports', 'sports', 3, 'news'),
  ('برامج حوارية', 'Talk Shows', 'talk-shows', 1, 'video'),
  ('تقارير خاصة', 'Special Reports', 'special-reports', 2, 'video');

-- 4) Seed programs with bilingual name/description
insert into public.programs (name, name_en, description, description_en, image_url, order_index, is_active)
values
  (
    'على الطاولة',
    'On the Table',
    'برنامج حواري يناقش القضايا السياسية والاقتصادية اليومية.',
    'A talk show discussing daily political and economic issues.',
    null,
    1,
    true
  ),
  (
    'لقاء خاص',
    'Special Interview',
    'حوارات مع شخصيات عامة وخبراء في ملفات متنوعة.',
    'Interviews with public figures and experts on diverse topics.',
    null,
    2,
    true
  );

-- 5) Seed main news with bilingual title/content
insert into public.news (
  title,
  title_en,
  content,
  content_en,
  image_url,
  category_id,
  location_id,
  created_at,
  is_hidden,
  is_featured,
  sent_notification
)
values
  (
    'اجتماع حكومي لبحث خطة الطاقة خلال الصيف',
    'Government meeting discusses summer energy plan',
    '<p>ناقشت الحكومة إجراءات دعم استقرار الشبكة الكهربائية وتحسين التوزيع في المحافظات خلال فصل الصيف.</p>',
    '<p>The government discussed measures to stabilize the power grid and improve electricity distribution across provinces during summer.</p>',
    null,
    (select id from public.categories where slug = 'politics' limit 1),
    (select id from public.locations where slug = 'damascus' limit 1),
    now() - interval '2 hours',
    false,
    true,
    true
  ),
  (
    'ارتفاع حركة الأسواق مع بداية الموسم التجاري',
    'Market activity rises at the start of the trade season',
    '<p>سجلت الأسواق المحلية نشاطاً ملحوظاً مدعوماً بزيادة الطلب على السلع الأساسية.</p>',
    '<p>Local markets recorded notable activity, supported by increased demand for essential goods.</p>',
    null,
    (select id from public.categories where slug = 'economy' limit 1),
    (select id from public.locations where slug = 'aleppo' limit 1),
    now() - interval '90 minutes',
    false,
    true,
    true
  ),
  (
    'المنتخب الوطني يواصل تحضيراته للتصفيات',
    'National team continues preparations for qualifiers',
    '<p>أجرى المنتخب الوطني حصة تدريبية مكثفة ضمن معسكره التحضيري استعداداً للمباريات القادمة.</p>',
    '<p>The national team held an intensive training session in its camp in preparation for upcoming matches.</p>',
    null,
    (select id from public.categories where slug = 'sports' limit 1),
    (select id from public.locations where slug = 'homs' limit 1),
    now() - interval '45 minutes',
    false,
    false,
    true
  ),
  (
    'إطلاق مبادرة لدعم المشاريع الصغيرة في المحافظات',
    'Launch of an initiative to support small businesses in provinces',
    '<p>تستهدف المبادرة تمويل المشاريع الإنتاجية الصغيرة وتوفير برامج تدريبية لأصحابها.</p>',
    '<p>The initiative aims to fund small productive businesses and provide training programs for their owners.</p>',
    null,
    (select id from public.categories where slug = 'economy' limit 1),
    (select id from public.locations where slug = 'damascus' limit 1),
    now() - interval '20 minutes',
    false,
    false,
    true
  );

-- 6) Seed breaking news with bilingual fields
insert into public.breaking_news (
  title,
  title_en,
  content,
  content_en,
  created_at,
  start_time,
  end_time,
  send_notification,
  is_active
)
values
  (
    'عاجل: إعادة فتح طريق دولي بعد انتهاء أعمال الصيانة',
    'Breaking: International highway reopened after maintenance',
    'أعلنت الجهات المعنية إعادة فتح الطريق الدولي أمام حركة المرور بشكل كامل.',
    'Authorities announced the full reopening of the international highway to traffic.',
    now() - interval '10 minutes',
    now() - interval '10 minutes',
    now() + interval '6 hours',
    true,
    true
  ),
  (
    'عاجل: بدء تسجيل الطلاب للعام الدراسي الجديد',
    'Breaking: Student registration for the new academic year has started',
    'بدأت مديريات التربية استقبال طلبات التسجيل وفق الجداول الزمنية المعتمدة.',
    'Education directorates started accepting registration applications according to approved timelines.',
    now() - interval '5 minutes',
    now() - interval '5 minutes',
    now() + interval '8 hours',
    true,
    true
  );

-- 7) Seed videos with bilingual titles
insert into public.videos (
  title,
  title_en,
  youtube_url,
  program_id,
  category_id,
  thumbnail_url,
  order_index,
  published_at,
  is_hidden
)
values
  (
    'حلقة: قراءة في المشهد السياسي الإقليمي',
    'Episode: Reading the regional political landscape',
    'https://www.youtube.com/watch?v=40x0fUqhgro',
    (select id from public.programs where name_en = 'On the Table' limit 1),
    (select id from public.categories where slug = 'talk-shows' limit 1),
    null,
    1,
    now() - interval '3 hours',
    false
  ),
  (
    'تقرير: فرص الاستثمار في القطاعات الإنتاجية',
    'Report: Investment opportunities in productive sectors',
    'https://www.youtube.com/watch?v=sdZ9W1qwYrE',
    (select id from public.programs where name_en = 'Special Interview' limit 1),
    (select id from public.categories where slug = 'special-reports' limit 1),
    null,
    2,
    now() - interval '2 hours',
    false
  ),
  (
    'حلقة: تحليل نتائج الجولة الرياضية الأخيرة',
    'Episode: Analysis of the latest sports round results',
    'https://www.youtube.com/watch?v=40x0fUqhgro',
    (select id from public.programs where name_en = 'On the Table' limit 1),
    (select id from public.categories where slug = 'talk-shows' limit 1),
    null,
    3,
    now() - interval '1 hour',
    false
  );

commit;
