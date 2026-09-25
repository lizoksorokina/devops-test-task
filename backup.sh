#!/usr/bin/env bash

ENV_FILE="/opt/postgres-backup/.backup.env"


if [[ "${1:-}" == "--help" ]]; then
    echo "Usage: $0 [--help] [--install-cron]"
    echo
    echo "Create PostgreSQL backup and rotate old backups."
    echo
    echo "Environment variables:"
    echo "  PGHOST       PostgreSQL host"
    echo "  PGDATABASE   PostgreSQL database name"
    echo "  PGUSER       PostgreSQL user"
    echo "  BACKUP_DIR   Directory for backups"
    echo
    echo "Options:"
    echo "  --help          Show this help"
    echo "  --install-cron Install daily cron job"
    exit 0
fi


if [[ -f "$ENV_FILE" ]]; then
    source "$ENV_FILE"
fi

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

mkdir -p "$BACKUP_DIR/daily"
mkdir -p "$BACKUP_DIR/monthly"

BACKUP_FILE="$BACKUP_DIR/daily/backup_$(date '+%Y-%m-%d').sql"

echo "Starting backup of database: $PGDATABASE"

if ! pg_dump -f "$BACKUP_FILE"; then
    echo "ERROR: backup failed"
    rm -f "$BACKUP_FILE"
    exit 1
fi

echo "Backup completed: $BACKUP_FILE"

# Keep 7 latest daily backups
count=0

for backup in $(ls -1t "$BACKUP_DIR/daily/"*.sql 2>/dev/null); do
    count=$((count + 1))

    if [[ "$count" -gt 7 ]]; then
        rm -f "$backup"
    fi
done

# If today is the last Sunday of the month,
# copy the daily backup to monthly
DAY_OF_WEEK=$(date '+%u')

if [[ "$DAY_OF_WEEK" -eq 7 ]]; then
    CURRENT_MONTH=$(date '+%Y-%m')
    NEXT_SUNDAY_MONTH=$(date -d '+7 days' '+%Y-%m')

    if [[ "$CURRENT_MONTH" != "$NEXT_SUNDAY_MONTH" ]]; then
        cp "$BACKUP_FILE" "$BACKUP_DIR/monthly/"
        echo "Monthly backup created: $BACKUP_DIR/monthly/$(basename "$BACKUP_FILE")"
    fi
fi
