#!/bin/bash
################################################################################
# CENTRAL CONFIGURATION FILE
# Edit this file when deploying to a new domain/VPS
################################################################################

# ==============================================================================
# DOMAIN CONFIGURATION
# ==============================================================================
export DOMAIN="attech.online"
export API_DOMAIN="api.attech.online"
export WWW_DOMAIN="www.attech.online"

# ==============================================================================
# VPS CONFIGURATION
# ==============================================================================
export VPS_IP="103.162.31.91"
export SSH_PORT="26266"
export DEPLOY_USER="ncpt"
export DEPLOY_PATH="/home/ncpt/projects/attech-deployment"

# ==============================================================================
# DATABASE CONFIGURATION
# ==============================================================================
export DB_NAME="AttechServerDb"
export SA_PASSWORD="AttechServer@123"

# ==============================================================================
# PATHS
# ==============================================================================
export UPLOADS_DIR="${DEPLOY_PATH}/uploads"
export SSL_DIR="${DEPLOY_PATH}/ssl"

# ==============================================================================
# DOCKER IMAGES
# ==============================================================================
export GITHUB_ORG="attech-thanhnk"
export BACKEND_IMAGE="ghcr.io/${GITHUB_ORG}/attech-server:latest"
export FRONTEND_IMAGE="ghcr.io/${GITHUB_ORG}/attech-client:latest"

# ==============================================================================
# NGINX CONFIGURATION
# ==============================================================================
export CLIENT_MAX_BODY_SIZE="100M"

# ==============================================================================
# APPLICATION
# ==============================================================================
export ASPNETCORE_ENVIRONMENT="Production"

################################################################################
# DO NOT EDIT BELOW THIS LINE (Auto-generated from above)
################################################################################

# Generate .env.production content
generate_env_production() {
    cat > "${DEPLOY_PATH}/.env.production" <<EOF
# ============================================
# PRODUCTION ENVIRONMENT CONFIGURATION
# Auto-generated from config.sh
# ============================================

# Domain Configuration
FRONTEND_DOMAIN=${DOMAIN}
FRONTEND_DOMAIN_WWW=${WWW_DOMAIN}
API_DOMAIN=${API_DOMAIN}

# Server Paths
UPLOADS_DIR=${UPLOADS_DIR}

# Database Configuration
SA_PASSWORD=${SA_PASSWORD}
DB_NAME=${DB_NAME}
ACCEPT_EULA=Y

# Nginx Settings
CLIENT_MAX_BODY_SIZE=${CLIENT_MAX_BODY_SIZE}
ASPNETCORE_ENVIRONMENT=${ASPNETCORE_ENVIRONMENT}
EOF
    echo "✓ Generated .env.production"
}

# Print configuration summary
print_config() {
    echo ""
    echo "=========================================="
    echo " DEPLOYMENT CONFIGURATION"
    echo "=========================================="
    echo ""
    echo "Domains:"
    echo "  Frontend:  https://${DOMAIN}"
    echo "  Frontend:  https://${WWW_DOMAIN}"
    echo "  Backend:   https://${API_DOMAIN}"
    echo ""
    echo "VPS:"
    echo "  IP:        ${VPS_IP}"
    echo "  SSH Port:  ${SSH_PORT}"
    echo "  User:      ${DEPLOY_USER}"
    echo "  Path:      ${DEPLOY_PATH}"
    echo ""
    echo "Docker Images:"
    echo "  Backend:   ${BACKEND_IMAGE}"
    echo "  Frontend:  ${FRONTEND_IMAGE}"
    echo ""
    echo "=========================================="
    echo ""
}

# Export function to be used by other scripts
export -f generate_env_production
export -f print_config
