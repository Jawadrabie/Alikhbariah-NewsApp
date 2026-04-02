Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Set-Location (Join-Path $PSScriptRoot '..')

function HtmlToText {
  param([string]$Value)
  if ([string]::IsNullOrWhiteSpace($Value)) { return '' }
  $decoded = [System.Net.WebUtility]::HtmlDecode($Value)
  $stripped = [regex]::Replace($decoded, '<[^>]+>', ' ')
  return ([regex]::Replace($stripped, '\s+', ' ')).Trim()
}

function SqlEscape {
  param([string]$Value)
  if ($null -eq $Value) { return '' }
  return ($Value -replace "'", "''")
}

function Add-Line {
  param(
    [System.Text.StringBuilder]$Builder,
    [string]$Line = ''
  )
  [void]$Builder.AppendLine($Line)
}

$newsCategories = @(
  [pscustomobject]@{ name = 'سياسي'; name_en = 'Politics'; slug = 'news-politics'; wp = 33; order = 1 },
  [pscustomobject]@{ name = 'اقتصاد'; name_en = 'Economy'; slug = 'news-economy'; wp = 8; order = 2 },
  [pscustomobject]@{ name = 'محلي'; name_en = 'Local'; slug = 'news-local'; wp = 32; order = 3 },
  [pscustomobject]@{ name = 'عربي ودولي'; name_en = 'Arab and International'; slug = 'news-arab-international'; wp = 34; order = 4 },
  [pscustomobject]@{ name = 'رياضة'; name_en = 'Sports'; slug = 'news-sports'; wp = 5; order = 5 },
  [pscustomobject]@{ name = 'ثقافة'; name_en = 'Culture'; slug = 'news-culture'; wp = 9; order = 6 },
  [pscustomobject]@{ name = 'صحة'; name_en = 'Health'; slug = 'news-health'; wp = 7; order = 7 }
)

$programCategories = @(
  [pscustomobject]@{ name = 'إشراقة سوريا'; name_en = 'Ishraqa Syria'; slug = 'program-ishraqa-syria'; source = 'إشراقة سوريا'; order = 1 },
  [pscustomobject]@{ name = 'بتوقيت سوريا'; name_en = 'Syria Time'; slug = 'program-syria-time'; source = 'بتوقيت سوريا'; order = 2 },
  [pscustomobject]@{ name = 'ستوريا'; name_en = 'Storia'; slug = 'program-storia'; source = 'ستوريا'; order = 3 },
  [pscustomobject]@{ name = 'على الطاولة'; name_en = 'On The Table'; slug = 'program-on-the-table'; source = 'على الطاولة'; order = 4 },
  [pscustomobject]@{ name = 'لقاء خاص'; name_en = 'Special Interview'; slug = 'program-special-interview'; source = 'لقاء خاص'; order = 5 },
  [pscustomobject]@{ name = 'مؤتمر صحفي'; name_en = 'Press Conference'; slug = 'program-press-conference'; source = 'مؤتمر صحفي'; order = 6 },
  [pscustomobject]@{ name = 'متداول'; name_en = 'Trending'; slug = 'program-trending'; source = 'متداول'; order = 7 }
)

$videoCategories = @(
  [pscustomobject]@{ name = 'نشرات الأخبار'; name_en = 'News Bulletins'; slug = 'video-news-bulletins'; source = 'نشرات الأخبار'; order = 1 },
  [pscustomobject]@{ name = 'إشراقة سوريا | مقاطع'; name_en = 'Ishraqa Syria Clips'; slug = 'video-ishraqa-clips'; source = 'إشراقة سوريا'; order = 2 },
  [pscustomobject]@{ name = 'بتوقيت سوريا | مقاطع'; name_en = 'Syria Time Clips'; slug = 'video-syria-time-clips'; source = 'بتوقيت سوريا'; order = 3 },
  [pscustomobject]@{ name = 'ستوريا | مقاطع'; name_en = 'Storia Clips'; slug = 'video-storia-clips'; source = 'ستوريا'; order = 4 },
  [pscustomobject]@{ name = 'على الطاولة | مقاطع'; name_en = 'On The Table Clips'; slug = 'video-on-the-table-clips'; source = 'على الطاولة'; order = 5 },
  [pscustomobject]@{ name = 'لقاء خاص | مقاطع'; name_en = 'Special Interview Clips'; slug = 'video-special-interview-clips'; source = 'لقاء خاص'; order = 6 },
  [pscustomobject]@{ name = 'مؤتمر صحفي | مقاطع'; name_en = 'Press Conference Clips'; slug = 'video-press-conference-clips'; source = 'مؤتمر صحفي'; order = 7 }
)

