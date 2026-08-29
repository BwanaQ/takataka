param(
    [Parameter(Mandatory = $true)]
    [string]$BackupFile
)

$ErrorActionPreference = "Stop"

Write-Host "======================================"
Write-Host "Taka Taka - Database Restore"
Write-Host "======================================"

if (!(Test-Path $BackupFile)) {
    Write-Host "ERROR: Backup file does not exist:"
    Write-Host "  $BackupFile"
    exit 1
}

$file = Get-Item $BackupFile

if ($file.Length -eq 0) {
    Write-Host "ERROR: Backup file is empty."
    exit 1
}

Write-Host ""
Write-Host "Backup:"
Write-Host "  $($file.FullName)"
Write-Host "  Size: $($file.Length) bytes"

Write-Host ""
Write-Host "WARNING: This will restore the selected database backup."
Write-Host ""

$confirmation = Read-Host "Type RESTORE to continue"

if ($confirmation -ne "RESTORE") {
    Write-Host "Restore cancelled."
    exit 0
}

Write-Host ""
Write-Host "Checking PostgreSQL..."

docker compose exec -T db pg_isready `
    -U takataka `
    -d takataka

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: PostgreSQL is not ready."
    exit 1
}

Write-Host ""
Write-Host "Restoring database..."

Get-Content $file.FullName |
    docker compose exec -T db psql `
        -U takataka `
        -d takataka

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Database restore failed."
    exit 1
}

Write-Host ""
Write-Host "Restore completed successfully."