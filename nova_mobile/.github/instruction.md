## Main functions
1. Design database, APIs (10%)
2. Sign Up / Login (10%)
3. List of Products (10%)
4. Product Details (10%)
5. Product Cart (10%)
6. Billing / Payment (10%)
7. Show notification if Cart has products when opening the app (10%)
8. Map screen: show Store location (10%)
9. Chat screen: customers can chat with Store (10%)
10. Apply MVVM (or chosen pattern) in app architecture (10%)
11. AI-based product recommendation (bonus +1)

## Quy tắc (Rules) cho phát triển Mobile UI — Flutter + RESTful API
Mục tiêu: cung cấp quy tắc rõ ràng để các thành viên triển khai phần Mobile (UI + logic) kết nối với backend `NovaCMS-API-PRM392` dựa trên `swagger.json`.

1) Công nghệ cơ bản (bắt buộc/khuyến nghị)
 - Flutter (stable channel)
 - State management: Riverpod (khuyến nghị) hoặc Provider/Bloc nếu đội đã quen
 - HTTP client: Dio (kèm Interceptor)
 - Models & serialization: freezed + json_serializable (immutable, easy to test)
 - Local storage: flutter_secure_storage (JWT), Hive (cart / offline cache)
 - Routing: go_router
 - Map: google_maps_flutter hoặc flutter_map
 - Notification: firebase_messaging (push) + local_notifications (local)
 - Testing: flutter_test + mocktail/mockito

2) `Kiến trúc bắt buộc`
 - MVVM (View, ViewModel, Repository, Model) — nếu nhóm muốn MVVM-Mediator, ghi rõ và áp dụng tương tự
 - Tách rõ layers:
	 - UI (widgets/screens): không gọi trực tiếp Dio, chỉ gọi ViewModel
	 - ViewModel: xử lý trạng thái, validation, mapping model->ui
	 - Repository: tương tác API, cache, mapping DTO->Model
	 - ApiClient (core/network): cấu hình Dio, Interceptor (attach token, logging, error mapping)

3) Cấu trúc thư mục tiêu chuẩn (ví dụ dưới `lib/`)
 - lib/
	 - main.dart
	 - app.dart
	 - core/
		 - network/api_client.dart
		 - network/interceptors.dart
		 - storage/secure_storage.dart

	 - models/  (freezed models)
	 - repositories/
	 - viewmodels/
	 - ui/
		 - screens/
		 - widgets/
	 - services/ (payment, map wrappers, chat)
	 - utils/
	 - di/ (providers / dependency injection)

4) Quy ước đặt tên và coding style
 - Tên file: snake_case (ví dụ: product_list_screen.dart)
 - Tên class: PascalCase (ProductListViewModel)
 - Method async trả về Future<T>
 - Không đưa logic network vào Widget
 - Sử dụng freezed/data classes cho models
 - Giữ các trạng thái UI dưới dạng sealed classes hoặc AsyncValue (Riverpod)

5) API Client và Interceptor (bắt buộc)
 - Dùng một lớp `ApiClient` để tạo `Dio` duy nhất trong app
 - Interceptor:
	 - Gắn header Authorization: Bearer <token> từ `flutter_secure_storage`
	 - Map lỗi HTTP -> DomainException (400 -> ValidationError, 401 -> Unauthorized, 500 -> ServerError)
	 - Retry / timeout cấu hình (tối đa 30s)

6) Sinh client từ `swagger.json` (tùy chọn nhưng khuyến nghị)
 - Nếu không sinh client: định nghĩa models bằng `freezed` theo schema cần thiết
 - Nếu không sinh, định nghĩa models bằng `freezed` theo schema cần thiết

7) Lưu trữ token & security
 - Lưu JWT: `flutter_secure_storage`
 - Cấm: không log trực tiếp token vào console trong production
 - Khi nhận 401: tự động điều hướng về màn login (ViewModel xử lý) hoặc gọi refresh token nếu backend hỗ trợ

8) Cart & offline
 - Lưu cart local bằng Hive
 - Khi app khởi động: kiểm tra cart non-empty => hiện local notification / modal (yêu cầu 7)
 - Đồng bộ (sync) chỉ khi user checkout hoặc explicit sync

9) Thanh toán (Billing)
 - Flow: tạo order -> gọi `POST /api/Payment` -> mở payment page (WebView hoặc redirect) -> backend callback `/api/Payment/callback`
 - UI phải hiển thị trạng thái (pending/success/fail)

10) Map
 - Hiển thị store location bằng `google_maps_flutter`
 - API key: cấu hình theo platform (AndroidManifest/Info.plist)
 - Cho phép user mở navigation ra Google Maps bằng `url_launcher`

11) Chat
 - Nếu chỉ chatbot/RAG: gọi `POST /api/Chat/ask` và hiện response dạng chat
 - Nếu cần realtime: confirm backend có WebSocket/Socket.IO; nếu không có, fallback dùng polling hoặc HTTP-based chat

