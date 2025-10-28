# NovaCMS - Hệ thống Quản lý Cho thuê Thiết bị (PRM392) 📸


Dự án **NovaCMS (Nova Camera Management System)** được phát triển trong khuôn khổ môn học **PRM392** tại Đại học FPT. Đây là một hệ thống quản lý việc cho thuê và bán thiết bị (tập trung vào máy ảnh và phụ kiện), bao gồm cả backend API và ứng dụng di động frontend.

---

## ✨ Tính năng chính

Dự án bao gồm các chức năng cốt lõi sau:

1.  **Thiết kế Cơ sở dữ liệu & API:** Xây dựng nền tảng backend vững chắc.
2.  **Xác thực người dùng:** Đăng ký, đăng nhập an toàn.
3.  **Quản lý Sản phẩm:**
    * Hiển thị danh sách sản phẩm (có phân trang, bộ lọc).
    * Xem chi tiết thông tin sản phẩm.
4.  **Giỏ hàng:** Quản lý các sản phẩm người dùng muốn thuê (sử dụng Redis).
5.  **Thanh toán & Đơn hàng:**
    * Tạo đơn hàng từ giỏ hàng.
    * Tích hợp thanh toán qua cổng thanh toán (VnPay).
    * Xử lý luồng thanh toán và cập nhật trạng thái đơn hàng.
6.  **Thông báo:** Thông báo cho người dùng (ví dụ: khi có sản phẩm trong giỏ hàng).
7.  **Bản đồ:** Hiển thị vị trí cửa hàng trên bản đồ.
8.  **Chat (AI/RAG):** Cho phép khách hàng tương tác, hỏi đáp về sản phẩm sử dụng AI (Google Gemini).

---

## 🛠️ Công nghệ sử dụng

Dự án được xây dựng dựa trên các công nghệ hiện đại:

* **Backend:**
    * Ngôn ngữ: **C#**
    * Framework: **.NET 8**
    * Database: **MySQL** (với Entity Framework Core)
    * API: **RESTful API** (với Swagger documentation)
    * Cloud Services: **Cloudinary** (lưu trữ ảnh)
    * Caching: **Redis** (quản lý giỏ hàng, đặt chỗ tạm thời)
    * AI: **Google Gemini** (cho tính năng RAG Chat & Embedding)
* **Frontend:**
    * Framework: **Flutter**
    * HTTP Client: **Dio** (với Interceptors)
    * Local Storage: **Flutter Secure Storage** (lưu JWT)
    * Maps: **Google Maps Flutter**
    * Payment Integration: **WebView Flutter**, **AppLinks** (xử lý callback)

---

## 🏗️ Kiến trúc

Dự án áp dụng hai mô hình kiến trúc riêng biệt nhưng bổ trợ cho nhau: **Clean Architecture** cho Backend và **MVVM** cho Frontend.

### Backend (.NET - Clean Architecture)

Backend được cấu trúc theo các lớp (projects) với quy tắc phụ thuộc rõ ràng, giúp tách biệt logic và tăng khả năng bảo trì:

1.  **`NovaCMS.Domain` (Lõi):**
    * Là lớp trong cùng, không phụ thuộc vào bất kỳ lớp nào khác.
    * Chứa các **Entities** (ví dụ: `Equipment`, `RentalOrder`, `User`) định nghĩa các đối tượng cốt lõi của nghiệp vụ.

2.  **`NovaCMS.Application` (Nghiệp vụ):**
    * Phụ thuộc vào `Domain`.
    * Định nghĩa các **Interfaces** (ví dụ: `IEquipmentRepository`, `IUserService`, `IUnitOfWork`).
    * Chứa các **DTOs** (Data Transfer Objects).
    * Chứa logic nghiệp vụ chính (Application Services, ví dụ: `EquipmentService`, `AuthService`).

3.  **`NovaCMS.Infrastructure` (Cơ sở hạ tầng):**
    * Phụ thuộc vào `Application`.
    * Triển khai (Implement) các interfaces từ lớp `Application`.
    * Chứa các **Repositories** (ví dụ: `EquipmentRepository`) để tương tác trực tiếp với CSDL.
    * Chứa `NovaCMSDBContext`.
    * Triển khai các dịch vụ bên ngoài (ví dụ: `CloudinaryService`, `RedisService`).

4.  **`NovaCMS.API` (Trình bày - Presentation):**
    * Là lớp ngoài cùng, phụ thuộc vào `Application` và `Infrastructure`.
    * Chứa các **Controllers** (API Endpoints) để tiếp nhận request từ client.
    * Cấu hình và khởi chạy ứng dụng (Dependency Injection, Middleware).

### Frontend (Flutter - MVVM)

Frontend sử dụng mô hình **MVVM (Model-View-ViewModel)** để tách biệt giao diện (View) khỏi logic nghiệp vụ (ViewModel):

* **View (UI):** Các màn hình (`screens`) và `widgets`. Chịu trách nhiệm hiển thị dữ liệu và gửi sự kiện lên ViewModel.
* **ViewModel:** Lớp trung gian, chứa logic xử lý trạng thái (state) của View. Nó gọi đến `Repository` để lấy/gửi dữ liệu.
* **Repository:** Tương tác với API backend (`ApiClient`/`Dio`), xử lý việc gọi API và mapping dữ liệu JSON trả về thành các **Model** (Dart objects).
* **Core:** Chứa các thành phần dùng chung như `ApiClient`, `SecureStorage`, `Endpoints`.

---

## 🚀 Cài đặt và Chạy dự án

Vui lòng tham khảo hướng dẫn chi tiết trong tệp `/.github/instruction.md` để biết cách cài đặt môi trường, dependencies và chạy cả backend lẫn frontend.

