
# Bản ghi toàn bộ nội dung video

---

## [00:00 - 00:12] — Màn hình giới thiệu

**Hình ảnh:** Desktop với hình nền hacker Anonymous, skull xanh lá, khóa bảo mật có cờ Bangladesh.

**Text trên màn hình:**
- AnonymousPro OFFICIAL
- Cyber Security
- Expert Of BD

**Các icon trên desktop:** DHT, 350, mdmonstafa..., mdmonstafa..., mdmonstafa..., mdmonstafa..., mdmonstafa..., mdmonstafa..., mdmonstafa..., mdmonstafa..., mdmonstafa..., mdmonstafa..., mdmonstafa..., mdmonstafa..., mdmonstafa..., mdmonstafa..., mdmonstafa..., md......

---

## [00:12 - 00:30] — Text overlay tiếng Bengali

**Text xuất hiện trên màn hình (tiếng Bengali):**
> যাদের কম্পিউটার নাই তারা আমার দেখানো প্রসেস ফলো করে মোবাইল দিয়ে RDP তৈরী করুন

**Dịch nghĩa:** "Những ai không có máy tính, hãy làm theo quy trình tôi hướng dẫn để tạo RDP bằng điện thoại di động."

Người dùng chuột phải vào desktop → hiển thị menu context với các tùy chọn: View, Sort by, Refresh, Paste, Paste shortcut, New, Display settings, Personalize.

---

## [00:30 - 00:48] — Mở GitHub

Người dùng mở trình duyệt Chrome, gõ `github.com` vào thanh địa chỉ và nhấn Enter.

Trang GitHub Dashboard tải lên. Người dùng click vào avatar profile → chuyển đến trang cá nhân `okids-dev`.

Click vào dấu `+` ở góc trên bên phải → chọn **New repository**.

---

## [00:48 - 01:06] — Tạo Repository mới

Trang "Create a new repository" hiện ra.

- **Owner:** okids-dev
- **Repository name:** windows10
- **Description:** (để trống)
- **Visibility:** Public
- **Add README:** Off
- **Add .gitignore:** No .gitignore
- **Add license:** No license

**Text overlay xuất hiện:** `@anonymousproofficial`

Người dùng click nút **Create repository**.

---

## [01:06 - 01:28] — Tạo file mới trong repository

Sau khi repository được tạo, người dùng click vào link **"creating a new file"** trong phần Quick setup.

Trang tạo file mới hiện ra:
- **Tên file:** windows10
- **Nội dung file:** `join our Telegram @anonymousproofficial`

Click **Commit changes...** → hộp thoại Commit message hiện ra → click **Commit changes**.

File `windows10` đã được commit vào repository.

---

## [01:28 - 01:57] — Tạo Codespace

Người dùng quay lại trang repository chính.

Click vào nút **Code** (màu xanh lá) → tab **Codespaces** → click **Create codespace on main**.

Màn hình loading "Setting up your codespace" hiện ra.

Codespace được tạo thành công, mở Visual Studio Code trong trình duyệt.

---

## [01:57 - 02:24] — Thay đổi loại máy Codespace

Quay lại GitHub repository → click vào dấu `...` bên cạnh codespace đang active → chọn **Change machine type**.

Hộp thoại "Change codespace machine type" hiện ra với tùy chọn:
- **2-core / 8GB RAM · 32GB**

Click **Update codespace**.

Codespace restart và mở lại VS Code trong trình duyệt.

---

## [02:24 - 03:07] — Terminal commands

Trong terminal của VS Code, người dùng chạy các lệnh sau:

```bash
$ ls /dev/kvm
/dev/kvm

$ free -h
              total        used        free      shared  buff/cache   available
Mem:           15Gi       1.8Gi        249Mi        59Mi        14Gi          1
Swap:         3.0Gi          0B          0B

$ git clone https://github.com/hopingboyz/windows10vm
Cloning into 'windows10vm'...
remote: Enumerating objects: 38, done.
remote: Counting objects: 100% (11/11), done.
remote: Compressing objects: 100% (11/11), done.
remote: Total 38 (delta 8), reused 0 (delta 8), pack-reused 27 (from 1)
Receiving objects: 100% (38/38), 15.63 KiB | 15.63 MiB/s, done.
Resolving deltas: 100% (8/8), done.

$ cd windows10vm

$ ls
Dockerfile  LICENSE  README.md
```

---

## [03:07 - 03:57] — Xem nội dung Dockerfile

