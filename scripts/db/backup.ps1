$ErrorActionPreference = "Stop"

Write-Host "======================================"
Write-Host "Taka Taka - Database Backup"
Write-Host "======================================"

Write-Host "Checking PostgreSQL..."

docker compose exec -T db pg_isready `
    -U takataka `
    -d takataka

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: PostgreSQL is not ready."
    exit 1
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupName = "takataka_$timestamp.sql"

Write-Host ""
Write-Host "Creating backup:"
Write-Host "  data/snapshots/db/$backupName"
Write-Host ""

docker compose exec -T db pg_dump `
    -U takataka `
    -d takataka `
    -F p `
    -f "/backups/$backupName"

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: pg_dump failed."
    exit 1
}

$backupPath = Join-Path `
    (Get-Location) `
    "data\snapshots\db\$backupName"

if (!(Test-Path $backupPath)) {
    Write-Host "ERROR: Backup file was not created."
    exit 1
}

$file = Get-Item $backupPath

if ($file.Length -eq 0) {
    Write-Host "ERROR: Backup file is empty."
    Remove-Item $backupPath
    exit 1
}

Write-Host ""
Write-Host "Backup verified:"
Write-Host "  $($file.FullName)"
Write-Host "  Size: $($file.Length) bytes"

Write-Host ""
Write-Host "Backup completed successfully."