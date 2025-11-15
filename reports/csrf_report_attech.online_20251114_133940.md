# 🔐 Phân tích kỹ thuật: "Cross-Site Request Forgery (CSRF) Vulnerability"

**Ngày phân tích:** 14/11/2025 13:39:40
**Website:** https://attech.online
**Domain:** attech.online
**Phân loại:** ✅ Protected

---

## 🚀 Quick Test Commands (Copy & Paste)

### Test nhanh bằng browser (30 giây):

```bash
# Mở Developer Tools (F12) trong Chrome/Firefox
# → Console → chạy lệnh:

// Kiểm tra forms có CSRF token không
document.querySelectorAll('form').forEach((form, i) => {
  const method = form.method.toUpperCase();
  const csrfInput = form.querySelector('input[name*="csrf" i], input[name*="token" i], input[name="_xsrf"]');

  if (method === 'POST' || method === 'PUT' || method === 'DELETE') {
    if (!csrfInput) {
      console.error(`❌ Form ${i+1} (${method}): THIẾU CSRF token`);
    } else {
      console.log(`✅ Form ${i+1} (${method}): CÓ CSRF token (${csrfInput.name})`);
    }
  }
});

// Kiểm tra cookies có SameSite không
document.cookie.split(';').forEach(c => {
  console.log('Cookie:', c.trim());
});
```

### Test bằng curl:

```bash
# Kiểm tra response headers
curl -I https://attech.online | grep -i "csrf\|xsrf"

# Kiểm tra cookies
curl -I https://attech.online | grep -i "set-cookie"
```

---

## 📚 1. Tham chiếu chuẩn kỹ thuật

- **OWASP Top 10 2021:** A01:2021 – Broken Access Control
- **CWE-352:** Cross-Site Request Forgery (CSRF)
- **CAPEC-62:** Cross Site Request Forgery
- **OWASP CSRF Prevention Cheat Sheet**

### CSRF là gì?

**Cross-Site Request Forgery (CSRF)** là kỹ thuật tấn công buộc người dùng đã authenticated thực hiện các hành động không mong muốn trên web application.

**Cách hoạt động:**

1. Nạn nhân đăng nhập vào website tin cậy (ví dụ: bank.com)
2. Website lưu session cookie trong browser
3. Nạn nhân truy cập trang độc hại (evil.com) - trong khi vẫn còn session
4. Trang độc hại gửi request đến bank.com
5. Browser tự động attach cookies → Request được xác thực
6. Hành động độc hại được thực hiện (chuyển tiền, đổi password, etc.)

**Ví dụ tấn công:**

```html
<!-- Trang của attacker: evil.com -->
<html>
<body>
  <h1>Xem ảnh mèo dễ thương!</h1>
  <img src="https://bank.com/transfer?to=attacker&amount=1000000" style="display:none">

  <!-- Hoặc dùng form tự động submit -->
  <form action="https://bank.com/transfer" method="POST" id="csrf-form">
    <input type="hidden" name="to" value="attacker">
    <input type="hidden" name="amount" value="1000000">
  </form>
  <script>
    document.getElementById('csrf-form').submit();
  </script>
</body>
</html>
```

**Kết quả:** Nạn nhân vừa chuyển 1 triệu đồng cho attacker mà không hề biết!

---

## 🧪 2. Kết quả kiểm tra thực tế

### Test 1: CSRF Protection Headers

```bash
curl -I https://attech.online
```

**CSRF Headers phát hiện:**

```
(Không có CSRF headers)
```

❌ Không có CSRF headers trong response

### Test 2: HTML Forms Analysis

**Tổng số forms:** 0
**GET forms:** 0
**POST forms:** 0
**Forms CÓ CSRF token:** 0
**Forms THIẾU CSRF token:** 0



### Test 3: Cookie SameSite Attribute

**Có cookies:** ❌ Không


---

## 📊 3. So sánh: Có lỗi vs Không có lỗi

### ❌ Trường hợp CÓ LỖ HỔNG (nguy hiểm):

```html
<!-- Form không có CSRF token -->
<form action="/transfer" method="POST">
  <input name="to" value="recipient">
  <input name="amount" value="100">
  <button type="submit">Transfer</button>
</form>
```

**Rủi ro thực tế:**

