-- Reset + Seed script for NewsAppJS
-- Includes:
-- 1) Remove old data (news-related)
-- 2) Seed all Syrian governorates
-- 3) Seed 6 news categories
-- 4) Seed 30 news items (5 per category)
-- 5) Seed 6 video playlists + 10 videos each
-- 6) Seed 6 programs + 10 episodes each
-- 7) Seed breaking news schedule: 3 items/day for 7 days from today

begin;

-- =============================
-- Schema compatibility (safe)
-- =============================
alter table if exists public.locations
  add column if not exists name_en text;

alter table if exists public.categories
  add column if not exists name_en text,
  add column if not exists type text not null default 'news';

alter table if exists public.news
  add column if not exists title_en text,
  add column if not exists summary text,
  add column if not exists summary_en text,
  add column if not exists content_en text,
  add column if not exists image_url text,
  add column if not exists category_id bigint,
  add column if not exists location_id bigint,
  add column if not exists is_hidden boolean not null default false,
  add column if not exists is_featured boolean not null default false,
  add column if not exists sent_notification boolean not null default true,
  add column if not exists view_count integer not null default 0;

do $$
begin
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'news'
      and column_name = 'created_at'
  ) then
    alter table public.news
      add column created_at timestamptz not null default now();
  end if;
end $$;

alter table if exists public.breaking_news
  add column if not exists title text,
  add column if not exists content text,
  add column if not exists start_time timestamptz,
  add column if not exists end_time timestamptz,
  add column if not exists view_count integer not null default 0,
  add column if not exists send_notification boolean not null default true,
  add column if not exists is_active boolean not null default true;

do $$
begin
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'breaking_news'
      and column_name = 'created_at'
  ) then
    alter table public.breaking_news
      add column created_at timestamptz not null default now();
  end if;
end $$;

alter table if exists public.videos
  add column if not exists title text,
  add column if not exists youtube_url text,
  add column if not exists category_id bigint,
  add column if not exists thumbnail_url text,
  add column if not exists order_index integer not null default 0,
  add column if not exists published_at timestamptz,
  add column if not exists is_hidden boolean not null default false;

do $$
begin
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'videos'
      and column_name = 'created_at'
  ) then
    alter table public.videos
      add column created_at timestamptz not null default now();
  end if;
end $$;

-- =============================
-- A) Clean old data
-- =============================
truncate table public.ticker_news restart identity cascade;
truncate table public.breaking_news restart identity cascade;
truncate table public.news restart identity cascade;
truncate table public.locations restart identity cascade;
truncate table public.videos restart identity cascade;

do $$
begin
  if to_regclass('public.programs') is not null then
    execute 'truncate table public.programs restart identity cascade';
  end if;
end $$;

delete from public.categories
where coalesce(type, 'news') in ('news', 'video', 'program');

-- =============================
-- B) Seed Syrian governorates
-- =============================
insert into public.locations (name, name_en, slug)
values
  ('دمشق', 'Damascus', 'damascus'),
  ('ريف دمشق', 'Rif Dimashq', 'rif-dimashq'),
  ('حلب', 'Aleppo', 'aleppo'),
  ('حمص', 'Homs', 'homs'),
  ('حماة', 'Hama', 'hama'),
  ('اللاذقية', 'Latakia', 'latakia'),
  ('طرطوس', 'Tartus', 'tartus'),
  ('إدلب', 'Idlib', 'idlib'),
  ('الرقة', 'Raqqa', 'raqqa'),
  ('دير الزور', 'Deir ez-Zor', 'deir-ez-zor'),
  ('الحسكة', 'Al-Hasakah', 'al-hasakah'),
  ('درعا', 'Daraa', 'daraa'),
  ('السويداء', 'As-Suwayda', 'as-suwayda'),
  ('القنيطرة', 'Quneitra', 'quneitra')
on conflict (slug) do update
set
  name = excluded.name,
  name_en = excluded.name_en;

-- =============================
-- C) Seed 6 categories
-- =============================
insert into public.categories (name, name_en, slug, order_index, type)
values
  ('سياسة', 'Politics', 'news-politics', 1, 'news'),
  ('اقتصاد', 'Economy', 'news-economy', 2, 'news'),
  ('محليات', 'Local', 'news-local', 3, 'news'),
  ('دولي', 'International', 'news-international', 4, 'news'),
  ('رياضة', 'Sports', 'news-sports', 5, 'news'),
  ('ثقافة', 'Culture', 'news-culture', 6, 'news')
on conflict (slug) do update
set
  name = excluded.name,
  name_en = excluded.name_en,
  order_index = excluded.order_index,
  type = excluded.type;

