#!/bin/bash
################################################################################
# RESTORE BACKUP SCRIPT
# Usage: ./restore-backup.sh [database|uploads] [backup-file]
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_TYPE="$1"
BACKUP_FILE="$2"
DB_PASSWORD="AttechServer@123"

function show_usage() {
    echo "Usage: $0 [database|uploads] [backup-file]"
    echo ""
    echo "Examples:"
    echo "  $0 database backups/database/backup_20241114_020000.bak"
    echo "  $0 uploads backups/uploads/uploads_20241114_030000.tar.gz"
    echo ""
    echo "List available backups:"
    echo "  ls -lh backups/database/"
    echo "  ls -lh backups/uploads/"
    exit 1
}

# Check arguments
if [ -z "$BACKUP_TYPE" ] || [ -z "$BACKUP_FILE" ]; then
    show_usage
fi

# Resolve backup file path
if [[ "$BACKUP_FILE" != /* ]]; then
    BACKUP_FILE="${SCRIPT_DIR}/${BACKUP_FILE}"
fi

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "=========================================="
echo " RESTORE BACKUP"
echo "=========================================="
echo ""
echo "Type:   $BACKUP_TYPE"
echo "File:   $BACKUP_FILE"
echo "Size:   $(du -h "$BACKUP_FILE" | cut -f1)"
echo ""

# Confirmation
read -p "⚠ This will REPLACE current data. Continue? (yes/no): " -r
echo ""
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Aborted."
    exit 1
fi

case "$BACKUP_TYPE" in
    database)
        echo "[1/3] Copying backup to container..."
        docker cp "$BACKUP_FILE" attechserver-db:/var/opt/mssql/data/restore.bak

        echo "[2/3] Restoring database..."
        docker exec attechserver-db /opt/mssql-tools18/bin/sqlcmd \
            -S localhost -U sa -P "${DB_PASSWORD}" -C \
            -Q "RESTORE DATABASE [AttechServerDb] FROM DISK = '/var/opt/mssql/data/restore.bak' WITH REPLACE, MOVE 'AttechServerDbClean' TO '/var/opt/mssql/data/AttechServerDb.mdf', MOVE 'AttechServerDbClean_log' TO '/var/opt/mssql/data/AttechServerDb_log.ldf'"

        echo "[3/3] Cleaning up..."
        docker exec attechserver-db rm /var/opt/mssql/data/restore.bak

        echo ""
        echo "✓ Database restored successfully!"
        ;;

    uploads)
        echo "[1/2] Backing up current uploads (safety)..."
        SAFETY_BACKUP="${SCRIPT_DIR}/backups/uploads/before_restore_$(date +%Y%m%d_%H%M%S).tar.gz"
        tar -czf "$SAFETY_BACKUP" -C "${SCRIPT_DIR}" uploads/ 2>/dev/null || true
        echo "  ✓ Safety backup: $SAFETY_BACKUP"

        echo "[2/2] Restoring uploads..."
        rm -rf "${SCRIPT_DIR}/uploads"
        tar -xzf "$BACKUP_FILE" -C "${SCRIPT_DIR}"

        echo ""
        echo "✓ Uploads restored successfully!"
        ;;

    *)
        echo "❌ Invalid backup type: $BACKUP_TYPE"
        show_usage
        ;;
esac

echo ""
echo "=========================================="
