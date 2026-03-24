import json
import os
from pathlib import Path
from urllib import parse, request


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


def api_request(base_url: str, service_key: str, method: str, endpoint: str, query: str = "", payload=None, extra_headers=None):
    url = f"{base_url.rstrip('/')}/{endpoint.lstrip('/')}"
    if query:
        url = f"{url}?{query}"

    headers = {
        "apikey": service_key,
        "Authorization": f"Bearer {service_key}",
        "Content-Type": "application/json",
        "Accept": "application/json",
    }
    if extra_headers:
        headers.update(extra_headers)

    body = None
    if payload is not None:
        body = json.dumps(payload, ensure_ascii=False).encode("utf-8")

    req = request.Request(url=url, method=method.upper(), data=body, headers=headers)
    with request.urlopen(req) as resp:
        raw = resp.read().decode("utf-8")
        if not raw:
            return None
        return json.loads(raw)


def select_rows(base_url: str, service_key: str, table: str, filters: str = "", select_fields: str = "*"):
    parts = [f"select={parse.quote(select_fields, safe=',*')}"]
    if filters:
        parts.append(filters)
    return api_request(base_url, service_key, "GET", f"rest/v1/{table}", "&".join(parts)) or []


def main() -> None:
    project_root = Path(__file__).resolve().parents[1]
    load_env_file(project_root / ".env")

    base_url = os.environ.get("SUPABASE_URL", "").strip()
    service_key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY", "").strip()
    if not base_url or not service_key:
        raise SystemExit("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY")

    categories_seed = [
        {"name": "نشرات الأخبار", "slug": "video-bulletins", "order_index": 1, "type": "video"},
        {"name": "تقارير إخبارية", "slug": "video-reports", "order_index": 2, "type": "video"},
        {"name": "مؤتمر صحفي", "slug": "video-press-conference", "order_index": 3, "type": "video"},
        {"name": "متداول", "slug": "video-trending", "order_index": 4, "type": "video"},
        {"name": "تغطيات", "slug": "video-coverages", "order_index": 5, "type": "video"},
    ]

    api_request(
        base_url,
        service_key,
        "POST",
        "rest/v1/categories",
        "on_conflict=slug",
        categories_seed,
        extra_headers={"Prefer": "resolution=merge-duplicates,return=representation"},
    )

    programs_seed = [
        {"name": "على الطاولة", "description": None, "order_index": 1, "is_active": True},
        {"name": "لقاء خاص", "description": None, "order_index": 2, "is_active": True},
        {"name": "ستوريا", "description": None, "order_index": 3, "is_active": True},
        {"name": "بتوقيت سوريا", "description": None, "order_index": 4, "is_active": True},
        {"name": "إشراقة سورية", "description": None, "order_index": 5, "is_active": True},
    ]

    created_programs = 0
    for program in programs_seed:
        encoded_name = parse.quote(program["name"], safe="")
        exists = select_rows(
            base_url,
            service_key,
            "programs",
            filters=f"name=eq.{encoded_name}&limit=1",
            select_fields="id,name",
        )
        if exists:
            continue
        api_request(base_url, service_key, "POST", "rest/v1/programs", payload=program)
        created_programs += 1

    categories = select_rows(
        base_url,
        service_key,
        "categories",
        filters="type=eq.video",
        select_fields="id,slug,name,type",
    )
    category_by_slug = {item["slug"]: item["id"] for item in categories}

    programs = select_rows(base_url, service_key, "programs", select_fields="id,name")
    program_by_name = {item["name"]: item["id"] for item in programs}

    videos_seed = [
        {
            "title": "نشرة الأخبار الرئيسية - المسائية",
            "youtube_url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            "category_slug": "video-bulletins",
            "program_name": "بتوقيت سوريا",
            "order_index": 1,
        },
        {
            "title": "أبرز تقارير الاقتصاد اليوم",
            "youtube_url": "https://www.youtube.com/watch?v=3JZ_D3ELwOQ",
            "category_slug": "video-reports",
            "program_name": "على الطاولة",
            "order_index": 2,
        },
        {
            "title": "مؤتمر صحفي حول المستجدات",
            "youtube_url": "https://www.youtube.com/watch?v=l482T0yNkeo",
            "category_slug": "video-press-conference",
            "program_name": "لقاء خاص",
            "order_index": 3,
        },
        {
            "title": "المحتوى المتداول هذا الأسبوع",
            "youtube_url": "https://www.youtube.com/watch?v=Zi_XLOBDo_Y",
            "category_slug": "video-trending",
            "program_name": None,
            "order_index": 4,
        },
        {
            "title": "تغطية خاصة من الميدان",
            "youtube_url": "https://www.youtube.com/watch?v=fLexgOxsZu0",
            "category_slug": "video-coverages",
            "program_name": "إشراقة سورية",
            "order_index": 5,
        },
    ]

    created_videos = 0
    for video in videos_seed:
        encoded_title = parse.quote(video["title"], safe="")
        encoded_url = parse.quote(video["youtube_url"], safe="")
        exists = select_rows(
            base_url,
            service_key,
            "videos",
            filters=f"title=eq.{encoded_title}&youtube_url=eq.{encoded_url}&limit=1",
            select_fields="id",
        )
        if exists:
            continue

        category_id = category_by_slug.get(video["category_slug"])
        if category_id is None:
            continue

        payload = {
            "title": video["title"],
            "youtube_url": video["youtube_url"],
            "category_id": category_id,
            "program_id": program_by_name.get(video["program_name"]) if video["program_name"] else None,
            "order_index": video["order_index"],
            "is_hidden": False,
        }
        api_request(base_url, service_key, "POST", "rest/v1/videos", payload=payload)
        created_videos += 1

    print(
        json.dumps(
            {
                "ok": True,
                "created_programs": created_programs,
                "created_videos": created_videos,
                "video_categories_count": len(categories),
            },
            ensure_ascii=False,
            indent=2,
        )
    )


if __name__ == "__main__":
    main()
