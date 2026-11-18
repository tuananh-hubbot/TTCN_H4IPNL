-- =========================================================================
-- DỮ LIỆU MẪU (SEED DATA) CHO HỆ THỐNG ĐẶT VÉ XEM PHIM (CINEMA-BOOK-SYSTEM)
-- Chuẩn MySQL / MariaDB
-- =========================================================================

USE CinemaBookSystem;

-- 1. Thêm Phân quyền (Role)
INSERT INTO role (role_name, description) VALUES
('CUSTOMER', 'Khách hàng sử dụng ứng dụng đặt vé'),
('STAFF', 'Nhân viên soát vé tại rạp'),
('ADMIN', 'Quản trị viên hệ thống quản lý rạp chiếu');

-- 2. Thêm Quyền hạn (Permission)
INSERT INTO permission (permission_code, description) VALUES
('BOOK_TICKET', 'Quyền thực hiện đặt vé và giữ ghế'),
('SCAN_QR', 'Quyền quét mã QR vé tại cửa phòng chiếu'),
('MANAGE_SHOWTIME', 'Quyền thêm sửa xóa suất chiếu và phim'),
('MANAGE_PRICING', 'Quyền cấu hình quy tắc giá vé');

-- 3. Gán quyền cho Vai trò (RolePermission)
INSERT INTO role_permission (role_id, permission_id) VALUES
(1, 1), -- CUSTOMER có quyền BOOK_TICKET
(2, 2), -- STAFF có quyền SCAN_QR
(3, 1), (3, 2), (3, 3), (3, 4); -- ADMIN có tất cả quyền

-- 4. Thêm Người dùng mẫu (Mật khẩu đã được mã hóa giả định)
INSERT INTO `user` (full_name, email, phone, password_hash, status) VALUES
(N'Quản Trị Viên', 'admin@cinema.vn', '0901112223', '$2a$10$hashedpasswordadmin', 'ACTIVE'),
(N'Nhân Viên Soát Vé', 'staff@cinema.vn', '0903334445', '$2a$10$hashedpasswordstaff', 'ACTIVE'),
(N'Đoàn Nguyễn Tuấn Anh', 'tuananh@gmail.com', '0987654321', '$2a$10$hashedpassworduser', 'ACTIVE');

-- 5. Gán vai trò cho Người dùng (UserRole)
INSERT INTO user_role (user_id, role_id) VALUES
(1, 3), -- User 1 là ADMIN
(2, 2), -- User 2 là STAFF
(3, 1); -- User 3 là CUSTOMER

-- 6. Thêm Danh mục Phim (Movie)
INSERT INTO movie (title, description, duration_minutes, genre, director, cast, release_date, age_rating, status) VALUES
(N'Dune: Hành Tinh Cát - Phần Hai', N'Paul Atreides hợp nhất với Chani và người Fremen để trả thù những kẻ đã hủy hoại gia đình anh.', 166, N'Khoa học viễn tưởng, Hành động', N'Denis Villeneuve', N'Timothée Chalamet, Zendaya', '2026-11-01', 'C13', 'NOW_SHOWING'),
(N'Lật Mặt 8: Vòng Tay Nắng', N'Câu chuyện cảm động về tình cảm gia đình và hành trình vượt qua nghịch cảnh tại miền Trung.', 135, N'Tâm lý, Gia đình', N'Lý Hải', N'Tiết Cương, Huy Khánh', '2026-11-15', 'P', 'NOW_SHOWING'),
(N'Avatar 3: Lửa Và Tro Tàn', N'Cuộc phiêu lưu tiếp theo của gia đình Jake Sully tại vùng đất núi lửa Pandora.', 190, N'Phiêu lưu, Viễn tưởng', N'James Cameron', N'Sam Worthington, Zoe Saldana', '2026-12-19', 'C13', 'COMING_SOON');

-- 7. Thêm Cụm Rạp (Cinema)
INSERT INTO cinema (name, address, phone, status) VALUES
(N'CGV Sư Vạn Hạnh', N'11 Sư Vạn Hạnh, Phường 12, Quận 10, TP.HCM', '02838620000', 'ACTIVE'),
(N'Lotte Cinema Nam Sài Gòn', N'469 Nguyễn Hữu Thọ, Tân Hưng, Quận 7, TP.HCM', '02837750000', 'ACTIVE');

-- 8. Thêm Phòng Chiếu (Room)
INSERT INTO room (cinema_id, room_name, status) VALUES
(1, N'Phòng 01 (2D)', 'ACTIVE'),
(1, N'Phòng 02 (IMAX)', 'ACTIVE'),
(2, N'Phòng 01', 'ACTIVE');

-- 9. Thêm Loại Ghế (SeatType)
INSERT INTO seat_type (type_name, description) VALUES
('NORMAL', N'Ghế thường tiêu chuẩn'),
('VIP', N'Ghế VIP vị trí đẹp, rộng rãi'),
('COUPLE', N'Ghế đôi (Sweetbox) dành cho 2 người');