-- =============================
-- D) Seed 30 news (5 per category)
-- =============================
insert into public.news (
  title,
  title_en,
  summary,
  summary_en,
  content,
  content_en,
  image_url,
  category_id,
  location_id,
  created_at,
  is_hidden,
  is_featured,
  sent_notification,
  view_count
)
values
-- Politics (5)
(
  'اجتماع حكومي يبحث أولويات الخدمات الأساسية للربع القادم',
  'Government meeting reviews key service priorities for next quarter',
  'جلسة موسعة لمتابعة ملفات الكهرباء والمياه والنقل ضمن خطة تنفيذ مرحلية.',
  'An expanded session reviewed electricity, water, and transport priorities with phased execution.',
  'عقدت الجهات المعنية اجتماعاً تنسيقياً لمراجعة أولويات الخدمات الأساسية خلال الربع القادم، مع التركيز على تحسين استقرار التغذية الكهربائية ورفع كفاءة شبكات المياه وتخفيف الاختناقات المرورية داخل المدن الكبرى. وتم الاتفاق على آلية متابعة أسبوعية ومؤشرات أداء واضحة لقياس التقدم في كل ملف.',
  'Authorities held a coordination session to review essential service priorities for the next quarter, focusing on electricity stability, water-network efficiency, and traffic relief in major cities. A weekly follow-up mechanism and clear KPIs were adopted.',
  'https://images.unsplash.com/photo-1517048676732-d65bc937f952',
  (select id from public.categories where slug = 'news-politics' limit 1),
  (select id from public.locations where slug = 'damascus' limit 1),
  now() - interval '1 hour',
  false,
  true,
  false,
  124
),
(
  'لجنة مشتركة تراجع خطة التحول الرقمي في المؤسسات العامة',
  'Joint committee reviews digital transformation plan in public institutions',
  'مناقشة مراحل الأتمتة وتوحيد قواعد البيانات والخدمات الإلكترونية.',
  'Discussion focused on automation stages, data integration, and digital services.',
  'ناقشت لجنة فنية مشتركة خارطة طريق التحول الرقمي في المؤسسات العامة، بما يشمل توحيد قواعد البيانات وإطلاق خدمات إلكترونية ذات أولوية للمواطنين. وأكدت اللجنة أن المرحلة الأولى تستهدف تقليل زمن إنجاز المعاملات ورفع مستوى الشفافية الإجرائية.',
  'A joint technical committee reviewed the public-sector digital transformation roadmap, including database unification and priority e-services. Phase one focuses on reducing processing times and improving procedural transparency.',
  'https://images.unsplash.com/photo-1551836022-d5d88e9218df',
  (select id from public.categories where slug = 'news-politics' limit 1),
  (select id from public.locations where slug = 'rif-dimashq' limit 1),
  now() - interval '3 hours',
  false,
  true,
  false,
  98
),
(
  'مشاورات لتحديث آليات الاستجابة للطوارئ في المحافظات',
  'Consultations to update emergency response mechanisms across governorates',
  'جلسات عمل لتعزيز التنسيق بين غرف العمليات المحلية والجهات المركزية.',
  'Work sessions aim to strengthen local-central operations-room coordination.',
  'شهدت العاصمة سلسلة مشاورات بين فرق الاستجابة السريعة والجهات الخدمية لرفع جاهزية غرف العمليات في المحافظات. وتضمنت النقاشات تطوير قنوات الإبلاغ المبكر وتوزيع الموارد وفق أولويات ميدانية متغيرة.',
  'The capital hosted consultations between rapid-response teams and service authorities to improve governorate operations-room readiness. Discussions covered early-alert channels and dynamic resource allocation.',
  'https://images.unsplash.com/photo-1469474968028-56623f02e42e',
  (select id from public.categories where slug = 'news-politics' limit 1),
  (select id from public.locations where slug = 'hama' limit 1),
  now() - interval '6 hours',
  false,
  false,
  false,
  73
),
(
  'تأكيد استمرار برامج الدعم الموجه للأسر الأكثر احتياجاً',
  'Authorities confirm continuation of targeted support programs for vulnerable families',
  'متابعة دورية لآليات الاستهداف وتحديث القوائم وفق معايير معلنة.',
  'Periodic review of targeting mechanisms and list updates under public criteria.',
  'أكدت الجهات المعنية استمرار برامج الدعم الموجه للأسر الأكثر احتياجاً، مع تحديث قواعد الاستهداف استناداً إلى بيانات ميدانية حديثة. وتمت الإشارة إلى أهمية التنسيق مع الوحدات الإدارية لضمان وصول الدعم في الوقت المناسب.',
  'Authorities confirmed ongoing targeted support programs for vulnerable families, with updated eligibility rules based on fresh field data. Coordination with local administrations was emphasized to ensure timely delivery.',
  'https://images.unsplash.com/photo-1450101499163-c8848c66ca85',
  (select id from public.categories where slug = 'news-politics' limit 1),
  (select id from public.locations where slug = 'daraa' limit 1),
  now() - interval '9 hours',
  false,
  false,
  false,
  65
),
(
  'ورشة وطنية حول تطوير الأداء المؤسسي وقياس النتائج',
  'National workshop on institutional performance and results measurement',
  'مناقشة أدوات متابعة الأداء وربطها بأهداف زمنية قابلة للقياس.',
  'Discussion on performance tracking tools linked to measurable timelines.',
  'نُظمت ورشة عمل وطنية تناولت تطوير الأداء المؤسسي عبر مؤشرات قياس واضحة، مع التأكيد على تدريب الكوادر وتبسيط الإجراءات الداخلية. وخلصت الورشة إلى توصيات عملية لرفع الكفاءة التشغيلية في القطاعات الخدمية.',
  'A national workshop addressed institutional performance through clear metrics, highlighting staff training and internal process simplification. Practical recommendations were issued to improve service-sector efficiency.',
  'https://images.unsplash.com/photo-1494172961521-33799ddd43a5',
  (select id from public.categories where slug = 'news-politics' limit 1),
  (select id from public.locations where slug = 'latakia' limit 1),
  now() - interval '12 hours',
  false,
  false,
  false,
  51
),

