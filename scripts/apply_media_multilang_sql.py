from pathlib import Path
import psycopg


def load_env(path: Path) -> dict[str, str]:
    data: dict[str, str] = {}
    for line in path.read_text(encoding='utf-8').splitlines():
        text = line.strip()
        if not text or text.startswith('#') or '=' not in text:
            continue
        key, value = text.split('=', 1)
        data[key.strip()] = value.strip().strip('"').strip("'")
    return data


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    env = load_env(root / '.env')

    supabase_url = env.get('SUPABASE_URL', '').strip()
    db_password = env.get('SUPABASE_DB_PASSWORD', '').strip()

    if not supabase_url or not db_password:
        raise SystemExit('Missing SUPABASE_URL or SUPABASE_DB_PASSWORD in .env')

    project_ref = supabase_url.replace('https://', '').split('.')[0]
    conninfo = (
        f'postgresql://postgres:{db_password}'
        f'@db.{project_ref}.supabase.co:5432/postgres?sslmode=require'
    )

    add_columns_sql = (root / 'docs' / 'add_media_multilingual_columns.sql').read_text(encoding='utf-8')
    backfill_sql = (root / 'docs' / 'backfill_media_english_columns.sql').read_text(encoding='utf-8')

    with psycopg.connect(conninfo) as conn:
        with conn.cursor() as cursor:
            cursor.execute(add_columns_sql)
            cursor.execute(backfill_sql)

    print('APPLIED_OK')


if __name__ == '__main__':
    main()
