Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Set-Location (Join-Path $PSScriptRoot '..')

Write-Host 'Step 1/3: Generating official source seed from alikhbariah.com...'
powershell -ExecutionPolicy Bypass -File "docs/generate_seed_7x10_real_ascii.ps1"
if ($LASTEXITCODE -ne 0) {
  throw 'Official source generator failed. Fix generator inputs/connectivity and retry.'
}

Write-Host 'Step 2/3: Building bilingual Arabic/English seed...'
powershell -ExecutionPolicy Bypass -File "docs/build_bilingual_seed_all.ps1" -InputSql "docs/seed_7x10_complete.sql" -OutputSql "docs/seed_official_alikhbariah_bilingual_7x10.sql"
if ($LASTEXITCODE -ne 0) {
  throw 'Bilingual builder failed.'
}

Write-Host 'Step 3/3: Done.'
Write-Host 'Output file: docs/seed_official_alikhbariah_bilingual_7x10.sql'
