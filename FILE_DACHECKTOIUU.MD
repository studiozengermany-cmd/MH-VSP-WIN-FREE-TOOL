# Hướng Dẫn Tạo VPS Windows 10 Miễn Phí (Qua GitHub Codespaces)
*(Bản Tối Ưu Hóa Tuyệt Đối - Độc Lập Hoàn Toàn 100%)*

Dựa trên phân tích từ video gốc, đây là phiên bản hướng dẫn đã được chắt lọc, loại bỏ các bước thừa và loại bỏ sự phụ thuộc vào repo của bên thứ ba (`hopingboyz`). Toàn bộ mã nguồn sẽ do bạn tự kiểm soát.

---

## 🛠 Cấu Trúc Tổng Quan (How it works)
1. **GitHub Codespaces:** Cung cấp môi trường máy ảo Ubuntu (có cấu hình 2-core, 8GB RAM).
2. **Docker:** Chạy bên trong Codespaces để cách ly môi trường.
3. **QEMU/KVM:** Phần mềm ảo hóa giúp boot hệ điều hành Windows 10 cực mượt nhờ tính năng tăng tốc phần cứng KVM.
4. **noVNC:** Công cụ Web Socket giúp xuất hình ảnh của máy ảo Windows lên trình duyệt web.

---

## 📝 Quy Trình Thực Hiện (5 Bước Nhanh Gọn)

### Bước 1: Tạo Repository & Codespaces
1. Đăng nhập vào GitHub.
2. Tạo 1 Repository mới:
   - Tên: `windows-vps` (hoặc tuỳ ý)
   - Visibility: `Public`
   - Đánh dấu vào ô **Add a README file** (để khởi tạo repo luôn).
   - Bấm **Create repository**.
3. Tại trang Repo vừa tạo, bấm nút màu xanh **Code** -> Chọn tab **Codespaces** -> Click **Create codespace on main**.
4. *(Tùy chọn cấu hình mạnh)*: Nếu muốn máy ảo chạy mượt hơn, quay lại trang GitHub, bấm vào dấu `...` cạnh tên Codespace đang chạy, chọn **Change machine type** và đổi sang loại **2-core / 8GB RAM / 32GB storage**. Đợi Codespace load lại.

### Bước 2: Tạo File Cấu Hình (Tự Chủ 100%)
Tại cửa sổ Visual Studio Code trên web (của Codespace), chúng ta sẽ tự tạo 1 file `Dockerfile`.

1. Ở khung bên trái (Explorer), click chuột phải chọn **New File**, đặt tên là `Dockerfile` (viết hoa chữ D, không có đuôi).
2. Copy và dán toàn bộ đoạn mã tối ưu sau vào file `Dockerfile` và lưu lại (Ctrl + S):

```dockerfile
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Cài đặt QEMU, KVM, noVNC và các công cụ cần thiết
RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-system-x86 \
    qemu-utils \
    novnc \
    websockify \
    wget \
    curl \
    net-tools \
    python3 \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /data /iso /novnc

# Cài đặt bản noVNC mới nhất
RUN wget https://github.com/novnc/noVNC/archive/refs/heads/master.zip -O /tmp/noVNC.zip && \
    unzip /tmp/noVNC.zip -d /tmp && \
    mv /tmp/noVNC-master/* /novnc && \
    rm -rf /tmp/noVNC.zip /tmp/noVNC-master

# Link tải ISO Windows 10 (Phiên bản English, x64)
ENV ISO_URL=https://archive.org/download/windows-10-111/Win10_22H2_English_x64.iso

# Tạo script Entrypoint tự động kiểm tra KVM và thiết lập cấu hình máy ảo
RUN echo '#!/bin/bash\n\
set -e\n\
if [ -e /dev/kvm ]; then\n\
  echo "✅ KVM acceleration available"\n\
  KVM_ARG="-enable-kvm"\n\
  CPU_ARG="host"\n\
  MEMORY="4G"\n\
  SMP_CORES=4\n\
else\n\
  echo "⚠️ KVM not available - using slower emulation"\n\
  KVM_ARG=""\n\
  CPU_ARG="qemu64"\n\
  MEMORY="2G"\n\
  SMP_CORES=2\n\
fi\n\
\n\
# Tải ISO nếu chưa có\n\
if [ ! -f /iso/win10.iso ]; then\n\
  echo "📥 Downloading Windows 10 ISO..."\n\
  wget $ISO_URL -O /iso/win10.iso\n\
fi\n\
\n\
# Tạo ổ cứng ảo 100GB nếu chưa có\n\
if [ ! -f /data/win10.qcow2 ]; then\n\
  echo "💾 Creating virtual disk..."\n\
  qemu-img create -f qcow2 /data/win10.qcow2 100G\n\
fi\n\
\n\
echo "🚀 Starting Windows 10 VM..."\n\
echo "💻 VNC Web Interface: http://localhost:6080/vnc.html"\n\
\n\
# Chạy noVNC qua websockify\n\
websockify --web=/novnc --wrap-mode=ignore 6080 localhost:5900 &\n\
\n\
# Boot QEMU VM\n\
exec qemu-system-x86_64 $KVM_ARG -cpu $CPU_ARG -smp $SMP_CORES -m $MEMORY \\\n\
  -drive file=/data/win10.qcow2,if=virtio \\\n\
  -cdrom /iso/win10.iso \\\n\
  -net nic,model=virtio -net user,hostfwd=tcp::3389-:3389 \\\n\
  -vnc :0\n\
' > /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Mở port VNC web và RDP
EXPOSE 5900 6080 3389

CMD ["/entrypoint.sh"]
```

