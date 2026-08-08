# Thiết kế làm sạch Windows 10 VM

## Mục tiêu

Đưa dự án về bộ tối thiểu có thể kiểm chứng trên GitHub Codespaces: `Dockerfile`, `entrypoint.sh`, `docker-compose.yml`, `README.md`.

## Phạm vi

- Xóa năm file ghi chép/rác do phiên Gemini tạo: `Deploying Windows 10 VM via GitHub gemini loi.md`, `file build docker image.txt`, `file check docker.txt`, `file huong dan goc.md`, `file start docker container.txt`.
- Giữ cấu trúc QEMU tương thích Windows: ổ IDE mặc định, mạng `e1000`, KVM khi có.
- Tải ISO vào file tạm; chỉ đổi thành file chính sau khi tải thành công và file không rỗng.
- Container phải thoát nếu QEMU hoặc noVNC chết; không dùng `tail -f /dev/null` che lỗi.
- README chỉ mô tả luồng đã kiểm chứng, phân biệt cổng web 6080 và RDP 3389.

## Luồng chạy

1. Docker Compose build image.
2. Entrypoint kiểm tra KVM.
3. Tải ISO an toàn nếu chưa có.
4. Tạo ổ QCOW2 nếu chưa có.
5. Khởi động QEMU và websockify.
6. Theo dõi hai tiến trình; một tiến trình chết thì container báo lỗi và dừng.
7. Người dùng mở cổng 6080 trong Codespaces để cài Windows.

## Xử lý lỗi

- Tải ISO lỗi: xóa file tạm, thoát khác 0.
- ISO rỗng: coi là lỗi, tải lại.
- QEMU không khởi động: container dừng, lỗi xuất hiện trong `docker compose logs`.
- Thiếu `/dev/kvm`: chạy TCG chậm hơn; không giả báo KVM.

## Kiểm chứng

- Kiểm tra cú pháp shell trong môi trường Linux/Codespace.
- Kiểm tra `docker compose config`.
- Build image.
- Khởi động container; đọc trạng thái và log thật.
- Kiểm tra cổng 6080 phản hồi.
- So sánh commit local với `origin/main` sau khi push.

## Giới hạn

Không phân phối khóa Windows. Không cam kết Codespaces miễn phí vĩnh viễn, hiệu năng RDP, hoặc URL ISO bên thứ ba luôn hoạt động.
