-- Clean media model: playlists are categories
-- program playlists => categories.type = 'program'
-- news video playlists => categories.type = 'video'
-- videos always linked by category_id

begin;

truncate table public.videos restart identity cascade;
truncate table public.categories restart identity cascade;

-- News categories (optional for dashboard completeness)
insert into public.categories (name, name_en, slug, order_index, type)
values
  ('سياسة', 'Politics', 'news-politics', 1, 'news'),
  ('اقتصاد', 'Economy', 'news-economy', 2, 'news');

-- Playlists for news videos
insert into public.categories (name, name_en, slug, cover_image_url, order_index, type)
values
  ('أخبار العالم', 'World News', 'video-world-news', 'https://images.unsplash.com/photo-1504711434969-e33886168f5c', 1, 'video'),
  ('تكنولوجيا', 'Technology', 'video-technology', 'https://images.unsplash.com/photo-1518770660439-4636190af475', 2, 'video'),
  ('رياضة', 'Sports', 'video-sports', 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211', 3, 'video');

-- Playlists for programs
insert into public.categories (name, name_en, slug, cover_image_url, order_index, type)
values
  ('نشرة التاسعة', 'Nine Oclock Bulletin', 'program-nine-bulletin', 'https://images.unsplash.com/photo-1495020689067-958852a7765e', 1, 'program'),
  ('عين على الاقتصاد', 'Eye on Economy', 'program-eye-on-economy', 'https://images.unsplash.com/photo-1611974714024-4607a55d4001', 2, 'program'),
  ('المسافة الصفر', 'Zero Distance', 'program-zero-distance', 'https://images.unsplash.com/photo-1557804506-669a67965ba0', 3, 'program');

-- Videos inside news-video playlists (type=video)
insert into public.videos (
  title,
  title_en,
  youtube_url,
  category_id,
  thumbnail_url,
  order_index,
  published_at,
  is_hidden
)
values
  (
    'أزمة الطاقة في أوروبا',
    'Europe Energy Crisis',
    'https://www.youtube.com/watch?v=aqz-KE-bpKQ',
    (select id from public.categories where slug = 'video-world-news' limit 1),
    'https://img.youtube.com/vi/aqz-KE-bpKQ/maxresdefault.jpg',
    1,
    now() - interval '2 hours',
    false
  ),
  (
    'هل الذكاء الاصطناعي يغير الإعلام؟',
    'Is AI Changing Media?',
    'https://www.youtube.com/watch?v=5p248yoa3oE',
    (select id from public.categories where slug = 'video-technology' limit 1),
    'https://img.youtube.com/vi/5p248yoa3oE/maxresdefault.jpg',
    1,
    now() - interval '90 minutes',
    false
  ),
  (
    'تحليل الجولة الرياضية',
    'Sports Round Analysis',
    'https://www.youtube.com/watch?v=0_fL68-C8uA',
    (select id from public.categories where slug = 'video-sports' limit 1),
    'https://img.youtube.com/vi/0_fL68-C8uA/maxresdefault.jpg',
    1,
    now() - interval '70 minutes',
    false
  );

-- Episodes inside program playlists (type=program)
insert into public.videos (
  title,
  title_en,
  youtube_url,
  category_id,
  thumbnail_url,
  order_index,
  published_at,
  is_hidden
)
values
  (
    'نشرة التاسعة | أهم أحداث اليوم',
    'Nine Oclock Bulletin | Top Stories',
    'https://www.youtube.com/watch?v=M7X_H-oUo2k',
    (select id from public.categories where slug = 'program-nine-bulletin' limit 1),
    'https://img.youtube.com/vi/M7X_H-oUo2k/maxresdefault.jpg',
    1,
    now() - interval '60 minutes',
    false
  ),
  (
    'عين على الاقتصاد | أسعار النفط',
    'Eye on Economy | Oil Prices',
    'https://www.youtube.com/watch?v=sdZ9W1qwYrE',
    (select id from public.categories where slug = 'program-eye-on-economy' limit 1),
    'https://img.youtube.com/vi/sdZ9W1qwYrE/maxresdefault.jpg',
    1,
    now() - interval '45 minutes',
    false
  ),
  (
    'المسافة الصفر | تحقيق خاص',
    'Zero Distance | Special Investigation',
    'https://www.youtube.com/watch?v=40x0fUqhgro',
    (select id from public.categories where slug = 'program-zero-distance' limit 1),
    'https://img.youtube.com/vi/40x0fUqhgro/maxresdefault.jpg',
    1,
    now() - interval '30 minutes',
    false
  );

commit;
