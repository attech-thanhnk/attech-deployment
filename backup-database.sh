#!/bin/bash
################################################################################
# DATABASE BACKUP SCRIPT
# Run daily via cron: 0 2 * * * /path/to/backup-database.sh
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${SCRIPT_DIR}/backups/database"
DATE=$(date +%Y%m%d_%H%M%S)

# Load password from .env.production
ENV_FILE="${SCRIPT_DIR}/.env.production"
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

DB_NAME="${DB_NAME:-AttechServerDb}"
DB_PASSWORD="${SA_PASSWORD}"
RETENTION_DAYS=7

# Validate password is set
if [ -z "$DB_PASSWORD" ]; then
    echo "[ERROR] SA_PASSWORD not set in .env.production"
    exit 1
fi

# Create backup directory
mkdir -p "${BACKUP_DIR}"

echo "=========================================="
echo " DATABASE BACKUP - $(date)"
echo "=========================================="

# Backup database
echo "[1/3] Creating backup..."
docker exec attechserver-db /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "${DB_PASSWORD}" -C \
  -Q "BACKUP DATABASE [${DB_NAME}] TO DISK = N'/var/opt/mssql/data/backup_${DATE}.bak' WITH NOFORMAT, INIT, NAME = 'Full Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10"

# Copy backup out of container
echo "[2/3] Copying backup file..."
docker cp attechserver-db:/var/opt/mssql/data/backup_${DATE}.bak "${BACKUP_DIR}/"

# Cleanup old backups (keep last 7 days)
echo "[3/3] Cleaning up old backups..."
find "${BACKUP_DIR}" -name "backup_*.bak" -type f -mtime +${RETENTION_DAYS} -delete

# Cleanup backup inside container
docker exec attechserver-db rm /var/opt/mssql/data/backup_${DATE}.bak

echo ""
echo "✓ Backup completed: ${BACKUP_DIR}/backup_${DATE}.bak"
echo "✓ Backup size: $(du -h "${BACKUP_DIR}/backup_${DATE}.bak" | cut -f1)"
echo ""

# Optional: Upload to cloud (uncomment if needed)
# Upload to Google Drive / Dropbox / S3
# rclone copy "${BACKUP_DIR}/backup_${DATE}.bak" remote:backups/database/

exit 0
