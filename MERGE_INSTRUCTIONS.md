# 🔀 Hướng Dẫn Merge Security Fixes vào Main

## ⚡ Cách Nhanh Nhất (1 lệnh)

```bash
./MERGE_TO_MAIN.sh
```

Script sẽ tự động:
- ✅ Cherry-pick commit security improvements
- ✅ Merge vào main
- ✅ Push lên remote
- ✅ Xóa nhánh claude (local + remote)
- ✅ Xóa sạch mọi dấu vết

---

## 🔧 Cách Thủ Công (nếu muốn kiểm soát từng bước)

### Bước 1: Lấy commit hash
```bash
git log --oneline -1 --grep="security: Major"
# Copy commit hash (ví dụ: 44fd5c2)
```

### Bước 2: Checkout main
```bash
git fetch origin main
git checkout main
git pull origin main
```

### Bước 3: Cherry-pick security commit
```bash
git cherry-pick 44fd5c2  # Thay bằng hash thật
```

### Bước 4: Push main
```bash
git push origin main
```

### Bước 5: Xóa nhánh claude
```bash
# Xóa local
git branch -D claude/review-security-config-012qDQTsDSxoQH9fvFqvBWaa

# Xóa remote
git push origin --delete claude/review-security-config-012qDQTsDSxoQH9fvFqvBWaa

# Clean up references
git remote prune origin
```

### Bước 6: Verify
```bash
git branch -a
# Không còn thấy nhánh claude nữa

git log --oneline -3
# Thấy commit "security: Major security improvements and fixes" trên main
```

---

## 🧹 Sau Khi Merge (Dọn Dẹp Files)

```bash
# Xóa các file hướng dẫn merge này
rm MERGE_TO_MAIN.sh
rm MERGE_INSTRUCTIONS.md

# Commit cleanup
git add -A
git commit -m "chore: Remove merge helper files"
git push origin main
```

---

## ✅ Checklist

- [ ] Chạy `./MERGE_TO_MAIN.sh` HOẶC làm thủ công
- [ ] Verify main đã có commit security improvements
- [ ] Verify nhánh claude đã bị xóa (`git branch -a`)
- [ ] Xóa files MERGE_TO_MAIN.sh và MERGE_INSTRUCTIONS.md
- [ ] Đọc SECURITY.md để setup `.env.production`

---

## 🚨 Lưu Ý Quan Trọng

1. **PHẢI tạo `.env.production`** sau khi merge:
   ```bash
   cp .env.production.example .env.production
   nano .env.production  # Điền passwords thật
   ```

2. **ĐỔI MẬT KHẨU DATABASE** vì mật khẩu cũ đã bị leak vào Git history

3. **Setup SMTP** với Gmail App Password (xem SECURITY.md)

---

**Thời gian thực hiện:** ~2 phút
**Kết quả:** Main branch sạch sẽ, không còn dấu vết claude
