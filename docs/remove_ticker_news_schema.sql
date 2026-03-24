-- Remove ticker_news feature schema (01-03-2026)
-- Keep breaking_news as the single source for urgent ticker content.

begin;

-- Remove policies first (if they exist)
drop policy if exists ticker_news_public_read on public.ticker_news;
drop policy if exists ticker_news_admin_all on public.ticker_news;

-- Remove index if it exists
drop index if exists public.idx_ticker_news_active;

-- Drop table
drop table if exists public.ticker_news cascade;

-- Reload PostgREST schema cache
notify pgrst, 'reload schema';

commit;
