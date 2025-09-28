# NovaCMS-API-Csharp

# 📖 NovaCMS – Equipment Rental and Sales Management System

[![.NET](https://img.shields.io/badge/.NET-8.0-blue)](https://dotnet.microsoft.com/)
[![MySQL](https://img.shields.io/badge/MySQL-8.x-orange)](https://www.mysql.com/)
[![License](https://img.shields.io/badge/License-MIT-green)](./LICENSE)

---

## 📚 Mục lục

* [Giới thiệu](#-giới-thiệu)
* [Công nghệ](#-công-nghệ)
* [Chức năng chính](#-chức-năng-chính)
* [Cấu trúc Database](#-cấu-trúc-database)
* [Yêu cầu](#-yêu-cầu)
* [Chuẩn bị môi trường](#️-chuẩn-bị-môi-trường)
* [Cấu hình kết nối](#-cấu-hình-kết-nối)
* [Scaffold Entities (Database-first)](#-scaffold-entities-database-first)
* [Migration (Code-first)](#-migration-code-first)
* [Chạy và Test](#️-chạy-và-test)
* [CI/CD với GitHub Actions](#️-cicd-với-github-actions)
* [License](#-license)
* [Liên hệ](#-liên-hệ)

---

## 📝 Giới thiệu

NovaCMS là hệ thống quản lý **thuê và bán thiết bị** (máy ảnh, ống kính, tripod, …).

Ứng dụng cho:

* Công ty cho thuê thiết bị chuyên nghiệp
* Các studio, freelancer cần quản lý tài sản

---

## 🚀 Công nghệ

* **Backend**: ASP.NET Core Web API (.NET 8)
* **Database**: MySQL / MariaDB
* **ORM**: Entity Framework Core (Pomelo MySQL Provider)

---

## 🎯 Chức năng chính

* Quản lý **người dùng**: Admin, Staff, Customer
* Quản lý **thiết bị & item theo serial**
* Quản lý **đơn thuê & chi tiết thuê**
* Quản lý **hóa đơn & thanh toán**
* **Báo cáo** tần suất sử dụng thiết bị
* Quản lý **nội dung Blog (BlogPosts, hình ảnh)**

---

## 📂 Cấu trúc Database

| Bảng                 | Mô tả                                           |
| -------------------- | ----------------------------------------------- |
| `Roles`              | Phân quyền hệ thống (Admin, Staff, Customer)    |
| `Users`              | Email, số điện thoại, avatar, loyalty points    |
| `Categories`         | Nhóm thiết bị (Camera, Lens, Tripod)            |
| `Equipments`         | Loại thiết bị (Canon EOS R6, Sony Lens, …)      |
| `EquipmentItems`     | Thiết bị cụ thể theo serial                     |
| `EquipmentImages`    | Hình ảnh kèm theo thiết bị                      |
| `RentalOrders`       | Đơn hàng thuê                                   |
| `RentalOrderDetails` | Chi tiết thuê (ngày thuê, phí cọc, phí quá hạn) |
| `Invoices`           | Hóa đơn thanh toán                              |
| `BlogPosts`          | Bài viết                                        |
| `BlogPostImages`     | Hình ảnh kèm bài viết                           |

---

## 🔧 Yêu cầu

* .NET 8 SDK
* MySQL Server (hoặc MySQL Cloud)
* EF Core CLI:

```bash
dotnet tool install --global dotnet-ef
```

---

## ⚙️ Chuẩn bị môi trường

Clone repo:

```bash
git clone https://github.com/your-org/NovaCMS-API-Csharp.git
cd NovaCMS-API-Csharp
```

Cài đặt .NET SDK: [Download .NET 8](https://dotnet.microsoft.com/download)

Cài MySQL Server hoặc tạo Database trên Cloud.

---

## 🔐 Cấu hình kết nối

Trong file `appsettings.Development.json`, chỉnh chuỗi kết nối:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=YOUR_SERVER;Port=YOUR_PORT;Database=NovaCMS;User=YOUR_USER;Password=YOUR_PASSWORD;"
  }
}
```

⚠️ **Lưu ý**: Không commit thông tin nhạy cảm lên Git.

---

## 🛠 Scaffold Entities (Database-first)

Khi đã có schema MySQL, chạy lệnh:

```bash
dotnet ef dbcontext scaffold \
  "Server=YOUR_SERVER;Port=YOUR_PORT;Database=NovaCMS;User=YOUR_USER;Password=YOUR_PASSWORD;" \
  Pomelo.EntityFrameworkCore.MySql \
  -o Entities \
  -c NovaCMSDBContext \
  --context-dir ../NovaCMS.Infrastructure/Data \
  --namespace NovaCMS.Domain.Entities \
  --context-namespace NovaCMS.Infrastructure.Data \
  --force
```

Giải thích:

* `-o Entities`: thư mục chứa entity classes
* `-c NovaCMSDBContext`: tên DbContext
* `--context-dir`: nơi lưu DbContext file
* `--namespace`: namespace cho entity
* `--context-namespace`: namespace cho DbContext
* `--force`: ghi đè nếu tồn tại

---

## 🚀 Migration (Code-first)

Tạo migration đầu tiên:

```bash
dotnet ef migrations add InitialCreate \
  -p NovaCMS.Infrastructure \
  -s NovaCMS.API
```

Áp dụng migration lên DB:

```bash
dotnet ef database update \
  -p NovaCMS.Infrastructure \
  -s NovaCMS.API
```

---

## ▶️ Chạy và Test

Build project:

```bash
dotnet restore
dotnet build
```

Chạy API:

```bash
dotnet run --project NovaCMS.API
```

Truy cập:

* `http://localhost:5000`
* `https://localhost:5001`

Chạy Unit Tests (nếu có):

```bash
dotnet test --no-build --verbosity normal
```

---

## 🛠️ CI/CD với GitHub Actions

Workflow `.github/workflows/dotnet.yml` tự động:

* Checkout code
* Cài .NET 8 SDK
* Restore, build, test

Ví dụ steps:

```yaml
- uses: actions/checkout@v4
- uses: actions/setup-dotnet@v4
  with:
    dotnet-version: '8.0.x'
- run: dotnet restore
- run: dotnet build --no-restore
- run: dotnet test --no-build --verbosity normal
```

(Bạn có thể mở rộng để deploy lên **Azure, Docker, v.v.**)
---

## 📄 License

Dự án được phát hành theo [MIT License](./LICENSE).

---

## 📬 Liên hệ

* **Email**: [yourname@example.com](mailto:tinhtse182892@fpt.edu.vn)
* **GitHub**: [@your-github-username](https://github.com/tinht04)

---

Bạn có muốn mình thêm **ảnh minh họa kiến trúc hệ thống (diagram)** vào README cho trực quan không?
