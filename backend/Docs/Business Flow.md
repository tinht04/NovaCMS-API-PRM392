# Luồng Xử Lý Thanh Toán Chuẩn cho Dịch vụ Cho thuê

---

## Bước 1: Khách hàng nhấn "Thanh toán" (Check & Soft Lock)

Hệ thống của bạn phải thực hiện các bước kiểm tra nghiêm ngặt trước khi cho phép giao dịch chuyển sang VnPay:

### 🔍 Kiểm tra Khả dụng (Availability Check)
- Hệ thống truy vấn Database chính (DB) để kiểm tra các `RentalOrder` đang ở trạng thái `Confirmed` (Đã xác nhận) hoặc `PendingPayment` (Đang chờ thanh toán).
- Mục tiêu là đảm bảo không có Camera nào bị trùng lịch thuê trong khoảng thời gian khách hàng yêu cầu.

### 🔒 Đặt chỗ Tạm thời (Soft Lock)
- Nếu Camera còn trống, hệ thống tạo một bản ghi đơn hàng tạm thời trong DB (ví dụ: bảng `RentalOrder`) với trạng thái là `PendingPayment`.
- Bản ghi này được xem là một "khóa mềm" (Soft Lock), ngăn không cho khách hàng khác thuê cùng khung thời gian đó.

### 🧠 Lưu vào Redis (Hồi phục)
- Toàn bộ dữ liệu đơn hàng (bao gồm ID giao dịch, thông tin đơn hàng, và thông tin đặt chỗ) được lưu vào Redis.
- TTL (Time-To-Live) được thiết lập là 15–20 phút — thời gian tối đa cho khách hàng thanh toán.
- Redis chỉ đóng vai trò là nơi lưu trữ trạng thái để phục hồi dữ liệu khi nhận Callback.

---

## Bước 2: Chuyển hướng Thanh toán

- Hệ thống trả về URL thanh toán của VnPay cho khách hàng.
- Thời điểm này, khách hàng đang ở ngoài hệ thống, và đơn hàng của họ đang được giữ chỗ tạm thời trong DB và dữ liệu được lưu tạm trong Redis.

---

## Bước 3: Xử lý Callback (Check & Recover)

Sau khi khách hàng thanh toán, VnPay sẽ gửi một Callback (thông báo kết quả) trở lại hệ thống của bạn:

### 📥 Lấy dữ liệu từ Redis
- Sử dụng ID giao dịch nhận được từ VnPay Callback, hệ thống truy xuất dữ liệu đơn hàng đầy đủ đã được lưu tạm trong Redis.

### ✅ Xác minh & Kiểm tra
- Xác minh Callback (chữ ký, số tiền).
- Đảm bảo đơn hàng trong Redis chưa hết hạn và trạng thái đặt chỗ trong DB vẫn còn hiệu lực.

---

## Bước 4: Lưu vào DB (Hard Lock)

### 🎉 Nếu Thanh toán THÀNH CÔNG:
- Cập nhật bản ghi đơn hàng trong DB từ trạng thái `PendingPayment` sang `Confirmed` hoặc `Processing`.
- Đây là hành động lưu vĩnh viễn (Hard Lock).
- Xóa dữ liệu đơn hàng khỏi Redis.

### ❌ Nếu Thanh toán THẤT BẠI hoặc Hết hạn:
- Xóa dữ liệu đơn hàng khỏi Redis (hoặc để TTL tự xóa).
- Cập nhật bản ghi đơn hàng trong DB sang trạng thái `Cancelled` hoặc `Payment Failed`.
- Việc này giúp giải phóng (Unlock) khung thời gian thuê, cho phép khách hàng khác có thể thuê Camera đó ngay lập tức.

---

