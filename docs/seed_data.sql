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
insert into public.news (title, content, category_id, location_id, is_featured, is_hidden)
select 
  'افتتاح مشروع تنموي جديد في العاصمة', 
  '<p>شهدت العاصمة دمشق اليوم افتتاح مشروع حيوي يهدف إلى تحسين البنية التحتية وتوفير فرص عمل جديدة للشباب. ويعتبر هذا المشروع خطوة هامة في مسيرة التنمية المستدامة.</p><p>تفاصيل إضافية عن المشروع وأهميته الاقتصادية...</p>',
  (select id from public.categories where slug = 'politics'),
  (select id from public.locations where slug = 'damascus'),
  true,
  false;

-- 4. News (Sample 2)
insert into public.news (title, content, category_id, is_featured, is_hidden)
select 
  'ارتفاع مؤشر البورصة في تداولات اليوم', 
  '<p>سجل سوق الأوراق المالية ارتفاعاً ملحوظاً في نهاية جلسة التداول مدعوماً بقطاع البنوك والاتصالات.</p>',
  (select id from public.categories where slug = 'economy'),
  false,
  false;

-- 5. News (Sample 3)
insert into public.news (title, content, category_id, is_featured, is_hidden)
select 
  'فوز المنتخب الوطني في المباراة الودية', 
  '<p>حقق المنتخب الوطني فوزاً ثميناً على نظيره الضيف بنتيجة 2-1 في المباراة التي جمعت بينهما مساء أمس على أرضية ملعب الفيحاء. سجل الأهداف اللاعب...</p>',
  (select id from public.categories where slug = 'sports'),
  true,
  false;

-- 6. Breaking News (Active)
insert into public.breaking_news (title, content, start_time, end_time, send_notification, is_active)
values 
('عاجل: بدء فعاليات مهرجان التسوق السنوي', 'انطلقت اليوم فعاليات مهرجان التسوق بمشاركة واسعة من الشركات المحلية.', now(), now() + interval '24 hours', true, true);

-- 7. Ticker News
insert into public.ticker_news (text, priority, is_active)
values
('تابعوا آخر الأخبار العاجلة أولاً بأول عبر تطبيق الإخبارية السورية', 100, true),
('تحديثات لحظية للأخبار المحلية والاقتصادية والرياضية', 90, true);

-- 8. Live Stream
insert into public.live_stream (broadcast_title, youtube_url, fallback_message, is_active)
values
('البث المباشر - الإخبارية السورية', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 'البث غير متاح حالياً، يرجى المحاولة لاحقاً.', true);

-- 9. Programs
insert into public.programs (name, description, image_url, order_index, is_active)
values
('نشرة التاسعة', 'برنامج إخباري يومي', null, 1, true),
('عين على الحدث', 'تحليل ومتابعة أهم التطورات', null, 2, true);

-- 10. Videos
insert into public.videos (title, youtube_url, program_id, category_id, order_index, is_hidden)
select
  'حلقة خاصة: قراءة في المشهد الاقتصادي',
  'https://www.youtube.com/watch?v=3JZ_D3ELwOQ',
  (select id from public.programs where name = 'عين على الحدث' limit 1),
  (select id from public.categories where slug = 'economy'),
  1,
  false
where exists (select 1 from public.programs where name = 'عين على الحدث');

-- 11. App Settings
insert into public.app_settings (key, value) values
('featured_slider_autoplay', 'true'),
('featured_slider_interval_seconds', '3'),
('facebook_url', 'https://facebook.com/alikhbariah')
on conflict (key) do update set value = excluded.value;

commit;
