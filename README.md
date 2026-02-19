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
