-- Migration: add cover image URL for video/program category lists
-- Run in Supabase SQL Editor

begin;

alter table public.categories
  add column if not exists cover_image_url text;

commit;
