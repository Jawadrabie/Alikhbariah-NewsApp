import argparse
import json
import os
from pathlib import Path
from typing import Any
from urllib import error, parse, request


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


def supabase_request(
    base_url: str,
    service_key: str,
    method: str,
    endpoint: str,
    query: str = "",
    payload: Any = None,
) -> Any:
    url = f"{base_url.rstrip('/')}/{endpoint.lstrip('/')}"
    if query:
        url = f"{url}?{query}"

    headers = {
        "apikey": service_key,
        "Authorization": f"Bearer {service_key}",
        "Content-Type": "application/json",
        "Accept": "application/json",
    }

    body = None
    if payload is not None:
        body = json.dumps(payload).encode("utf-8")

    req = request.Request(url=url, data=body, method=method.upper(), headers=headers)
    try:
        with request.urlopen(req) as resp:
            raw = resp.read().decode("utf-8")
            if not raw:
                return {"status": resp.status, "ok": True}
            try:
                return json.loads(raw)
            except json.JSONDecodeError:
                return {"status": resp.status, "text": raw}
    except error.HTTPError as http_err:
        raw_err = http_err.read().decode("utf-8")
        try:
            details = json.loads(raw_err)
        except json.JSONDecodeError:
            details = {"message": raw_err}
        return {
            "ok": False,
            "status": http_err.code,
            "error": details,
        }


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Supabase admin helper via REST API")
    parser.add_argument("command", choices=["health", "select", "insert", "update", "delete"])
    parser.add_argument("--table", help="Table name for select/insert/update/delete")
    parser.add_argument("--limit", type=int, default=10, help="Used with select")
    parser.add_argument(
        "--filter",
        default="",
        help="Raw PostgREST filter, ex: id=eq.1&status=eq.published",
    )
    parser.add_argument(
        "--data",
        default="",
        help="JSON payload for insert/update. Example: '{\"title\":\"hello\"}'",
    )
    return parser


def main() -> None:
    project_root = Path(__file__).resolve().parents[1]
    load_env_file(project_root / ".env")

    base_url = os.environ.get("SUPABASE_URL", "").strip()
    service_key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY", "").strip()

    if not base_url or not service_key:
        raise SystemExit("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY in .env")

    args = build_parser().parse_args()

    if args.command == "health":
        result = supabase_request(
            base_url=base_url,
            service_key=service_key,
            method="GET",
            endpoint="rest/v1/",
            query=parse.urlencode({"select": "*"}),
        )
        print(json.dumps(result, ensure_ascii=False, indent=2))
        return

    if not args.table:
        raise SystemExit("--table is required for select/insert/update/delete")

    endpoint = f"rest/v1/{args.table}"

    if args.command == "select":
        query_parts = [f"select=*", f"limit={args.limit}"]
        if args.filter:
            query_parts.append(args.filter)
        result = supabase_request(base_url, service_key, "GET", endpoint, "&".join(query_parts))
        print(json.dumps(result, ensure_ascii=False, indent=2))
        return

    payload = None
    if args.command in {"insert", "update"}:
        if not args.data:
            raise SystemExit("--data is required for insert/update")
        payload = json.loads(args.data)

    if args.command == "insert":
        result = supabase_request(base_url, service_key, "POST", endpoint, "", payload)
    elif args.command == "update":
        result = supabase_request(base_url, service_key, "PATCH", endpoint, args.filter, payload)
    else:
        result = supabase_request(base_url, service_key, "DELETE", endpoint, args.filter)

    print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
