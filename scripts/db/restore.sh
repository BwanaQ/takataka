#!/usr/bin/env bash

set -euo pipefail

SERVICE="db"
BACKUP_DIR="./data/snapshots/db"

echo "======================================"
echo "Taka Taka — Database Restore"
echo "======================================"

if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  ./scripts/db/restore.sh <backup-file>"
    echo
    echo "Example:"
    echo "  ./scripts/db/restore.sh data/snapshots/db/takataka_20260829_140000.sql"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "${BACKUP_FILE}" ]; then
    echo "ERROR: Backup file does not exist:"
    echo "  ${BACKUP_FILE}"
    exit 1
fi

if [ ! -s "${BACKUP_FILE}" ]; then
    echo "ERROR: Backup file is empty:"
    echo "  ${BACKUP_FILE}"
    exit 1
fi

echo "Backup:"
echo "  ${BACKUP_FILE}"

echo
echo "WARNING:"
echo "This will restore the selected SQL dump into PostgreSQL."
echo

read -r -p "Type RESTORE to continue: " CONFIRM

if [ "${CONFIRM}" != "RESTORE" ]; then
    echo "Restore cancelled."
    exit 0
fi

echo
echo "Checking PostgreSQL..."

if ! docker compose ps --status running "${SERVICE}" >/dev/null 2>&1; then
    echo "ERROR: PostgreSQL service '${SERVICE}' is not running."
    echo "Start it with:"
    echo "  docker compose up -d ${SERVICE}"
    exit 1
fi

echo "PostgreSQL is running."

echo
echo "Restoring database..."

cat "${BACKUP_FILE}" | \
    docker compose exec -T "${SERVICE}" \
    psql \
    -U "${POSTGRES_USER:-takataka}" \
    -d "${POSTGRES_DB:-takataka}"

echo
echo "Restore completed."