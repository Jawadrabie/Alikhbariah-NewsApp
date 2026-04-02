param(
  [string]$InputSql = 'docs/seed_7x10_complete.sql',
  [string]$OutputSql = 'docs/seed_7x10_bilingual_full.sql',
  [string]$CacheFile = 'docs/translation_cache_all.json'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Set-Location (Join-Path $PSScriptRoot '..')

function SqlUnescape {
  param([string]$s)
  if ($null -eq $s) { return '' }
  return ($s -replace "''", "'")
}

function SqlEscape {
  param([string]$s)
  if ($null -eq $s) { return '' }
  return ($s -replace "'", "''")
}

function HasArabic {
  param([string]$Text)
  if ([string]::IsNullOrWhiteSpace($Text)) { return $false }
  return $Text -match '[\u0600-\u06FF]'
}

function Split-ForTranslation {
  param(
    [string]$Text,
    [int]$MaxChunk = 260
  )

  $clean = [regex]::Replace(($Text -replace "`r`n", ' ' -replace "`n", ' '), '\s+', ' ').Trim()
  if ([string]::IsNullOrWhiteSpace($clean)) { return @() }

  $chunks = New-Object System.Collections.Generic.List[string]
  $start = 0
  while ($start -lt $clean.Length) {
    $remaining = $clean.Length - $start
    if ($remaining -le $MaxChunk) {
      [void]$chunks.Add($clean.Substring($start))
      break
    }

    $len = $MaxChunk
    $slice = $clean.Substring($start, $len)
    $lastSpace = $slice.LastIndexOf(' ')
    if ($lastSpace -gt 120) { $len = $lastSpace }

    [void]$chunks.Add($clean.Substring($start, $len).Trim())
    $start += $len
    while ($start -lt $clean.Length -and $clean[$start] -eq ' ') { $start += 1 }
  }

  return $chunks.ToArray()
}

$cache = @{}
if (Test-Path $CacheFile) {
  try {
    $loaded = Get-Content -Raw $CacheFile | ConvertFrom-Json -AsHashtable
    if ($loaded) { $cache = $loaded }
  } catch {
    $cache = @{}
  }
}

function Translate-ArToEn {
  param([string]$Text)

  if ([string]::IsNullOrWhiteSpace($Text)) { return '' }
  $key = $Text.Trim()

  if ($cache.ContainsKey($key)) { return [string]$cache[$key] }
  if (-not (HasArabic $key)) {
    $cache[$key] = $key
    return $key
  }

  $parts = New-Object System.Collections.Generic.List[string]
  foreach ($chunk in (Split-ForTranslation -Text $key -MaxChunk 260)) {
    $translated = $null
    for ($i = 0; $i -lt 4 -and [string]::IsNullOrWhiteSpace($translated); $i++) {
      try {
        $q = [uri]::EscapeDataString($chunk)
        $uri = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=ar&tl=en&dt=t&q=$q"
        $resp = Invoke-RestMethod -Uri $uri -TimeoutSec 30
        $translated = (($resp[0] | ForEach-Object { $_[0] }) -join '').Trim()
      } catch {
        Start-Sleep -Milliseconds (400 * ($i + 1))
      }
    }

    if ([string]::IsNullOrWhiteSpace($translated)) { $translated = $chunk }
    [void]$parts.Add($translated)
  }

  $result = (($parts -join ' ') -replace '\s+', ' ').Trim()
  if ([string]::IsNullOrWhiteSpace($result)) { $result = $key }

  $cache[$key] = $result
  return $result
}

function Translate-VideoOrProgramTitle {
  param([string]$Title)

  if ([string]::IsNullOrWhiteSpace($Title)) { return '' }

  $m = [regex]::Match($Title, '^(.*?)(\s*\|\s*(?:Video|Episode)\s+\d+)\s*$')
  if ($m.Success) {
    $core = $m.Groups[1].Value.Trim()
    $suffix = $m.Groups[2].Value
    $coreEn = Translate-ArToEn $core
    return ($coreEn + $suffix)
  }

  return (Translate-ArToEn $Title)
}

function Refine-EnglishMediaTitle {
  param([string]$TitleEn)

  if ([string]::IsNullOrWhiteSpace($TitleEn)) { return '' }

  $t = $TitleEn.Trim()

  # Keep common newsroom naming consistent and less literal.
  $replacements = @{
    'Al-Ekhbariya' = 'Alikhbariah'
    'Mr\. President' = 'President'
    'The Minister of Endowments' = 'Minister of Endowments'
    'The Minister of Health' = 'Minister of Health'
    'The Minister of Finance' = 'Minister of Finance'
    'The Minister of Defense' = 'Minister of Defense'
    'The Minister of Culture' = 'Minister of Culture'
    'The Ministry of Health' = 'Ministry of Health'
    'The Ministry of Finance' = 'Ministry of Finance'
    'The Ministry of Interior' = 'Ministry of Interior'
    'The Ministry of Culture' = 'Ministry of Culture'
    'The Governor of' = 'Governor of'
  }

  foreach ($k in $replacements.Keys) {
    $t = [regex]::Replace($t, "(?i)$k", [string]$replacements[$k])
  }

  # Normalize repeated punctuation/spacing introduced by machine translation.
  $t = [regex]::Replace($t, '\s+', ' ')
  $t = [regex]::Replace($t, '\s+\|\s+', ' | ')
  $t = [regex]::Replace($t, '\s+\?$', '?')
  $t = [regex]::Replace($t, '\s+\.$', '.')

  return $t.Trim()
}

if (-not (Test-Path $InputSql)) {
  throw "Input SQL file not found: $InputSql"
}

$lines = Get-Content -Path $InputSql

$inNews = $false
$inBreakingSeed = $false
$inVideosValues = $false

$newsUpdated = 0
$breakingUpdated = 0
$videosUpdated = 0

$newsPattern = "^\s*\('((?:''|[^'])*)',\s*'((?:''|[^'])*)',\s*'((?:''|[^'])*)',\s*'((?:''|[^'])*)',\s*'((?:''|[^'])*)',\s*'((?:''|[^'])*)',\s*'(.*)$"
$breakingValuePattern = "^(\s*)\((\d+),\s*'((?:''|[^'])*)',\s*'((?:''|[^'])*)'\)(,?)\s*$"
$videoValuePattern = "^(\s*)\('((?:''|[^'])*)',\s*'(https://www\.youtube\.com/watch\?v=[^']+)'(.*)$"

for ($idx = 0; $idx -lt $lines.Count; $idx++) {
  $line = $lines[$idx]

  if ($line -like '*insert into public.news*') { $inNews = $true; continue }
  if ($inNews -and $line -eq ';') { $inNews = $false; continue }

  if ($line -match '^\s*with breaking_seed as \(') { $inBreakingSeed = $true; continue }
  if ($inBreakingSeed -and $line -match '^\s*\)\s*as\s+t\(') { $inBreakingSeed = $false; continue }

  if ($line -match '^\s*insert into public\.videos \(') { $inVideosValues = $true; continue }
  if ($inVideosValues -and $line -eq ';') { $inVideosValues = $false; continue }

  if ($inNews) {
    $m = [regex]::Match($line, $newsPattern)
    if ($m.Success) {
      $titleAr = SqlUnescape $m.Groups[1].Value
      $summaryAr = SqlUnescape $m.Groups[3].Value
      $contentAr = SqlUnescape $m.Groups[5].Value
      $rest = $m.Groups[7].Value

      $titleEn = Translate-ArToEn $titleAr
      $summaryEn = Translate-ArToEn $summaryAr
      $contentEn = Translate-ArToEn $contentAr

      $lines[$idx] = (
        "  ('{0}', '{1}', '{2}', '{3}', '{4}', '{5}', '{6}" -f
        (SqlEscape $titleAr),
        (SqlEscape $titleEn),
        (SqlEscape $summaryAr),
        (SqlEscape $summaryEn),
        (SqlEscape $contentAr),
        (SqlEscape $contentEn),
        $rest
      )
      $newsUpdated += 1
      continue
    }
  }

  if ($inBreakingSeed) {
    $m = [regex]::Match($line, $breakingValuePattern)
    if ($m.Success) {
      $indent = $m.Groups[1].Value
      $seq = $m.Groups[2].Value
      $titleArRaw = SqlUnescape $m.Groups[3].Value
      $contentAr = SqlUnescape $m.Groups[4].Value
      $trailingComma = $m.Groups[5].Value

      $titleAr = [regex]::Replace($titleArRaw, '^\s*Breaking\s*\|\s*', '').Trim()
      $titleEn = Translate-ArToEn $titleAr
      $contentEn = Translate-ArToEn $contentAr

      $lines[$idx] = (
        "{0}({1}, '{2}', '{3}', '{4}', '{5}'){6}" -f
        $indent,
        $seq,
        (SqlEscape $titleAr),
        (SqlEscape $titleEn),
        (SqlEscape $contentAr),
        (SqlEscape $contentEn),
        $trailingComma
      )
      $breakingUpdated += 1
      continue
    }
  }

  if ($inVideosValues) {
    $m = [regex]::Match($line, $videoValuePattern)
    if ($m.Success) {
      $indent = $m.Groups[1].Value
      $titleAr = SqlUnescape $m.Groups[2].Value
      $youtube = $m.Groups[3].Value
      $rest = $m.Groups[4].Value

      $titleEn = Refine-EnglishMediaTitle (Translate-VideoOrProgramTitle $titleAr)

      $lines[$idx] = (
        "{0}('{1}', '{2}', '{3}'{4}" -f
        $indent,
        (SqlEscape $titleAr),
        (SqlEscape $titleEn),
        $youtube,
        $rest
      )
      $videosUpdated += 1
      continue
    }
  }
}

$text = ($lines -join "`r`n")

$text = [regex]::Replace(
  $text,
  '(?ms)^\s*\)\s*as\s+t\(seq_no,\s*title,\s*content\)',
  '  ) as t(seq_no, title, title_en, content, content_en)'
)

$text = [regex]::Replace(
  $text,
  '(?ms)insert into public\.breaking_news \(\s*title,\s*content,\s*created_at,\s*start_time,\s*end_time,\s*send_notification,\s*is_active,\s*view_count\s*\)',
  "insert into public.breaking_news (`r`n  title, title_en, content, content_en, created_at, start_time, end_time, send_notification, is_active, view_count`r`n)"
)

$text = [regex]::Replace(
  $text,
  '(?ms)select\s*b\.title,\s*b\.content,\s*now\(\),',
  "select`r`n  b.title,`r`n  b.title_en,`r`n  b.content,`r`n  b.content_en,`r`n  now(),"
)

$text = [regex]::Replace(
  $text,
  'insert into public\.videos \(title,\s*youtube_url,\s*category_id,\s*thumbnail_url,\s*order_index,\s*published_at,\s*is_hidden\)',
  'insert into public.videos (title, title_en, youtube_url, category_id, thumbnail_url, order_index, published_at, is_hidden)'
)

if ($text -notmatch '(?i)add column if not exists title_en text') {
  $marker = '-- Ensure English columns are populated for all content types'
  if ($text -match [regex]::Escape($marker)) {
    $compat = @"

-- Compatibility for bilingual fields used by this seed
alter table if exists public.breaking_news
  add column if not exists title_en text,
  add column if not exists content_en text;

alter table if exists public.videos
  add column if not exists title_en text;
"@
    $text = $text -replace [regex]::Escape($marker), ($compat + "`r`n" + $marker)
  }
}

Set-Content -Path $OutputSql -Value $text -Encoding UTF8

$cache | ConvertTo-Json -Depth 4 | Set-Content -Path $CacheFile -Encoding UTF8

Write-Host "Done."
Write-Host "Output: $OutputSql"
Write-Host "News rows translated: $newsUpdated"
Write-Host "Breaking rows translated: $breakingUpdated"
Write-Host "Video/Program rows translated: $videosUpdated"
