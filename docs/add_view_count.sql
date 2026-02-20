-- Migration: add view_count to news (safe, idempotent)
-- Run this in Supabase SQL Editor after fix_rls_recursion.sql

begin;

-- Add column if not exists (Postgres doesn't have IF NOT EXISTS for add column,
-- so we check with a DO block)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'news'
          AND column_name = 'view_count'
    ) THEN
        ALTER TABLE public.news
        ADD COLUMN view_count integer NOT NULL DEFAULT 0;
    END IF;
END$$;

commit;