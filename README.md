# Attech Production Deployment

Production deployment configuration for Attech fullstack application.

## Infrastructure

- **Frontend**: <https://attech.online>
- **Backend API**: <https://api.attech.online>
- **VPS**: Ubuntu 22.04 (see config.sh)

## Quick Start

### First Time Deployment

```bash
# 1. Clone repo on VPS
git clone https://github.com/attech-thanhnk/attech-deployment.git
cd attech-deployment

# 2. Configure deployment
nano config.sh  # Edit domain, VPS IP, passwords

# 3. Generate .env.production
chmod +x setup-config.sh
./setup-config.sh

# 4. Setup SSL certificates
mkdir -p ssl
sudo cp -L /etc/letsencrypt/live/attech.online/fullchain.pem ssl/
sudo cp -L /etc/letsencrypt/live/attech.online/privkey.pem ssl/
sudo cp /etc/letsencrypt/options-ssl-nginx.conf ssl/
sudo cp /etc/letsencrypt/ssl-dhparams.pem ssl/
sudo chown -R $USER:docker ssl/

# 5. Create uploads folder
mkdir -p uploads/temp
chmod -R 777 uploads

# 6. Login to GHCR
docker login ghcr.io -u attech-thanhnk

# 7. Deploy
sudo ./initial-setup.sh
```

### Update Services

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

## Configuration

### Central Config (config.sh)

Edit `config.sh` for new deployments:

```bash
# Domains
DOMAIN="attech.online"
API_DOMAIN="api.attech.online"
WWW_DOMAIN="www.attech.online"

# VPS
VPS_IP="103.162.31.91"
SSH_PORT="26266"
DEPLOY_USER="ncpt"
DEPLOY_PATH="/home/ncpt/projects/attech-deployment"
```

### Environment Variables

Create `.env.production`:

```bash
# Copy example and edit
cp .env.production.example .env.production
nano .env.production
```

**Required:**

- `SA_PASSWORD` - Database password (20+ chars, strong!)
- `SMTP_USERNAME` - Email for sending notifications
- `SMTP_PASSWORD` - Gmail App Password (NOT real password!)

**Get Gmail App Password:** <https://myaccount.google.com/apppasswords>

## Backup & Restore

### Setup Automated Backups

```bash
chmod +x setup-backups.sh
./setup-backups.sh
```

Creates daily cron jobs:

- Database backup: 2:00 AM (keeps 7 days)
- Uploads backup: 3:00 AM (keeps 7 days)

### Manual Backup

```bash
# Database
./backup-database.sh

# Uploads
./backup-uploads.sh
```

### Restore

```bash
# List backups
ls -lh backups/database/
ls -lh backups/uploads/

# Restore database
./restore-backup.sh database backups/database/backup_20241114_020000.bak

# Restore uploads
./restore-backup.sh uploads backups/uploads/uploads_20241114_030000.tar.gz
```

## Security

### Critical Rules

- **NEVER commit `.env.production`** - Contains passwords!
- **Use strong passwords** - 20+ chars, mixed case, numbers, symbols
- **Gmail App Password** - NOT your real Gmail password
- **Change default passwords** - Don't use examples from docs

### File Upload Security (IMPORTANT!)

**Nginx Layer Protection (Already configured):**

- ✅ Blocks execution of `.php`, `.asp`, `.jsp`, `.sh`, `.exe`, etc.
- ✅ Whitelist only safe file types (images, docs, videos)
- ✅ Only allows GET/OPTIONS methods on `/uploads/`
- ✅ `X-Content-Type-Options: nosniff` header

**Backend Code Requirements (MUST implement in backend repo):**

1. **Validate MIME type** - Check actual file content, not just extension
2. **Rename files** - Don't use original filename (e.g., use GUID)
3. **Validate file size** - Enforce max size limits
4. **Scan for malware** - Use antivirus/malware scanner if possible
5. **Store outside webroot** - Or use cloud storage (S3, etc.)
6. **Check file content** - For images, verify it's actually an image

