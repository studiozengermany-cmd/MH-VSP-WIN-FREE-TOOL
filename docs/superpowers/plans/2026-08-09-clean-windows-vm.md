# Clean Windows VM Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Làm sạch dự án và tạo bộ Windows 10 VM tối thiểu, báo lỗi thật, kiểm chứng được trên GitHub Codespaces.

**Architecture:** Docker Compose build một image Ubuntu chứa QEMU và noVNC. `entrypoint.sh` tải ISO nguyên tử, tạo disk, chạy QEMU cùng websockify, giám sát tiến trình để container dừng khi dịch vụ lỗi.

**Tech Stack:** Docker, Docker Compose, Bash, QEMU/KVM, noVNC, websockify, GitHub Codespaces.

## Global Constraints

- Bộ chạy chỉ gồm `Dockerfile`, `entrypoint.sh`, `docker-compose.yml`, `README.md`.
- Không thêm dependency ngoài package Ubuntu hiện có.
- ISO tải vào file tạm; chỉ đổi tên sau khi tải thành công và khác rỗng.
- Container phải dừng khi QEMU hoặc websockify chết.
- Không cam kết Codespaces miễn phí vĩnh viễn, hiệu năng RDP, hoặc URL ISO luôn hoạt động.
- Không báo hoàn tất trước khi có kết quả lệnh kiểm chứng thật.

---

### Task 1: Làm sạch artifact Gemini

**Files:**
- Delete: `Deploying Windows 10 VM via GitHub gemini loi.md`
- Delete: `file build docker image.txt`
- Delete: `file check docker.txt`
- Delete: `file huong dan goc.md`
- Delete: `file start docker container.txt`

**Interfaces:**
- Consumes: phê duyệt xóa trực tiếp của anh.
- Produces: working tree không còn năm artifact.

- [ ] **Step 1: Xác nhận đúng năm file đang tồn tại**

Run:
```powershell
Get-Item -LiteralPath 'Deploying Windows 10 VM via GitHub gemini loi.md','file build docker image.txt','file check docker.txt','file huong dan goc.md','file start docker container.txt' | Select-Object Name,Length
```
Expected: đúng năm tên file, không có file khác.

- [ ] **Step 2: Xóa đúng năm file đã duyệt**

Run:
```powershell
Remove-Item -LiteralPath 'Deploying Windows 10 VM via GitHub gemini loi.md','file build docker image.txt','file check docker.txt','file huong dan goc.md','file start docker container.txt' -Force -Confirm:$false
```
Expected: lệnh thành công, không xóa file lõi.

- [ ] **Step 3: Kiểm tra trạng thái**

Run:
```powershell
git status --short
```
Expected: năm file không còn xuất hiện; spec và plan vẫn tồn tại.

### Task 2: Làm tải ISO và giám sát tiến trình an toàn

**Files:**
- Modify: `entrypoint.sh:1-67`
- Create: `tests/entrypoint-static.sh`

**Interfaces:**
- Consumes: biến môi trường `ISO_URL`; volume `/iso`, `/data`; thiết bị `/dev/kvm` tùy chọn.
- Produces: `/iso/win10.iso`, `/data/win10.qcow2`; PID QEMU và websockify được `wait -n` giám sát.

- [ ] **Step 1: Viết static test thất bại**

Create `tests/entrypoint-static.sh`:
```bash
#!/usr/bin/env bash
set -euo pipefail
script=entrypoint.sh
grep -F 'ISO_TMP="/iso/win10.iso.part"' "$script"
grep -F 'mv "$ISO_TMP" "$ISO_PATH"' "$script"
grep -F 'trap cleanup EXIT INT TERM' "$script"
grep -F 'wait -n "$QEMU_PID" "$NOVNC_PID"' "$script"
if grep -Fq 'tail -f /dev/null' "$script"; then
  echo 'entrypoint still masks process failures' >&2
  exit 1
fi
```

- [ ] **Step 2: Chạy test để xác nhận thất bại**

Run in Codespace:
```bash
bash tests/entrypoint-static.sh
```
Expected: FAIL vì chưa có `ISO_TMP`.

- [ ] **Step 3: Viết implementation tối thiểu**

Replace `entrypoint.sh` bằng:
```bash
#!/usr/bin/env bash
set -euo pipefail

ISO_PATH="/iso/win10.iso"
ISO_TMP="/iso/win10.iso.part"
DISK_PATH="/data/win10.qcow2"
QEMU_PID=""
NOVNC_PID=""

cleanup() {
  [ -z "$NOVNC_PID" ] || kill "$NOVNC_PID" 2>/dev/null || true
  [ -z "$QEMU_PID" ] || kill "$QEMU_PID" 2>/dev/null || true
  rm -f "$ISO_TMP"
}
trap cleanup EXIT INT TERM

if [ -e /dev/kvm ]; then
  echo "KVM acceleration available"
  KVM_ARGS=(-enable-kvm -cpu host -m 4G -smp 4)
else
  echo "KVM unavailable; using slower TCG emulation"
  KVM_ARGS=(-cpu qemu64 -m 2G -smp 1)
fi

if [ ! -s "$ISO_PATH" ]; then
  rm -f "$ISO_PATH" "$ISO_TMP"
  echo "Downloading Windows 10 ISO"
  wget --progress=dot:giga --tries=3 --timeout=30 "$ISO_URL" -O "$ISO_TMP"
  test -s "$ISO_TMP"
  mv "$ISO_TMP" "$ISO_PATH"
fi

if [ ! -f "$DISK_PATH" ]; then
  echo "Creating 100GB virtual disk"
  qemu-img create -f qcow2 "$DISK_PATH" 100G
fi

qemu-system-x86_64 \
  "${KVM_ARGS[@]}" \
  -machine q35,accel=kvm:tcg \
  -vga std \
  -usb -device usb-tablet \
  -boot order=d,menu=on \
  -drive file="$DISK_PATH",format=qcow2 \
  -drive file="$ISO_PATH",media=cdrom,readonly=on \
  -netdev user,id=net0,hostfwd=tcp::3389-:3389 \
  -device e1000,netdev=net0 \
  -display vnc=:0 \
  -name Windows10_VM &
QEMU_PID=$!

websockify --web /usr/share/novnc 6080 localhost:5900 &
NOVNC_PID=$!

echo "noVNC: port 6080; RDP after Windows setup: port 3389"
wait -n "$QEMU_PID" "$NOVNC_PID"
echo "QEMU or noVNC exited unexpectedly" >&2
exit 1
```

