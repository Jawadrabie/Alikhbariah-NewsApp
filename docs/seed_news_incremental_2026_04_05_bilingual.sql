-- Incremental news insert (new items only) from alikhbariah.com
-- Batch date: 2026-04-05

begin;

alter table if exists public.news
  add column if not exists source_url text,
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

insert into public.news (
  title, title_en, summary, summary_en, content, content_en,
  image_url, source_url, category_id, location_id, created_at,
  is_hidden, is_featured, sent_notification, view_count
)
select
  'أجواء غير مستقرة وأمطار على مناطق متفرقة من البلاد',
  'Unstable weather and rainfall in several parts of the country',
  'تشهد البلاد أجواء غير مستقرة مع فرص لهطولات مطرية على مناطق متفرقة، وفق النشرات الجوية الصادرة صباح الأحد 5 نيسان.',
  'The country is experiencing unstable weather with chances of rainfall in scattered areas, according to weather bulletins issued on Sunday morning, April 5.',
  'تشهد البلاد أجواء غير مستقرة مع فرص لهطولات مطرية على مناطق متفرقة، وفق النشرات الجوية الصادرة صباح الأحد 5 نيسان.',
  'The country is experiencing unstable weather with chances of rainfall in scattered areas, according to weather bulletins issued on Sunday morning, April 5.',
  'https://alikhbariah.com/wp-content/uploads/2026/04/Damascus.jpg',
  'https://alikhbariah.com/%d8%a3%d8%ac%d9%88%d8%a7%d8%a1-%d8%ba%d9%8a%d8%b1-%d9%85%d8%b3%d8%aa%d9%82%d8%b1%d8%a9-%d9%88%d8%a3%d9%85%d8%b7%d8%a7%d8%b1-%d8%b9%d9%84%d9%89-%d9%85%d9%86%d8%a7%d8%b7%d9%82-%d9%85%d8%aa%d9%81%d8%b1/',
  (select id from public.categories where slug = 'news-local' and type = 'news' limit 1),
  (select id from public.locations where slug = 'syria' limit 1),
  '2026-04-05T08:57:26Z'::timestamptz,
  false, false, true, 0
where not exists (
  select 1 from public.news n where n.title = 'أجواء غير مستقرة وأمطار على مناطق متفرقة من البلاد'
    or coalesce(to_jsonb(n)->>'source_url','') = 'https://alikhbariah.com/%d8%a3%d8%ac%d9%88%d8%a7%d8%a1-%d8%ba%d9%8a%d8%b1-%d9%85%d8%b3%d8%aa%d9%82%d8%b1%d8%a9-%d9%88%d8%a3%d9%85%d8%b7%d8%a7%d8%b1-%d8%b9%d9%84%d9%89-%d9%85%d9%86%d8%a7%d8%b7%d9%82-%d9%85%d8%aa%d9%81%d8%b1/'
);

insert into public.news (
  title, title_en, summary, summary_en, content, content_en,
  image_url, source_url, category_id, location_id, created_at,
  is_hidden, is_featured, sent_notification, view_count
)
select
  'وزارة الطاقة: حريق يوقف ضخّ المياه في محطة مسكنة ويستدعي تدخلاً عاجلاً',
  'Ministry of Energy: Fire halts water pumping at Maskana station and requires urgent intervention',
  'أعلنت وزارة الطاقة أن حريقاً أدى إلى توقف ضخ المياه في محطة مسكنة، وأكدت مباشرة الفرق الفنية لاحتواء الأضرار وإعادة الخدمة.',
  'The Ministry of Energy announced that a fire halted water pumping at Maskana station and confirmed that technical teams began urgent intervention to restore service.',
  'أعلنت وزارة الطاقة أن حريقاً أدى إلى توقف ضخ المياه في محطة مسكنة، وأكدت مباشرة الفرق الفنية لاحتواء الأضرار وإعادة الخدمة.',
  'The Ministry of Energy announced that a fire halted water pumping at Maskana station and confirmed that technical teams began urgent intervention to restore service.',
  'https://alikhbariah.com/wp-content/uploads/2026/04/Ministry-of-Energy-Fire-halts-water-pumping-at-Maskana-station-requiring-urgent-intervention.jpg',
  'https://alikhbariah.com/%d9%88%d8%b2%d8%a7%d8%b1%d8%a9-%d8%a7%d9%84%d8%b7%d8%a7%d9%82%d8%a9-%d8%ad%d8%b1%d9%8a%d9%82-%d9%8a%d9%88%d9%82%d9%81-%d8%b6%d8%ae%d9%91-%d8%a7%d9%84%d9%85%d9%8a%d8%a7%d9%87-%d9%81%d9%8a-%d9%85%d8%ad/',
  (select id from public.categories where slug = 'news-local' and type = 'news' limit 1),
  (select id from public.locations where slug = 'syria' limit 1),
  '2026-04-05T02:45:05Z'::timestamptz,
  false, false, true, 0
