-- Add bilingual columns for manual Arabic/English entry in dashboard
-- Run this once in Supabase SQL Editor

begin;

alter table public.news
  add column if not exists title_en text,
  add column if not exists content_en text;

alter table public.categories
  add column if not exists name_en text;

create index if not exists idx_news_title_en on public.news using gin (to_tsvector('english', coalesce(title_en, '')));
create index if not exists idx_news_content_en on public.news using gin (to_tsvector('english', coalesce(content_en, '')));

commit;
