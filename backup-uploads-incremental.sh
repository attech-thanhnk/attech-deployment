#!/bin/bash
################################################################################
# INCREMENTAL UPLOADS BACKUP (rsync)
# Only backs up new/changed files - much faster and smaller!
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${SCRIPT_DIR}/backups/uploads-incremental"
UPLOADS_DIR="${SCRIPT_DIR}/uploads"
DATE=$(date +%Y%m%d)

# Create backup directory structure
mkdir -p "${BACKUP_DIR}/current"
mkdir -p "${BACKUP_DIR}/history"

echo "=========================================="
echo " INCREMENTAL UPLOADS BACKUP - $(date)"
echo "=========================================="

# Check if uploads exists
if [ ! -d "${UPLOADS_DIR}" ]; then
    echo "⚠ Uploads directory doesn't exist"
    exit 0
fi

# Use rsync for incremental backup
echo "[1/3] Syncing changed files..."
rsync -avh --delete \
    --exclude='temp/' \
    --exclude='*.tmp' \
    --link-dest="${BACKUP_DIR}/current" \
    "${UPLOADS_DIR}/" \
    "${BACKUP_DIR}/current/" \
    2>&1 | grep -v "sending incremental" || true

# Create daily snapshot (hardlinks - no extra space!)
echo "[2/3] Creating daily snapshot..."
cp -al "${BACKUP_DIR}/current" "${BACKUP_DIR}/history/${DATE}"

# Cleanup old snapshots (keep last 7 days)
echo "[3/3] Cleaning old snapshots..."
find "${BACKUP_DIR}/history" -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \;

# Show stats
TOTAL_SIZE=$(du -sh "${BACKUP_DIR}/current" | cut -f1)
SNAPSHOT_SIZE=$(du -sh "${BACKUP_DIR}/history/${DATE}" | cut -f1)
FILE_COUNT=$(find "${BACKUP_DIR}/current" -type f | wc -l)

echo ""
echo "✓ Backup completed!"
echo "  Current size:  ${TOTAL_SIZE}"
echo "  Today snapshot: ${SNAPSHOT_SIZE}"
echo "  Files: ${FILE_COUNT}"
echo ""
echo "Available snapshots:"
ls -lh "${BACKUP_DIR}/history/"
echo ""

exit 0
