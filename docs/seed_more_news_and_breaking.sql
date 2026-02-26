-- Extra seed data for NewsAppJS
-- Adds 10 news items (diverse categories) + 5 breaking news items
-- Run after docs/supabase_init.sql and after categories exist (see docs/seed_data.sql)

begin;

-- 10 News items (diverse categories)
insert into public.news (title, content, image_url, category_id, location_id, is_featured, is_hidden, sent_notification)
select
  'تطوير شبكة النقل في العاصمة',
  '<p>أعلنت الجهات المعنية بدء مشروع لتطوير النقل العام عبر إضافة خطوط جديدة وزيادة عدد الحافلات بهدف تخفيف الازدحام وتحسين الخدمة.</p>',
  null,
  (select id from public.categories where slug = 'politics'),
  (select id from public.locations where slug = 'damascus'),
  true,
  false,
  true
where exists (select 1 from public.categories where slug = 'politics');

insert into public.news (title, content, image_url, category_id, location_id, is_featured, is_hidden, sent_notification)
select
  'تراجع طفيف في أسعار بعض السلع الأساسية',
  '<p>سجلت أسعار بعض السلع الأساسية انخفاضًا محدودًا خلال اليومين الماضيين مع استقرار نسبي في أسعار المواد الغذائية.</p>',
  null,
  (select id from public.categories where slug = 'economy'),
  null,
  false,
  false,
  true
where exists (select 1 from public.categories where slug = 'economy');

insert into public.news (title, content, image_url, category_id, location_id, is_featured, is_hidden, sent_notification)
select
  'فوز مستحق لفريق المدينة في الدوري',
  '<p>حقق فريق المدينة فوزًا مهمًا في الجولة الحالية من الدوري بعد أداء قوي في الشوط الثاني.</p>',
  null,
  (select id from public.categories where slug = 'sports'),
  null,
  true,
  false,
  true
where exists (select 1 from public.categories where slug = 'sports');

insert into public.news (title, content, image_url, category_id, location_id, is_featured, is_hidden, sent_notification)
select
  'افتتاح معرض الكتاب السنوي',
  '<p>افتتحت فعاليات معرض الكتاب السنوي بمشاركة دور نشر محلية وعربية، مع برنامج ثقافي متنوع.</p>',
  null,
  (select id from public.categories where slug = 'culture-art'),
  null,
  false,
  false,
  true
where exists (select 1 from public.categories where slug = 'culture-art');

insert into public.news (title, content, image_url, category_id, location_id, is_featured, is_hidden, sent_notification)
select
  'إطلاق مبادرة للتحول الرقمي',
  '<p>أطلقت الجهات المعنية مبادرة للتحول الرقمي تشمل تطوير منصات للخدمات الإلكترونية وتدريب الكوادر.</p>',
  null,
  (select id from public.categories where slug = 'tech'),
  null,
  false,
  false,
  true
where exists (select 1 from public.categories where slug = 'tech');

insert into public.news (title, content, image_url, category_id, location_id, is_featured, is_hidden, sent_notification)
select
  'لقاء تشاوري حول خطة تنموية جديدة',
  '<p>عُقد لقاء تشاوري لمناقشة خطة تنموية جديدة تركز على تحسين الخدمات العامة والبنية التحتية.</p>',
  null,
  (select id from public.categories where slug = 'politics'),
  null,
  false,
  false,
  true
where exists (select 1 from public.categories where slug = 'politics');

insert into public.news (title, content, image_url, category_id, location_id, is_featured, is_hidden, sent_notification)
select
  'ارتفاع تدريجي في حجم الصادرات',
  '<p>أظهرت تقارير اقتصادية تحسنًا طفيفًا في حجم الصادرات خلال الشهر الجاري مع توقعات بمزيد من التحسن.</p>',
  null,
  (select id from public.categories where slug = 'economy'),
  null,
  false,
  false,
  true
where exists (select 1 from public.categories where slug = 'economy');

insert into public.news (title, content, image_url, category_id, location_id, is_featured, is_hidden, sent_notification)
select
  'انطلاق بطولة مدرسية لكرة السلة',
  '<p>انطلقت البطولة المدرسية لكرة السلة بمشاركة فرق من عدة محافظات، وتشهد منافسة قوية بين المدارس.</p>',
  null,
  (select id from public.categories where slug = 'sports'),
  null,
  false,
  false,
  true
where exists (select 1 from public.categories where slug = 'sports');

insert into public.news (title, content, image_url, category_id, location_id, is_featured, is_hidden, sent_notification)
select
  'عرض مسرحي جديد للجمهور',
  '<p>يقدم المسرح المحلي عرضًا جديدًا يستعرض قصة اجتماعية معاصرة برؤية فنية مميزة.</p>',
  null,
  (select id from public.categories where slug = 'culture-art'),
  null,
  false,
  false,
  true
where exists (select 1 from public.categories where slug = 'culture-art');

insert into public.news (title, content, image_url, category_id, location_id, is_featured, is_hidden, sent_notification)
select
  'تحديثات على منصة الخدمات الإلكترونية',
  '<p>أعلنت الجهة التقنية عن تحديثات جديدة على منصة الخدمات الإلكترونية بهدف تحسين تجربة المستخدم.</p>',
  null,
  (select id from public.categories where slug = 'tech'),
  null,
  false,
  false,
  true
where exists (select 1 from public.categories where slug = 'tech');

-- 5 Breaking news items
insert into public.breaking_news (title, content, start_time, end_time, is_active, send_notification)
values
('عاجل: فتح طريق رئيسي بعد أعمال صيانة', 'أُعيد فتح الطريق الرئيسي بعد انتهاء أعمال الصيانة.', now(), now() + interval '12 hours', true, true),
('عاجل: حالة جوية غير مستقرة مساء اليوم', 'توقعات بتساقط أمطار خفيفة في عدة مناطق.', now(), now() + interval '8 hours', true, true),
('عاجل: استئناف الدوام في عدد من المؤسسات', 'عودة العمل في المؤسسات بعد انتهاء العطلة الرسمية.', now(), now() + interval '24 hours', true, false),
('عاجل: إعلان نتائج مسابقة وطنية', 'تم إعلان نتائج المسابقة الوطنية صباح اليوم.', now(), now() + interval '6 hours', true, true),
('عاجل: انطلاق فعاليات رياضية محلية', 'بدء فعاليات رياضية بمشاركة فرق متعددة.', now(), now() + interval '10 hours', true, false);

commit;