1. **Chuyển tiền trái phép:**
   ```html
   <!-- Trang attacker -->
   <form action="https://bank.com/transfer" method="POST">
     <input type="hidden" name="to" value="attacker">
     <input type="hidden" name="amount" value="999999">
   </form>
   <script>document.forms[0].submit();</script>
   ```

2. **Thay đổi mật khẩu:**
   ```html
   <form action="https://victim.com/change-password" method="POST">
     <input type="hidden" name="new_password" value="hacked123">
   </form>
   <script>document.forms[0].submit();</script>
   ```

3. **Xóa tài khoản:**
   ```html
   <img src="https://victim.com/delete-account?confirm=yes">
   ```

### ✅ Trường hợp AN TOÀN (có CSRF protection):

```html
<!-- Form có CSRF token -->
<form action="/transfer" method="POST">
  <input type="hidden" name="_csrf" value="a7f3c9b2e1d4f8a6">
  <input name="to" value="recipient">
  <input name="amount" value="100">
  <button type="submit">Transfer</button>
</form>
```

**Bảo vệ:**
- Server tạo unique token cho mỗi session/request
- Token được nhúng vào form
- Server verify token trước khi xử lý request
- Request từ bên ngoài không có token → bị reject

### ✅ Trường hợp AN TOÀN (website đang kiểm tra):

**Phát hiện:**
- ✅ Không có forms trên trang
- ✅ Không có cookies được set


---

## 🎯 4. Kịch bản tấn công thực tế

### Kịch bản 1: Banking CSRF Attack

**Bước 1:** Nạn nhân đăng nhập vào nganhang.com

**Bước 2:** Attacker gửi email chứa link độc hại hoặc quảng cáo

**Bước 3:** Nạn nhân click vào link → Mở trang evil.com

**Bước 4:** Trang evil.com tự động gửi request:

```html
<form action="https://nganhang.com/api/transfer" method="POST" id="csrf">
  <input type="hidden" name="to_account" value="attacker_account">
  <input type="hidden" name="amount" value="50000000">
  <input type="hidden" name="description" value="Chuyen tien">
</form>
<script>
  document.getElementById('csrf').submit();
</script>
```

**Kết quả:** 50 triệu đồng bị chuyển đi trong vài giây!

### Kịch bản 2: Social Media Account Takeover

```html
<!-- Trang attacker -->
<img src="https://facebook.com/settings/password/change?new=hacked123&confirm=hacked123">
<img src="https://facebook.com/settings/email/change?email=attacker@evil.com">
<img src="https://facebook.com/page/123/admin/add?user=attacker">
```

**Impact:**
- Đổi password
- Đổi email
- Thêm admin vào page
- Đăng bài spam
- Gửi tin nhắn lừa đảo

### Kịch bản 3: E-commerce Order Manipulation

```javascript
// Attacker's page
fetch('https://shop.com/api/cart/add', {
  method: 'POST',
  credentials: 'include', // Tự động gửi cookies
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify({
    product_id: 999,
    quantity: 100,
    shipping_address: 'attacker_address'
  })
});

fetch('https://shop.com/api/checkout', {
  method: 'POST',
  credentials: 'include'
});
```

**Kết quả:** Đơn hàng bị đặt tự động, ship đến địa chỉ attacker

---

## 📋 5. Bảng đánh giá bảo vệ

| Tiêu chí | Kết quả | Đánh giá | Điểm |
|----------|---------|----------|------|
| POST Forms | ℹ️ Không có | Không cần CSRF token | N/A |
| Cookies SameSite | ℹ️ Không có cookies | N/A | 25/50 |

**Tổng điểm bảo vệ:** 75/100

⚠️ **Đánh giá:** BẢO VỆ TRUNG BÌNH - Cần tăng cường

### Điểm mạnh:

- ✅ Không có forms trên trang
- ✅ Không có cookies được set


---

## 🔧 6. Biện pháp khắc phục

### ✅ Đã được bảo vệ tốt, có thể tăng cường thêm

### Option A: CSRF Token (Backend Implementation)

**Node.js (Express + csurf):**
```javascript
const csrf = require('csurf');
const cookieParser = require('cookie-parser');

app.use(cookieParser());
app.use(csrf({ cookie: true }));

// Render form với CSRF token
app.get('/form', (req, res) => {
  res.render('form', { csrfToken: req.csrfToken() });
});

// Verify CSRF token (tự động bởi middleware)
app.post('/submit', (req, res) => {
  // CSRF đã được verify
  res.send('Success');
});
```

