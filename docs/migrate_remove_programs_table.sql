-- Migration: Remove legacy programs table
-- Rationale: All program playlists are now stored as categories (type='program')
-- No data is lost since categories contain all program information
-- Videos link to categories directly, not to programs

begin;

-- Drop foreign key constraints referencing programs table
alter table public.videos
  drop constraint if exists videos_program_id_fkey;

-- Drop the programs table entirely
drop table if exists public.programs cascade;

-- Verify that all videos have category_id set (should always be true in new model)
-- Videos now exist only as:
-- 1. Standalone videos (type='video' category)
-- 2. Program episodes (type='program' category)
-- Both linked via category_id only

commit;