where not exists (
  select 1 from public.news n where n.title = 'وزارة الطاقة: حريق يوقف ضخّ المياه في محطة مسكنة ويستدعي تدخلاً عاجلاً'
    or coalesce(to_jsonb(n)->>'source_url','') = 'https://alikhbariah.com/%d9%88%d8%b2%d8%a7%d8%b1%d8%a9-%d8%a7%d9%84%d8%b7%d8%a7%d9%82%d8%a9-%d8%ad%d8%b1%d9%8a%d9%82-%d9%8a%d9%88%d9%82%d9%81-%d8%b6%d8%ae%d9%91-%d8%a7%d9%84%d9%85%d9%8a%d8%a7%d9%87-%d9%81%d9%8a-%d9%85%d8%ad/'
);

insert into public.news (
  title, title_en, summary, summary_en, content, content_en,
  image_url, source_url, category_id, location_id, created_at,
  is_hidden, is_featured, sent_notification, view_count
)
select
  'وزير الطوارئ: سوريا تعيش فوق بحر من الألغام والذخائر غير المنفجرة',
  'Emergency Minister: Syria is living above a sea of mines and unexploded ordnance',
  'أكد وزير الطوارئ أن مخلفات الحرب ما زالت تشكل تهديداً واسعاً في سوريا، داعياً إلى تسريع أعمال الإزالة والحماية المدنية.',
  'The Emergency Minister said war remnants still pose a wide threat across Syria and called for accelerating mine-clearance and civilian protection efforts.',
  'أكد وزير الطوارئ أن مخلفات الحرب ما زالت تشكل تهديداً واسعاً في سوريا، داعياً إلى تسريع أعمال الإزالة والحماية المدنية.',
  'The Emergency Minister said war remnants still pose a wide threat across Syria and called for accelerating mine-clearance and civilian protection efforts.',
  'https://alikhbariah.com/wp-content/uploads/2026/04/Emergency-Minister-Syria-is-living-atop-a-sea-of-​​mines-and-unexploded-ordnance.jpg',
  'https://alikhbariah.com/%d9%88%d8%b2%d9%8a%d8%b1-%d8%a7%d9%84%d8%b7%d9%88%d8%a7%d8%b1%d8%a6-%d8%b3%d9%88%d8%b1%d9%8a%d8%a7-%d8%aa%d8%b9%d9%8a%d8%b4-%d9%81%d9%88%d9%82-%d8%a8%d8%ad%d8%b1-%d9%85%d9%86-%d8%a7%d9%84%d8%a3%d9%84/',
  (select id from public.categories where slug = 'news-local' and type = 'news' limit 1),
  (select id from public.locations where slug = 'syria' limit 1),
  '2026-04-05T02:30:55Z'::timestamptz,
  false, false, true, 0
where not exists (
  select 1 from public.news n where n.title = 'وزير الطوارئ: سوريا تعيش فوق بحر من الألغام والذخائر غير المنفجرة'
    or coalesce(to_jsonb(n)->>'source_url','') = 'https://alikhbariah.com/%d9%88%d8%b2%d9%8a%d8%b1-%d8%a7%d9%84%d8%b7%d9%88%d8%a7%d8%b1%d8%a6-%d8%b3%d9%88%d8%b1%d9%8a%d8%a7-%d8%aa%d8%b9%d9%8a%d8%b4-%d9%81%d9%88%d9%82-%d8%a8%d8%ad%d8%b1-%d9%85%d9%86-%d8%a7%d9%84%d8%a3%d9%84/'
);

