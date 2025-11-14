# BACKUP & RESTORE GUIDE

## 📦 What Gets Backed Up

### 1. Database (Daily at 2:00 AM)
- **Content**: Full SQL Server database
- **Location**: `backups/database/backup_YYYYMMDD_HHMMSS.bak`
- **Retention**: Last 7 days
- **Size**: ~15MB (compressed)

### 2. Uploads (Daily at 3:00 AM)
- **Content**: User uploaded files (images, documents)
- **Location**: `backups/uploads/uploads_YYYYMMDD_HHMMSS.tar.gz`
- **Retention**: Last 7 days
- **Size**: Varies

---

## 🚀 Quick Start

### Setup Automated Backups (One Time)

```bash
ssh -p 26266 ncpt@103.162.31.91
cd ~/projects/attech-deployment
chmod +x setup-backups.sh
./setup-backups.sh
```

This will:
- ✅ Create backup directories
- ✅ Make scripts executable
- ✅ Setup daily cron jobs
- ✅ Run initial test backups

---

## 📋 Manual Backup

### Backup Database

```bash
cd ~/projects/attech-deployment
./backup-database.sh
```

### Backup Uploads

```bash
cd ~/projects/attech-deployment
./backup-uploads.sh
```

---

## 🔄 Restore Backup

### List Available Backups

```bash
# Database backups
ls -lh backups/database/

# Uploads backups
ls -lh backups/uploads/
```

### Restore Database

```bash
./restore-backup.sh database backups/database/backup_20241114_020000.bak
```

### Restore Uploads

```bash
./restore-backup.sh uploads backups/uploads/uploads_20241114_030000.tar.gz
```

---

## 📊 View Backup Status

### Check Cron Jobs

```bash
crontab -l
```

### View Backup Logs

```bash
# Database backup log
tail -f backups/backup-database.log

# Uploads backup log
tail -f backups/backup-uploads.log

# View last 50 lines
tail -50 backups/backup-database.log
```

### Check Backup Sizes

```bash
# Total backup size
du -sh backups/

# Database backups
du -sh backups/database/

# Uploads backups
du -sh backups/uploads/
```

---

## ☁️ Off-Site Backup (Recommended)

### Why Off-Site Backup?

- 🔥 Protection from server failure/fire
- 💻 Protection from hardware failure
- 🏢 Protection from data center issues
- 🔒 Additional security layer

### Setup with rclone (Google Drive / Dropbox / S3)

**1. Install rclone:**

```bash
sudo apt install rclone
```

**2. Configure remote:**

```bash
rclone config
# Follow prompts to setup Google Drive, Dropbox, or AWS S3
```

**3. Update backup scripts:**

Uncomment these lines in `backup-database.sh` and `backup-uploads.sh`:

```bash
# Upload to cloud
rclone copy "${BACKUP_DIR}/backup_${DATE}.bak" remote:backups/database/
```

**4. Test:**

```bash
rclone ls remote:backups/
```

---

## 🗓️ Backup Retention Policy

### Current Policy (Last 7 Days)

| Backup Type | Frequency | Retention | Location |
|-------------|-----------|-----------|----------|
| Database | Daily 2 AM | 7 days | Local VPS |
| Uploads | Daily 3 AM | 7 days | Local VPS |

### Recommended Extended Policy

| Backup Type | Retention | Location |
|-------------|-----------|----------|
| Daily | Last 7 days | Local VPS |
| Weekly | Last 4 weeks | Cloud storage |
| Monthly | Last 12 months | Cloud storage |

### Implement Extended Policy

Update `RETENTION_DAYS` in backup scripts:

```bash
# Keep daily backups for 7 days
RETENTION_DAYS=7

# Keep weekly backups for 28 days (4 weeks)
RETENTION_DAYS=28

# Keep monthly backups for 365 days (1 year)
RETENTION_DAYS=365
```

---

## 🔐 Backup Security

### Current Setup

- ✅ Backups stored on same VPS (local)
- ⚠️ Not encrypted
- ⚠️ No off-site backup

### Recommended Improvements

**1. Encrypt backups:**

```bash
# Encrypt backup
gpg --encrypt --recipient your@email.com backup_file.bak

# Decrypt backup
gpg --decrypt backup_file.bak.gpg > backup_file.bak
```

**2. Secure backup directory:**

```bash
chmod 700 ~/projects/attech-deployment/backups
```

**3. Use encrypted cloud storage (rclone with encryption)**

---

## 🧪 Test Restore Procedure

**Test monthly to ensure backups are working!**

```bash
# 1. Backup current database first
./backup-database.sh

# 2. Restore from older backup
./restore-backup.sh database backups/database/backup_20241110_020000.bak

# 3. Verify application works
curl https://api.attech.online/health

# 4. Restore back to latest
./restore-backup.sh database backups/database/backup_20241114_020000.bak
```

---

## 📞 Troubleshooting

### Backup Failed

```bash
# Check disk space
df -h

# Check docker container
docker ps
docker logs attechserver-db

# Check backup logs
tail -50 backups/backup-database.log
```

### Restore Failed

```bash
# Check backup file integrity
tar -tzf backups/uploads/uploads_20241114_030000.tar.gz

# Check database connection
docker exec -it attechserver-db /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "AttechServer@123" -C -Q "SELECT @@VERSION"
```

### Disk Space Full

```bash
# Find large files
du -sh backups/*

# Manual cleanup (older than 14 days)
find backups/ -name "*.bak" -mtime +14 -delete
find backups/ -name "*.tar.gz" -mtime +14 -delete
```

---

## 🎯 Best Practices

1. ✅ **Test restores regularly** (monthly)
2. ✅ **Monitor backup logs** (weekly)
3. ✅ **Setup off-site backup** (cloud storage)
4. ✅ **Verify backup sizes** (detect issues early)
5. ✅ **Document recovery procedures**
6. ✅ **Keep backups encrypted**
7. ✅ **Multiple backup locations** (3-2-1 rule)

### 3-2-1 Backup Rule

- **3** copies of data (original + 2 backups)
- **2** different storage types (local + cloud)
- **1** off-site backup (cloud)

---

## 📧 Backup Notifications (Optional)

### Send email on backup failure

Add to backup scripts:

```bash
# At the end of script
if [ $? -ne 0 ]; then
    echo "Backup failed at $(date)" | mail -s "Backup Failed" admin@attech.online
fi
```

### Setup sendmail or use SMTP

```bash
sudo apt install sendmail
# Or configure SMTP in script
```

---

## 🆘 Emergency Contacts

- **VPS Provider**: [Contact info]
- **Database Admin**: [Your contact]
- **Backup Location**: `ncpt@103.162.31.91:/home/ncpt/projects/attech-deployment/backups/`

---

## 📝 Change Log

| Date | Action | Notes |
|------|--------|-------|
| 2024-11-14 | Initial setup | Created automated backup system |
