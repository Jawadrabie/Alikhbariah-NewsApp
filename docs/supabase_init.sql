-- Supabase initial schema for NewsAppJS
-- Generated from docs/alikhbariah_master_plan.md (18-02-2026)

begin;

-- ============
-- Core tables
-- ============

create table if not exists public.categories (
  id bigint generated always as identity primary key,
  name text not null,
  slug text not null unique,
  order_index integer not null default 0,
  parent_id bigint null references public.categories(id) on delete set null
);

create table if not exists public.locations (
  id bigint generated always as identity primary key,
  name text not null,
  slug text not null unique
);

create table if not exists public.programs (
  id bigint generated always as identity primary key,
  name text not null,
  description text null,
  image_url text null,
  order_index integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.news (
  id bigint generated always as identity primary key,
  title text not null,
  content text not null,
  image_url text null,
  category_id bigint null references public.categories(id) on delete set null,
  location_id bigint null references public.locations(id) on delete set null,
  created_at timestamptz not null default now(),
  is_hidden boolean not null default false,
  is_featured boolean not null default false,
  sent_notification boolean not null default true
);

create table if not exists public.manual_notifications_log (
  id bigint generated always as identity primary key,
  title text not null,
  body text not null,
  sent_at timestamptz not null default now(),
  created_by uuid null references auth.users(id) on delete set null,
  view_count integer not null default 0
);

create table if not exists public.breaking_news (
  id bigint generated always as identity primary key,
  title text not null,
  content text not null,
  created_at timestamptz not null default now(),
  start_time timestamptz not null,
  end_time timestamptz not null,
  send_notification boolean not null default true,
  is_active boolean not null default true,
  constraint breaking_news_time_check check (end_time >= start_time)
);

create table if not exists public.live_stream (
  id bigint generated always as identity primary key,
  broadcast_title text null,
  youtube_url text not null,
  fallback_message text null,
  is_active boolean not null default false
);

create table if not exists public.videos (
  id bigint generated always as identity primary key,
  title text not null,
  youtube_url text not null,
  program_id bigint null references public.programs(id) on delete set null,
  category_id bigint null references public.categories(id) on delete set null,
  thumbnail_url text null,
  order_index integer not null default 0,
  published_at timestamptz null,
  created_at timestamptz not null default now(),
  is_hidden boolean not null default false
);

create table if not exists public.user_reports (
  id bigint generated always as identity primary key,
  name text null,
  phone text null,
  message text not null,
  attachment_url text null,
  created_at timestamptz not null default now(),
  is_reviewed boolean not null default false
);

create table if not exists public.app_settings (
  key text primary key,
  value text not null
);

-- Optional helper table to define dashboard admins
create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

-- ============
-- Indexes
-- ============

create index if not exists idx_categories_order on public.categories(order_index);
create index if not exists idx_news_created_at on public.news(created_at desc);
create index if not exists idx_news_category_created on public.news(category_id, created_at desc);
create index if not exists idx_news_featured_created on public.news(is_featured, created_at desc);
create index if not exists idx_breaking_news_time on public.breaking_news(start_time, end_time);
create index if not exists idx_videos_created_at on public.videos(created_at desc);
create index if not exists idx_videos_program_order on public.videos(program_id, order_index);
create index if not exists idx_programs_order_active on public.programs(order_index, is_active);

-- ============
-- RLS helpers
-- ============

create or replace function public.is_admin_user()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.admin_users au
    where au.user_id = auth.uid()
  );
$$;

-- ============
-- Enable RLS
-- ============

alter table public.categories enable row level security;
alter table public.locations enable row level security;
alter table public.news enable row level security;
alter table public.manual_notifications_log enable row level security;
alter table public.breaking_news enable row level security;
alter table public.live_stream enable row level security;
alter table public.videos enable row level security;
alter table public.programs enable row level security;
alter table public.user_reports enable row level security;
alter table public.app_settings enable row level security;
alter table public.admin_users enable row level security;

-- ============
-- Public read policies (mobile app anonymous read)
-- ============

drop policy if exists categories_public_read on public.categories;
create policy categories_public_read on public.categories
for select
to anon, authenticated
using (true);

drop policy if exists locations_public_read on public.locations;
create policy locations_public_read on public.locations
for select
to anon, authenticated
using (true);

drop policy if exists news_public_read on public.news;
create policy news_public_read on public.news
for select
to anon, authenticated
using (is_hidden = false);

drop policy if exists manual_notifications_public_read on public.manual_notifications_log;
create policy manual_notifications_public_read on public.manual_notifications_log
for select
to anon, authenticated
using (true);

drop policy if exists breaking_news_public_read on public.breaking_news;
create policy breaking_news_public_read on public.breaking_news
for select
to anon, authenticated
using (
  is_active = true
  and now() between start_time and end_time
);

drop policy if exists live_stream_public_read on public.live_stream;
create policy live_stream_public_read on public.live_stream
for select
to anon, authenticated
using (is_active = true);

