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

$cache = @{}

function Split-ForTranslation {
  param(
    [string]$Text,
    [int]$MaxChunk = 220
  )

  $clean = ([regex]::Replace(($Text -replace "`r`n", ' ' -replace "`n", ' '), '\s+', ' ')).Trim()
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
    if ($lastSpace -gt 80) { $len = $lastSpace }

    [void]$chunks.Add($clean.Substring($start, $len).Trim())
    $start += $len
    while ($start -lt $clean.Length -and $clean[$start] -eq ' ') { $start += 1 }
  }

  return $chunks.ToArray()
}

function Translate-ArToEn {
  param([string]$Text)

  if ([string]::IsNullOrWhiteSpace($Text)) { return '' }
  $key = $Text.Trim()

  if ($cache.ContainsKey($key)) { return $cache[$key] }
  if ($key -notmatch '[\u0600-\u06FF]') {
    $cache[$key] = $key
    return $key
  }

  $parts = New-Object System.Collections.Generic.List[string]
  foreach ($chunk in (Split-ForTranslation -Text $key -MaxChunk 220)) {
    $translated = $null
    for ($i = 0; $i -lt 3 -and [string]::IsNullOrWhiteSpace($translated); $i++) {
      try {
        $q = [uri]::EscapeDataString($chunk)
        $uri = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=ar&tl=en&dt=t&q=$q"
        $resp = Invoke-RestMethod -Uri $uri -TimeoutSec 30
        $translated = (($resp[0] | ForEach-Object { $_[0] }) -join '').Trim()
      } catch {
        Start-Sleep -Milliseconds (350 * ($i + 1))
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

$path = 'docs/seed_7x10_complete.sql'
$lines = Get-Content -Path $path

$inNewsValues = $false
$updated = 0

$pattern = "^\s*\('((?:''|[^'])*)',\s*'((?:''|[^'])*)',\s*'((?:''|[^'])*)',\s*'((?:''|[^'])*)',\s*'((?:''|[^'])*)',\s*'((?:''|[^'])*)',\s*'(.*)$"

for ($idx = 0; $idx -lt $lines.Count; $idx++) {
  $line = $lines[$idx]

  if ($line -like '*insert into public.news*') {
    $inNewsValues = $true
    continue
  }

  if ($inNewsValues -and $line -eq ';') {
    $inNewsValues = $false
    continue
  }

  if (-not $inNewsValues) { continue }

  $m = [regex]::Match($line, $pattern)
  if (-not $m.Success) { continue }

  $titleAr = SqlUnescape $m.Groups[1].Value
  $summaryAr = SqlUnescape $m.Groups[3].Value
  $contentAr = SqlUnescape $m.Groups[5].Value
  $rest = $m.Groups[7].Value

  $titleEn = Translate-ArToEn $titleAr
  $summaryEn = Translate-ArToEn $summaryAr
  $contentEn = Translate-ArToEn $contentAr

  $rebuilt = (
    "  ('{0}', '{1}', '{2}', '{3}', '{4}', '{5}', '{6}" -f
    (SqlEscape $titleAr),
    (SqlEscape $titleEn),
    (SqlEscape $summaryAr),
    (SqlEscape $summaryEn),
    (SqlEscape $contentAr),
    (SqlEscape $contentEn),
    $rest
  )

  $lines[$idx] = $rebuilt
  $updated += 1
}

Set-Content -Path $path -Value $lines -Encoding UTF8
Write-Host "Translated news rows updated: $updated"
