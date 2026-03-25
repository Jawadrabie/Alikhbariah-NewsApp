-- RPC: atomically increment news view_count for public clients
-- Run this in Supabase SQL editor after ensuring news.view_count exists.

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

grant execute on function public.increment_news_view_count(bigint) to anon, authenticated;
