import argparse
import os
from pathlib import Path
from urllib.parse import urlparse

import psycopg


def load_env_file(env_path: Path) -> None:
    if not env_path.exists():
        return
    for line in env_path.read_text(encoding="utf-8").splitlines():
        text = line.strip()
        if not text or text.startswith("#") or "=" not in text:
            continue
        key, value = text.split("=", 1)
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        if key and key not in os.environ:
            os.environ[key] = value


def resolve_connection_values(project_root: Path) -> tuple[str, str]:
    load_env_file(project_root / ".env")

    supabase_url = os.environ.get("SUPABASE_URL", "").strip()
    db_password = os.environ.get("SUPABASE_DB_PASSWORD", "").strip()

    if not supabase_url:
        raise SystemExit("Missing SUPABASE_URL in environment/.env")
    if not db_password:
        raise SystemExit("Missing SUPABASE_DB_PASSWORD in environment/.env")

    project_ref = urlparse(supabase_url).netloc.split(".")[0]
    if not project_ref:
        raise SystemExit("Could not extract Supabase project ref from SUPABASE_URL")

    db_host = f"db.{project_ref}.supabase.co"
    return db_host, db_password


def apply_sql_file(sql_file: Path, db_host: str, db_password: str) -> None:
    if not sql_file.exists():
        raise SystemExit(f"SQL file not found: {sql_file}")

    sql = sql_file.read_text(encoding="utf-8")
    with psycopg.connect(
        host=db_host,
        port=5432,
        dbname="postgres",
        user="postgres",
        password=db_password,
        sslmode="require",
    ) as connection:
        with connection.cursor() as cursor:
            cursor.execute(sql)
        connection.commit()


def main() -> None:
    parser = argparse.ArgumentParser(description="Apply a SQL file directly to Supabase Postgres")
    parser.add_argument("sql_file", help="Path to SQL file")
    args = parser.parse_args()

    project_root = Path(__file__).resolve().parents[1]
    sql_path = (project_root / args.sql_file).resolve() if not Path(args.sql_file).is_absolute() else Path(args.sql_file)

    db_host, db_password = resolve_connection_values(project_root)
    apply_sql_file(sql_path, db_host, db_password)
    print(f"Applied SQL successfully: {sql_path}")


if __name__ == "__main__":
    main()
