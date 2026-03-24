-- Optional helper to quickly copy Arabic into English columns for old records
-- Use this only as a temporary bootstrap, then edit values manually in dashboard.

begin;

update public.news
set
  title_en = coalesce(nullif(title_en, ''), title),
  content_en = coalesce(nullif(content_en, ''), content)
where coalesce(nullif(title_en, ''), '') = ''
   or coalesce(nullif(content_en, ''), '') = '';

update public.categories
set name_en = coalesce(nullif(name_en, ''), name)
where coalesce(nullif(name_en, ''), '') = '';

commit;