-- Economy (5)
(
  'حزمة إجراءات لدعم الإنتاج المحلي في الصناعات الغذائية',
  'Package of measures to support local production in food industries',
  'خطوات لتسهيل التوريد وخفض كلف التشغيل في عدد من المنشآت.',
  'Steps to ease supply chains and reduce operating costs in key facilities.',
  'أعلنت الجهات الاقتصادية عن حزمة إجراءات لدعم الإنتاج المحلي في الصناعات الغذائية، تشمل تسهيلات لوجستية وتبسيط إجراءات التوريد. وتهدف الخطة إلى تعزيز الاستقرار السعري ورفع نسب توافر السلع الأساسية في الأسواق.',
  'Economic authorities announced a package to support local food manufacturing, including logistics facilitation and streamlined supply procedures. The plan aims to stabilize prices and improve availability of essential goods.',
  'https://images.unsplash.com/photo-1556740749-887f6717d7e4',
  (select id from public.categories where slug = 'news-economy' limit 1),
  (select id from public.locations where slug = 'aleppo' limit 1),
  now() - interval '2 hours',
  false,
  true,
  false,
  167
),
(
  'توسع تدريجي في أسواق الهال مع تحسين منظومة النقل المبرد',
  'Gradual expansion of wholesale markets with improved cold-chain transport',
  'استثمارات تشغيلية جديدة لضبط الفاقد وتحسين جودة التوزيع.',
  'New operational investments to reduce waste and improve distribution quality.',
  'بدأت الجهات المختصة تنفيذ خطة توسع تدريجية في أسواق الهال، بالتوازي مع إدخال تحسينات على منظومة النقل المبرد. وتستهدف الخطة الحد من الفاقد في السلع الطازجة ورفع كفاءة التوزيع بين المحافظات.',
  'Authorities launched a gradual expansion plan for wholesale markets alongside upgrades to refrigerated transport. The objective is to reduce fresh-goods waste and enhance inter-governorate distribution efficiency.',
  'https://images.unsplash.com/photo-1542838132-92c53300491e',
  (select id from public.categories where slug = 'news-economy' limit 1),
  (select id from public.locations where slug = 'homs' limit 1),
  now() - interval '5 hours',
  false,
  false,
  false,
  121
),
(
  'رفع جاهزية المناطق الصناعية لاستقبال استثمارات صغيرة ومتوسطة',
  'Industrial zones prepared to host small and medium investments',
  'توسيع خدمات البنية التحتية وتبسيط نوافذ الترخيص.',
  'Infrastructure services expanded and licensing windows simplified.',
  'تعمل الإدارات المحلية على رفع جاهزية المناطق الصناعية عبر تحسين خدمات الكهرباء والمياه والاتصالات، مع تبسيط إجراءات الترخيص للمشروعات الصغيرة والمتوسطة. وتركز الخطة على توفير بيئة تشغيل مستقرة ومحفزة للإنتاج.',
  'Local administrations are enhancing industrial-zone readiness by improving electricity, water, and connectivity services while simplifying licensing for SMEs. The plan targets a stable, investment-friendly operating environment.',
  'https://images.unsplash.com/photo-1581090700227-1e8e8f7aef35',
  (select id from public.categories where slug = 'news-economy' limit 1),
  (select id from public.locations where slug = 'hama' limit 1),
  now() - interval '8 hours',
  false,
  false,
  false,
  87
),
(
  'برنامج تمويلي لدعم المشاريع الريفية المنتجة',
  'Financing program to support productive rural projects',
  'تمويلات صغيرة ميسرة موجهة للأنشطة الزراعية والصناعات المنزلية.',
  'Accessible micro-financing for agricultural and home-based production.',
  'أطلقت الجهات المعنية برنامجاً تمويلياً لدعم المشاريع الريفية المنتجة، مع أولوية للأنشطة الزراعية والصناعات المنزلية ذات الأثر المحلي. ويتضمن البرنامج خدمات إرشاد فني ومتابعة تنفيذية لتحسين استدامة المشروعات.',
  'Authorities launched a financing program for productive rural projects, prioritizing agriculture and home-based industries with local impact. The initiative includes technical guidance and implementation follow-up.',
  'https://images.unsplash.com/photo-1498050108023-c5249f4df085',
  (select id from public.categories where slug = 'news-economy' limit 1),
  (select id from public.locations where slug = 'tartus' limit 1),
  now() - interval '11 hours',
  false,
  false,
  false,
  69
),
(
  'خطة لتطوير أسواق العمل وربط التدريب باحتياجات القطاعات',
  'Plan to modernize labor markets and align training with sector needs',
  'توسيع برامج التأهيل المهني بالتعاون مع الجهات الإنتاجية.',
  'Expanded vocational programs in partnership with productive sectors.',
  'ناقشت الجهات الاقتصادية والاجتماعية خطة لتطوير أسواق العمل عبر ربط برامج التدريب المهني باحتياجات القطاعات الإنتاجية. وتهدف المبادرة إلى تحسين فرص التوظيف ورفع جاهزية القوى العاملة.',
  'Economic and social authorities discussed a labor-market modernization plan by aligning vocational training with productive-sector needs. The initiative aims to improve employability and workforce readiness.',
  'https://images.unsplash.com/photo-1520607162513-77705c0f0d4a',
  (select id from public.categories where slug = 'news-economy' limit 1),
  (select id from public.locations where slug = 'as-suwayda' limit 1),
  now() - interval '14 hours',
  false,
  false,
  false,
  44
),

-- Local (5)
(
  'خطة خدمية لتحسين واقع الطرق الداخلية في المدن المتوسطة',
  'Service plan to improve internal roads in mid-sized cities',
  'أعمال صيانة وإعادة تأهيل على محاور مكتظة خلال الأسابيع المقبلة.',
  'Maintenance and rehabilitation works on congested corridors in coming weeks.',
  'باشرت البلديات تنفيذ خطة خدمية لتحسين واقع الطرق الداخلية، مع إعطاء أولوية للمحاور ذات الكثافة المرورية العالية. وتشمل الأعمال إعادة تعبيد مقاطع متضررة وتحسين تصريف المياه المطرية.',
  'Municipalities launched a service plan to improve internal roads, prioritizing high-traffic corridors. Works include resurfacing damaged sections and improving rainwater drainage.',
  'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df',
  (select id from public.categories where slug = 'news-local' limit 1),
  (select id from public.locations where slug = 'damascus' limit 1),
  now() - interval '4 hours',
  false,
  true,
  false,
  133
),
(
  'ورشات ميدانية لرفع كفاءة شبكات الصرف الصحي',
  'Field workshops to improve sewer network efficiency',
  'تدخلات عاجلة في النقاط الأكثر تضرراً داخل الأحياء السكنية.',
  'Urgent interventions at the most affected points in residential areas.',
  'نفذت الجهات الخدمية ورشات ميدانية مركزة لرفع كفاءة شبكات الصرف الصحي في عدد من الأحياء السكنية. وتمت معالجة اختناقات متكررة ووضع خطة متابعة دورية لتقليل الأعطال الموسمية.',
  'Service authorities conducted focused field workshops to improve sewer-network efficiency in several neighborhoods. Recurrent bottlenecks were addressed and a periodic follow-up plan was set.',
  'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1f',
  (select id from public.categories where slug = 'news-local' limit 1),
  (select id from public.locations where slug = 'homs' limit 1),
  now() - interval '7 hours',
  false,
  false,
  false,
  90
),
(
  'افتتاح مركز خدمي موحد لتسريع إنجاز المعاملات',
  'Opening of a unified service center to speed up procedures',
  'المركز يضم نوافذ متعددة ضمن منصة خدمة موحدة للمراجعين.',
  'The center provides multiple counters under one integrated service platform.',
  'افتتحت المحافظة مركزاً خدمياً موحداً يضم عدداً من النوافذ الإدارية ضمن منصة متكاملة، بهدف تقليل زمن إنجاز المعاملات وتخفيف الازدحام في الدوائر الخدمية التقليدية.',
  'A governorate opened a unified service center with multiple administrative counters under an integrated platform to reduce processing times and ease congestion in traditional offices.',
  'https://images.unsplash.com/photo-1497366754035-f200968a6e72',
  (select id from public.categories where slug = 'news-local' limit 1),
  (select id from public.locations where slug = 'aleppo' limit 1),
  now() - interval '10 hours',
  false,
  false,
  false,
  78
),
(
  'برنامج صيانة موسمي لشبكات الإنارة في الأحياء',
  'Seasonal maintenance program for neighborhood lighting networks',
  'استبدال تجهيزات قديمة وتحسين كفاءة الاستهلاك الطاقي.',
  'Replacement of old fixtures and improved energy efficiency.',
  'بدأت الفرق الفنية تنفيذ برنامج صيانة موسمي لشبكات الإنارة في الأحياء، متضمناً استبدال تجهيزات متقادمة ورفع كفاءة الاستهلاك. وتسعى الخطة إلى تحسين السلامة المرورية خلال ساعات الليل.',
  'Technical teams started a seasonal maintenance program for neighborhood lighting networks, including replacement of outdated fixtures and efficiency improvements to enhance nighttime road safety.',
  'https://images.unsplash.com/photo-1479839672679-a46483c0e7c8',
  (select id from public.categories where slug = 'news-local' limit 1),
  (select id from public.locations where slug = 'latakia' limit 1),
  now() - interval '13 hours',
  false,
  false,
  false,
  57
),
(
  'تعزيز جاهزية فرق الإطفاء والإسعاف في مراكز المدن',
  'Enhanced readiness for firefighting and ambulance teams in city centers',
  'تحديث خطط الانتشار السريع ورفع جاهزية التجهيزات الأساسية.',
  'Rapid deployment plans updated and essential equipment readiness improved.',
  'أعلنت الجهات المحلية تعزيز جاهزية فرق الإطفاء والإسعاف في مراكز المدن، عبر تحديث خطط الانتشار السريع ودعم التجهيزات الأساسية. ويأتي ذلك ضمن برنامج وقائي يركز على الاستجابة المبكرة للحوادث.',
  'Local authorities announced enhanced readiness of firefighting and ambulance teams through updated rapid-deployment plans and improved essential equipment under a prevention-focused response program.',
  'https://images.unsplash.com/photo-1516483638261-f4dbaf036963',
  (select id from public.categories where slug = 'news-local' limit 1),
  (select id from public.locations where slug = 'daraa' limit 1),
  now() - interval '16 hours',
  false,
  false,
  false,
  49
),

