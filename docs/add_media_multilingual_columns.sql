-- Add bilingual columns for media + breaking content managed from dashboard
-- Run this once in Supabase SQL Editor

begin;

alter table public.breaking_news
  add column if not exists title_en text,
  add column if not exists content_en text;

alter table public.videos
  add column if not exists title_en text;

alter table public.live_stream
  add column if not exists broadcast_title_en text,
  add column if not exists fallback_message_en text;

alter table public.programs
  add column if not exists name_en text,
  add column if not exists description_en text;

commit;
