-- Remove summary columns from news permanently
-- Run once in Supabase SQL editor

begin;

drop index if exists idx_news_summary_en;

alter table public.news
  drop column if exists summary,
  drop column if exists summary_en;

commit;
