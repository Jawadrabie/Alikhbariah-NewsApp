# newsappjs

Flutter news application for **Alikhbariah Syria**. The project ships as a public news app plus a private dashboard for managing editorial content, media, notifications, and supporting data.

## What The App Does

- Publishes the home feed with featured content, category chips, breaking news, search, and news cards.
- Shows full news details with related stories, share actions, saved/bookmarked items, and HTML content rendering.
- Provides a media area for live stream, programs, videos, and an in-app video player.
- Accepts user reports with optional attachments.
- Includes an admin dashboard for news, breaking news, ticker news, categories, locations, programs, videos, live stream, settings, user reports, and manual notifications.
- Supports Arabic and English UI strings and generated localization files.
- Targets Android, iOS, Web, Windows, macOS, and Linux.

## Main Features

### Public App

- Home screen with featured slider, breaking ticker, category chips, search, and curated sections.
- News detail page with related news, rich content rendering, share, and bookmark support.
- Saved news stored locally on the device.
- Live stream and video playback experiences.
- Program and episode browsing for media content.
- User report submission for audience feedback.
- Splash screen and branded launch assets.

### Admin Dashboard

- Admin login and role-gated access.
- News management with create, edit, publish, and image upload support.
- Breaking news and ticker news management.
- Category and location management.
- Program and video management with category forms and video forms.
- Live stream management.
- Manual notifications.
- Settings and dashboard localization.
- User reports review.

### Platform and Infrastructure

- Supabase for auth, database, and storage.
- Firebase Cloud Messaging for manual notifications and breaking news alerts.
- Supabase Storage upload support for news images.
- Local caching and image helpers for smoother browsing.

## Setup

### 1. Supabase

1. Open [docs/supabase_init.sql](docs/supabase_init.sql) in the Supabase SQL Editor and run the schema setup.
2. Create your first admin user in Supabase Auth.
3. Insert the admin UUID into `public.admin_users`.

```sql
insert into public.admin_users(user_id) values ('PUT_ADMIN_UUID_HERE');
```

### 2. Run The App

Use the VS Code launch configuration in [/.vscode/launch.json](.vscode/launch.json) or run Flutter directly:

```bash
flutter run \
  --dart-define=SUPABASE_URL=YOUR_SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

After launch, open the home screen and press **"اختبر الاتصال الآن"** to verify the backend connection.

### 3. Firebase Cloud Messaging

The project uses FCM for manual notifications and breaking news pushes.

1. Go to `supabase/functions/send-fcm`.
2. Follow [supabase/functions/send-fcm/deploy_instructions.md](supabase/functions/send-fcm/deploy_instructions.md).
3. Add the `FIREBASE_SERVICE_ACCOUNT` secret to your Supabase project.

### 4. Storage

For dashboard news image uploads, create a Supabase Storage bucket with these settings:

1. Bucket name: `news-images`
2. Public bucket: enabled
3. File size limit: 5 MB

The app also validates the image size on the client side. If a selected image is too large, the news form shows an inline error.

## Project Structure

- `lib/features/home` - public home experience and related widgets.
- `lib/features/news` - news details, saved news, and bookmark logic.
- `lib/features/media` - live stream, programs, videos, and player screens.
- `lib/features/user_reports` - report submission flow.
- `lib/features/splash` - splash screen.
- `lib/dashboard` - admin dashboard screens, services, models, and widgets.
- `docs` - Supabase SQL, seed files, and operational scripts.

## Notes

- `saved_news` is intentionally local-only and does not map to a Supabase table.
- Anonymous users can read public content only.
- Dashboard writes are restricted to authenticated users listed in `admin_users`.
- The app is configured for branded launcher icons and platform assets across all supported targets.

## Useful Commands

```bash
flutter analyze
flutter test
flutter run
```