-- International (5)
(
  'متابعة دبلوماسية لملفات التعاون الإقليمي في مجالات الطاقة',
  'Diplomatic follow-up on regional cooperation files in energy',
  'مشاورات حول استقرار الإمدادات وتبادل الخبرات الفنية.',
  'Consultations on supply stability and technical knowledge exchange.',
  'تابعت بعثات دبلوماسية ملفات تعاون إقليمي في مجالات الطاقة، مع التركيز على استقرار الإمدادات وتبادل الخبرات الفنية. وأكدت المشاورات أهمية التنسيق الفني طويل الأمد لتعزيز أمن الطاقة.',
  'Diplomatic channels followed regional energy cooperation files, focusing on supply stability and technical knowledge exchange. Consultations stressed long-term technical coordination for energy security.',
  'https://images.unsplash.com/photo-1451187580459-43490279c0fa',
  (select id from public.categories where slug = 'news-international' limit 1),
  (select id from public.locations where slug = 'damascus' limit 1),
  now() - interval '5 hours',
  false,
  true,
  false,
  150
),
(
  'تقارير دولية ترصد تحولات التجارة عبر الممرات البحرية',
  'International reports track trade shifts across maritime corridors',
  'تحليل لتأثير تكاليف الشحن على سلاسل الإمداد في المنطقة.',
  'Analysis of shipping-cost impact on regional supply chains.',
  'رصدت تقارير دولية أحدث التحولات في حركة التجارة عبر الممرات البحرية، مع إبراز تأثير كلف الشحن على سلاسل الإمداد الإقليمية. وتوقعت التقارير استمرار إعادة تموضع بعض المسارات التجارية خلال الفترة المقبلة.',
  'International reports tracked recent shifts in maritime trade flows, highlighting shipping-cost effects on regional supply chains. They anticipate continued route reconfiguration in the near term.',
  'https://images.unsplash.com/photo-1473448912268-2022ce9509d8',
  (select id from public.categories where slug = 'news-international' limit 1),
  (select id from public.locations where slug = 'tartus' limit 1),
  now() - interval '8 hours',
  false,
  false,
  false,
  102
),
(
  'مؤشرات جديدة حول تباطؤ التضخم في عدة اقتصادات ناشئة',
  'New indicators show inflation slowdown in several emerging economies',
  'بيانات حديثة تشير إلى تحسن نسبي في أسعار المستهلك خلال الربع الحالي.',
  'Recent data indicates relative improvement in consumer prices this quarter.',
  'أظهرت مؤشرات اقتصادية دولية تباطؤاً تدريجياً في معدلات التضخم لدى عدد من الاقتصادات الناشئة، مدفوعة باستقرار نسبي في سلاسل الإمداد العالمية. ويرى محللون أن الاتجاه الجديد يحتاج إلى متابعة خلال الأشهر القادمة.',
  'Global indicators showed a gradual inflation slowdown in several emerging economies, supported by relative supply-chain stabilization. Analysts say the trend needs close monitoring in coming months.',
  'https://images.unsplash.com/photo-1464037866556-6812c9d1c72e',
  (select id from public.categories where slug = 'news-international' limit 1),
  (select id from public.locations where slug = 'aleppo' limit 1),
  now() - interval '11 hours',
  false,
  false,
  false,
  88
),
(
  'جلسات حوار حول أمن الغذاء وتحديات المناخ عالمياً',
  'Dialogue sessions on global food security and climate challenges',
  'مناقشة سياسات الدعم الزراعي والإنذار المبكر لموجات الجفاف.',
  'Discussion on agricultural support policies and drought early-warning systems.',
  'ناقشت جلسات حوار دولية قضايا أمن الغذاء في ضوء تغيرات المناخ، مع دعوات لتعزيز أنظمة الإنذار المبكر وتبادل البيانات الزراعية بين الدول. كما طُرحت سياسات دعم إنتاج محلي أكثر مرونة.',
  'International dialogue sessions discussed food security amid climate change, calling for stronger early-warning systems and agricultural data sharing. More resilient local production policies were also proposed.',
  'https://images.unsplash.com/photo-1501004318641-b39e6451bec6',
  (select id from public.categories where slug = 'news-international' limit 1),
  (select id from public.locations where slug = 'hama' limit 1),
  now() - interval '14 hours',
  false,
  false,
  false,
  63
),
(
  'متابعة تطورات أسواق الطاقة العالمية وانعكاساتها الإقليمية',
  'Monitoring global energy markets and their regional implications',
  'قراءة في حركة الأسعار وخيارات إدارة المخاطر خلال الموسم الحالي.',
  'A readout on price movement and risk-management options this season.',
  'يواصل خبراء الاقتصاد والطاقة متابعة تطورات أسواق الطاقة العالمية، مع تقييم انعكاساتها على كلف الإنتاج والنقل في المنطقة. وتشير التقديرات إلى أهمية تنويع مصادر التوريد وإدارة المخاطر التعاقدية.',
  'Energy and economic experts continue tracking global energy-market developments, assessing implications for production and transport costs in the region. Estimates stress diversification and contractual risk management.',
  'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e',
  (select id from public.categories where slug = 'news-international' limit 1),
  (select id from public.locations where slug = 'homs' limit 1),
  now() - interval '18 hours',
  false,
  false,
  false,
  54
),