**Example validation in backend (C#):**

```csharp
// Validate MIME type AND extension
var allowedTypes = new[] { "image/jpeg", "image/png", "application/pdf" };
if (!allowedTypes.Contains(file.ContentType)) {
    return BadRequest("Invalid file type");
}

// Rename file to prevent path traversal
var fileName = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";

// Validate it's actually an image (not just extension)
using var image = Image.Load(file.OpenReadStream());
```

### Generate Strong Password

```bash
openssl rand -base64 32
```

### Security Features

- HTTPS/TLS with Let's Encrypt
- HSTS enabled (max-age=31536000)
- Rate limiting (100 req/s API, 10 req/m login)
- Content Security Policy (CSP)
- Strict CORS configuration
- Security headers (X-Frame-Options, X-Content-Type-Options, etc.)

### Get SSL Certificates

```bash
sudo certbot certonly --standalone \
  -d attech.online \
  -d www.attech.online \
  -d api.attech.online \
  --email your@email.com \
  --agree-tos
```

### SSL Renewal

```bash
# Auto-renews via certbot
sudo certbot renew

# Then copy new certs to ssl/
```

## CI/CD

GitHub Actions auto-deploys from:

- Backend: <https://github.com/attech-thanhnk/attech-server>
- Frontend: <https://github.com/attech-thanhnk/attech-client>

### Required GitHub Secrets

Add to both repos (Settings → Secrets → Actions):

- `SSH_PRIVATE_KEY` - Private key for SSH access
- `SSH_HOST` - VPS IP address
- `SSH_PORT` - SSH port (default: 22)
- `SSH_USER` - Deploy user

### Generate SSH Key

```bash
# On VPS
ssh-keygen -t ed25519 -C "github-actions"
cat ~/.ssh/id_ed25519  # Copy private key to GitHub Secret
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
```

### Test Deploy

```bash
# Trigger workflow with empty commit
git commit --allow-empty -m "Test deploy"
git push
```

## Deploy to New Domain/VPS

**Step 1:** Edit `config.sh` with new domain, VPS IP, passwords

**Step 2:** Update in frontend repo:

- `Dockerfile` - ARG REACT_APP_API_HOST
- `.env.production` - REACT_APP_API_HOST
- `.github/workflows/deploy-frontend.yml` - build-args, script paths

**Step 3:** Update in backend repo:

- `.github/workflows/deploy-backend.yml` - script paths, health check URL

**Step 4:** Setup VPS:

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Get SSL certificates
sudo certbot certonly --standalone -d newdomain.com ...

# Clone and deploy (see Quick Start above)
```

**Step 5:** Add GitHub Secrets to both repos

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

### Check Status

```bash
docker-compose -f docker-compose.fullstack.yml -f docker-compose.fullstack.production.yml ps
```

## Troubleshooting

### Services Won't Start

```bash
# Check logs
docker-compose logs backend
docker-compose logs frontend

# Check .env.production exists
ls -la .env.production
```

### Database Connection Failed

```bash
# Verify password in .env.production
cat .env.production | grep SA_PASSWORD

# Test connection
source .env.production
docker exec -it attechserver-db /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "${SA_PASSWORD}" -C -Q "SELECT @@VERSION"
```

### HTTPS Not Working

```bash
# Check SSL certificates
ls -la ssl/

# Check nginx config
docker-compose logs proxy

# Verify DNS
nslookup attech.online
```

### Uploads Not Accessible

```bash
# Check uploads folder
ls -la uploads/

# Check permissions
chmod -R 777 uploads/

# Verify path in docker-compose
grep UPLOADS_DIR .env.production
```

## Files Structure

```text
.
├── README.md                              # This file
├── config.sh                              # Central configuration
├── .env.production.example                # Environment template
├── .env.production                        # Actual secrets (gitignored)
├── initial-setup.sh                       # First-time deployment
├── setup-config.sh                        # Generate .env.production
├── setup-backups.sh                       # Setup automated backups
├── update-nginx.sh                        # Update nginx config
├── backup-database.sh                     # Manual DB backup
├── backup-uploads.sh                      # Manual uploads backup
├── backup-uploads-incremental.sh          # Incremental uploads backup
├── backup-to-cloud.sh                     # Cloud backup (requires rclone)
├── restore-backup.sh                      # Restore from backup
├── docker-compose.fullstack.yml           # Base services
├── docker-compose.fullstack.production.yml # Production overrides
├── nginx/                                 # Nginx configuration
│   └── proxy/
│       ├── nginx.conf
│       └── conf.d/
│           ├── production.conf.template   # Template (edit this)
│           └── production.conf            # Generated (auto-created)
├── ssl/                                   # SSL certificates (gitignored)
├── uploads/                               # Uploaded files (gitignored)
└── backups/                               # Backup files (gitignored)
```

## Support

- Check this README for common tasks
- Review `config.sh` for configuration options
- Never commit secrets to Git!

---

**Last Updated:** 2025-11-17
