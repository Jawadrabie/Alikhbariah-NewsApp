-- One-time migration: add view_count for news and breaking_news
-- and create RPCs to increment counts safely under RLS.

-- 1) Ensure view_count columns exist
alter table if exists public.news
  add column if not exists view_count integer not null default 0;

alter table if exists public.breaking_news
  add column if not exists view_count integer not null default 0;

-- 2) Optional indexes for sorting/filtering by views
create index if not exists idx_news_view_count
  on public.news(view_count desc);

create index if not exists idx_breaking_news_view_count
  on public.breaking_news(view_count desc);

-- 3) RPC: increment news views
create or replace function public.increment_news_view_count(p_news_id bigint)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.news
  set view_count = coalesce(view_count, 0) + 1
  where id = p_news_id
    and is_hidden = false;
end;
$$;

-- 4) RPC: increment breaking news views
create or replace function public.increment_breaking_news_view_count(
  p_breaking_news_id bigint
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.breaking_news
  set view_count = coalesce(view_count, 0) + 1
  where id = p_breaking_news_id;
end;
$$;

-- 5) Allow app clients to call RPCs
grant execute on function public.increment_news_view_count(bigint)
  to anon, authenticated;

grant execute on function public.increment_breaking_news_view_count(bigint)
  to anon, authenticated;