Người dùng mở file `Dockerfile` trong Explorer. Nội dung file:

```dockerfile
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-system-x86 \
    qemu-utils \
    novnc \
    websockify \
    wget \
    curl \
    net-tools \
    python3 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /data /iso /novnc

RUN wget https://github.com/novnc/noVNC/archive/refs/heads/master.zip -O /tmp/noVNC.zip && \
    unzip /tmp/noVNC.zip -d /tmp && \
    mv /tmp/noVNC-master/* /novnc && \
    rm -rf /tmp/noVNC.zip /tmp/noVNC-master

ENV ISO_URL=https://archive.org/download/windows-10-111/Win10_22H2_English_x64.iso

RUN echo '#!/bin/bash\nset -e\n\n# Check for KVM support\nif [ -e /dev/kvm ]; then\n  echo "✅ KVM acceleration available"\n  KVM_ARG="-enable-kvm"\n  CPU_ARG="host"\n  MEMORY="4G"\n  SMP_CORES=4\nelse\n  echo "️ KVM not available - using slower emulation"\n  KVM_ARG=""\n  CPU_ARG="qemu64"\n  MEMORY="2G"\n  SMP_CORES=2\nfi\n...' > /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 5900 6080

CMD ["/entrypoint.sh"]
```

---

## [03:57 - 04:43] — Build Docker image

Trong terminal, người dùng chạy lệnh:

```bash
$ docker build -t windows10-vm .
[+] Building 63.9s (10/10) FINISHED                   docker:default
 => [internal] load build definition from Dockerfile                 0.0s
 => [internal] load metadata for docker.io/library/ubuntu:22.04      2.2s
 => [auth] library/ubuntu:pull token for registry-1.docker.io        0.0s
 => [internal] load .dockerignore                                    0.0s
 => [internal] load build context                                    0.0s
 => [1/5] FROM docker.io/library/ubuntu:22.04@sha256:...             2.0s
 => [2/5] RUN apt-get update && apt-get install -y --no-install-... 41.1s
 => [3/5] RUN wget https://github.com/novnc/noVNC/archive/refs/h...  1.1s
 => [4/5] RUN echo '#!/bin/bash\nset -e\n\n# Check for KVM suppo...  0.4s
 => [5/5] RUN wget $ISO_URL -O /iso/win10.iso                       16.7s
 => exporting to image                                              12.8s
 => naming to docker.io/library/windows10-vm:latest                  0.0s
 => unpacking to docker.io/library/windows10-vm:latest               3.7s
```

---

## [04:43 - 05:22] — Chạy Docker container

```bash
$ docker run -it --rm \
  --device /dev/kvm \
  -p 6080:6080 \
  -p 3389:3389 \
  -v windows_data:/data \
  -v windows_iso:/iso \
  windows10-vm

✅ KVM acceleration available
📥 Downloading Windows 10 ISO...
/iso/iso.iso  100%[===================>]  1.11G  14.9MB/s    in 88s

Creating virtual disk...
Formatting '/data/win10.qcow2', fmt=qcow2 cluster_size=65536 extended_l2=off compression_type=zlib size=107374182400 lazy_refcounts=off refcount_bits=16

️ First boot - Installing Windows from ISO
Starting Windows 10 VM with 4 CPU cores and 16G RAM
qemu-system-x86_64: cannot set up guest memory 'pc.ram': Cannot allocate memory

💻 Connect via VNC: http://localhost:6080
 After install, use RDP: localhost:3389
First boot may take 20-30 minutes for Windows install

WebSocket server settings:
  - Listen on :6080
  - Web server. Web root: /novnc
  - No SSL/TLS support (no cert file)
  - proxying from :6080 to localhost:5900
```

---

## [05:22 - 05:55] — Mở forwarded port

Người dùng click vào tab **PORTS** trong VS Code.

Hai port được forward:
- **3389** → Private
- **6080** → Private

Click vào icon "Open in Browser" của port 6080.

Trình duyệt mở trang Directory listing cho `/` với các file/folder: app/, AUTHORS, core/, defaults.json, docs/, eslint.config.mjs, karma.conf.cjs, LICENSE.txt, mandatory.json, package.json, po/, README.md, snap/, tests/, utils/, vendor/, vnc.html, vnc_lite.html

Click vào **vnc.html**.

Trang noVNC hiện ra với nút **Connect**. Click **Connect**.

---

## [05:55 - 06:21] — Cài đặt Windows 10

