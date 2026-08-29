#!/usr/bin/env bash

set -euo pipefail

SERVICE="db"
BACKUP_DIR="./data/snapshots/db"
TIMESTAMP="$(date +"%Y%m%d_%H%M%S")"
BACKUP_NAME="takataka_${TIMESTAMP}.sql"
CONTAINER_BACKUP="/backups/${BACKUP_NAME}"
HOST_BACKUP="${BACKUP_DIR}/${BACKUP_NAME}"

echo "======================================"
echo "Taka Taka — Database Backup"
echo "======================================"

mkdir -p "${BACKUP_DIR}"

echo "Checking PostgreSQL..."

if ! docker compose ps --status running "${SERVICE}" >/dev/null 2>&1; then
    echo "ERROR: PostgreSQL service '${SERVICE}' is not running."
    echo "Start it with:"
    echo "  docker compose up -d ${SERVICE}"
    exit 1
fi

echo "PostgreSQL is running."

echo
echo "Creating backup:"
echo "  ${HOST_BACKUP}"
echo

docker compose exec -T "${SERVICE}" \
    pg_dump \
    -U "${POSTGRES_USER:-takataka}" \
    -d "${POSTGRES_DB:-takataka}" \
    -F p \
    -f "${CONTAINER_BACKUP}"

if [ ! -f "${HOST_BACKUP}" ]; then
    echo "ERROR: Backup file was not created."
    exit 1
fi

if [ ! -s "${HOST_BACKUP}" ]; then
    echo "ERROR: Backup file is empty."
    rm -f "${HOST_BACKUP}"
    exit 1
fi

echo
echo "Backup verified:"
ls -lh "${HOST_BACKUP}"

echo
echo "Backup completed successfully."