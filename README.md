# 🚀 Hướng Dẫn Tự Tạo VPS Windows 10 Miễn Phí Trên GitHub (Chi Tiết A-Z)

Đây là tài liệu hướng dẫn "cầm tay chỉ việc", dành cho những người chưa biết gì về lập trình vẫn có thể dễ dàng làm được. Hãy đọc chậm và làm theo chính xác từng lệnh.

---

## BƯỚC 1: KHỞI TẠO MÁY CHỦ TRÊN GITHUB (CODESPACES)

1. Ở trang chủ của giao diện này, bạn tìm và bấm vào nút màu xanh lá cây có chữ **Code** ở góc phải.
2. Chuyển sang tab có chữ **Codespaces**.
3. Bấm vào nút màu xanh lá cây **Create codespace on main**.
4. Màn hình sẽ chuyển sang chế độ tải (Loading) khoảng 10-20 giây. Khi tải xong, bạn sẽ thấy một giao diện màu đen giống hệt một phần mềm code (đây gọi là Visual Studio Code trên nền web).

### Nâng cấp cấu hình máy chủ (Bắt buộc để chạy mượt)
1. Quay lại trang GitHub ban đầu, bấm lại vào nút màu xanh **Code** -> **Codespaces**.
2. Bạn sẽ thấy tên Codespace vừa tạo đang hiện ra. Hãy bấm vào **dấu 3 chấm (...)** ở ngay bên cạnh tên đó.
3. Chọn dòng chữ **Change machine type**.
4. Chọn loại cấu hình cao nhất: **2-core / 8GB RAM · 32GB** và bấm nút **Update codespace**.
5. Quay lại cái tab giao diện màu đen lúc nãy, nó sẽ tự động tải lại với sức mạnh cấu hình mới.

---

## BƯỚC 2: RA LỆNH CÀI ĐẶT WINDOWS (Chạy lệnh)

Khi giao diện màu đen đã tải xong hoàn toàn:
1. Bạn nhìn xuống **dưới cùng màn hình**, sẽ có một khu vực để gõ chữ gọi là bảng **Terminal** (nếu không thấy, bạn bấm tổ hợp phím `Ctrl` + `~` trên bàn phím để gọi nó lên).
2. Bấm chuột vào bảng Terminal đó và **Copy / Dán** chính xác câu lệnh sau đây vào:

```bash
docker-compose up -d
```

3. Bấm phím **Enter** trên bàn phím.
4. Hệ thống sẽ bắt đầu tự động tải file cài đặt Windows 10 (bản Lite siêu nhẹ 1.1GB). Vui lòng kiên nhẫn chờ **khoảng 1 đến 3 phút** để nó kéo file về máy ảo.

---

## BƯỚC 3: BẬT MÀN HÌNH WINDOWS LÊN SỬ DỤNG

Sau khi bạn chờ 3 phút để hệ thống tải xong file cài đặt:
1. Ở ngay cạnh chỗ cái bảng Terminal lúc nãy, bạn sẽ thấy có một tab tên là **PORTS** (Cổng). Bấm vào đó.
2. Bạn sẽ thấy danh sách 2 cổng là `3389` và `6080`.
3. Di chuột lại gần con số **6080**, bạn sẽ thấy một biểu tượng hình quả địa cầu 🌐 (có chữ *Open in Browser* khi rê chuột vào). Hãy **Click vào cái biểu tượng đó**.
4. Một tab web mới sẽ mở ra hiển thị vài cái tên file, bạn hãy tìm và click vào dòng chữ **`vnc.html`**.
5. Trang web xuất hiện chữ Connect. Hãy bấm vào nút **Connect** ở giữa màn hình.

**🎉 XONG! Màn hình xanh cài đặt Windows 10 đã hiện ra ngay trước mắt bạn.**
Từ bước này trở đi, bạn chỉ việc dùng chuột thao tác click cài đặt y hệt như đang dùng một chiếc máy tính thật. Quá trình cài mất khoảng 10-15 phút.

---

## 💡 Các Lưu Ý Cực Kỳ Quan Trọng
- Khi Windows hỏi tạo tên người dùng, bạn cứ nhập tuỳ ý (ví dụ: `Anonymous`). Mật khẩu nên đặt ngắn gọn dễ nhớ (ví dụ: `123456789`).
- Đây là bản Windows 10 Lite, đã được tối ưu xoá hết rác dư thừa nên chạy cực kỳ mượt mà cho các tác vụ lướt web, treo tool hoặc làm việc văn phòng cơ bản.
- Sau khi cài Windows xong, bạn có thể thiết lập dùng Remote Desktop Connection (RDP) để kết nối trực tiếp từ máy tính thật vào VPS thông qua cổng `3389` thay vì dùng qua trình duyệt để có tốc độ nhanh nhất!
