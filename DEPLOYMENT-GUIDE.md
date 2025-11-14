# HƯỚNG DẪN DEPLOY LÊN DOMAIN/VPS MỚI

## BƯỚC 1: CẬP NHẬT CONFIG

### **1.1. Chỉnh sửa `config.sh`:**

```bash
nano config.sh
```

**Sửa các giá trị sau:**

```bash
# DOMAIN CONFIGURATION
export DOMAIN="newdomain.com"                    # ← Đổi domain mới
export API_DOMAIN="api.newdomain.com"            # ← Đổi API domain
export WWW_DOMAIN="www.newdomain.com"            # ← Đổi WWW domain

# VPS CONFIGURATION
export VPS_IP="NEW_VPS_IP"                       # ← Đổi IP VPS mới
export SSH_PORT="22"                             # ← Đổi SSH port (nếu khác)
export DEPLOY_USER="deployuser"                  # ← Đổi username
export DEPLOY_PATH="/home/deployuser/projects/attech-deployment"  # ← Đổi path

# DATABASE CONFIGURATION
export SA_PASSWORD="YourNewPassword@123"         # ← Đổi DB password

# DOCKER IMAGES (nếu đổi GitHub org)
export GITHUB_ORG="your-github-org"              # ← Đổi GitHub org/username
```

### **1.2. Generate .env.production:**

```bash
chmod +x setup-config.sh
./setup-config.sh
```

Script sẽ:
- Hiển thị configuration
- Hỏi confirm
- Generate file `.env.production` tự động

---

## BƯỚC 2: CẬP NHẬT FRONTEND REPO

### **2.1. File `Dockerfile`:**

```dockerfile
ARG REACT_APP_API_HOST=api.newdomain.com    # ← Đổi domain mới
```

### **2.2. File `.env.production`:**

```env
REACT_APP_API_HOST=api.newdomain.com        # ← Đổi domain mới
```

### **2.3. File `.github/workflows/deploy-frontend.yml`:**

```yaml
build-args: |
  REACT_APP_API_HOST=api.newdomain.com      # ← Đổi domain mới

script: |
  cd /home/deployuser/projects/attech-deployment   # ← Đổi path
  curl -f https://newdomain.com || exit 1          # ← Đổi domain
```

---

## BƯỚC 3: CẬP NHẬT BACKEND REPO

### **3.1. File `.github/workflows/deploy-backend.yml`:**

```yaml
script: |
  cd /home/deployuser/projects/attech-deployment        # ← Đổi path
  curl -f https://api.newdomain.com/health || exit 1   # ← Đổi domain
```

---

## BƯỚC 4: SETUP TRÊN VPS

### **4.1. Tạo user và cài Docker:**

```bash
# SSH as root
ssh root@NEW_VPS_IP

# Tạo user
adduser deployuser
usermod -aG sudo deployuser

# Cài Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker deployuser

# Tạo SSH key cho GitHub Actions
su - deployuser
ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/github_deploy
cat ~/.ssh/github_deploy  # Copy private key
```

### **4.2. Setup DNS & SSL:**

```bash
# Verify DNS
nslookup newdomain.com
nslookup api.newdomain.com

# Get SSL
sudo certbot certonly --standalone \
  -d newdomain.com \
  -d www.newdomain.com \
  -d api.newdomain.com \
  --email your@email.com \
  --agree-tos
```

### **4.3. Clone deployment repo:**

```bash
cd ~
mkdir -p projects
cd projects
git clone https://github.com/YOUR_USERNAME/attech-deployment.git
cd attech-deployment
```

### **4.4. Copy SSL certificates:**

```bash
mkdir -p ssl
sudo cp -L /etc/letsencrypt/live/newdomain.com/fullchain.pem ssl/
sudo cp -L /etc/letsencrypt/live/newdomain.com/privkey.pem ssl/
sudo cp /etc/letsencrypt/options-ssl-nginx.conf ssl/
sudo cp /etc/letsencrypt/ssl-dhparams.pem ssl/
sudo chown -R $USER:docker ssl/
```

### **4.5. Setup configuration:**

```bash
# Sửa config.sh (đã sửa từ local rồi git pull về)
# Hoặc sửa trực tiếp trên VPS
nano config.sh

# Generate .env.production
chmod +x setup-config.sh
./setup-config.sh

# Tạo uploads folder
mkdir -p uploads/temp
chmod -R 777 uploads
```

### **4.6. Login GHCR và deploy:**

```bash
# Login to GitHub Container Registry
docker login ghcr.io -u YOUR_GITHUB_USERNAME
# Paste Personal Access Token

# Deploy
chmod +x initial-setup.sh
sudo ./initial-setup.sh
```

---

## BƯỚC 5: SETUP GITHUB SECRETS

### **5.1. Add vào Backend repo:**

`https://github.com/YOUR_USERNAME/backend-repo/settings/secrets/actions`

- `SSH_PRIVATE_KEY`: Copy từ `~/.ssh/github_deploy`
- `SSH_HOST`: `NEW_VPS_IP`
- `SSH_PORT`: `22` (hoặc custom)
- `SSH_USER`: `deployuser`

### **5.2. Add vào Frontend repo:**

Làm tương tự.

### **5.3. Set repository permissions:**

Cả 2 repos:
- Settings → Actions → General
- Workflow permissions: **Read and write permissions** ✓
- Allow GitHub Actions to create and approve pull requests ✓

---

## BƯỚC 6: TEST CI/CD

```bash
# Push code để trigger workflow
cd backend-repo
git commit --allow-empty -m "Test deploy to new domain"
git push

cd frontend-repo
git commit --allow-empty -m "Test deploy to new domain"
git push
```

Check workflows:
- https://github.com/YOUR_USERNAME/backend-repo/actions
- https://github.com/YOUR_USERNAME/frontend-repo/actions

---

## CHECKLIST

- [ ] **config.sh**: Đã sửa domain, VPS IP, paths
- [ ] **Frontend Dockerfile**: Đã sửa ARG default
- [ ] **Frontend .env.production**: Đã sửa API host
- [ ] **Frontend workflow**: Đã sửa build-args, deploy path, health check
- [ ] **Backend workflow**: Đã sửa deploy path, health check
- [ ] **VPS**: User, Docker, DNS, SSL đã setup
- [ ] **VPS**: Deployment repo đã clone và setup
- [ ] **VPS**: SSL certificates đã copy vào ssl/
- [ ] **VPS**: .env.production đã generate từ config.sh
- [ ] **VPS**: Uploads folder đã tạo với permissions đúng
- [ ] **VPS**: Đã login GHCR thành công
- [ ] **VPS**: initial-setup.sh đã chạy thành công
- [ ] **GitHub Secrets**: Đã add 4 secrets vào cả 2 repos
- [ ] **GitHub**: Repository permissions đã set đúng
- [ ] **CI/CD**: Test push và verify auto-deploy thành công

---

## TÓM TẮT: CẦN SỬA GÌ?

| File | Location | Cần sửa |
|------|----------|---------|
| `config.sh` | Deployment repo | Domain, VPS IP, paths, password |
| `Dockerfile` | Frontend repo | ARG default domain |
| `.env.production` | Frontend repo | API host |
| `deploy-frontend.yml` | Frontend repo | Build-args, deploy path, health check |
| `deploy-backend.yml` | Backend repo | Deploy path, health check |

**Tổng: 5 files cần sửa**

Sau khi sửa xong → commit → push → CI/CD tự động deploy! 🚀
