#!/bin/bash
################################################################################
# SETUP AUTOMATED BACKUPS
# Run this once to setup cron jobs for automated backups
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo " SETUP AUTOMATED BACKUPS"
echo "=========================================="
echo ""

# Make scripts executable
echo "[1/5] Making backup scripts executable..."
chmod +x "${SCRIPT_DIR}/backup-database.sh"
chmod +x "${SCRIPT_DIR}/backup-uploads.sh"
echo "  ✓ Scripts are executable"

# Create backup directories
echo "[2/5] Creating backup directories..."
mkdir -p "${SCRIPT_DIR}/backups/database"
mkdir -p "${SCRIPT_DIR}/backups/uploads"
echo "  ✓ Directories created"

# Setup cron jobs
echo "[3/5] Setting up cron jobs..."

# Check if cron jobs already exist
CRON_FILE="/tmp/attech_cron"
crontab -l > "${CRON_FILE}" 2>/dev/null || echo "# Attech Backups" > "${CRON_FILE}"

# Remove old backup cron jobs if exist
sed -i '/backup-database.sh/d' "${CRON_FILE}"
sed -i '/backup-uploads.sh/d' "${CRON_FILE}"

# Add new cron jobs
cat >> "${CRON_FILE}" <<EOF

# Attech Production Backups
# Database backup: Daily at 2:00 AM
0 2 * * * ${SCRIPT_DIR}/backup-database.sh >> ${SCRIPT_DIR}/backups/backup-database.log 2>&1

# Uploads backup: Daily at 3:00 AM
0 3 * * * ${SCRIPT_DIR}/backup-uploads.sh >> ${SCRIPT_DIR}/backups/backup-uploads.log 2>&1
EOF

# Install cron jobs
crontab "${CRON_FILE}"
rm "${CRON_FILE}"

echo "  ✓ Cron jobs installed"

# Test backup scripts
echo "[4/5] Testing backup scripts..."
echo ""
echo "Testing database backup..."
"${SCRIPT_DIR}/backup-database.sh"

echo ""
echo "Testing uploads backup..."
"${SCRIPT_DIR}/backup-uploads.sh"

# Summary
echo ""
echo "[5/5] Setup complete!"
echo ""
echo "=========================================="
echo " BACKUP SCHEDULE"
echo "=========================================="
echo ""
echo "Database backup:  Daily at 2:00 AM"
echo "Uploads backup:   Daily at 3:00 AM"
echo ""
echo "Backup location:  ${SCRIPT_DIR}/backups/"
echo "Logs location:    ${SCRIPT_DIR}/backups/*.log"
echo ""
echo "View cron jobs:   crontab -l"
echo "View logs:        tail -f ${SCRIPT_DIR}/backups/backup-database.log"
echo ""
echo "⚠ IMPORTANT: Setup off-site backup (cloud storage)"
echo "   Consider using: rclone, AWS S3, Google Drive, or Dropbox"
echo ""
echo "=========================================="
