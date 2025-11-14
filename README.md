# Attech Production Deployment

Production deployment configuration for Attech fullstack application.

## Infrastructure

- **Frontend**: https://attech.online
- **Backend API**: https://api.attech.online
- **VPS**: Ubuntu 22.04 on 103.162.31.91

## 📋 Documentation

- **[DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md)** - Complete guide for deploying to new domain/VPS
- **[config.sh](config.sh)** - Central configuration file (edit this for new deployments)

## 🚀 Quick Start (Current VPS)

```bash
# Clone repo on VPS
git clone https://github.com/attech-thanhnk/attech-deployment.git
cd attech-deployment

# Setup SSL certificates (copy to ssl/ folder)
mkdir -p ssl
sudo cp -L /etc/letsencrypt/live/attech.online/fullchain.pem ssl/
sudo cp -L /etc/letsencrypt/live/attech.online/privkey.pem ssl/
sudo cp /etc/letsencrypt/options-ssl-nginx.conf ssl/
sudo cp /etc/letsencrypt/ssl-dhparams.pem ssl/
sudo chown -R $USER:docker ssl/

# Create uploads folder
mkdir -p uploads/temp
chmod -R 777 uploads

# Login to GHCR (one time only)
docker login ghcr.io -u attech-thanhnk

# Run deployment
./initial-setup.sh
```

## Files

- `docker-compose.fullstack.yml` - Base services configuration
- `docker-compose.fullstack.production.yml` - Production overrides
- `.env.production` - Environment variables (gitignored)
- `initial-setup.sh` - Automated deployment script
- `nginx/` - Nginx reverse proxy configuration
- `ssl/` - SSL certificates (gitignored)
- `uploads/` - Upload files storage (gitignored)

## Deployment

### Manual Deployment

```bash
./initial-setup.sh
```

### Update Single Service

**Backend:**
```bash
docker pull ghcr.io/attech-thanhnk/attech-server:latest
docker-compose -f docker-compose.fullstack.yml -f docker-compose.fullstack.production.yml up -d backend
```

**Frontend:**
```bash
docker pull ghcr.io/attech-thanhnk/attech-client:latest
docker-compose -f docker-compose.fullstack.yml -f docker-compose.fullstack.production.yml up -d frontend
docker-compose -f docker-compose.fullstack.yml -f docker-compose.fullstack.production.yml restart proxy
```

## CI/CD

GitHub Actions automatically deploys when pushing to:
- Backend: https://github.com/attech-thanhnk/attech-server
- Frontend: https://github.com/attech-thanhnk/attech-client

Required GitHub Secrets:
- `SSH_PRIVATE_KEY`
- `SSH_HOST`
- `SSH_PORT`
- `SSH_USER`

## Maintenance

### View Logs

```bash
docker-compose -f docker-compose.fullstack.yml -f docker-compose.fullstack.production.yml logs -f
```

### Restart Services

```bash
docker-compose -f docker-compose.fullstack.yml -f docker-compose.fullstack.production.yml restart
```

### Stop Services

```bash
docker-compose -f docker-compose.fullstack.yml -f docker-compose.fullstack.production.yml down
```

### SSL Renewal

```bash
sudo certbot renew
# Then copy new certificates to ssl/ folder
```
