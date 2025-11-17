#!/bin/bash
################################################################################
# BACKUP DIRECTLY TO CLOUD (No local storage)
# Requires: rclone configured with remote storage
# Setup: rclone config
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REMOTE="gdrive"  # Change to your rclone remote name
DATE=$(date +%Y%m%d_%H%M%S)

# Load password from .env.production
ENV_FILE="${SCRIPT_DIR}/.env.production"
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

DB_PASSWORD="${SA_PASSWORD}"
DB_NAME="${DB_NAME:-AttechServerDb}"

# Validate password is set
if [ -z "$DB_PASSWORD" ]; then
    echo "[ERROR] SA_PASSWORD not set in .env.production"
    exit 1
fi

echo "=========================================="
echo " CLOUD BACKUP - $(date)"
echo "=========================================="

# Check if rclone is installed
if ! command -v rclone &> /dev/null; then
    echo "❌ rclone not installed!"
    echo "Install: sudo apt install rclone"
    echo "Configure: rclone config"
    exit 1
fi

# Check if remote exists
if ! rclone listremotes | grep -q "^${REMOTE}:"; then
    echo "❌ Remote '${REMOTE}' not configured!"
    echo "Run: rclone config"
    exit 1
fi

# === BACKUP DATABASE ===
echo ""
echo "[1/3] Backing up database to cloud..."

# Create temp backup
TEMP_DB="/tmp/backup_${DATE}.bak"
docker exec attechserver-db /opt/mssql-tools18/bin/sqlcmd \
    -S localhost -U sa -P "${DB_PASSWORD}" -C \
    -Q "BACKUP DATABASE [${DB_NAME}] TO DISK = N'/var/opt/mssql/data/backup_temp.bak' WITH NOFORMAT, INIT, COMPRESSION"

docker cp attechserver-db:/var/opt/mssql/data/backup_temp.bak "${TEMP_DB}"
docker exec attechserver-db rm /var/opt/mssql/data/backup_temp.bak

# Upload to cloud
rclone copy "${TEMP_DB}" "${REMOTE}:attech-backups/database/" --progress

# Cleanup temp file
rm "${TEMP_DB}"

echo "  ✓ Database uploaded"

# === SYNC UPLOADS TO CLOUD ===
echo ""
echo "[2/3] Syncing uploads to cloud..."

rclone sync "${SCRIPT_DIR}/uploads/" \
    "${REMOTE}:attech-backups/uploads/" \
    --exclude "temp/**" \
    --exclude "*.tmp" \
    --progress \
    --fast-list

echo "  ✓ Uploads synced"

# === CLEANUP OLD CLOUD BACKUPS ===
echo ""
echo "[3/3] Cleaning old cloud backups..."

# Keep last 30 database backups
rclone delete "${REMOTE}:attech-backups/database/" \
    --min-age 30d \
    --rmdirs

echo "  ✓ Old backups cleaned"

# === SHOW STATS ===
echo ""
echo "=========================================="
echo " CLOUD BACKUP STATUS"
echo "=========================================="
echo ""
echo "Database backups:"
rclone ls "${REMOTE}:attech-backups/database/" | tail -5

echo ""
echo "Uploads size:"
rclone size "${REMOTE}:attech-backups/uploads/"

echo ""
echo "✓ Cloud backup completed!"
echo ""

exit 0