-- 10. Tạo sơ đồ ghế tự động cho Phòng 1 (room_id = 1): 4 hàng (A, B, C, D) x 10 ghế
-- Hàng A, B: Thường | Hàng C: VIP | Hàng D: Ghế Đôi
INSERT INTO seat (room_id, seat_type_id, row_label, seat_number, status) VALUES
(1, 1, 'A', 1, 'ACTIVE'), (1, 1, 'A', 2, 'ACTIVE'), (1, 1, 'A', 3, 'ACTIVE'), (1, 1, 'A', 4, 'ACTIVE'), (1, 1, 'A', 5, 'ACTIVE'),
(1, 1, 'A', 6, 'ACTIVE'), (1, 1, 'A', 7, 'ACTIVE'), (1, 1, 'A', 8, 'ACTIVE'), (1, 1, 'A', 9, 'ACTIVE'), (1, 1, 'A', 10, 'ACTIVE'),
(1, 1, 'B', 1, 'ACTIVE'), (1, 1, 'B', 2, 'ACTIVE'), (1, 1, 'B', 3, 'ACTIVE'), (1, 1, 'B', 4, 'ACTIVE'), (1, 1, 'B', 5, 'ACTIVE'),
(1, 1, 'B', 6, 'ACTIVE'), (1, 1, 'B', 7, 'ACTIVE'), (1, 1, 'B', 8, 'ACTIVE'), (1, 1, 'B', 9, 'ACTIVE'), (1, 1, 'B', 10, 'ACTIVE'),
(1, 2, 'C', 1, 'ACTIVE'), (1, 2, 'C', 2, 'ACTIVE'), (1, 2, 'C', 3, 'ACTIVE'), (1, 2, 'C', 4, 'ACTIVE'), (1, 2, 'C', 5, 'ACTIVE'),
(1, 2, 'C', 6, 'ACTIVE'), (1, 2, 'C', 7, 'ACTIVE'), (1, 2, 'C', 8, 'ACTIVE'), (1, 2, 'C', 9, 'ACTIVE'), (1, 2, 'C', 10, 'ACTIVE'),
(1, 3, 'D', 1, 'ACTIVE'), (1, 3, 'D', 2, 'ACTIVE'), (1, 3, 'D', 3, 'ACTIVE'), (1, 3, 'D', 4, 'ACTIVE'), (1, 3, 'D', 5, 'ACTIVE');

-- 11. Thêm Khung Giờ (TimeSlot)
INSERT INTO time_slot (name, start_time, end_time) VALUES
(N'Suất sáng', '08:00:00', '11:59:59'),
(N'Suất chiều', '12:00:00', '17:59:59'),
(N'Suất tối (Giờ vàng)', '18:00:00', '23:59:59');

-- 12. Thêm Ngày Đặc Biệt (SpecialDay)
INSERT INTO special_day (special_date, name) VALUES
('2026-12-25', N'Lễ Giáng Sinh (Noel)'),
('2027-01-01', N'Tết Dương Lịch');

-- 13. Thêm Quy Tắc Định Giá (PricingRule)
INSERT INTO pricing_rule (time_slot_id, seat_type_id, special_day_id, day_of_week, rule_type, price_amount, priority, status) VALUES
(NULL, 1, NULL, NULL, 'DEFAULT', 75000.00, 100, 'ACTIVE'), -- Giá cơ bản ghế thường: 75k
(NULL, 2, NULL, NULL, 'DEFAULT', 95000.00, 100, 'ACTIVE'), -- Giá cơ bản ghế VIP: 95k
(NULL, 3, NULL, NULL, 'DEFAULT', 160000.00, 100, 'ACTIVE'), -- Giá cơ bản ghế Đôi: 160k
(3, NULL, NULL, NULL, 'DEFAULT', 20000.00, 50, 'ACTIVE'); -- Phụ thu suất tối: +20k

-- 14. Thêm Suất Chiếu (Showtime)
INSERT INTO showtime (movie_id, room_id, start_at, end_at, status) VALUES
(1, 1, '2026-11-25 18:00:00', '2026-11-25 20:46:00', 'OPEN'),
(1, 1, '2026-11-25 21:15:00', '2026-11-26 00:01:00', 'OPEN'),
(2, 1, '2026-11-25 15:00:00', '2026-11-25 17:15:00', 'OPEN');

-- 15. Khởi tạo trạng thái ghế cho suất chiếu (ShowtimeSeat) dựa trên sơ đồ ghế của phòng 1
INSERT INTO showtime_seat (showtime_id, seat_id, status)
SELECT 1, seat_id, 'AVAILABLE' FROM seat WHERE room_id = 1;

-- 16. Thêm Đánh giá mẫu (Rating)
INSERT INTO rating (user_id, movie_id, score) VALUES
(3, 1, 5);

-- 17. Thêm Bình luận mẫu (Comment)
INSERT INTO comment (user_id, movie_id, content, status) VALUES
(3, 1, N'Phim xem cực kỳ mãn nhãn, âm thanh và kỹ xảo đỉnh cao!', 'VISIBLE');