Màn hình Windows Setup hiện ra trong noVNC:

**Where do you want to install Windows?**
- Drive 0 Unallocated Space | Total size: 100.0 GB | Free space: 100.0 GB

Click **Next**.

**Installing Windows**
- ✅ Copying Windows files
- Getting files ready for installation (0%) → tăng dần đến 100%
- Installing features
- Installing updates
- Finishing updates

**Windows needs to restart to continue**
- Restarting in 10 seconds → đếm ngược

---

## [06:21 - 06:42] — Windows khởi động lại

Màn hình SeaBIOS hiện ra:
```
SeaBIOS (version 1.15.0-1)
iPXE (https://ipxe.org) 00:02.0 CA00 PCI2.10 PnP PMM-7FF8B1B0-7FECB1B0 CA00

Press ESC for boot menu.
Booting from DVD/CD...
Press any key to boot from CD or DVD...
```

Logo Windows hiện ra → "Getting devices ready" → "Getting ready" → "Just a moment..."

Màn hình "Now let's see what's new from Windows." hiện ra.

---

## [06:42 - 07:40] — Thiết lập tài khoản Windows

**Who's going to use this PC?**
- Name: `Anonymousproofficial`
- Click Next

**Create a super memorable password**
- Password: `123456789`
- Click Next

**Confirm your password**
- Confirm password: `123456789`
- Click Next

**Create security questions for this account**

Security question (1 of 3): What's the first name of your oldest cousin?
- Answer: `anonymousproofficial`

Security question (2 of 3): What was your first pet's name?
- Answer: `anonymousproofficial`

Security question (3 of 3): What was your childhood nickname?
- Answer: `anonymousproofficial`

Click Next → "Just a moment..."

---

## [07:40 - 07:49] — Cortana setup

**Get help from your digital assistant**
"Cortana helps you manage your time, get things done, and stay connected"

Click **Accept** → "Just a moment..."

---

## [07:49 - 08:30] — Desktop Windows 10

Desktop Windows 10 hiện ra với các icon: This PC, Network, Recycle Bin, Control Panel, oprekin, ReadMe.html, support me!!!

Người dùng chuột phải → Display settings → Display resolution: 1024 × 768 (Recommended)

Click vào Start menu → Settings → System, Devices, Network & Internet, Personalization, Apps, Accounts, Time & Language, Ease of Access, Privacy, Update & Security.

Mở This PC → Local Disk (C:) 86.0 GB free of 99.4 GB, CD Drive (D:) Win10Pro_1909_A76_oprekin, CD Drive (E:)

---

## [08:30 - 09:31] — Cài đặt Google Chrome

Mở Internet Explorer → truy cập `oprekin.com/support-me/` → lỗi "Oops! We ran into some problems"

Tìm kiếm "google chrome download" trên Bing → click vào link Google Chrome → Download Chrome → Accept and Install → Run ChromeSetup.exe

Chrome installer hiện ra: "Waiting to install..." → "Installing..." → hoàn tất.

Google Chrome mở lên → Sign in to Chrome → Stay signed out → Set as default browser → Skip.

---

## [09:31 - 10:05] — Speedtest.net

Tìm kiếm "speed test" trên Google → click vào Speedtest by Ookla.

Trang speedtest.net hiện ra → GO.

Kết quả:
- **DOWNLOAD:** 163.25 Mbps
- **UPLOAD:** 227.39 Mbps
- **Ping:** 31 ms
- **Jitter:** 16 ms
- **Loss:** 16%
- **Connection:** Multi
- **Server:** Jio, Pune
- **IP:** 193.186.4.139

---

## [10:05 - 10:22] — Fast.com speed test

Truy cập fast.com.

Kết quả: **Your Internet speed is 190 Mbps**

---

## [10:22 - 11:04] — Kết thúc

Người dùng thoát khỏi VM, quay lại GitHub repository.

Click vào tab **Insights** → Pulse → Period: 1 week → June 11, 2026 – June 18, 2026

Overview: 0 Active pull requests, 0 Active issues, 0 Merged, 0 Closed, 0 New issues

Summary và Top Committers hiển thị biểu đồ.

---

## [11:02 - 11:04] — End screen

Màn hình đen với text trắng:

```
DIRECTED BY

Input Title
```

---

**Lưu ý:** Toàn bộ video có watermark `@anonymousproofficial` xuất hiện xuyên suốt từ giây thứ 54 đến hết video.