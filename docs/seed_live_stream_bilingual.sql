-- Live stream seed for Alikhbariah bilingual app
-- Run in Supabase SQL Editor.
-- Replace the YouTube URL with the actual live stream link if needed.

begin;

alter table if exists public.live_stream
  add column if not exists broadcast_title_en text,
  add column if not exists fallback_message_en text;

delete from public.live_stream;

insert into public.live_stream (
  broadcast_title,
  broadcast_title_en,
  youtube_url,
  fallback_message,
  fallback_message_en,
  is_active
)
values (
  'البث المباشر - الإخبارية السورية',
  'Live Broadcast - Alikhbariah',
  'https://www.youtube.com/watch?v=REPLACE_ME_WITH_LIVE_STREAM_ID',
  'البث المباشر غير متاح حالياً، يرجى المحاولة لاحقاً.',
  'The live broadcast is currently unavailable. Please try again later.',
  true
);

commit;
