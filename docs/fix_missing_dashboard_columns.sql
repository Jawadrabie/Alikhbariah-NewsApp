-- Fix missing columns for dashboard features(23-02-2026)

-- 1. Fix `live_stream` missing `fallback_message`
ALTER TABLE public.live_stream
ADD COLUMN IF NOT EXISTS fallback_message text NULL;

-- 2. Force schema cache reload (for PostgREST)
NOTIFY pgrst, 'reload schema';