insert into public.news (
  title, title_en, summary, summary_en, content, content_en,
  image_url, source_url, category_id, location_id, created_at,
  is_hidden, is_featured, sent_notification, view_count
)
select
  'وزارة الإعلام تفند تقرير "نيويورك تايمز" حول الاختطاف: شهادات مجهولة وافتقار للأدلة',
  'Ministry of Information refutes New York Times kidnapping report: anonymous testimonies and lack of evidence',
  'فندت وزارة الإعلام ما ورد في تقرير صحفي أجنبي حول ملف اختطاف، مؤكدة أن التقرير استند إلى مصادر مجهولة دون أدلة كافية.',
  'The Ministry of Information rejected claims in a foreign media report on a kidnapping case, stating it relied on anonymous sources without sufficient evidence.',
  'فندت وزارة الإعلام ما ورد في تقرير صحفي أجنبي حول ملف اختطاف، مؤكدة أن التقرير استند إلى مصادر مجهولة دون أدلة كافية.',
  'The Ministry of Information rejected claims in a foreign media report on a kidnapping case, stating it relied on anonymous sources without sufficient evidence.',
  'https://alikhbariah.com/wp-content/uploads/2026/04/The-Ministry-of-Information-refutes-the-New-York-Times-report-on-the-kidnapping-anonymous-testimonies-and-a-lack-of-evidence.jpg',
  'https://alikhbariah.com/%d9%88%d8%b2%d8%a7%d8%b1%d8%a9-%d8%a7%d9%84%d8%a5%d8%b9%d9%84%d8%a7%d9%85-%d8%aa%d9%81%d9%86%d8%af-%d8%aa%d9%82%d8%b1%d9%8a%d8%b1-%d9%86%d9%8a%d9%88%d9%8a%d9%88%d8%b1%d9%83-%d8%aa%d8%a7%d9%8a%d9%85/',
  (select id from public.categories where slug = 'news-politics' and type = 'news' limit 1),
  (select id from public.locations where slug = 'syria' limit 1),
  '2026-04-05T01:58:44Z'::timestamptz,
  false, false, true, 0
where not exists (
  select 1 from public.news n where n.title = 'وزارة الإعلام تفند تقرير "نيويورك تايمز" حول الاختطاف: شهادات مجهولة وافتقار للأدلة'
    or coalesce(to_jsonb(n)->>'source_url','') = 'https://alikhbariah.com/%d9%88%d8%b2%d8%a7%d8%b1%d8%a9-%d8%a7%d9%84%d8%a5%d8%b9%d9%84%d8%a7%d9%85-%d8%aa%d9%81%d9%86%d8%af-%d8%aa%d9%82%d8%b1%d9%8a%d8%b1-%d9%86%d9%8a%d9%88%d9%8a%d9%88%d8%b1%d9%83-%d8%aa%d8%a7%d9%8a%d9%85/'
);

