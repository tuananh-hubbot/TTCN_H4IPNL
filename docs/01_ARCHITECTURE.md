# Kiến trúc CineBook

## Luồng request
1. Trình duyệt mở Angular tại `http://localhost:4200`.
2. Người dùng nhấn **Kiểm tra backend**.
3. Angular HttpClient gửi `GET /api/health` tới Nginx.
4. Nginx chuyển tiếp `/api/*` tới service `backend:8080` trong Docker.
5. `HealthController` trả JSON `{ "status": "ok", "application": "CineBook API" }`.
6. Angular nhận JSON và hiển thị trạng thái.

## Luồng dữ liệu khi thêm nghiệp vụ
Angular component → Angular service → REST Controller → Spring Service → Spring Data Repository → MySQL.

## Bảo mật
`SecurityConfig` hiện chỉ mở public endpoint health, còn các API khác bị chặn. **JWT chưa được triển khai**.

## Database
Flyway chạy migration `V1__initial_schema.sql` khi backend khởi động, tạo bảng demo `app_metadata`.
