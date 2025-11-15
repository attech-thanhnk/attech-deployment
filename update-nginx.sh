#!/bin/bash

# Script to update nginx configuration
# Usage: ./update-nginx.sh

set -e

echo "🔄 Updating nginx configuration..."

# Navigate to deployment directory
cd ~/projects/attech-deployment

# Pull latest changes
echo "📥 Pulling latest changes from git..."
git pull

# Load environment variables
echo "🔧 Loading environment variables..."
source .env.production

# Export required variables for envsubst
export FRONTEND_DOMAIN
export FRONTEND_DOMAIN_WWW
export API_DOMAIN
export CLIENT_MAX_BODY_SIZE

# Generate production.conf from template
echo "📝 Generating production.conf from template..."
envsubst '$FRONTEND_DOMAIN $FRONTEND_DOMAIN_WWW $API_DOMAIN $CLIENT_MAX_BODY_SIZE' \
  < nginx/proxy/conf.d/production.conf.template \
  | sudo tee nginx/proxy/conf.d/production.conf > /dev/null

# Test nginx config before restart
echo "🧪 Testing nginx configuration..."
docker exec attech-proxy nginx -t

# Restart nginx container
echo "🔄 Restarting nginx container..."
docker restart attech-proxy

echo "✅ Nginx configuration updated successfully!"
echo ""
echo "🔍 To verify:"
echo "   docker logs attech-proxy --tail 50"
echo "   curl -I https://attech.online"
