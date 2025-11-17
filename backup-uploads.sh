#!/bin/bash
################################################################################
# UPLOADS BACKUP SCRIPT
# Run daily via cron: 0 3 * * * /path/to/backup-uploads.sh
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${SCRIPT_DIR}/backups/uploads"
UPLOADS_DIR="${SCRIPT_DIR}/uploads"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

# Create backup directory
mkdir -p "${BACKUP_DIR}"

echo "=========================================="
echo " UPLOADS BACKUP - $(date)"
echo "=========================================="

# Check if uploads directory exists and has content
if [ ! -d "${UPLOADS_DIR}" ] || [ -z "$(ls -A ${UPLOADS_DIR})" ]; then
    echo "⚠ Uploads directory is empty or doesn't exist. Skipping backup."
    exit 0
fi

# Create tar.gz archive
echo "[1/2] Creating archive..."
tar -czf "${BACKUP_DIR}/uploads_${DATE}.tar.gz" \
    -C "${SCRIPT_DIR}" uploads/ \
    --exclude='uploads/temp' \
    2>/dev/null

# Cleanup old backups
echo "[2/2] Cleaning up old backups..."
find "${BACKUP_DIR}" -name "uploads_*.tar.gz" -type f -mtime +${RETENTION_DAYS} -delete

echo ""
echo "✓ Backup completed: ${BACKUP_DIR}/uploads_${DATE}.tar.gz"
echo "✓ Backup size: $(du -h "${BACKUP_DIR}/uploads_${DATE}.tar.gz" | cut -f1)"
echo "✓ Files backed up: $(tar -tzf "${BACKUP_DIR}/uploads_${DATE}.tar.gz" | wc -l)"
echo ""

# Optional: Upload to cloud
# rclone copy "${BACKUP_DIR}/uploads_${DATE}.tar.gz" remote:backups/uploads/

exit 0