- [ ] **Step 4: Chạy test cú pháp và static test**

Run in Codespace:
```bash
bash -n entrypoint.sh
bash tests/entrypoint-static.sh
```
Expected: cả hai exit 0.

- [ ] **Step 5: Commit logic runtime**

```bash
git add entrypoint.sh tests/entrypoint-static.sh
git commit -m "fix: surface VM startup failures"
```

### Task 3: Chuẩn hóa image và Compose

**Files:**
- Modify: `Dockerfile:1-35`
- Modify: `docker-compose.yml:1-17`

**Interfaces:**
- Consumes: `entrypoint.sh`, `/dev/kvm`, named volumes.
- Produces: service `vps-win`, ports 6080/3389, image có QEMU/noVNC.

- [ ] **Step 1: Validate Compose hiện tại**

Run in Codespace:
```bash
docker compose config --quiet
```
Expected: exit 0.

- [ ] **Step 2: Thu gọn Dockerfile**

Giữ package `qemu-system-x86`, `qemu-utils`, `novnc`, `websockify`, `wget`; bỏ `curl`, `net-tools`, `python3`, `unzip` cùng bước tải noVNC master vì package `novnc` đã cung cấp web root. Đặt:
```dockerfile
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
ENV ISO_URL="https://archive.org/download/windows-10-lite-edition-19h2-x64/Windows%2010%20Lite%20Edition%2019H2%20x64.iso"
RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-system-x86 qemu-utils novnc websockify wget \
    && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /data /iso
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 6080 3389
CMD ["/entrypoint.sh"]
```

- [ ] **Step 3: Giữ Compose tối thiểu**

Giữ service, device, ports, volumes hiện tại. Bỏ comment thừa; không thêm `privileged`.

- [ ] **Step 4: Validate và build**

Run in Codespace:
```bash
docker compose config --quiet
docker compose build --no-cache
```
Expected: config exit 0; build thành công.

- [ ] **Step 5: Commit container config**

```bash
git add Dockerfile docker-compose.yml
git commit -m "chore: minimize Windows VM image"
```

### Task 4: Viết README đúng bằng chứng

**Files:**
- Modify: `README.md:1-55`

**Interfaces:**
- Consumes: service và port từ Compose.
- Produces: hướng dẫn độc lập cho người mới.

- [ ] **Step 1: Viết README với đúng luồng**

README phải có các mục: yêu cầu Codespaces có `/dev/kvm`; tạo Codespace; chạy `docker compose up -d --build`; xem `docker compose logs -f`; mở port 6080; cài Windows; dùng 3389 chỉ sau khi bật RDP trong Windows; lệnh dừng `docker compose down`; cảnh báo volume giữ dữ liệu; không dùng `down -v` trừ khi muốn xóa VM.

- [ ] **Step 2: Kiểm tra lệnh cũ và cam kết sai**

Run:
```bash
! grep -nE 'docker-compose|miễn phí vĩnh viễn|100%|1 đến 3 phút|10-15 phút' README.md
```
Expected: exit 0, không có nội dung hứa quá mức hoặc cú pháp Compose cũ.

- [ ] **Step 3: Commit tài liệu**

```bash
git add README.md
git commit -m "docs: document verified Codespaces workflow"
```

### Task 5: Kiểm chứng end-to-end và đồng bộ

**Files:**
- Test: `tests/entrypoint-static.sh`
- Verify: toàn bộ working tree.

**Interfaces:**
- Consumes: image, Compose, Codespace đang hoạt động.
- Produces: log thật, HTTP response port 6080, commit local/remote giống nhau.

- [ ] **Step 1: Chạy static checks**

```bash
bash -n entrypoint.sh
bash tests/entrypoint-static.sh
docker compose config --quiet
```
Expected: tất cả exit 0.

- [ ] **Step 2: Khởi động sạch nhưng giữ volume**

```bash
docker compose down
docker compose up -d --build
```
Expected: service chuyển sang running; không dùng `-v`.

- [ ] **Step 3: Kiểm tra container và log**

```bash
docker compose ps
docker compose logs --no-color --tail=100
```
Expected: container running; log có trạng thái tải ISO hoặc noVNC; không có `No bootable device`, `Cannot allocate memory`, hay process exit.

- [ ] **Step 4: Kiểm tra noVNC nội bộ Codespace**

```bash
curl --fail --silent --show-error --max-time 10 http://localhost:6080/vnc.html > /dev/null
```
Expected: exit 0.

- [ ] **Step 5: Commit phần xóa và plan nếu còn staged**

```bash
git add -A
git commit -m "chore: remove Gemini artifacts"
```
Expected: commit chỉ chứa artifact đã duyệt và tài liệu kế hoạch chưa commit.

- [ ] **Step 6: Push và xác minh đồng bộ**

```bash
git push origin main
test "$(git rev-parse HEAD)" = "$(git ls-remote origin refs/heads/main | cut -f1)"
git status --short
```
Expected: hash giống nhau; working tree sạch.
