# Tạo máy ảo Windows 10 trên GitHub Codespaces

Hướng dẫn cầm tay chỉ việc cho người mới. Dự án dùng Docker, QEMU/KVM và noVNC để chạy bộ cài Windows 10 trong GitHub Codespaces.

> GitHub Codespaces có giới hạn giờ dùng và dung lượng theo tài khoản. Đây không phải VPS miễn phí vĩnh viễn. ISO được tải từ nguồn bên thứ ba; hãy tự kiểm tra quyền sử dụng và độ tin cậy trước khi cài.

## Bước 1: Tạo GitHub Codespace

1. Đưa toàn bộ dự án này lên một GitHub repository.
2. Mở repository trên GitHub.
3. Bấm **Code**.
4. Chọn tab **Codespaces**.
5. Bấm **Create codespace on main**.
6. Chờ giao diện Codespace tải xong.

## Bước 2: Kiểm tra KVM

Mở **Terminal** trong Codespace bằng `Ctrl` + `` ` ``, rồi chạy:

```bash
ls -l /dev/kvm
```

Kết quả cần có đường dẫn `/dev/kvm`. Nếu không có, VM vẫn có thể chạy bằng giả lập phần mềm nhưng rất chậm.

## Bước 3: Khởi động Windows VM

Trong Terminal, chạy đúng lệnh:

```bash
docker compose up -d --build
```

Theo dõi tiến trình thật:

```bash
docker compose logs -f
```

Lần đầu hệ thống sẽ:

1. Build Docker image.
2. Tải ISO Windows vào volume `windows_iso`.
3. Tạo ổ đĩa ảo 100GB trong volume `windows_data`.
4. Khởi động QEMU và noVNC.

Thời gian phụ thuộc tốc độ mạng và tải của máy chủ chứa ISO. Không đóng Codespace trong lúc tải.

Nhấn `Ctrl` + `C` để thoát màn hình log; container vẫn chạy nền.

## Bước 4: Mở màn hình cài Windows

1. Trong Codespace, mở tab **PORTS**.
2. Tìm cổng **6080**.
3. Bấm biểu tượng **Open in Browser** của cổng 6080.
4. Nếu trang liệt kê file xuất hiện, bấm `vnc.html`.
5. Bấm **Connect**.
6. Làm theo Windows Setup.
7. Tại màn hình chọn ổ đĩa, chọn **Drive 0 Unallocated Space**, rồi bấm **Next**.

Không mở cổng 3389 bằng trình duyệt. Cổng 3389 dùng cho ứng dụng Remote Desktop sau khi Windows đã cài xong và RDP đã được bật trong Windows.

## Bước 5: Kiểm tra hoặc xử lý lỗi

Xem trạng thái:

```bash
docker compose ps
```

Xem 100 dòng log gần nhất:

```bash
docker compose logs --tail=100
```

Khởi động lại, vẫn giữ Windows và ISO:

```bash
docker compose down
docker compose up -d
```

Dừng hệ thống:

```bash
docker compose down
```

## Cảnh báo dữ liệu

Hai volume sau giữ dữ liệu qua các lần restart:

- `windows_data`: ổ đĩa Windows.
- `windows_iso`: file ISO.

Không chạy lệnh sau nếu còn cần Windows đã cài:

```bash
docker compose down -v
```

Lệnh đó xóa cả hai volume, đồng nghĩa xóa máy Windows và ISO.

## Bảo mật

- Dùng mật khẩu Windows mạnh, duy nhất. Không dùng `123456789`.
- Giữ cổng Codespaces ở chế độ **Private**.
- Chỉ bật RDP sau khi Windows đã cài hoàn chỉnh.
- Không công khai cổng 3389 ra Internet.