insert into public.news (
  title, title_en, summary, summary_en, content, content_en,
  image_url, source_url, category_id, location_id, created_at,
  is_hidden, is_featured, sent_notification, view_count
)
select
  'إدلب.. اجتماع موسع لمناقشة خطة عودة الأهالي من المخيمات',
  'Idlib: Expanded meeting to discuss a plan for residents returning from camps',
  'شهدت إدلب اجتماعاً موسعاً لبحث آليات عودة الأهالي من المخيمات، ضمن جهود تحسين الاستقرار والخدمات الأساسية.',
  'An expanded meeting was held in Idlib to discuss mechanisms for residents returning from camps, as part of efforts to improve stability and basic services.',
  'شهدت إدلب اجتماعاً موسعاً لبحث آليات عودة الأهالي من المخيمات، ضمن جهود تحسين الاستقرار والخدمات الأساسية.',
  'An expanded meeting was held in Idlib to discuss mechanisms for residents returning from camps, as part of efforts to improve stability and basic services.',
  'https://alikhbariah.com/wp-content/uploads/2026/04/Idlib-Extensive-meeting-held-to-discuss-the-plan-for-the-return-of-residents-from-the-camps.jpg',
  'https://alikhbariah.com/%d8%a5%d8%af%d9%84%d8%a8-%d8%a7%d8%ac%d8%aa%d9%85%d8%a7%d8%b9-%d9%85%d9%88%d8%b3%d8%b9-%d9%84%d9%85%d9%86%d8%a7%d9%82%d8%b4%d8%a9-%d8%ae%d8%b7%d8%a9-%d8%b9%d9%88%d8%af%d8%a9-%d8%a7%d9%84%d8%a3%d9%87/',
  (select id from public.categories where slug = 'news-local' and type = 'news' limit 1),
  (select id from public.locations where slug = 'idlib' limit 1),
  '2026-04-05T00:45:51Z'::timestamptz,
  false, false, true, 0
where not exists (
  select 1 from public.news n where n.title = 'إدلب.. اجتماع موسع لمناقشة خطة عودة الأهالي من المخيمات'
    or coalesce(to_jsonb(n)->>'source_url','') = 'https://alikhbariah.com/%d8%a5%d8%af%d9%84%d8%a8-%d8%a7%d8%ac%d8%aa%d9%85%d8%a7%d8%b9-%d9%85%d9%88%d8%b3%d8%b9-%d9%84%d9%85%d9%86%d8%a7%d9%82%d8%b4%d8%a9-%d8%ae%d8%b7%d8%a9-%d8%b9%d9%88%d8%af%d8%a9-%d8%a7%d9%84%d8%a3%d9%87/'
);

insert into public.news (
  title, title_en, summary, summary_en, content, content_en,
  image_url, source_url, category_id, location_id, created_at,
  is_hidden, is_featured, sent_notification, view_count
)
select
  'الشيباني يشدد على عمق العلاقات الأخوية مع الإمارات',
  'Al-Shaibani stresses the depth of fraternal relations with the UAE',
  'شدد الوزير الشيباني على متانة العلاقات الأخوية مع دولة الإمارات وأهمية تطوير التعاون المشترك في الملفات ذات الاهتمام.',
  'Minister Al-Shaibani stressed the strength of fraternal ties with the UAE and the importance of advancing cooperation on shared priorities.',
  'شدد الوزير الشيباني على متانة العلاقات الأخوية مع دولة الإمارات وأهمية تطوير التعاون المشترك في الملفات ذات الاهتمام.',
  'Minister Al-Shaibani stressed the strength of fraternal ties with the UAE and the importance of advancing cooperation on shared priorities.',
  'https://alikhbariah.com/wp-content/uploads/2026/04/Al-Shaibani-emphasizes-the-depth-of-fraternal-relations-with-the-UAE.jpg',
  'https://alikhbariah.com/%d8%a7%d9%84%d8%b4%d9%8a%d8%a8%d8%a7%d9%86%d9%8a-%d9%8a%d8%b4%d8%af%d8%af-%d8%b9%d9%84%d9%89-%d8%b9%d9%85%d9%82-%d8%a7%d9%84%d8%b9%d9%84%d8%a7%d9%82%d8%a7%d8%aa-%d8%a7%d9%84%d8%a3%d8%ae%d9%88%d9%8a/',
  (select id from public.categories where slug = 'news-politics' and type = 'news' limit 1),
  (select id from public.locations where slug = 'syria' limit 1),
  '2026-04-05T00:38:36Z'::timestamptz,
  false, false, true, 0
where not exists (
  select 1 from public.news n where n.title = 'الشيباني يشدد على عمق العلاقات الأخوية مع الإمارات'
    or coalesce(to_jsonb(n)->>'source_url','') = 'https://alikhbariah.com/%d8%a7%d9%84%d8%b4%d9%8a%d8%a8%d8%a7%d9%86%d9%8a-%d9%8a%d8%b4%d8%af%d8%af-%d8%b9%d9%84%d9%89-%d8%b9%d9%85%d9%82-%d8%a7%d9%84%d8%b9%d9%84%d8%a7%d9%82%d8%a7%d8%aa-%d8%a7%d9%84%d8%a3%d8%ae%d9%88%d9%8a/'
);

