# 🔒 Security Guide - ATTECH Deployment

## ⚠️ CRITICAL: Secrets Management

### 🚨 NEVER commit these files to Git:
- `.env.production` - Contains real passwords and secrets
- `ssl/` directory - SSL certificates and private keys
- Any files containing passwords, API keys, or tokens

### ✅ How to Setup Secrets Securely

#### Step 1: Create `.env.production` file

```bash
# Copy the example file
cp .env.production.example .env.production

# Edit with real values (use nano, vim, or any editor)
nano .env.production
```

#### Step 2: Generate Strong Passwords

**For Database Password (SA_PASSWORD):**
```bash
# Generate a strong 32-character password
openssl rand -base64 32

# Or use this pattern (20+ chars, mixed case, numbers, symbols):
# Example: Xk9#mP2$vL8@nQ5&wR7!zA3%bC6^
```

**Requirements:**
- Minimum 20 characters
- Include: uppercase, lowercase, numbers, special characters
- Do NOT use common words or patterns

#### Step 3: Setup SMTP Credentials

**For Gmail:**
1. Go to: https://myaccount.google.com/apppasswords
2. Generate an App Password (16 characters)
3. Use this in `SMTP_PASSWORD`, NOT your real Gmail password

**Update .env.production:**
```bash
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=abcd efgh ijkl mnop  # App password from Google
```

#### Step 4: Verify .env.production is NOT tracked by Git

```bash
# Check Git status
git status

# .env.production should NOT appear in the list
# If it does, add it to .gitignore immediately!
```

---

## 🔐 Security Features Implemented

### 1. **HTTPS/TLS Configuration**
- ✅ HTTP to HTTPS redirect
- ✅ HSTS enabled (max-age=31536000)
- ✅ HTTP/2 enabled
- ✅ Strong SSL ciphers
- ✅ Let's Encrypt certificates

### 2. **Security Headers**
- ✅ **HSTS**: Force HTTPS connections
- ✅ **CSP**: Content Security Policy to prevent XSS
- ✅ **X-Frame-Options**: Prevent clickjacking (DENY)
- ✅ **X-Content-Type-Options**: Prevent MIME sniffing
- ✅ **Referrer-Policy**: Control referrer information
- ✅ **Permissions-Policy**: Disable dangerous browser features

### 3. **Rate Limiting**
- ✅ API: 100 requests/second (burst 20)
- ✅ Login: 10 requests/minute
- ✅ Protection against brute force attacks

### 4. **CORS Configuration**
- ✅ Whitelist specific domains only
- ✅ Credentials properly controlled
- ✅ No wildcard (*) origins

### 5. **File Upload Security**
- ✅ Max upload size: 100MB (configurable)
- ✅ Files served with proper headers

---

## 🔍 Security Checklist (Before Production Deployment)

### Pre-Deployment
- [ ] Created `.env.production` with strong passwords
- [ ] Verified `.env.production` is in `.gitignore`
- [ ] Changed default database password from example
- [ ] Setup SMTP with App Password (not real password)
- [ ] All `.sh` scripts have executable permissions (755)
- [ ] SSL certificates installed in `ssl/` directory

### Post-Deployment
- [ ] HTTPS is working (test: https://attech.online)
- [ ] HTTP redirects to HTTPS
- [ ] Security headers are present (test with: https://securityheaders.com)
- [ ] Rate limiting is working
- [ ] Database connection is secure
- [ ] Email sending works

### Regular Maintenance
- [ ] Update SSL certificates before expiration (Let's Encrypt auto-renews)
- [ ] Review security headers monthly
- [ ] Monitor failed login attempts
- [ ] Update dependencies regularly
- [ ] Backup database and uploads

---

## 🛡️ Content Security Policy (CSP)

### Current Policy

**Frontend:**
- Scripts: Only from same origin (`'self'`)
- Styles: Same origin + Google Fonts + CDNs
- Images: Same origin + API + Google services
- Frames: YouTube + Google Maps only

**Backend API:**
- Stricter policy: `default-src 'none'`
- APIs typically don't serve HTML/JS

### ⚠️ If Website Breaks After CSP Update

1. **Check Browser Console:**
   ```
   Open DevTools (F12) → Console tab
   Look for CSP violation errors
   ```

2. **Temporary Fix:**
   ```nginx
   # Add 'unsafe-inline' back temporarily (NOT recommended for production)
   script-src 'self' 'unsafe-inline';
   ```

3. **Proper Fix:**
   - Use nonce-based CSP
   - Move inline scripts to external files
   - Use CSP hash for specific inline scripts

---

## 🚨 Security Incident Response

### If Credentials Are Compromised:

1. **Immediately change passwords:**
   ```bash
   # Update .env.production with new password
   nano .env.production

   # Restart services
   docker-compose -f docker-compose.fullstack.yml \
     -f docker-compose.fullstack.production.yml down

   docker-compose -f docker-compose.fullstack.yml \
     -f docker-compose.fullstack.production.yml up -d
   ```

2. **Check for unauthorized access:**
   ```bash
   # Review nginx access logs
   tail -n 100 /var/log/nginx/access.log

   # Check for suspicious IPs
   grep "POST /api/login" /var/log/nginx/access.log
   ```

3. **If passwords were committed to Git:**
   ```bash
   # ⚠️ WARNING: This rewrites Git history!
   # Coordinate with team before running

   # Remove sensitive data from Git history
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch .env.production" \
     --prune-empty --tag-name-filter cat -- --all

   # Force push (DANGEROUS!)
   git push origin --force --all
   ```

---

## 📊 Security Monitoring

### Tools for Testing:

1. **Security Headers:**
   - https://securityheaders.com/?q=https://attech.online
   - https://observatory.mozilla.org/analyze/attech.online

2. **SSL/TLS:**
   - https://www.ssllabs.com/ssltest/analyze.html?d=attech.online

3. **Manual Testing:**
   ```bash
   # Check security headers
   curl -I https://attech.online | grep -i "strict-transport\|content-security\|x-frame"

   # Test rate limiting
   for i in {1..150}; do curl -I https://api.attech.online/health; done

   # Verify HTTPS redirect
   curl -I http://attech.online
   ```

---

## 🔗 Security Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
- [Mozilla Web Security Guidelines](https://infosec.mozilla.org/guidelines/web_security)
- [Content Security Policy Guide](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
- [Let's Encrypt Best Practices](https://letsencrypt.org/docs/)

---

## 📞 Support

For security concerns or questions:
- Review this guide
- Check deployment documentation
- Test in staging environment first
- Never commit secrets to Git!

---

**Last Updated:** 2025-11-17
**Version:** 1.0
**Maintained by:** ATTECH DevOps Team
