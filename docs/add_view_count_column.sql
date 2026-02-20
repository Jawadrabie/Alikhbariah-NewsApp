-- Add view_count column to public.news (safe migration)
-- Run in Supabase SQL Editor

begin;

alter table if exists public.news
  add column if not exists view_count integer not null default 0;

create index if not exists idx_news_view_count on public.news(view_count desc);

commit;