drop policy if exists videos_public_read on public.videos;
create policy videos_public_read on public.videos
for select
to anon, authenticated
using (is_hidden = false);

drop policy if exists programs_public_read on public.programs;
create policy programs_public_read on public.programs
for select
to anon, authenticated
using (is_active = true);

drop policy if exists app_settings_public_read on public.app_settings;
create policy app_settings_public_read on public.app_settings
for select
to anon, authenticated
using (true);

-- User reports: allow public insert only (شاركنا الخبر)
drop policy if exists user_reports_public_insert on public.user_reports;
create policy user_reports_public_insert on public.user_reports
for insert
to anon, authenticated
with check (true);

-- ============
-- Admin write policies (dashboard authenticated admins)
-- ============

drop policy if exists categories_admin_all on public.categories;
create policy categories_admin_all on public.categories
for all
to authenticated
using (public.is_admin_user())
with check (public.is_admin_user());

drop policy if exists locations_admin_all on public.locations;
create policy locations_admin_all on public.locations
for all
to authenticated
using (public.is_admin_user())
with check (public.is_admin_user());

drop policy if exists news_admin_all on public.news;
create policy news_admin_all on public.news
for all
to authenticated
using (public.is_admin_user())
with check (public.is_admin_user());

drop policy if exists manual_notifications_admin_all on public.manual_notifications_log;
create policy manual_notifications_admin_all on public.manual_notifications_log
for all
to authenticated
using (public.is_admin_user())
with check (public.is_admin_user());

drop policy if exists breaking_news_admin_all on public.breaking_news;
create policy breaking_news_admin_all on public.breaking_news
for all
to authenticated
using (public.is_admin_user())
with check (public.is_admin_user());

drop policy if exists live_stream_admin_all on public.live_stream;
create policy live_stream_admin_all on public.live_stream
for all
to authenticated
using (public.is_admin_user())
with check (public.is_admin_user());

drop policy if exists videos_admin_all on public.videos;
create policy videos_admin_all on public.videos
for all
to authenticated
using (public.is_admin_user())
with check (public.is_admin_user());

drop policy if exists programs_admin_all on public.programs;
create policy programs_admin_all on public.programs
for all
to authenticated
using (public.is_admin_user())
with check (public.is_admin_user());

drop policy if exists user_reports_admin_read_update_delete on public.user_reports;
create policy user_reports_admin_read_update_delete on public.user_reports
for select
to authenticated
using (public.is_admin_user());

drop policy if exists user_reports_admin_update on public.user_reports;
create policy user_reports_admin_update on public.user_reports
for update
to authenticated
using (public.is_admin_user())
with check (public.is_admin_user());

drop policy if exists user_reports_admin_delete on public.user_reports;
create policy user_reports_admin_delete on public.user_reports
for delete
to authenticated
using (public.is_admin_user());

drop policy if exists app_settings_admin_all on public.app_settings;
create policy app_settings_admin_all on public.app_settings
for all
to authenticated
using (public.is_admin_user())
with check (public.is_admin_user());

-- admin_users can be managed only by existing admins
-- first admin can be inserted manually in SQL Editor

drop policy if exists admin_users_admin_all on public.admin_users;
drop policy if exists admin_users_self_select on public.admin_users;
create policy admin_users_self_select on public.admin_users
for select
to authenticated
using (user_id = auth.uid());

-- ============
-- Storage policies (news-images bucket)
-- ============

-- Allow public/app users to upload report attachments only under the user-reports folder
drop policy if exists user_reports_attachments_insert on storage.objects;
create policy user_reports_attachments_insert on storage.objects
for insert
to anon, authenticated
with check (
  bucket_id = 'news-images'
  and name like 'user-reports/%'
);

-- Allow authenticated admins only to upload files
drop policy if exists news_images_admin_insert on storage.objects;
create policy news_images_admin_insert on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'news-images'
  and exists (
    select 1
    from public.admin_users au
    where au.user_id = auth.uid()
  )
);

-- Allow authenticated admins only to update files
drop policy if exists news_images_admin_update on storage.objects;
create policy news_images_admin_update on storage.objects
for update
to authenticated
using (
  bucket_id = 'news-images'
  and exists (
    select 1
    from public.admin_users au
    where au.user_id = auth.uid()
  )
)
with check (
  bucket_id = 'news-images'
  and exists (
    select 1
    from public.admin_users au
    where au.user_id = auth.uid()
  )
);

-- Allow authenticated admins only to delete files
drop policy if exists news_images_admin_delete on storage.objects;
create policy news_images_admin_delete on storage.objects
for delete
to authenticated
using (
  bucket_id = 'news-images'
  and exists (
    select 1
    from public.admin_users au
    where au.user_id = auth.uid()
  )
);

commit;

-- ============
-- After running this script:
-- 1) Create your dashboard auth user in Supabase Authentication.
-- 2) Add first admin manually (replace USER_UUID):
--    insert into public.admin_users(user_id) values ('USER_UUID');
-- 3) Insert initial app settings keys if needed.
-- ============
