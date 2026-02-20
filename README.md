# newsappjs

Flutter news application for **Alikhbariah Syria**.

## Supabase setup (Step 1)

1. Execute database schema from [docs/supabase_init.sql](docs/supabase_init.sql) in Supabase SQL Editor.
2. Create your first admin user in Supabase Auth.
3. Insert the admin user UUID into `public.admin_users`.

```sql
insert into public.admin_users(user_id) values ('PUT_ADMIN_UUID_HERE');
```

## Run app with Supabase (Step 2)

Use one of these options:

- VS Code launch config: [/.vscode/launch.json](.vscode/launch.json)
- CLI:

```bash
flutter run \
	--dart-define=SUPABASE_URL=YOUR_SUPABASE_URL \
	--dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

After launch, press **"اختبر الاتصال الآن"** on the home screen.

## Notes

- `saved_news` is intentionally local-only (no table in Supabase currently).
- Anonymous users can read public content only.
- Dashboard writes are restricted to `authenticated` users listed in `admin_users`.

## FCM Setup (Step 3)

The project requires Firebase Cloud Messaging for "Manual Notifications" and "Breaking News".

1.  Navigate to `supabase/functions/send-fcm`.
2.  Follow `DEPLOY.md` (or `deploy_instructions.md`) to set up the Edge Function.
3.  Add the `FIREBASE_SERVICE_ACCOUNT` secret to your Supabase project.

See full instructions in [supabase/functions/send-fcm/deploy_instructions.md](supabase/functions/send-fcm/deploy_instructions.md).

## Storage Setup (Step 4)

For Dashboard news image uploads, create a Supabase Storage bucket with these settings:

1. Bucket name: `news-images`
2. Public bucket: enabled
3. Restrict file size: enabled, set to **5 MB**

Notes:
- The app also validates image size client-side with a 5 MB limit.
- If a larger image is selected, an inline error appears in the news form.

## Storage Policies (Step 5)

Apply admin-only write/delete policies for `news-images` bucket:

1. Open [docs/storage_policies.sql](docs/storage_policies.sql)
2. Run it in Supabase SQL Editor

What this enforces:
- Upload/Update/Delete on `news-images` is allowed only for `authenticated` users that satisfy `public.is_admin_user()`.
- Optional MIME hardening is applied to allow only: `image/jpeg`, `image/png`, `image/webp`.