$locations = @(
  [pscustomobject]@{ name = 'دمشق'; name_en = 'Damascus'; slug = 'damascus' },
  [pscustomobject]@{ name = 'ريف دمشق'; name_en = 'Rif Dimashq'; slug = 'rif-dimashq' },
  [pscustomobject]@{ name = 'حلب'; name_en = 'Aleppo'; slug = 'aleppo' },
  [pscustomobject]@{ name = 'حمص'; name_en = 'Homs'; slug = 'homs' },
  [pscustomobject]@{ name = 'حماة'; name_en = 'Hama'; slug = 'hama' },
  [pscustomobject]@{ name = 'اللاذقية'; name_en = 'Latakia'; slug = 'latakia' },
  [pscustomobject]@{ name = 'طرطوس'; name_en = 'Tartus'; slug = 'tartus' },
  [pscustomobject]@{ name = 'إدلب'; name_en = 'Idlib'; slug = 'idlib' },
  [pscustomobject]@{ name = 'الرقة'; name_en = 'Raqqa'; slug = 'raqqa' },
  [pscustomobject]@{ name = 'دير الزور'; name_en = 'Deir ez-Zor'; slug = 'deir-ez-zor' },
  [pscustomobject]@{ name = 'الحسكة'; name_en = 'Al-Hasakah'; slug = 'al-hasakah' },
  [pscustomobject]@{ name = 'درعا'; name_en = 'Daraa'; slug = 'daraa' },
  [pscustomobject]@{ name = 'السويداء'; name_en = 'As-Suwayda'; slug = 'as-suwayda' },
  [pscustomobject]@{ name = 'القنيطرة'; name_en = 'Quneitra'; slug = 'quneitra' }
)

$allPosts = @()
$usedPostIds = New-Object 'System.Collections.Generic.HashSet[int]'
$globalPostOrdinal = 0

foreach ($cat in $newsCategories) {
  $catRows = @()
  $page = 1
  while ($catRows.Count -lt 10 -and $page -le 15) {
    $uri = "https://alikhbariah.com/wp-json/wp/v2/posts?categories=$($cat.wp)&per_page=20&page=$page&_embed=1"
    try {
      $posts = Invoke-RestMethod -Uri $uri -TimeoutSec 90
    } catch {
      break
    }

    if (-not $posts) {
      break
    }

    foreach ($post in $posts) {
      if ($catRows.Count -ge 10) {
        break
      }
      if (-not $usedPostIds.Add([int]$post.id)) {
        continue
      }

      $title = HtmlToText $post.title.rendered
      $summary = HtmlToText $post.excerpt.rendered
      $content = HtmlToText $post.content.rendered

      if ([string]::IsNullOrWhiteSpace($summary)) {
        $summary = $content
      }
      if ([string]::IsNullOrWhiteSpace($content)) {
        $content = $summary
      }
      if ($content.Length -gt 850) {
        $content = $content.Substring(0, 850)
      }

      $imageUrl = $null
      if ($post.PSObject.Properties.Name -contains '_embedded') {
        $embedded = $post._embedded
        if ($embedded.PSObject.Properties.Name -contains 'wp:featuredmedia') {
          $media = $embedded.'wp:featuredmedia'
          if ($media -and $media.Count -gt 0) {
            $imageUrl = $media[0].source_url
          }
        }
      }
      if ([string]::IsNullOrWhiteSpace($imageUrl) -and ($post.PSObject.Properties.Name -contains 'yoast_head_json')) {
        $yh = $post.yoast_head_json
        if ($yh -and $yh.og_image -and $yh.og_image.Count -gt 0) {
          $imageUrl = $yh.og_image[0].url
        }
      }

      if ([string]::IsNullOrWhiteSpace($imageUrl)) {
        continue
      }

      $createdAtValue = if ([string]::IsNullOrWhiteSpace($post.date_gmt)) { $post.date } else { $post.date_gmt }
      $createdAt = ([datetimeoffset]$createdAtValue).ToString('yyyy-MM-ddTHH:mm:sszzz')

      $globalPostOrdinal += 1
      $catRows += [pscustomobject]@{
        post_id = [int]$post.id
        category_slug = $cat.slug
        category_order = [int]$cat.order
        category_rank = $catRows.Count + 1
        title = $title
        summary = $summary
        content = $content
        image_url = $imageUrl
        link = $post.link
        created_at = $createdAt
        ordinal = $globalPostOrdinal
      }
    }

    $page += 1
  }

  if ($catRows.Count -lt 10) {
    throw "Not enough real posts for category '$($cat.name)'. Collected: $($catRows.Count)"
  }

  $allPosts += ($catRows | Select-Object -First 10)
}