-- Sports (5)
(
  'انطلاق تحضيرات الأندية للموسم الجديد بخطط فنية مكثفة',
  'Clubs launch intensive technical plans for the new season',
  'برامج تدريبية تتضمن اختبارات لياقة ومباريات ودية متدرجة.',
  'Training programs include fitness tests and phased friendly matches.',
  'بدأت الأندية المحلية تحضيراتها للموسم الجديد عبر برامج فنية وبدنية مكثفة، تتضمن اختبارات لياقة ومباريات ودية تجريبية. وتركز الأجهزة الفنية على تعزيز الانسجام التكتيكي ورفع الجاهزية العامة.',
  'Local clubs started preparations for the new season through intensive technical and physical programs, including fitness tests and friendly fixtures. Coaching staffs focus on tactical cohesion and overall readiness.',
  'https://images.unsplash.com/photo-1461896836934-ffe607ba8211',
  (select id from public.categories where slug = 'news-sports' limit 1),
  (select id from public.locations where slug = 'aleppo' limit 1),
  now() - interval '6 hours',
  false,
  true,
  false,
  142
),
(
  'تحديث روزنامة المنافسات المحلية وتحديد مواعيد الجولات',
  'Local competition calendar updated with round schedules',
  'إعلان جدول مبدئي يراعي جاهزية الملاعب وبرامج النقل.',
  'Preliminary schedule announced, considering stadium readiness and logistics.',
  'أعلنت الجهات الرياضية روزنامة محدثة للمنافسات المحلية، مع تحديد مواعيد الجولات وفق جاهزية الملاعب والظروف اللوجستية. ويتيح الجدول الجديد مساحة زمنية أفضل للتحضير الفني بين المباريات.',
  'Sports authorities announced an updated domestic competition calendar, setting round dates according to stadium readiness and logistics. The new timetable provides better preparation windows between matches.',
  'https://images.unsplash.com/photo-1579952363873-27f3bade9f55',
  (select id from public.categories where slug = 'news-sports' limit 1),
  (select id from public.locations where slug = 'damascus' limit 1),
  now() - interval '9 hours',
  false,
  false,
  false,
  95
),
(
  'برنامج لاكتشاف المواهب الشابة في مراكز التدريب',
  'Program to identify young talents in training centers',
  'توسيع اختبارات الانتقاء للفئات العمرية في عدة محافظات.',
  'Talent scouting expanded across youth age groups in multiple governorates.',
  'أطلقت الاتحادات الرياضية برنامجاً لاكتشاف المواهب الشابة في مراكز التدريب، مع توسيع اختبارات الانتقاء للفئات العمرية المختلفة. ويهدف البرنامج إلى رفد الأندية والمنتخبات بعناصر واعدة على المدى المتوسط.',
  'Sports federations launched a youth talent-identification program in training centers, expanding scouting trials across age groups. The initiative aims to feed clubs and national teams with promising players.',
  'https://images.unsplash.com/photo-1517649763962-0c623066013b',
  (select id from public.categories where slug = 'news-sports' limit 1),
  (select id from public.locations where slug = 'hama' limit 1),
  now() - interval '12 hours',
  false,
  false,
  false,
  71
),
(
  'رفع الجاهزية الطبية للفرق عبر وحدات متابعة متخصصة',
  'Medical readiness for teams boosted through specialized monitoring units',
  'تطبيق بروتوكولات فحوص دورية للحد من الإصابات العضلية.',
  'Periodic screening protocols introduced to reduce muscular injuries.',
  'بدأت الفرق الرياضية تطبيق بروتوكولات متابعة طبية دورية بإشراف وحدات متخصصة، للحد من الإصابات ورفع الاستشفاء لدى اللاعبين. كما تم اعتماد خطط تغذية داعمة للبرامج التدريبية المكثفة.',
  'Sports teams started periodic medical monitoring protocols under specialized units to reduce injuries and improve recovery. Nutrition plans were also adopted to support intensive training cycles.',
  'https://images.unsplash.com/photo-1546519638-68e109498ffc',
  (select id from public.categories where slug = 'news-sports' limit 1),
  (select id from public.locations where slug = 'latakia' limit 1),
  now() - interval '15 hours',
  false,
  false,
  false,
  59
),
(
  'ورشات تحكيمية لرفع مستوى إدارة المباريات محلياً',
  'Refereeing workshops to improve match management standards locally',
  'جلسات تقنية حول تطبيق القانون وتوحيد معايير القرار التحكيمي.',
  'Technical sessions on law application and decision consistency.',
  'نُظمت ورشات تحكيمية متخصصة لرفع مستوى إدارة المباريات، مع جلسات تقنية حول تطبيق القانون وتوحيد معايير القرارات التحكيمية. وركزت الورشات على تقليل الأخطاء المؤثرة وتحسين التواصل داخل الطاقم.',
  'Specialized refereeing workshops were held to improve match management, with technical sessions on law application and decision consistency. Focus areas included reducing impactful errors and better crew communication.',
  'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d',
  (select id from public.categories where slug = 'news-sports' limit 1),
  (select id from public.locations where slug = 'tartus' limit 1),
  now() - interval '19 hours',
  false,
  false,
  false,
  46
),

