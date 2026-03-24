-- Seed breaking news items
-- Safe to run in Supabase SQL Editor

begin;

truncate table public.breaking_news restart identity cascade;

insert into public.breaking_news (
  title,
  content,
  start_time,
  end_time,
  send_notification,
  is_active,
  created_at
)
values
  (
    'عاجل: اجتماع حكومي طارئ الآن',
    'يعقد اجتماع حكومي طارئ لمناقشة المستجدات واتخاذ قرارات عاجلة.',
    now() - interval '10 minutes',
    now() + interval '2 hours',
    true,
    true,
    now() - interval '10 minutes'
  ),
  (
    'عاجل: تحديثات مهمة في السوق',
    'صدرت قبل قليل تحديثات مهمة في حركة السوق والأسعار.',
    now() - interval '25 minutes',
    now() + interval '1 hour 30 minutes',
    true,
    true,
    now() - interval '25 minutes'
  ),
  (
    'عاجل: بيان رسمي جديد',
    'صدر بيان رسمي جديد حول آخر التطورات الميدانية والخدمية.',
    now() - interval '40 minutes',
    now() + interval '3 hours',
    true,
    true,
    now() - interval '40 minutes'
  );

commit;
