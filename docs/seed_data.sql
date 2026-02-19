-- Seed Data for NewsAppJS
-- Run this in Supabase SQL Editor

begin;

-- 1. Categories
insert into public.categories (name, slug, order_index) values
('سياسة', 'politics', 1),
('اقتصاد', 'economy', 2),
('رياضة', 'sports', 3),
('ثقافة وفن', 'culture-art', 4),
('تقنية', 'tech', 5)
on conflict (slug) do nothing;

-- 2. Locations
insert into public.locations (name, slug) values
('دمشق', 'damascus'),
('حلب', 'aleppo'),
('اللاذقية', 'lattakia')
on conflict (slug) do nothing;

-- 3. News (Sample 1)
insert into public.news (title, summary, content, category_id, location_id, is_featured, is_hidden)
select 
  'افتتاح مشروع تنموي جديد في العاصمة', 
  'شهدت العاصمة دمشق اليوم افتتاح مشروع حيوي يهدف إلى تحسين البنية التحتية...',
  '<p>شهدت العاصمة دمشق اليوم افتتاح مشروع حيوي يهدف إلى تحسين البنية التحتية وتوفير فرص عمل جديدة للشباب. ويعتبر هذا المشروع خطوة هامة في مسيرة التنمية المستدامة.</p><p>تفاصيل إضافية عن المشروع وأهميته الاقتصادية...</p>',
  (select id from public.categories where slug = 'politics'),
  (select id from public.locations where slug = 'damascus'),
  true,
  false;

-- 4. News (Sample 2)
insert into public.news (title, summary, content, category_id, is_featured, is_hidden)
select 
  'ارتفاع مؤشر البورصة في تداولات اليوم', 
  'سجل سوق الأوراق المالية ارتفاعاً ملحوظاً في نهاية جلسة التداول...',
  '<p>سجل سوق الأوراق المالية ارتفاعاً ملحوظاً في نهاية جلسة التداول مدعوماً بقطاع البنوك والاتصالات.</p>',
  (select id from public.categories where slug = 'economy'),
  false,
  false;

-- 5. News (Sample 3)
insert into public.news (title, summary, content, category_id, is_featured, is_hidden)
select 
  'فوز المنتخب الوطني في المباراة الودية', 
  'حقق المنتخب الوطني فوزاً ثميناً على نظيره الضيف بنتيجة 2-1...',
  '<p>حقق المنتخب الوطني فوزاً ثميناً على نظيره الضيف بنتيجة 2-1 في المباراة التي جمعت بينهما مساء أمس على أرضية ملعب الفيحاء. سجل الأهداف اللاعب...</p>',
  (select id from public.categories where slug = 'sports'),
  true,
  false;

-- 6. Breaking News (Active)
insert into public.breaking_news (title, content, start_time, end_time, is_active)
values 
('عاجل: بدء فعاليات مهرجان التسوق السنوي', 'انطلقت اليوم فعاليات مهرجان التسوق بمشاركة واسعة من الشركات المحلية.', now(), now() + interval '24 hours', true);

commit;