### Bước 3: Build Image Docker
Trong VS Code Codespace, mở Terminal (nếu chưa có thì bấm `Ctrl + ~` hoặc Terminal -> New Terminal).
Gõ lệnh sau để build image (sẽ mất khoảng 1-2 phút):

```bash
docker build -t windows10-vm .
```

### Bước 4: Chạy Máy Ảo
Gõ lệnh sau vào Terminal để khởi động Container với đầy đủ quyền và kết nối thư mục (Lệnh này sẽ chạy mất chút thời gian ở lần đầu để nó tải file ISO Windows 10):

```bash
docker run -it --rm \
  --device /dev/kvm \
  -p 6080:6080 \
  -p 3389:3389 \
  -v windows_data:/data \
  -v windows_iso:/iso \
  windows10-vm
```
*Lưu ý: Nó sẽ hiển thị trạng thái tải ISO. Khi tải xong và hiển thị `Starting Windows 10 VM`, chuyển sang bước 5.*

### Bước 5: Kết Nối VNC & Cài Đặt Windows
1. Nhìn xuống dưới thanh công cụ của Terminal ở VS Code, chọn tab **PORTS**.
2. Bạn sẽ thấy Port **6080** hiện ra (nếu không thấy, tự bấm nút Forward a port và nhập `6080`).
3. Bấm vào biểu tượng **Open in Browser** (hình quả địa cầu) kế bên port 6080.
4. Trình duyệt mở ra tab mới. Bạn chọn dòng **vnc.html**.
5. Bấm nút **Connect**.
6. Lúc này màn hình cài đặt Windows 10 sẽ hiện ra. Bạn thao tác chuột cài đặt Windows y hệt như cài máy tính thật (Bấm Next -> Install Now -> Chọn I don't have a product key -> Chấp nhận điều khoản -> Chọn Custom install -> Bấm vào phân vùng 100GB -> Next).

Quá trình cài đặt tự động mất khoảng 10-20 phút. Sau khi xong, hệ thống khởi động lại, bạn setup User (tên, pass, câu hỏi bảo mật). Thế là bạn đã có 1 chiếc VPS Windows 10 mượt mà chạy hoàn toàn miễn phí trên trình duyệt web!

---

## 💡 Mẹo Tối Ưu (Advanced Tips)
- **Để màn hình không bị mờ:** Chuột phải màn hình Desktop Windows > `Display Settings` > Chọn độ phân giải `1024x768` trở lên.
- **Để Codespace không tự tắt:** Mặc định Codespace rảnh quá sẽ tự Sleep. Bạn nên treo 1 tab trình duyệt hoặc thi thoảng quay lại tab Codespace bấm vài phím để nó luôn hoạt động.
- **Kết nối bằng Remote Desktop (RDP):** Thay vì dùng web VNC hơi giật, khi cài Win xong bạn có thể bật Remote Desktop trong Windows, sau đó forward port 3389 trên Codespace ra ngoài và dùng ứng dụng Remote Desktop Connection của máy tính để kết nối cực mượt.