insert into public.news (
  title, title_en, summary, summary_en, content, content_en,
  image_url, source_url, category_id, location_id, created_at,
  is_hidden, is_featured, sent_notification, view_count
)
select
  'وزير الدفاع يشيد بجهود وتضحيات أفواج الهندسة العسكرية في إزالة الألغام',
  'Defense Minister praises military engineering regiments for mine-clearance efforts and sacrifices',
  'أشاد وزير الدفاع بجهود أفواج الهندسة العسكرية في تفكيك الألغام ومخلفات الحرب، مثمناً التضحيات الميدانية لحماية المدنيين.',
  'The Defense Minister praised military engineering regiments for mine-clearance operations and field sacrifices to protect civilians.',
  'أشاد وزير الدفاع بجهود أفواج الهندسة العسكرية في تفكيك الألغام ومخلفات الحرب، مثمناً التضحيات الميدانية لحماية المدنيين.',
  'The Defense Minister praised military engineering regiments for mine-clearance operations and field sacrifices to protect civilians.',
  'https://alikhbariah.com/wp-content/uploads/2026/04/Minister-of-Defense-Major-General-Marhaf-Abu-Qasra.jpg',
  'https://alikhbariah.com/%d9%88%d8%b2%d9%8a%d8%b1-%d8%a7%d9%84%d8%af%d9%81%d8%a7%d8%b9-%d9%8a%d8%b4%d9%8a%d8%af-%d8%a8%d8%ac%d9%87%d9%88%d8%af-%d9%88%d8%aa%d8%b6%d8%ad%d9%8a%d8%a7%d8%aa-%d8%a3%d9%81%d9%88%d8%a7%d8%ac-%d8%a7/',
  (select id from public.categories where slug = 'news-local' and type = 'news' limit 1),
  (select id from public.locations where slug = 'syria' limit 1),
  '2026-04-04T23:30:43Z'::timestamptz,
  false, false, true, 0
where not exists (
  select 1 from public.news n where n.title = 'وزير الدفاع يشيد بجهود وتضحيات أفواج الهندسة العسكرية في إزالة الألغام'
    or coalesce(to_jsonb(n)->>'source_url','') = 'https://alikhbariah.com/%d9%88%d8%b2%d9%8a%d8%b1-%d8%a7%d9%84%d8%af%d9%81%d8%a7%d8%b9-%d9%8a%d8%b4%d9%8a%d8%af-%d8%a8%d8%ac%d9%87%d9%88%d8%af-%d9%88%d8%aa%d8%b6%d8%ad%d9%8a%d8%a7%d8%aa-%d8%a3%d9%81%d9%88%d8%a7%d8%ac-%d8%a7/'
);

insert into public.news (
  title, title_en, summary, summary_en, content, content_en,
  image_url, source_url, category_id, location_id, created_at,
  is_hidden, is_featured, sent_notification, view_count
)
select
  'مراسل الإخبارية: وصول قافلة تُقلّ 200 عائلة من القامشلي إلى عفرين',
  'News correspondent: A convoy carrying 200 families arrived from Qamishli to Afrin',
  'أفاد مراسل الإخبارية بوصول قافلة تقل 200 عائلة من القامشلي إلى عفرين ضمن دفعات العودة المنظمة.',
  'The news correspondent reported the arrival of a convoy carrying 200 families from Qamishli to Afrin as part of organized return convoys.',
  'أفاد مراسل الإخبارية بوصول قافلة تقل 200 عائلة من القامشلي إلى عفرين ضمن دفعات العودة المنظمة.',
  'The news correspondent reported the arrival of a convoy carrying 200 families from Qamishli to Afrin as part of organized return convoys.',
  'https://alikhbariah.com/wp-content/uploads/2026/04/News-correspondent-A-convoy-carrying-200-families-from-Qamishli-has-arrived-in-Afrin.jpg',
  'https://alikhbariah.com/%d9%85%d8%b1%d8%a7%d8%b3%d9%84-%d8%a7%d9%84%d8%a5%d8%ae%d8%a8%d8%a7%d8%b1%d9%8a%d8%a9-%d9%88%d8%b5%d9%88%d9%84-%d9%82%d8%a7%d9%81%d9%84%d8%a9-%d8%aa%d9%8f%d9%82%d9%84%d9%91-200-%d8%b9%d8%a7%d8%a6/',
  (select id from public.categories where slug = 'news-local' and type = 'news' limit 1),
  (select id from public.locations where slug = 'syria' limit 1),
  '2026-04-04T23:21:29Z'::timestamptz,
  false, false, true, 0
