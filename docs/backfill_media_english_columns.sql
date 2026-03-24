-- Optional bootstrap for old media/breaking records
-- Copies Arabic values into English columns when English is empty.

begin;

update public.breaking_news
set
  title_en = coalesce(nullif(title_en, ''), title),
  content_en = coalesce(nullif(content_en, ''), content)
where coalesce(nullif(title_en, ''), '') = ''
   or coalesce(nullif(content_en, ''), '') = '';

update public.videos
set title_en = coalesce(nullif(title_en, ''), title)
where coalesce(nullif(title_en, ''), '') = '';

update public.live_stream
set
  broadcast_title_en = coalesce(nullif(broadcast_title_en, ''), broadcast_title),
  fallback_message_en = coalesce(nullif(fallback_message_en, ''), fallback_message)
where coalesce(nullif(broadcast_title_en, ''), '') = ''
   or coalesce(nullif(fallback_message_en, ''), '') = '';

update public.programs
set
  name_en = coalesce(nullif(name_en, ''), name),
  description_en = coalesce(nullif(description_en, ''), description)
where coalesce(nullif(name_en, ''), '') = ''
   or coalesce(nullif(description_en, ''), '') = '';

commit;