-- Culture (5)
(
  'افتتاح موسم ثقافي جديد بفعاليات فنية ومعارض كتاب',
  'New cultural season launches with arts events and book fairs',
  'برنامج متنوع يشمل مسرحاً وموسيقى ومعارض للفنون البصرية.',
  'A diverse program featuring theater, music, and visual arts exhibitions.',
  'انطلق الموسم الثقافي الجديد ببرنامج متنوع يضم عروضاً مسرحية وأمسيات موسيقية ومعارض للفنون البصرية، إلى جانب فعاليات للكتاب والقراءة. ويهدف البرنامج إلى توسيع المشاركة الثقافية بين مختلف الفئات العمرية.',
  'The new cultural season launched with a diverse agenda of theater performances, music evenings, visual arts exhibitions, and book events. The program aims to broaden cultural participation across age groups.',
  'https://images.unsplash.com/photo-1518998053901-5348d3961a04',
  (select id from public.categories where slug = 'news-culture' limit 1),
  (select id from public.locations where slug = 'damascus' limit 1),
  now() - interval '7 hours',
  false,
  true,
  false,
  115
),
(
  'مبادرة لحفظ التراث اللامادي وتوثيق الحكاية الشعبية',
  'Initiative to preserve intangible heritage and document oral storytelling',
  'ورشات تدريبية لتوثيق الموروث المحلي بمشاركة باحثين شباب.',
  'Training workshops to document local heritage with young researchers.',
  'أطلقت مؤسسات ثقافية مبادرة لحفظ التراث اللامادي وتوثيق الحكاية الشعبية عبر ورشات تدريبية ميدانية. وتركز المبادرة على إشراك الباحثين الشباب في جمع الروايات الشفوية والأرشفة الرقمية.',
  'Cultural institutions launched an initiative to preserve intangible heritage and document oral storytelling through field workshops. The initiative engages young researchers in oral-history collection and digital archiving.',
  'https://images.unsplash.com/photo-1512820790803-83ca734da794',
  (select id from public.categories where slug = 'news-culture' limit 1),
  (select id from public.locations where slug = 'homs' limit 1),
  now() - interval '10 hours',
  false,
  false,
  false,
  82
),
(
  'ترميم مواقع أثرية ضمن خطة حماية المعالم التاريخية',
  'Restoration works at archaeological sites under heritage protection plan',
  'فرق متخصصة تباشر مراحل توثيق وترميم أولي في عدد من المواقع.',
  'Specialized teams begin documentation and initial restoration at selected sites.',
  'باشرت فرق متخصصة تنفيذ مراحل أولية من ترميم مواقع أثرية ضمن خطة وطنية لحماية المعالم التاريخية. وتتضمن الأعمال توثيقاً فنياً دقيقاً ومعالجات إنشائية مدروسة للحفاظ على القيمة التراثية للمواقع.',
  'Specialized teams began initial restoration phases at archaeological sites under a national heritage-protection plan, combining precise technical documentation with carefully designed structural interventions.',
  'https://images.unsplash.com/photo-1473445361085-b9a07f55608b',
  (select id from public.categories where slug = 'news-culture' limit 1),
  (select id from public.locations where slug = 'aleppo' limit 1),
  now() - interval '13 hours',
  false,
  false,
  false,
  66
),
(
  'إطلاق منصة رقمية لدعم المحتوى الثقافي المحلي',
  'Digital platform launched to support local cultural content',
  'نشر مواد مرئية ومكتوبة للتعريف بالمبادرات الثقافية في المحافظات.',
  'Publishing visual and written materials on cultural initiatives nationwide.',
  'أُطلقت منصة رقمية جديدة لدعم المحتوى الثقافي المحلي، بما يتيح نشر المواد المرئية والمكتوبة حول الفعاليات والمبادرات في المحافظات. وتسعى المنصة إلى توسيع الوصول للجمهور الشاب عبر قنوات رقمية حديثة.',
  'A new digital platform was launched to support local cultural content by publishing visual and written coverage of initiatives across governorates, aiming to reach younger audiences through modern digital channels.',
  'https://images.unsplash.com/photo-1491841550275-ad7854e35ca6',
  (select id from public.categories where slug = 'news-culture' limit 1),
  (select id from public.locations where slug = 'latakia' limit 1),
  now() - interval '16 hours',
  false,
  false,
  false,
  53
),
(
  'ملتقى إبداعي للشباب يركز على الكتابة والصناعة السينمائية',
  'Youth creative forum focuses on writing and filmmaking',
  'جلسات تدريبية ومساحات عرض لمشاريع ناشئة في السرد البصري.',
  'Training sessions and showcase spaces for emerging visual storytelling projects.',
  'استضافت إحدى المدن ملتقى إبداعياً للشباب ركز على مهارات الكتابة وصناعة الفيلم القصير، مع جلسات تدريبية يديرها مختصون ومساحات عرض لمشاريع ناشئة. ويهدف الملتقى إلى تشجيع الإنتاج الثقافي المستقل.',
  'A city hosted a youth creative forum focused on writing and short filmmaking, featuring specialist-led workshops and showcases for emerging projects. The forum aims to encourage independent cultural production.',
  'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba',
  (select id from public.categories where slug = 'news-culture' limit 1),
  (select id from public.locations where slug = 'as-suwayda' limit 1),
  now() - interval '20 hours',
  false,
  false,
  false,
  41
);

-- =============================
-- E) Seed video playlists + program playlists
-- =============================
alter table public.categories
  add column if not exists cover_image_url text;

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
exception
  when duplicate_object then
    null;
end $$;

