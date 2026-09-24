#!/usr/bin/env bash

if [[ -z "${PGHOST:-}" ]]; then
    echo "ERROR: PGHOST is not set"
    exit 1
fi

if [[ -z "${PGDATABASE:-}" ]]; then
    echo "ERROR: PGDATABASE is not set"
    exit 1
fi

if [[ -z "${BACKUP_DIR:-}" ]]; then
    echo "ERROR: BACKUP_DIR is not set"
    exit 1
fi

mkdir -p "$BACKUP_DIR"

BACKUP_FILE="$BACKUP_DIR/backup_$(date '+%Y-%m-%d_%H-%M-%S').sql"

echo "Starting backup of database: $PGDATABASE"

if ! pg_dump -f "$BACKUP_FILE"; then
    echo "ERROR: backup failed"
    rm -f "$BACKUP_FILE"
    exit 1
fi

echo "Backup completed: $BACKUP_FILE"
