from pathlib import Path
import psycopg


def load_env(path: Path) -> dict[str, str]:
    result: dict[str, str] = {}
    for line in path.read_text(encoding='utf-8').splitlines():
        text = line.strip()
        if not text or text.startswith('#') or '=' not in text:
            continue
        key, value = text.split('=', 1)
        result[key.strip()] = value.strip().strip('"').strip("'")
    return result


def main() -> None:
    env = load_env(Path('.env'))
    supabase_url = env.get('SUPABASE_URL', '')
    db_password = env.get('SUPABASE_DB_PASSWORD', '')
    if not supabase_url or not db_password:
        print('MISSING_ENV')
        return

    ref = supabase_url.replace('https://', '').split('.')[0]

    regions = [
        'us-east-1',
        'us-west-1',
        'us-west-2',
        'eu-west-1',
        'eu-west-2',
        'eu-central-1',
        'ap-southeast-1',
        'ap-southeast-2',
        'ap-northeast-1',
        'sa-east-1',
    ]

    hosts = [f'db.{ref}.supabase.co'] + [f'aws-0-{r}.pooler.supabase.com' for r in regions]
    users = ['postgres', f'postgres.{ref}']

    for host in hosts:
        for user in users:
            conninfo = (
                f'postgresql://{user}:{db_password}@{host}:5432/postgres'
                f'?sslmode=require&connect_timeout=3'
            )
            try:
                with psycopg.connect(conninfo) as conn:
                    with conn.cursor() as cur:
                        cur.execute('select 1')
                print(f'OK {host} {user}')
                return
            except Exception:
                continue

    print('NO_DB_HOST_FOUND')


if __name__ == '__main__':
    main()
