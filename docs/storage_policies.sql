-- Storage policies for bucket: news-images
-- Run in Supabase SQL Editor after creating the bucket.
-- Important: ensure function public.is_admin_user() is SECURITY DEFINER
-- and admin_users policies do not recursively call public.is_admin_user().

begin;

-- Admin-only upload

drop policy if exists news_images_admin_insert on storage.objects;
create policy news_images_admin_insert on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'news-images'
  and public.is_admin_user()
);

-- Admin-only update

drop policy if exists news_images_admin_update on storage.objects;
create policy news_images_admin_update on storage.objects
for update
to authenticated
using (
  bucket_id = 'news-images'
  and public.is_admin_user()
)
with check (
  bucket_id = 'news-images'
  and public.is_admin_user()
);

-- Admin-only delete

drop policy if exists news_images_admin_delete on storage.objects;
create policy news_images_admin_delete on storage.objects
for delete
to authenticated
using (
  bucket_id = 'news-images'
  and public.is_admin_user()
);

-- Optional hardening: MIME restrictions
update storage.buckets
set allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp']::text[]
where id = 'news-images';

commit;