12) AI Recommendation (bonus)
 - Sử dụng endpoint RAG hoặc tạo endpoint recommend dựa trên embeddings
 - Hiển thị suggestion ở product detail / checkout

13) UI/UX guidelines
 - Luôn support responsive layout (phone <= 480dp, tablet breakpoint)
 - Accessibility: textScaleFactor, semantic labels cho các controls quan trọng
 - Loading & empty states: skeleton / placeholders
 - Error states: hiển thị message rõ ràng và action (retry)

14) Tests & CI
 - Viết unit tests cho ViewModel và Repository (mock ApiClient)
 - Viết widget tests cho Login, Product List, Cart
 - CI (GitHub Actions): analyze, test, build

15) Quality check trước nộp
 - flutter analyze (0 issue hoặc only allowed exceptions)
 - flutter test (all tests pass)
 - No hard-coded secrets
 - Build APK/IPA success (smoke test)

16) Commit / PR rules
 - Commit message: <type>(scope): short description
	 - type: feat|fix|chore|docs|test
 - Small, atomic PRs (mỗi PR 1 feature/screen)
 - PR description: mapping tới requirement numbers (ví dụ: implements 2,3,4)
 - Attach screenshots / brief video of UI in PR

17) Deliverables cho mỗi chức năng (phải có)
 - UI screen (responsive)
 - ViewModel + unit tests
 - Repository + API integration
 - Integration test (smoke) hoặc manual test steps
 - README ngắn cho feature (cách test)

18) Mapping nhanh tới `Main functions` (bắt buộc hiển thị trong PR)
 - 2: Sign Up/Login -> `POST /api/Auth/register`, `POST /api/Auth/login`
 - 3: List Products -> `GET /api/Equipment` (pagi, filter)
 - 4: Product Details -> `GET /api/Equipment/{id}`
 - 5: Cart -> local Hive + checkout -> `POST /api/RentalOrder`
 - 6: Billing -> `POST /api/Payment` + callback
 - 7: Notification on open -> check Hive cart
 - 8: Map -> Google Maps screen
 - 9: Chat -> `POST /api/Chat/ask` (RAG) or WebSocket
 - 10: Architecture: MVVM enforced
 - 11: AI: use `Chat/ask` or dedicated endpoint for recommendations

19) Checklist đánh giá (khi nghiệm thu)
 - [ ] Màn hình hoạt động, UI giống mock/acceptable
 - [ ] API integration đúng theo swagger
 - [ ] Xử lý lỗi & edge cases
 - [ ] Tests: unit + widget cơ bản
 - [ ] Không lưu secrets, token dùng secure storage
 - [ ] PR nhỏ, có mô tả và ảnh chụp

---



# Nova Mobile — Setup & Run (Windows / PowerShell)

Tài liệu ngắn gọn để chạy project khi clone từ GitHub (dành cho môi trường Windows, PowerShell).

Mục tiêu: hướng dẫn cài dependency, cấu hình dev và các lệnh để chạy Flutter app.

---

## 1. Yêu cầu trước khi bắt đầu
- Git
- Flutter SDK (thêm vào PATH)
- .NET SDK (nếu bạn chạy backend local)
- Android SDK / Android Studio (nếu chạy trên emulator / Android)
- Java JDK (nếu làm Android builds)

Kiểm tra nhanh:

```powershell
# Kiểm tra các công cụ
git --version
flutter --version
dotnet --info
```

---

## 2. Clone repo

Clone repository, rồi vào thư mục mobile:

```powershell
Set-Location -Path 'D:\'
git clone <your-repo-url>
# vào thư mục mobile
Set-Location -Path 'D:\Mobile\nova_mobile'
```

---

## 3. Thiết lập Mobile (Flutter)

1. Cài dependencies:

```powershell
Set-Location -Path 'D:\Mobile\nova_mobile'
flutter pub get
```

2. Clean (nếu cần):

```powershell
flutter clean
Remove-Item -Recurse -Force .\build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .\.dart_tool -ErrorAction SilentlyContinue
flutter pub get
```

3. Android (tuỳ chọn):

```powershell
Set-Location -Path 'D:\Mobile\nova_mobile\android'
.\gradlew.bat clean
```

4. Chạy ứng dụng:

- Flutter web (Chrome):

```powershell
Set-Location -Path 'D:\Mobile\nova_mobile'
flutter run -d chrome
```

- Android emulator:

```powershell
Set-Location -Path 'D:\Mobile\nova_mobile'
flutter devices
flutter run -d <device-id>
```

Lưu ý: file `lib/core/env.dart` trong repo đã có logic platform-aware; web thường gọi `http://localhost:5162`, Android emulator dùng `http://10.0.2.2:5162`.

---