$allPosts = $allPosts | Sort-Object category_order, category_rank

$termApi = Invoke-RestMethod -Uri 'https://alikhbariah.com/wp-json/wp/v2/video_list?per_page=100' -TimeoutSec 90
$termByName = @{}
foreach ($term in $termApi) {
  $termByName[$term.name] = $term
}

$videoIdCache = @{}
function Get-TermYoutubeIds {
  param([string]$SourceName)
  if ($videoIdCache.ContainsKey($SourceName)) {
    return $videoIdCache[$SourceName]
  }
  if (-not $termByName.ContainsKey($SourceName)) {
    throw "Missing video_list source '$SourceName' in API"
  }

  $link = $termByName[$SourceName].link
  $html = (Invoke-WebRequest -UseBasicParsing -Uri $link -TimeoutSec 150).Content
  $matches = [regex]::Matches($html, '(?:watch\?v=|embed/|vi/)([A-Za-z0-9_-]{11})')

  $seen = New-Object 'System.Collections.Generic.HashSet[string]'
  $ids = New-Object 'System.Collections.Generic.List[string]'
  foreach ($m in $matches) {
    $id = $m.Groups[1].Value
    if ($seen.Add($id)) {
      [void]$ids.Add($id)
    }
  }

  if ($ids.Count -lt 10) {
    throw "Not enough youtube ids extracted for '$SourceName'. Count: $($ids.Count)"
  }

  $result = $ids.ToArray()
  $videoIdCache[$SourceName] = $result
  return $result
}

$ytMetaCache = @{}
function Get-YoutubeMeta {
  param([string]$YoutubeId)
  if ($ytMetaCache.ContainsKey($YoutubeId)) {
    return $ytMetaCache[$YoutubeId]
  }

  $fallback = [pscustomobject]@{
    title = "YouTube video $YoutubeId"
    thumbnail_url = "https://i.ytimg.com/vi/$YoutubeId/hqdefault.jpg"
  }

  try {
    $url = "https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=$YoutubeId&format=json"
    $oembed = Invoke-RestMethod -Uri $url -TimeoutSec 30
    $title = HtmlToText $oembed.title
    if ([string]::IsNullOrWhiteSpace($title)) {
      $title = $fallback.title
    }
    $thumbnail = if ([string]::IsNullOrWhiteSpace($oembed.thumbnail_url)) { $fallback.thumbnail_url } else { $oembed.thumbnail_url }
    $meta = [pscustomobject]@{ title = $title; thumbnail_url = $thumbnail }
    $ytMetaCache[$YoutubeId] = $meta
    return $meta
  } catch {
    $ytMetaCache[$YoutubeId] = $fallback
    return $fallback
  }
}

$categoryCover = @{}
$usedYoutubeIds = New-Object 'System.Collections.Generic.HashSet[string]'
$videoRows = New-Object System.Collections.Generic.List[object]
$programRows = New-Object System.Collections.Generic.List[object]