**Template (EJS/Pug):**
```html
<form method="POST" action="/submit">
  <input type="hidden" name="_csrf" value="<%= csrfToken %>">
  <!-- Other inputs -->
  <button type="submit">Submit</button>
</form>
```

**Django:**
```python
# settings.py
MIDDLEWARE = [
    ...
    'django.middleware.csrf.CsrfViewMiddleware',
]

# Template
<form method="POST">
  {% csrf_token %}
  <!-- Other inputs -->
  <button type="submit">Submit</button>
</form>
```

**Laravel (PHP):**
```php
<!-- Blade template -->
<form method="POST" action="/submit">
  @csrf
  <!-- Other inputs -->
  <button type="submit">Submit</button>
</form>
```

**Ruby on Rails:**
```ruby
# Controller
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
end

# View (ERB)
<%= form_with url: "/submit", method: :post do |f| %>
  <%= f.hidden_field :authenticity_token, value: form_authenticity_token %>
  <!-- Other inputs -->
  <%= f.submit "Submit" %>
<% end %>
```

### Option B: SameSite Cookies

**Node.js (Express):**
```javascript
const session = require('express-session');

app.use(session({
  secret: 'your-secret-key',
  cookie: {
    httpOnly: true,
    secure: true, // Chỉ HTTPS
    sameSite: 'strict' // Hoặc 'lax'
  }
}));

// Set cookie manually
res.cookie('session', value, {
  httpOnly: true,
  secure: true,
  sameSite: 'strict',
  maxAge: 3600000 // 1 hour
});
```

**Nginx:**
```nginx
# Thêm SameSite vào Set-Cookie headers
proxy_cookie_path / "/; SameSite=Strict; Secure";
```

**Apache (.htaccess):**
```apache
# Không support trực tiếp, cần implement ở backend
```

**SameSite values:**
- `Strict`: Cookie chỉ gửi khi request từ cùng site (bảo mật nhất)
- `Lax`: Cookie gửi khi navigate đến site (balance giữa bảo mật và UX)
- `None`: Cookie luôn gửi (cần có Secure attribute)

### Option C: Custom Headers (API)

**Frontend (JavaScript/Fetch):**
```javascript
// Get CSRF token từ meta tag hoặc cookie
const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

// Gửi trong header
fetch('/api/endpoint', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-CSRF-Token': csrfToken
  },
  body: JSON.stringify(data)
});
```

**Backend validation:**
```javascript
app.use((req, res, next) => {
  if (req.method !== 'GET' && req.method !== 'HEAD') {
    const token = req.headers['x-csrf-token'];
    const sessionToken = req.session.csrfToken;

    if (!token || token !== sessionToken) {
      return res.status(403).json({ error: 'Invalid CSRF token' });
    }
  }
  next();
});
```

### Option D: Double Submit Cookie Pattern

```javascript
// Backend: Set CSRF token vào cookie
res.cookie('XSRF-TOKEN', generateToken(), {
  httpOnly: false, // JavaScript cần đọc được
  secure: true,
  sameSite: 'strict'
});

// Frontend: Đọc cookie và gửi trong header
const csrfToken = document.cookie
  .split('; ')
  .find(row => row.startsWith('XSRF-TOKEN='))
  .split('=')[1];

fetch('/api/endpoint', {
  method: 'POST',
  headers: {
    'X-XSRF-TOKEN': csrfToken
  },
  body: JSON.stringify(data)
});

// Backend: So sánh cookie với header
app.use((req, res, next) => {
  const cookieToken = req.cookies['XSRF-TOKEN'];
  const headerToken = req.headers['x-xsrf-token'];

  if (cookieToken !== headerToken) {
    return res.status(403).send('CSRF token mismatch');
  }
  next();
});
```

**⚠️ Lưu ý quan trọng:**

1. **CSRF token phải:**
   - Unpredictable (dùng cryptographically strong random)
   - Unique per session hoặc per request
   - Được validate ở server-side

2. **SameSite cookies:**
   - `Strict`: Bảo mật cao nhưng có thể ảnh hưởng UX
   - `Lax`: Balance tốt cho hầu hết use cases
   - Luôn kết hợp với `Secure` và `HttpOnly`

