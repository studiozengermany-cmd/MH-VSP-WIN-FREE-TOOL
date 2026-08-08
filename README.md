# MH - VSP WIN FREE TOOL
*(Bản Tối Ưu Hóa Tuyệt Đối - Độc Lập Hoàn Toàn 100%)*

Đây là công cụ tự động tạo VPS Windows 10 miễn phí thông qua GitHub Codespaces. Toàn bộ mã nguồn chạy máy ảo đều được công khai, độc lập 100% giúp bạn không phải phụ thuộc vào repo của bên thứ ba nào.

## 🛠 Cấu Trúc Tổng Quan
1. **GitHub Codespaces:** Cung cấp môi trường máy ảo Ubuntu (có cấu hình 2-core, 8GB RAM, 32GB Storage).
2. **Docker:** Chạy bên trong Codespaces để cách ly môi trường.
3. **QEMU/KVM:** Phần mềm ảo hóa giúp boot hệ điều hành Windows 10 mượt mà.
4. **noVNC:** Công cụ xuất hình ảnh của máy ảo lên trình duyệt web.

---

## 🚀 Hướng Dẫn Sử Dụng Nhanh (Quick Start)

### Bước 1: Mở Codespaces
Tại trang chủ của repository này:
- Bấm vào nút màu xanh **Code**.
- Chọn tab **Codespaces**.
- Click **Create codespace on main**.
*(Mẹo: Để cấu hình mạnh hơn, bạn có thể click dấu `...` cạnh tên Codespace -> chọn **Change machine type** -> chọn loại `2-core / 8GB RAM / 32GB storage`)*.

### Bước 2: Khởi động hệ thống
Đợi Codespace load xong giao diện VS Code nền web. Ở khung Terminal phía dưới, bạn gõ lệnh sau để khởi chạy:
```bash
docker-compose up -d
```
*Lần đầu tiên chạy lệnh này sẽ mất một lúc do hệ thống phải tải file cài đặt ISO Windows 10 về.*

### Bước 3: Kết nối & Cài đặt Windows
- Mở thanh **PORTS** ở dưới cùng VS Code.
- Mở **Port 6080** trên trình duyệt (Bấm vào biểu tượng Open in Browser hình quả địa cầu).
- Trình duyệt mở ra, bấm vào `vnc.html` rồi bấm nút **Connect**.
- Màn hình cài Windows hiện ra, bạn thao tác cài đặt như bình thường. Chờ tầm 10-20 phút là bạn có một chiếc VPS Windows 10 hoàn chỉnh.

*(Bạn có thể thiết lập mật khẩu Windows rồi dùng trình Remote Desktop Connection (RDP) trên máy tính của bạn thông qua **Port 3389** để dùng mượt hơn VNC web).*