function Add-CategoryVideos {
  param(
    [pscustomobject]$Definition,
    [string]$CategoryType,
    [System.Collections.Generic.List[object]]$Bucket
  )

  $pool = Get-TermYoutubeIds -SourceName $Definition.source
  $selected = New-Object 'System.Collections.Generic.List[string]'

  foreach ($youtubeId in $pool) {
    if ($usedYoutubeIds.Add($youtubeId)) {
      [void]$selected.Add($youtubeId)
    }
    if ($selected.Count -eq 10) {
      break
    }
  }

  if ($selected.Count -lt 10) {
    throw "Insufficient unique YouTube videos for '$($Definition.name)' ($CategoryType)."
  }

  for ($i = 0; $i -lt $selected.Count; $i++) {
    $youtubeId = $selected[$i]
    $meta = Get-YoutubeMeta -YoutubeId $youtubeId
    $publishedAt = (Get-Date).AddHours(-1 * (($Definition.order * 24) + ($i + 1))).ToString('yyyy-MM-ddTHH:mm:sszzz')

    if (-not $categoryCover.ContainsKey($Definition.slug)) {
      $categoryCover[$Definition.slug] = $meta.thumbnail_url
    }

    $titlePrefix = if ($CategoryType -eq 'program') { 'حلقة' } else { 'فيديو' }
    $title = "$($meta.title) | $titlePrefix $($i + 1)"

    $Bucket.Add([pscustomobject]@{
      category_slug = $Definition.slug
      title = $title
      youtube_url = "https://www.youtube.com/watch?v=$youtubeId"
      thumbnail_url = $meta.thumbnail_url
      order_index = $i + 1
      published_at = $publishedAt
    })
  }
}

foreach ($def in $programCategories) {
  Add-CategoryVideos -Definition $def -CategoryType 'program' -Bucket $programRows
}
foreach ($def in $videoCategories) {
  Add-CategoryVideos -Definition $def -CategoryType 'video' -Bucket $videoRows
}

if ($programRows.Count -ne 70) {
  throw "Program rows mismatch. Expected 70, got $($programRows.Count)"
}
if ($videoRows.Count -ne 70) {
  throw "Video rows mismatch. Expected 70, got $($videoRows.Count)"
}

$breakingSeed = @($allPosts | Sort-Object created_at -Descending | Select-Object -First 50)
if ($breakingSeed.Count -lt 50) {
  throw "Breaking seed mismatch. Expected 50, got $($breakingSeed.Count)"
}

$sb = New-Object System.Text.StringBuilder