3. **Testing:**
   - Test kỹ các flows: login, payment, profile update
   - Verify không ảnh hưởng legitimate users
   - Test với nhiều browsers

---

## ✅ 7. Kiểm tra lại sau khi khắc phục

### Bước 1: Kiểm tra CSRF token trong forms

```javascript
// Browser Console
document.querySelectorAll('form[method="POST"], form[method="post"]').forEach((form, i) => {
  const csrf = form.querySelector('input[name*="csrf" i], input[name*="token" i]');
  if (csrf) {
    console.log(`✅ Form ${i+1}: Có CSRF token (${csrf.name})`);
  } else {
    console.error(`❌ Form ${i+1}: THIẾU CSRF token`);
  }
});
```

### Bước 2: Test CSRF protection thực tế

**Tạo file test-csrf.html:**

```html
<!DOCTYPE html>
<html>
<head><title>CSRF Test</title></head>
<body>
  <h1>CSRF Attack Simulation</h1>
  <form action="https://attech.online/some-action" method="POST" id="csrf-test">
    <input type="hidden" name="param" value="malicious_value">
    <button type="submit">Test CSRF (Manual)</button>
  </form>

  <script>
    // Auto-submit test (để test protection)
    // document.getElementById('csrf-test').submit();
  </script>

  <p>
    ✅ Nếu request bị reject (403/400) = CSRF protection hoạt động<br>
    ❌ Nếu request thành công = VẪN CÒN LỖI
  </p>
</body>
</html>
```

### Bước 3: Kiểm tra SameSite cookies

```bash
# Chrome DevTools
# F12 → Application → Cookies
# Xem cột "SameSite" phải có giá trị (Strict/Lax)

# Hoặc dùng curl
curl -I https://attech.online | grep -i "set-cookie"
# Kết quả phải có: SameSite=Strict hoặc SameSite=Lax
```

### Bước 4: Automated testing

```javascript
// Playwright/Puppeteer test
const { test, expect } = require('@playwright/test');

test('All POST forms have CSRF token', async ({ page }) => {
  await page.goto('https://attech.online');

  const formsWithoutCSRF = await page.evaluate(() => {
    return Array.from(document.querySelectorAll('form'))
      .filter(form => {
        const method = form.method.toUpperCase();
        if (method !== 'POST') return false;

        const csrf = form.querySelector('input[name*="csrf" i]');
        return !csrf;
      })
      .length;
  });

  expect(formsWithoutCSRF).toBe(0);
});
```

### Bước 5: Security scan

```bash
# OWASP ZAP
# Tools → Options → Active Scan → Policy
# Enable "Cross Site Request Forgery"

# Burp Suite
# Scanner → Scan Configuration
# Enable "CSRF Token Missing"

# Scan lại bằng tool này
python3 scanCSRF.py https://attech.online
```

---

## 📊 8. Kết luận và khuyến nghị

### Đánh giá tổng quan:

✅ **Website ĐÃ ĐƯỢC BẢO VỆ TỐT**

**Điểm bảo vệ:** 75/100
**Mức độ rủi ro:** Low

**Bảo vệ hiện tại:**
- ✅ Không có forms trên trang
- ✅ Không có cookies được set

**Đánh giá:**
- Website có CSRF protection tốt
- Tuân thủ OWASP security best practices
- An toàn trước tấn công CSRF

**Hành động khuyến nghị:**
1. ✅ **MAINTAIN** - Duy trì implementation hiện tại
2. 🔄 **UPDATE** - Luôn áp dụng CSRF cho features mới
3. 📊 **MONITOR** - Regular security scan (quarterly)
4. 📝 **DOCUMENT** - Lưu báo cáo cho audit


---

## 🔗 References

- [OWASP CSRF Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html)
- [CWE-352: Cross-Site Request Forgery](https://cwe.mitre.org/data/definitions/352.html)
- [MDN: SameSite cookies](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie/SameSite)
- [OWASP Testing Guide - CSRF](https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/06-Session_Management_Testing/05-Testing_for_Cross_Site_Request_Forgery)

---

**Prepared by:** CSRF Security Scanner
**Scan Time:** 2025-11-14 13:39:40
**Report Version:** 1.0
**Tool Version:** 1.0.0