-- 6 video playlists (type = video)
insert into public.categories (name, name_en, slug, cover_image_url, order_index, type)
values
  ('الأخبار السياسية', 'Political News Videos', 'video-political-news', 'https://images.unsplash.com/photo-1495020689067-958852a7765e', 1, 'video'),
  ('الاقتصاد والأسواق', 'Economy and Markets', 'video-economy-markets', 'https://images.unsplash.com/photo-1611974714024-4607a55d4001', 2, 'video'),
  ('محليات', 'Local Reports', 'video-local-reports', 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df', 3, 'video'),
  ('شؤون دولية', 'International Affairs', 'video-international-affairs', 'https://images.unsplash.com/photo-1451187580459-43490279c0fa', 4, 'video'),
  ('رياضة', 'Sports Videos', 'video-sports-news', 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211', 5, 'video'),
  ('ثقافة ومجتمع', 'Culture and Society', 'video-culture-society', 'https://images.unsplash.com/photo-1518998053901-5348d3961a04', 6, 'video')
on conflict (slug) do update
set
  name = excluded.name,
  name_en = excluded.name_en,
  cover_image_url = excluded.cover_image_url,
  order_index = excluded.order_index,
  type = excluded.type;

-- 6 program playlists (type = program)
insert into public.categories (name, name_en, slug, cover_image_url, order_index, type)
values
  ('نشرة التاسعة', 'Nine Oclock Bulletin', 'program-nine-bulletin', 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab', 1, 'program'),
  ('عين على الاقتصاد', 'Eye on Economy', 'program-eye-on-economy', 'https://images.unsplash.com/photo-1554224155-6726b3ff858f', 2, 'program'),
  ('المشهد السياسي', 'Political Scene', 'program-political-scene', 'https://images.unsplash.com/photo-1504711434969-e33886168f5c', 3, 'program'),
  ('ملف الأسبوع', 'Weekly File', 'program-weekly-file', 'https://images.unsplash.com/photo-1450101499163-c8848c66ca85', 4, 'program'),
  ('الشارع السوري', 'Syrian Street', 'program-syrian-street', 'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1f', 5, 'program'),
  ('منصة الحوار', 'Dialogue Platform', 'program-dialogue-platform', 'https://images.unsplash.com/photo-1517048676732-d65bc937f952', 6, 'program')
on conflict (slug) do update
set
  name = excluded.name,
  name_en = excluded.name_en,
  cover_image_url = excluded.cover_image_url,
  order_index = excluded.order_index,
  type = excluded.type;

-- 10 real YouTube videos in each video playlist (6 x 10 = 60)
with video_playlists as (
  select
    id,
    name,
    order_index,
    row_number() over (order by order_index, id) as playlist_no
  from public.categories
  where type = 'video'
),
video_pool as (
  select *
  from (values
    (1, 'aqz-KE-bpKQ', 'تقرير خاص'),
    (2, '5p248yoa3oE', 'ملف اليوم'),
    (3, '0_fL68-C8uA', 'تغطية ميدانية'),
    (4, 'M7X_H-oUo2k', 'نقاش مباشر'),
    (5, 'sdZ9W1qwYrE', 'اقتصاد وسياسة'),
    (6, '40x0fUqhgro', 'قراءة تحليلية'),
    (7, 'ScMzIvxBSi4', 'خلاصة الأحداث'),
    (8, 'LXb3EKWsInQ', 'متابعة خاصة'),
    (9, 'ysz5S6PUM-U', 'تقرير موسع'),
    (10, 'dQw4w9WgXcQ', 'موجز مرئي'),
    (11, '9bZkp7q19f0', 'أخبار الساعة'),
    (12, 'kJQP7kiw5Fk', 'تقرير اقتصادي'),
    (13, '3JZ_D3ELwOQ', 'متابعة سياسية'),
    (14, '60ItHLz5WEA', 'تغطية مباشرة'),
    (15, 'fJ9rUzIMcZQ', 'شؤون محلية'),
    (16, 'OPf0YbXqDm0', 'قراءة سريعة'),
    (17, 'RgKAFK5djSk', 'بين السطور'),
    (18, 'YQHsXMglC9A', 'نبض الشارع'),
    (19, '2Vv-BfVoq4g', 'تقرير ميداني'),
    (20, 'M7lc1UVf-VE', 'ملخص اليوم'),
    (21, 'e-ORhEE9VVg', 'قضايا دولية'),
    (22, 'CevxZvSJLk8', 'تحليل معمق'),
    (23, '09R8_2nJtjg', 'تطورات عاجلة'),
    (24, 'hLQl3WQQoQ0', 'اقتصاد وأسواق'),
    (25, 'JGwWNGJdvx8', 'مشهد إقليمي'),
    (26, 'pRpeEdMmmQ0', 'قصة خبر'),
    (27, 'YqeW9_5kURI', 'عين على الحدث'),
    (28, 'kffacxfA7G4', 'تغطية خاصة'),
    (29, 'QJO3ROT-A4E', 'نافذة الأخبار'),
    (30, 'YVkUvmDQ3HY', 'إيجاز المساء'),
    (31, 'fRh_vgS2dFE', 'مؤشرات اليوم'),
    (32, 'RB-RcX5DS5A', 'حوار وتحليل'),
    (33, 'xTlNMmZKwpA', 'الشأن المحلي'),
    (34, 'J_ub7Etch2U', 'حركة الأسواق'),
    (35, 'lp-EO5I60KA', 'قراءة استراتيجية'),
    (36, 'iS1g8G_njx8', 'خبر وصورة'),
    (37, '3tmd-ClpJxA', 'ملف متجدد'),
    (38, 'rYEDA3JcQqw', 'رصد يومي'),
    (39, 'uelHwf8o7_U', 'حدث وتداعيات'),
    (40, 'KQ6zr6kCPj8', 'لقطة سريعة'),
    (41, 'LsoLEjrDogU', 'خلف العناوين'),
    (42, '2vjPBrBU-TM', 'تقرير أسبوعي'),
    (43, '34Na4j8AVgA', 'شؤون عامة'),
    (44, 'tVj0ZTS4WF4', 'قراءة المسار'),
    (45, 'hTWKbfoikeg', 'نقطة نظام'),
    (46, '04854XqcfCY', 'مشهد متحرك'),
    (47, 'ZZ5LpwO-An4', 'ملف خاص'),
    (48, 'pAgnJDJN4VA', 'تحليل رقمي'),
    (49, '5NV6Rdv1a3I', 'صوت الشارع'),
    (50, '6Ejga4kJUts', 'خلاصة المشهد'),
    (51, 'SR6iYWJxHqs', 'نظرة معمقة'),
    (52, 'UceaB4D0jpo', 'تغطية مستمرة'),
    (53, 'nc3CY31kMJ4', 'موجز الأخبار'),
    (54, 'kXYiU_JCYtU', 'متابعة الملف'),
    (55, '8SbUC-UaAxE', 'حدث اليوم'),
    (56, '7wtfhZwyrcc', 'تقرير مفصل'),
    (57, '4fndeDfaWCg', 'رؤية تحليلية'),
    (58, 'CVxMTl6cACc', 'تطورات متسارعة'),
    (59, '4NRXx6U8ABQ', 'ملامح المشهد'),
    (60, 'pXRviuL6vMY', 'نشرة ختامية')
  ) as v(seq_no, youtube_id, label)
),
video_assignment as (
  select
    vp.id as category_id,
    vp.name as playlist_name,
    vp.order_index,
    slot.order_no,
    v.youtube_id,
    v.label
  from video_playlists vp
  join lateral (
    select
      gs as order_no,
      ((vp.playlist_no - 1) * 10) + gs as seq_no
    from generate_series(1, 10) as gs
  ) slot on true
  join video_pool v on v.seq_no = slot.seq_no
)
insert into public.videos (
  title,
  youtube_url,
  category_id,
  thumbnail_url,
  order_index,
  published_at,
  is_hidden
)
select
  va.playlist_name || ' | الفيديو ' || va.order_no || ' - ' || va.label as title,
  'https://www.youtube.com/watch?v=' || va.youtube_id as youtube_url,
  va.category_id,
  'https://img.youtube.com/vi/' || va.youtube_id || '/hqdefault.jpg' as thumbnail_url,
  va.order_no as order_index,
  now() - (((va.order_index - 1) * 30 + va.order_no) || ' hours')::interval as published_at,
  false as is_hidden
from video_assignment va
order by va.order_index, va.order_no;

-- 10 episodes in each program playlist (6 x 10 = 60)
with program_playlists as (
  select
    id,
    name,
    order_index,
    row_number() over (order by order_index, id) as playlist_no
  from public.categories
  where type = 'program'
),
episode_pool as (
  select *
  from (values
    (1, 'xTlNMmZKwpA', 'الحلقة 1'),
    (2, 'J_ub7Etch2U', 'الحلقة 2'),
    (3, 'lp-EO5I60KA', 'الحلقة 3'),
    (4, 'iS1g8G_njx8', 'الحلقة 4'),
    (5, '3tmd-ClpJxA', 'الحلقة 5'),
    (6, 'rYEDA3JcQqw', 'الحلقة 6'),
    (7, 'uelHwf8o7_U', 'الحلقة 7'),
    (8, 'KQ6zr6kCPj8', 'الحلقة 8'),
    (9, 'LsoLEjrDogU', 'الحلقة 9'),
    (10, '2vjPBrBU-TM', 'الحلقة 10'),
    (11, '34Na4j8AVgA', 'الحلقة 11'),
    (12, 'tVj0ZTS4WF4', 'الحلقة 12'),
    (13, 'hTWKbfoikeg', 'الحلقة 13'),
    (14, '04854XqcfCY', 'الحلقة 14'),
    (15, 'ZZ5LpwO-An4', 'الحلقة 15'),
    (16, 'pAgnJDJN4VA', 'الحلقة 16'),
    (17, '5NV6Rdv1a3I', 'الحلقة 17'),
    (18, '6Ejga4kJUts', 'الحلقة 18'),
    (19, 'SR6iYWJxHqs', 'الحلقة 19'),
    (20, 'UceaB4D0jpo', 'الحلقة 20'),
    (21, 'nc3CY31kMJ4', 'الحلقة 21'),
    (22, 'kXYiU_JCYtU', 'الحلقة 22'),
    (23, '8SbUC-UaAxE', 'الحلقة 23'),
    (24, '7wtfhZwyrcc', 'الحلقة 24'),
    (25, '4fndeDfaWCg', 'الحلقة 25'),
    (26, 'CVxMTl6cACc', 'الحلقة 26'),
    (27, '4NRXx6U8ABQ', 'الحلقة 27'),
    (28, 'pXRviuL6vMY', 'الحلقة 28'),
    (29, 'aqz-KE-bpKQ', 'الحلقة 29'),
    (30, '5p248yoa3oE', 'الحلقة 30'),
    (31, '0_fL68-C8uA', 'الحلقة 31'),
    (32, 'M7X_H-oUo2k', 'الحلقة 32'),
    (33, 'sdZ9W1qwYrE', 'الحلقة 33'),
    (34, '40x0fUqhgro', 'الحلقة 34'),
    (35, 'ScMzIvxBSi4', 'الحلقة 35'),
    (36, 'LXb3EKWsInQ', 'الحلقة 36'),
    (37, 'ysz5S6PUM-U', 'الحلقة 37'),
    (38, 'dQw4w9WgXcQ', 'الحلقة 38'),
    (39, '9bZkp7q19f0', 'الحلقة 39'),
    (40, 'kJQP7kiw5Fk', 'الحلقة 40'),
    (41, '3JZ_D3ELwOQ', 'الحلقة 41'),
    (42, '60ItHLz5WEA', 'الحلقة 42'),
    (43, 'fJ9rUzIMcZQ', 'الحلقة 43'),
    (44, 'OPf0YbXqDm0', 'الحلقة 44'),
    (45, 'RgKAFK5djSk', 'الحلقة 45'),
    (46, 'YQHsXMglC9A', 'الحلقة 46'),
    (47, '2Vv-BfVoq4g', 'الحلقة 47'),
    (48, 'M7lc1UVf-VE', 'الحلقة 48'),
    (49, 'e-ORhEE9VVg', 'الحلقة 49'),
    (50, 'CevxZvSJLk8', 'الحلقة 50'),
    (51, '09R8_2nJtjg', 'الحلقة 51'),
    (52, 'hLQl3WQQoQ0', 'الحلقة 52'),
    (53, 'JGwWNGJdvx8', 'الحلقة 53'),
    (54, 'pRpeEdMmmQ0', 'الحلقة 54'),
    (55, 'YqeW9_5kURI', 'الحلقة 55'),
    (56, 'kffacxfA7G4', 'الحلقة 56'),
    (57, 'QJO3ROT-A4E', 'الحلقة 57'),
    (58, 'YVkUvmDQ3HY', 'الحلقة 58'),
    (59, 'fRh_vgS2dFE', 'الحلقة 59'),
    (60, 'RB-RcX5DS5A', 'الحلقة 60')
  ) as e(seq_no, youtube_id, label)
),
episode_assignment as (
  select
    pp.id as category_id,
    pp.name as playlist_name,
    pp.order_index,
    slot.order_no,
    e.youtube_id,
    e.label
  from program_playlists pp
  join lateral (
    select
      gs as order_no,
      ((pp.playlist_no - 1) * 10) + gs as seq_no
    from generate_series(1, 10) as gs
  ) slot on true
  join episode_pool e on e.seq_no = slot.seq_no
)
insert into public.videos (
  title,
  youtube_url,
  category_id,
  thumbnail_url,
  order_index,
  published_at,
  is_hidden
)
select
  ea.playlist_name || ' | الحلقة ' || ea.order_no || ' - ' || ea.label as title,
  'https://www.youtube.com/watch?v=' || ea.youtube_id as youtube_url,
  ea.category_id,
  'https://img.youtube.com/vi/' || ea.youtube_id || '/hqdefault.jpg' as thumbnail_url,
  ea.order_no as order_index,
  now() - (((ea.order_index - 1) * 40 + ea.order_no) || ' hours')::interval as published_at,
  false as is_hidden
from episode_assignment ea
order by ea.order_index, ea.order_no;

-- =============================
-- F) Breaking news: 3/day for 7 days from today
-- =============================
with days as (
  select generate_series(0, 6) as day_offset
),
slots as (
  select 1 as slot_no, interval '08:00' as slot_start, interval '12:00' as slot_end
  union all
  select 2, interval '12:00', interval '16:00'
  union all
  select 3, interval '16:00', interval '23:59'
)
insert into public.breaking_news (
  title,
  content,
  created_at,
  start_time,
  end_time,
  send_notification,
  is_active,
  view_count
)
select
  case s.slot_no
    when 1 then 'عاجل: تحديثات خدمية وميدانية - اليوم ' || (d.day_offset + 1)
    when 2 then 'عاجل: مستجدات اقتصادية ومحلية - اليوم ' || (d.day_offset + 1)
    else 'عاجل: متابعة آخر التطورات - اليوم ' || (d.day_offset + 1)
  end as title,
  case s.slot_no
    when 1 then 'متابعة عاجلة للملفات الخدمية وحركة الاستجابة خلال الفترة الصباحية.'
    when 2 then 'متابعة عاجلة لتطورات الأسواق المحلية وحالة الخدمات خلال فترة الظهيرة.'
    else 'متابعة عاجلة لأبرز التطورات الميدانية والبيانات الرسمية في المساء.'
  end as content,
  now() as created_at,
  date_trunc('day', now()) + (d.day_offset || ' day')::interval + s.slot_start as start_time,
  date_trunc('day', now()) + (d.day_offset || ' day')::interval + s.slot_end as end_time,
  true as send_notification,
  true as is_active,
  0 as view_count
from days d
cross join slots s
order by d.day_offset, s.slot_no;

commit;
