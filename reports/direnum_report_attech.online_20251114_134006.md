# 🔍 Directory Enumeration Scan Report

**Scan Time:** 2025-11-14 13:39:57
**Target:** https://attech.online
**Assessment:** 🔴 SENSITIVE PATHS EXPOSED

---

## Summary

- **Total Paths Found:** 20
- **Sensitive Paths:** 6
- **Risk Level:** High
- **CVSS Score:** 7.5
- **Protection Score:** 20/100

---

## Found Paths

### admin
- **Status:** 200
- **Size:** 2449 bytes

### administrator
- **Status:** 200
- **Size:** 2449 bytes

### backup
- **Status:** 200
- **Size:** 2449 bytes

### backups
- **Status:** 200
- **Size:** 2449 bytes

### config
- **Status:** 200
- **Size:** 2449 bytes

### configs
- **Status:** 200
- **Size:** 2449 bytes

### data
- **Status:** 200
- **Size:** 2449 bytes

### database
- **Status:** 200
- **Size:** 2449 bytes

### db
- **Status:** 200
- **Size:** 2449 bytes

### debug
- **Status:** 200
- **Size:** 2449 bytes

### dev
- **Status:** 200
- **Size:** 2449 bytes

### development
- **Status:** 200
- **Size:** 2449 bytes

### docs
- **Status:** 200
- **Size:** 2449 bytes

### download
- **Status:** 200
- **Size:** 2449 bytes

### downloads
- **Status:** 200
- **Size:** 2449 bytes

### files
- **Status:** 200
- **Size:** 2449 bytes

### images
- **Status:** 200
- **Size:** 2449 bytes

### img
- **Status:** 200
- **Size:** 2449 bytes

### includes
- **Status:** 200
- **Size:** 2449 bytes

### js
- **Status:** 200
- **Size:** 2449 bytes

---

## Issues

- 6 sensitive paths exposed
- Exposed: admin (HTTP 200)
- Exposed: administrator (HTTP 200)
- Exposed: backup (HTTP 200)
- Exposed: backups (HTTP 200)
- Exposed: config (HTTP 200)
- Exposed: configs (HTTP 200)

---

## Remediation

### Disable Directory Listing

**Apache (.htaccess):**
```apache
Options -Indexes
```

**Nginx:**
```nginx
autoindex off;
```

### Remove Sensitive Files

```bash
# Remove version control
rm -rf .git .svn

# Remove config files from web root
rm .env config.yml database.yml

# Remove backup files
find . -name "*.bak" -delete
find . -name "*~" -delete
```

### Use robots.txt Wisely

**Note:** robots.txt does NOT provide security. Use proper access controls instead.

```
# robots.txt example
User-agent: *
Disallow: /admin/
Disallow: /private/
```

---

**Report Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