Add-Line $sb '-- Seed 7x10 dataset for NewsAppJS (real-source edition)'
Add-Line $sb '-- Source news + media: https://alikhbariah.com (WP REST + video_list pages)'
Add-Line $sb '-- Source video metadata: YouTube oEmbed for extracted IDs'
Add-Line $sb ''
Add-Line $sb 'begin;'
Add-Line $sb ''
Add-Line $sb '-- ============================='
Add-Line $sb '-- 0) Compatibility columns'
Add-Line $sb '-- ============================='
Add-Line $sb 'alter table if exists public.locations'
Add-Line $sb '  add column if not exists name_en text,'
Add-Line $sb '  add column if not exists slug text;'
Add-Line $sb ''
Add-Line $sb 'alter table if exists public.categories'
Add-Line $sb '  add column if not exists name_en text,'
Add-Line $sb "  add column if not exists type text not null default 'news',"
Add-Line $sb '  add column if not exists cover_image_url text;'
Add-Line $sb ''
Add-Line $sb 'alter table if exists public.news'
Add-Line $sb '  add column if not exists title_en text,'
Add-Line $sb '  add column if not exists summary text,'
Add-Line $sb '  add column if not exists summary_en text,'
Add-Line $sb '  add column if not exists content_en text,'
Add-Line $sb '  add column if not exists image_url text,'
Add-Line $sb '  add column if not exists category_id bigint,'
Add-Line $sb '  add column if not exists location_id bigint,'
Add-Line $sb '  add column if not exists created_at timestamptz not null default now(),'
Add-Line $sb '  add column if not exists is_hidden boolean not null default false,'
Add-Line $sb '  add column if not exists is_featured boolean not null default false,'
Add-Line $sb '  add column if not exists sent_notification boolean not null default true,'
Add-Line $sb '  add column if not exists view_count integer not null default 0;'
Add-Line $sb ''
Add-Line $sb 'alter table if exists public.breaking_news'
Add-Line $sb '  add column if not exists title text,'
Add-Line $sb '  add column if not exists content text,'
Add-Line $sb '  add column if not exists created_at timestamptz not null default now(),'
Add-Line $sb '  add column if not exists start_time timestamptz,'
Add-Line $sb '  add column if not exists end_time timestamptz,'
Add-Line $sb '  add column if not exists send_notification boolean not null default true,'
Add-Line $sb '  add column if not exists is_active boolean not null default true,'
Add-Line $sb '  add column if not exists view_count integer not null default 0;'
Add-Line $sb ''
Add-Line $sb 'alter table if exists public.videos'
Add-Line $sb '  add column if not exists title text,'
Add-Line $sb '  add column if not exists youtube_url text,'
Add-Line $sb '  add column if not exists category_id bigint,'
Add-Line $sb '  add column if not exists thumbnail_url text,'
Add-Line $sb '  add column if not exists order_index integer not null default 0,'
Add-Line $sb '  add column if not exists published_at timestamptz,'
Add-Line $sb '  add column if not exists created_at timestamptz not null default now(),'
Add-Line $sb '  add column if not exists is_hidden boolean not null default false;'
Add-Line $sb ''
Add-Line $sb '-- Accept program type in categories'
Add-Line $sb 'do $$'
Add-Line $sb 'begin'
Add-Line $sb '  if exists ('
Add-Line $sb '    select 1 from pg_constraint'
Add-Line $sb "    where conname = 'categories_type_check'"
Add-Line $sb "      and conrelid = 'public.categories'::regclass"
Add-Line $sb '  ) then'
Add-Line $sb '    alter table public.categories drop constraint categories_type_check;'
Add-Line $sb '  end if;'
Add-Line $sb ''
Add-Line $sb '  alter table public.categories'
Add-Line $sb '    add constraint categories_type_check'
Add-Line $sb "    check (type in ('news', 'video', 'program'));"
Add-Line $sb 'exception when duplicate_object then'
Add-Line $sb '  null;'
Add-Line $sb 'end $$;'
Add-Line $sb ''
Add-Line $sb '-- ============================='
Add-Line $sb '-- 1) Clear existing rows'
Add-Line $sb '-- ============================='
Add-Line $sb 'truncate table public.ticker_news restart identity cascade;'
Add-Line $sb 'truncate table public.breaking_news restart identity cascade;'
Add-Line $sb 'truncate table public.news restart identity cascade;'
Add-Line $sb 'truncate table public.videos restart identity cascade;'
Add-Line $sb 'truncate table public.locations restart identity cascade;'
Add-Line $sb "delete from public.categories where coalesce(type, 'news') in ('news', 'video', 'program');"
Add-Line $sb ''
Add-Line $sb '-- ============================='
Add-Line $sb '-- 2) Locations (Syrian governorates)'
Add-Line $sb '-- ============================='
Add-Line $sb 'insert into public.locations (name, name_en, slug)'
Add-Line $sb 'values'
for ($i = 0; $i -lt $locations.Count; $i++) {
  $loc = $locations[$i]
  $suffix = if ($i -lt ($locations.Count - 1)) { ',' } else { '' }
  Add-Line $sb ("  ('{0}', '{1}', '{2}'){3}" -f (SqlEscape $loc.name), (SqlEscape $loc.name_en), (SqlEscape $loc.slug), $suffix)
}
Add-Line $sb 'on conflict (slug) do update'
Add-Line $sb 'set name = excluded.name, name_en = excluded.name_en;'
Add-Line $sb ''
Add-Line $sb '-- ============================='
Add-Line $sb '-- 3) News categories (7)'
Add-Line $sb '-- ============================='
Add-Line $sb 'insert into public.categories (name, name_en, slug, order_index, type)'
Add-Line $sb 'values'
for ($i = 0; $i -lt $newsCategories.Count; $i++) {
  $cat = $newsCategories[$i]
  $suffix = if ($i -lt ($newsCategories.Count - 1)) { ',' } else { '' }
  Add-Line $sb ("  ('{0}', '{1}', '{2}', {3}, 'news'){4}" -f (SqlEscape $cat.name), (SqlEscape $cat.name_en), (SqlEscape $cat.slug), $cat.order, $suffix)
}
Add-Line $sb 'on conflict (slug) do update'
Add-Line $sb 'set name = excluded.name, name_en = excluded.name_en, order_index = excluded.order_index, type = excluded.type;'
Add-Line $sb ''
Add-Line $sb '-- ============================='
Add-Line $sb '-- 4) 70 real news items (7 x 10)'
Add-Line $sb '-- ============================='
Add-Line $sb 'insert into public.news ('
Add-Line $sb '  title, title_en, summary, summary_en, content, content_en,'
Add-Line $sb '  image_url, category_id, location_id, created_at,'
Add-Line $sb '  is_hidden, is_featured, sent_notification, view_count'
Add-Line $sb ')'
Add-Line $sb 'values'

