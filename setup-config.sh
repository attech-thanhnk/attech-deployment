#!/bin/bash
################################################################################
# SETUP CONFIGURATION
# Run this script to generate .env.production from config.sh
# Usage: ./setup-config.sh
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.sh"

# Check if config.sh exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "[ERROR] config.sh not found!"
    exit 1
fi

# Load configuration
source "$CONFIG_FILE"

echo "=========================================="
echo " SETUP CONFIGURATION"
echo "=========================================="
echo ""

# Print current configuration
print_config

# Ask for confirmation
read -p "Generate .env.production with this configuration? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Generate .env.production
generate_env_production

echo ""
echo "✓ Configuration complete!"
echo ""
echo "Next steps:"
echo "  1. Review .env.production file"
echo "  2. Run: sudo ./initial-setup.sh"
echo ""
