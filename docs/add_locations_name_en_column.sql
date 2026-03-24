-- Add optional English name for locations (safe migration)
-- Run in Supabase SQL Editor

begin;

alter table if exists public.locations
  add column if not exists name_en text;

commit;