for ($i = 0; $i -lt $allPosts.Count; $i++) {
  $row = $allPosts[$i]
  $isFeatured = if ($row.category_rank -le 2) { 'true' } else { 'false' }
  $locationOffset = ($row.ordinal - 1) % $locations.Count
  $viewCount = 120 + ($allPosts.Count - $i)
  $summaryWithSource = "$($row.summary) المصدر: $($row.link)"
  $contentWithSource = "$($row.content) المصدر: $($row.link)"
  $suffix = if ($i -lt ($allPosts.Count - 1)) { ',' } else { '' }
  Add-Line $sb ("  ('{0}', '{1}', '{2}', '{3}', '{4}', '{5}', '{6}', (select id from public.categories where slug = '{7}' and type = 'news' limit 1), (select id from public.locations order by id offset {8} limit 1), '{9}'::timestamptz, false, {10}, false, {11}){12}" -f
      (SqlEscape $row.title),
      (SqlEscape $row.title),
      (SqlEscape $row.summary),
      (SqlEscape $row.summary),
      (SqlEscape $contentWithSource),
      (SqlEscape $contentWithSource),
      (SqlEscape $row.image_url),
      (SqlEscape $row.category_slug),
      $locationOffset,
      (SqlEscape $row.created_at),
      $isFeatured,
      $viewCount,
      $suffix)
}
Add-Line $sb ';'
Add-Line $sb ''
Add-Line $sb '-- ============================='
Add-Line $sb '-- 5) Breaking news (10 days x 5/day, each 24h)'
Add-Line $sb '-- ============================='
Add-Line $sb 'with breaking_seed as ('
Add-Line $sb '  select * from (values'
for ($i = 0; $i -lt $breakingSeed.Count; $i++) {
  $row = $breakingSeed[$i]
  $seq = $i + 1
  $title = "عاجل | " + $row.title
  $content = "$($row.summary) المصدر: $($row.link)"
  $suffix = if ($i -lt ($breakingSeed.Count - 1)) { ',' } else { '' }
  Add-Line $sb ("    ({0}, '{1}', '{2}'){3}" -f $seq, (SqlEscape $title), (SqlEscape $content), $suffix)
}
Add-Line $sb "  ) as t(seq_no, title, content)"
Add-Line $sb ')'
Add-Line $sb 'insert into public.breaking_news ('
Add-Line $sb '  title, content, created_at, start_time, end_time, send_notification, is_active, view_count'
Add-Line $sb ')'
Add-Line $sb 'select'
Add-Line $sb '  b.title,'
Add-Line $sb '  b.content,'
Add-Line $sb '  now(),'
Add-Line $sb "  date_trunc('day', now()) + (((b.seq_no - 1) / 5)::text || ' day')::interval as start_time,"
Add-Line $sb "  date_trunc('day', now()) + ((((b.seq_no - 1) / 5) + 1)::text || ' day')::interval as end_time,"
Add-Line $sb '  true,'
Add-Line $sb '  true,'
Add-Line $sb '  0'
Add-Line $sb 'from breaking_seed b'
Add-Line $sb 'order by b.seq_no;'
Add-Line $sb ''
Add-Line $sb '-- ============================='
Add-Line $sb '-- 6) Video playlists (7) + 70 videos'
Add-Line $sb '-- ============================='
Add-Line $sb 'insert into public.categories (name, name_en, slug, cover_image_url, order_index, type)'
Add-Line $sb 'values'
for ($i = 0; $i -lt $videoCategories.Count; $i++) {
  $cat = $videoCategories[$i]
  $cover = if ($categoryCover.ContainsKey($cat.slug)) { $categoryCover[$cat.slug] } else { 'https://i.ytimg.com/vi/Bbk-lsNLoYA/hqdefault.jpg' }
  $suffix = if ($i -lt ($videoCategories.Count - 1)) { ',' } else { '' }
  Add-Line $sb ("  ('{0}', '{1}', '{2}', '{3}', {4}, 'video'){5}" -f (SqlEscape $cat.name), (SqlEscape $cat.name_en), (SqlEscape $cat.slug), (SqlEscape $cover), $cat.order, $suffix)
}
Add-Line $sb 'on conflict (slug) do update'
Add-Line $sb 'set name = excluded.name, name_en = excluded.name_en, cover_image_url = excluded.cover_image_url, order_index = excluded.order_index, type = excluded.type;'
Add-Line $sb ''
Add-Line $sb 'insert into public.videos (title, youtube_url, category_id, thumbnail_url, order_index, published_at, is_hidden)'
Add-Line $sb 'values'
for ($i = 0; $i -lt $videoRows.Count; $i++) {
  $row = $videoRows[$i]
  $suffix = if ($i -lt ($videoRows.Count - 1)) { ',' } else { '' }
  Add-Line $sb ("  ('{0}', '{1}', (select id from public.categories where slug = '{2}' and type = 'video' limit 1), '{3}', {4}, '{5}'::timestamptz, false){6}" -f
      (SqlEscape $row.title),
      (SqlEscape $row.youtube_url),
      (SqlEscape $row.category_slug),
      (SqlEscape $row.thumbnail_url),
      $row.order_index,
      (SqlEscape $row.published_at),
      $suffix)
}
Add-Line $sb ';'
Add-Line $sb ''
Add-Line $sb '-- ============================='
Add-Line $sb '-- 7) Program playlists (7) + 70 episodes'
Add-Line $sb '-- ============================='
Add-Line $sb 'insert into public.categories (name, name_en, slug, cover_image_url, order_index, type)'
Add-Line $sb 'values'
for ($i = 0; $i -lt $programCategories.Count; $i++) {
  $cat = $programCategories[$i]
  $cover = if ($categoryCover.ContainsKey($cat.slug)) { $categoryCover[$cat.slug] } else { 'https://i.ytimg.com/vi/Bbk-lsNLoYA/hqdefault.jpg' }
  $suffix = if ($i -lt ($programCategories.Count - 1)) { ',' } else { '' }
  Add-Line $sb ("  ('{0}', '{1}', '{2}', '{3}', {4}, 'program'){5}" -f (SqlEscape $cat.name), (SqlEscape $cat.name_en), (SqlEscape $cat.slug), (SqlEscape $cover), $cat.order, $suffix)
}
Add-Line $sb 'on conflict (slug) do update'
Add-Line $sb 'set name = excluded.name, name_en = excluded.name_en, cover_image_url = excluded.cover_image_url, order_index = excluded.order_index, type = excluded.type;'
Add-Line $sb ''
Add-Line $sb 'insert into public.videos (title, youtube_url, category_id, thumbnail_url, order_index, published_at, is_hidden)'
Add-Line $sb 'values'
for ($i = 0; $i -lt $programRows.Count; $i++) {
  $row = $programRows[$i]
  $suffix = if ($i -lt ($programRows.Count - 1)) { ',' } else { '' }
  Add-Line $sb ("  ('{0}', '{1}', (select id from public.categories where slug = '{2}' and type = 'program' limit 1), '{3}', {4}, '{5}'::timestamptz, false){6}" -f
      (SqlEscape $row.title),
      (SqlEscape $row.youtube_url),
      (SqlEscape $row.category_slug),
      (SqlEscape $row.thumbnail_url),
      $row.order_index,
      (SqlEscape $row.published_at),
      $suffix)
}
Add-Line $sb ';'
Add-Line $sb ''
Add-Line $sb 'commit;'
Add-Line $sb ''
Add-Line $sb '-- Quick checks'
Add-Line $sb "-- select type, count(*) from public.categories where type in ('news','video','program') group by type order by type;"
Add-Line $sb '-- select count(*) from public.news;'
Add-Line $sb '-- select count(*) from public.breaking_news;'
Add-Line $sb '-- select count(*) from public.videos;'

Set-Content -Path 'docs/seed_7x10_complete.sql' -Value $sb.ToString() -Encoding UTF8

Write-Host "Generated docs/seed_7x10_complete.sql"
Write-Host "News rows: $($allPosts.Count)"
Write-Host "Breaking rows: $($breakingSeed.Count)"
Write-Host "Video rows: $($videoRows.Count)"
Write-Host "Program rows: $($programRows.Count)"