where not exists (
  select 1 from public.news n where n.title = 'مراسل الإخبارية: وصول قافلة تُقلّ 200 عائلة من القامشلي إلى عفرين'
    or coalesce(to_jsonb(n)->>'source_url','') = 'https://alikhbariah.com/%d9%85%d8%b1%d8%a7%d8%b3%d9%84-%d8%a7%d9%84%d8%a5%d8%ae%d8%a8%d8%a7%d8%b1%d9%8a%d8%a9-%d9%88%d8%b5%d9%88%d9%84-%d9%82%d8%a7%d9%81%d9%84%d8%a9-%d8%aa%d9%8f%d9%82%d9%84%d9%91-200-%d8%b9%d8%a7%d8%a6/'
);

insert into public.news (
  title, title_en, summary, summary_en, content, content_en,
  image_url, source_url, category_id, location_id, created_at,
  is_hidden, is_featured, sent_notification, view_count
)
select
  'هيئة المنافذ والجمارك تعلن إيقاف حركة العبور عبر منفذ جديدة يابوس مؤقتاً',
  'Ports and Customs Authority announces temporary suspension of crossing movement through Jdeidet Yabous border crossing',
  'أعلنت هيئة المنافذ والجمارك تعليق حركة العبور عبر منفذ جديدة يابوس بشكل مؤقت، لحين استكمال الإجراءات التنظيمية والفنية.',
  'The Ports and Customs Authority announced a temporary suspension of crossing movement through Jdeidet Yabous border crossing pending completion of regulatory and technical procedures.',
  'أعلنت هيئة المنافذ والجمارك تعليق حركة العبور عبر منفذ جديدة يابوس بشكل مؤقت، لحين استكمال الإجراءات التنظيمية والفنية.',
  'The Ports and Customs Authority announced a temporary suspension of crossing movement through Jdeidet Yabous border crossing pending completion of regulatory and technical procedures.',
  'https://alikhbariah.com/wp-content/uploads/2026/04/The-Ports-and-Customs-Authority-announces-the-temporary-suspension-of-traffic-through-the-New-Yabous-border-crossing.-2.jpg',
  'https://alikhbariah.com/%d9%87%d9%8a%d8%a6%d8%a9-%d8%a7%d9%84%d9%85%d9%86%d8%a7%d9%81%d8%b0-%d9%88%d8%a7%d9%84%d8%ac%d9%85%d8%a7%d8%b1%d9%83-%d8%aa%d8%b9%d9%84%d9%86-%d8%a5%d9%8a%d9%82%d8%a7%d9%81-%d8%ad%d8%b1%d9%83%d8%a9-2/',
  (select id from public.categories where slug = 'news-politics' and type = 'news' limit 1),
  (select id from public.locations where slug = 'syria' limit 1),
  '2026-04-04T22:33:27Z'::timestamptz,
  false, false, true, 0
where not exists (
  select 1 from public.news n where n.title = 'هيئة المنافذ والجمارك تعلن إيقاف حركة العبور عبر منفذ جديدة يابوس مؤقتاً'
    or coalesce(to_jsonb(n)->>'source_url','') = 'https://alikhbariah.com/%d9%87%d9%8a%d8%a6%d8%a9-%d8%a7%d9%84%d9%85%d9%86%d8%a7%d9%81%d8%b0-%d9%88%d8%a7%d9%84%d8%ac%d9%85%d8%a7%d8%b1%d9%83-%d8%aa%d8%b9%d9%84%d9%86-%d8%a5%d9%8a%d9%82%d8%a7%d9%81-%d8%ad%d8%b1%d9%83%d8%a9-2/'
);

insert into public.news (
  title, title_en, summary, summary_en, content, content_en,
  image_url, source_url, category_id, location_id, created_at,
  is_hidden, is_featured, sent_notification, view_count
)
select
  'الشبكة السورية تكشف حصيلة ضحايا الألغام والذخائر العنقودية منذ 2011',
  'The Syrian Network reveals mine and cluster-munition victims toll since 2011',
  'كشفت الشبكة السورية تقريراً محدثاً حول حصيلة ضحايا الألغام والذخائر العنقودية منذ عام 2011، مع دعوات لتعزيز جهود الحماية.',
  'The Syrian Network released an updated report on victims of mines and cluster munitions since 2011, with calls to strengthen protection efforts.',
  'كشفت الشبكة السورية تقريراً محدثاً حول حصيلة ضحايا الألغام والذخائر العنقودية منذ عام 2011، مع دعوات لتعزيز جهود الحماية.',
  'The Syrian Network released an updated report on victims of mines and cluster munitions since 2011, with calls to strengthen protection efforts.',
  'https://alikhbariah.com/wp-content/uploads/2026/02/Mining.jpg',
  'https://alikhbariah.com/%d8%a7%d9%84%d8%b4%d8%a8%d9%83%d8%a9-%d8%a7%d9%84%d8%b3%d9%88%d8%b1%d9%8a%d8%a9-%d8%aa%d9%83%d8%b4%d9%81-%d8%ad%d8%b5%d9%8a%d9%84%d8%a9-%d8%b6%d8%ad%d8%a7%d9%8a%d8%a7-%d8%a7%d9%84%d8%a3%d9%84%d8%ba/',
  (select id from public.categories where slug = 'news-local' and type = 'news' limit 1),
  (select id from public.locations where slug = 'syria' limit 1),
  '2026-04-04T21:14:19Z'::timestamptz,
  false, false, true, 0
where not exists (
  select 1 from public.news n where n.title = 'الشبكة السورية تكشف حصيلة ضحايا الألغام والذخائر العنقودية منذ 2011'
    or coalesce(to_jsonb(n)->>'source_url','') = 'https://alikhbariah.com/%d8%a7%d9%84%d8%b4%d8%a8%d9%83%d8%a9-%d8%a7%d9%84%d8%b3%d9%88%d8%b1%d9%8a%d8%a9-%d8%aa%d9%83%d8%b4%d9%81-%d8%ad%d8%b5%d9%8a%d9%84%d8%a9-%d8%b6%d8%ad%d8%a7%d9%8a%d8%a7-%d8%a7%d9%84%d8%a3%d9%84%d8%ba/'
);

insert into public.news (
  title, title_en, summary, summary_en, content, content_en,
  image_url, source_url, category_id, location_id, created_at,
  is_hidden, is_featured, sent_notification, view_count
)
select
  'وزارة الدفاع تعلن استشهاد عنصرين بانفجار مخلفات حربية في إدلب',
  'Ministry of Defense announces martyrdom of two personnel in a war-remnants explosion in Idlib',
  'أعلنت وزارة الدفاع استشهاد عنصرين نتيجة انفجار مخلفات حربية في ريف إدلب، مع متابعة الإجراءات الميدانية ذات الصلة.',
  'The Ministry of Defense announced the martyrdom of two personnel after a war-remnants explosion in Idlib countryside and said field procedures are underway.',
  'أعلنت وزارة الدفاع استشهاد عنصرين نتيجة انفجار مخلفات حربية في ريف إدلب، مع متابعة الإجراءات الميدانية ذات الصلة.',
  'The Ministry of Defense announced the martyrdom of two personnel after a war-remnants explosion in Idlib countryside and said field procedures are underway.',
  'https://alikhbariah.com/wp-content/uploads/2026/03/Ministry-of-Defense-to-Al-Ikhbariya-Two-soldiers-martyred-on-the-Aleppo-Al-Bab-highway.jpg',
  'https://alikhbariah.com/%d9%88%d8%b2%d8%a7%d8%b1%d8%a9-%d8%a7%d9%84%d8%af%d9%81%d8%a7%d8%b9-%d8%aa%d8%b9%d9%84%d9%86-%d8%a7%d8%b3%d8%aa%d8%b4%d9%87%d8%a7%d8%af-%d8%b9%d9%86%d8%b5%d8%b1%d9%8a%d9%86-%d8%a8%d8%a7%d9%86%d9%81/',
  (select id from public.categories where slug = 'news-local' and type = 'news' limit 1),
  (select id from public.locations where slug = 'idlib' limit 1),
  '2026-04-04T19:24:15Z'::timestamptz,
  false, false, true, 0
where not exists (
  select 1 from public.news n where n.title = 'وزارة الدفاع تعلن استشهاد عنصرين بانفجار مخلفات حربية في إدلب'
    or coalesce(to_jsonb(n)->>'source_url','') = 'https://alikhbariah.com/%d9%88%d8%b2%d8%a7%d8%b1%d8%a9-%d8%a7%d9%84%d8%af%d9%81%d8%a7%d8%b9-%d8%aa%d8%b9%d9%84%d9%86-%d8%a7%d8%b3%d8%aa%d8%b4%d9%87%d8%a7%d8%af-%d8%b9%d9%86%d8%b5%d8%b1%d9%8a%d9%86-%d8%a8%d8%a7%d9%86%d9%81/'
);

insert into public.news (
  title, title_en, summary, summary_en, content, content_en,
  image_url, source_url, category_id, location_id, created_at,
  is_hidden, is_featured, sent_notification, view_count
)
select
  'إصابات في صفوف الجيش العربي السوري بانفجار مخلفات حرب بريف إدلب',
  'Injuries among Syrian Arab Army personnel in a war-remnants explosion in Idlib countryside',
  'أفادت مصادر محلية بوقوع إصابات في صفوف الجيش العربي السوري نتيجة انفجار مخلفات حرب في ريف إدلب.',
  'Local sources reported injuries among Syrian Arab Army personnel after a war-remnants explosion in Idlib countryside.',
  'أفادت مصادر محلية بوقوع إصابات في صفوف الجيش العربي السوري نتيجة انفجار مخلفات حرب في ريف إدلب.',
  'Local sources reported injuries among Syrian Arab Army personnel after a war-remnants explosion in Idlib countryside.',
  'https://alikhbariah.com/wp-content/uploads/2026/03/mines.jpg',
  'https://alikhbariah.com/%d8%a5%d8%b5%d8%a7%d8%a8%d8%a7%d8%aa-%d9%81%d9%8a-%d8%b5%d9%81%d9%88%d9%81-%d8%a7%d9%84%d8%ac%d9%8a%d8%b4-%d8%a7%d9%84%d8%b9%d8%b1%d8%a8%d9%8a-%d8%a7%d9%84%d8%b3%d9%88%d8%b1%d9%8a-%d8%a8%d8%a7%d9%86/',
  (select id from public.categories where slug = 'news-local' and type = 'news' limit 1),
  (select id from public.locations where slug = 'idlib' limit 1),
  '2026-04-04T18:30:59Z'::timestamptz,
  false, false, true, 0
where not exists (
  select 1 from public.news n where n.title = 'إصابات في صفوف الجيش العربي السوري بانفجار مخلفات حرب بريف إدلب'
    or coalesce(to_jsonb(n)->>'source_url','') = 'https://alikhbariah.com/%d8%a5%d8%b5%d8%a7%d8%a8%d8%a7%d8%aa-%d9%81%d9%8a-%d8%b5%d9%81%d9%88%d9%81-%d8%a7%d9%84%d8%ac%d9%8a%d8%b4-%d8%a7%d9%84%d8%b9%d8%b1%d8%a8%d9%8a-%d8%a7%d9%84%d8%b3%d9%88%d8%b1%d9%8a-%d8%a8%d8%a7%d9%86/'
);

commit;

-- Quick check
-- select count(*) from public.news;