-- =========================================================================
-- HỆ THỐNG ĐẶT VÉ XEM PHIM (CINEMA-BOOK-SYSTEM)
-- Cơ sở dữ liệu chuẩn MySQL / MariaDB
-- =========================================================================

CREATE DATABASE IF NOT EXISTS CinemaBookSystem CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE CinemaBookSystem;

-- =========================================================================
-- NHÓM 1: TÀI KHOẢN, PHÂN QUYỀN (RBAC) & NHẬT KÝ HỆ THỐNG
-- =========================================================================

-- 1. Bảng User: Lưu thông tin tài khoản người dùng (Khách hàng, Nhân viên, Quản trị viên)
CREATE TABLE `user` (
    user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(30) NOT NULL,                    -- Họ tên người dùng
    email VARCHAR(50) NOT NULL UNIQUE,                 -- Email đăng nhập
    phone VARCHAR(20) NULL UNIQUE,                     -- Số điện thoại (cho phép NULL nhiều lần trong MySQL)
    password_hash VARCHAR(255) NOT NULL,               -- Mật khẩu đã mã hóa (bcrypt/argon2)
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',      -- Trạng thái: ACTIVE (Hoạt động), LOCKED (Khóa)
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NULL ON UPDATE CURRENT_TIMESTAMP(3),
    CONSTRAINT CK_User_Status CHECK (status IN ('ACTIVE', 'LOCKED'))
);

-- 2. Bảng Role: Định nghĩa các vai trò trong hệ thống (CUSTOMER, ADMIN, TICKET_CHECKER...)
CREATE TABLE role (
    role_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(30) NOT NULL UNIQUE,             -- Tên vai trò
    description VARCHAR(250) NULL                      -- Mô tả chi tiết vai trò
);

-- 3. Bảng Permission: Định nghĩa các quyền hạn cụ thể (BOOK_TICKET, SCAN_QR, MANAGE_SHOWTIME...)
CREATE TABLE permission (
    permission_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    permission_code VARCHAR(50) NOT NULL UNIQUE,       -- Mã định danh quyền
    description VARCHAR(250) NULL                      -- Mô tả quyền hạn
);

-- 4. Bảng UserRole: Bảng trung gian phân vai trò cho người dùng (Quan hệ N:N)
CREATE TABLE user_role (
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    assigned_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT FK_UserRole_User FOREIGN KEY (user_id) REFERENCES `user`(user_id) ON DELETE CASCADE,
    CONSTRAINT FK_UserRole_Role FOREIGN KEY (role_id) REFERENCES role(role_id) ON DELETE CASCADE
);

-- 5. Bảng RolePermission: Bảng trung gian gán quyền cho từng vai trò (Quan hệ N:N)
CREATE TABLE role_permission (
    role_id BIGINT NOT NULL,
    permission_id BIGINT NOT NULL,
    PRIMARY KEY (role_id, permission_id),
    CONSTRAINT FK_RolePermission_Role FOREIGN KEY (role_id) REFERENCES role(role_id) ON DELETE CASCADE,
    CONSTRAINT FK_RolePermission_Permission FOREIGN KEY (permission_id) REFERENCES permission(permission_id) ON DELETE CASCADE
);

-- 6. Bảng AuditLog: Ghi lại lịch sử thao tác quan trọng của hệ thống (Nhật ký kiểm toán)
CREATE TABLE audit_log (
    audit_log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    actor_user_id BIGINT NULL,                         -- Người thực hiện hành động
    action VARCHAR(120) NOT NULL,                      -- Tên hành động (Ví dụ: UPDATE_SHOWTIME)
    target_type VARCHAR(80) NULL,                      -- Đối tượng bị tác động (Ví dụ: MOVIE)
    target_id VARCHAR(80) NULL,                        -- ID của đối tượng
    details TEXT NULL,                                 -- Chi tiết thay đổi lưu dưới dạng chuỗi JSON
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    CONSTRAINT FK_AuditLog_User FOREIGN KEY (actor_user_id) REFERENCES `user`(user_id) ON DELETE SET NULL
);

-- =========================================================================
-- NHÓM 2: PHIM, RẠP, PHÒNG, GHẾ & SUẤT CHIẾU
-- =========================================================================

-- 7. Bảng Movie: Quản lý thông tin chi tiết các bộ phim chiếu rạp
CREATE TABLE movie (
    movie_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(250) NOT NULL,                       -- Tên phim
    description TEXT NULL,                             -- Nội dung tóm tắt
    poster_url VARCHAR(500) NULL,                      -- Link ảnh poster
    trailer_url VARCHAR(500) NULL,                     -- Link video trailer
    duration_minutes SMALLINT NOT NULL,                -- Thời lượng phim (tính bằng phút)
    release_date DATE NULL,                            -- Ngày khởi chiếu
    age_rating VARCHAR(20) NULL,                       -- Giới hạn độ tuổi (P, C13, C16, C18)
    language VARCHAR(30) NULL,                         -- Ngôn ngữ / Phụ đề
    country VARCHAR(50) NULL,                          -- Quốc gia sản xuất
    genre VARCHAR(250) NULL,                           -- Thể loại phim
    director VARCHAR(50) NULL,                         -- Đạo diễn
    cast TEXT NULL,                                    -- Diễn viên chính
    status VARCHAR(30) NOT NULL DEFAULT 'COMING_SOON', -- Trạng thái: COMING_SOON, NOW_SHOWING, ENDED
    CONSTRAINT CK_Movie_Duration CHECK (duration_minutes > 0),
    CONSTRAINT CK_Movie_Status CHECK (status IN ('COMING_SOON', 'NOW_SHOWING', 'ENDED'))
);

-- 8. Bảng Cinema: Quản lý các chi nhánh cụm rạp
CREATE TABLE cinema (
    cinema_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,                        -- Tên cụm rạp (Ví dụ: CGV Sư Vạn Hạnh)
    address VARCHAR(250) NOT NULL,                     -- Địa chỉ chi nhánh
    phone VARCHAR(20) NULL,                            -- Số điện thoại rạp
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',      -- Trạng thái: ACTIVE, INACTIVE
    CONSTRAINT CK_Cinema_Status CHECK (status IN ('ACTIVE', 'INACTIVE'))
);

-- 9. Bảng Room: Quản lý các phòng chiếu thuộc từng cụm rạp
CREATE TABLE room (
    room_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cinema_id BIGINT NOT NULL,                         -- Thuộc cụm rạp nào
    room_name VARCHAR(80) NOT NULL,                    -- Tên phòng chiếu (Ví dụ: Phòng 01, Phòng IMAX)
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',      -- Trạng thái: ACTIVE, MAINTENANCE (Đang bảo trì)
    CONSTRAINT FK_Room_Cinema FOREIGN KEY (cinema_id) REFERENCES cinema(cinema_id) ON DELETE RESTRICT,
    CONSTRAINT CK_Room_Status CHECK (status IN ('ACTIVE', 'MAINTENANCE'))
);

-- 10. Bảng SeatType: Phân loại hạng ghế (Thường, VIP, Ghế đôi)
CREATE TABLE seat_type (
    seat_type_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(30) NOT NULL UNIQUE,             -- Tên loại ghế (NORMAL, VIP, COUPLE)
    description VARCHAR(250) NULL                      -- Mô tả loại ghế
);

-- 11. Bảng Seat: Sơ đồ ghế vật lý cố định trong mỗi phòng chiếu
CREATE TABLE seat (
    seat_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    room_id BIGINT NOT NULL,                           -- Thuộc phòng chiếu nào
    seat_type_id BIGINT NOT NULL,                      -- Thuộc hạng ghế nào
    row_label VARCHAR(5) NOT NULL,                     -- Hàng ghế (A, B, C...)
    seat_number SMALLINT NOT NULL,                     -- Số thứ tự ghế trong hàng (1, 2, 3...)
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',      -- Trạng thái: ACTIVE, BROKEN (Hỏng)
    CONSTRAINT FK_Seat_Room FOREIGN KEY (room_id) REFERENCES room(room_id) ON DELETE RESTRICT,
    CONSTRAINT FK_Seat_SeatType FOREIGN KEY (seat_type_id) REFERENCES seat_type(seat_type_id) ON DELETE RESTRICT,
    CONSTRAINT CK_Seat_Number CHECK (seat_number > 0),
    CONSTRAINT CK_Seat_Status CHECK (status IN ('ACTIVE', 'BROKEN')),
    CONSTRAINT UQ_Seat_Room_Row_Num UNIQUE (room_id, row_label, seat_number)
);

-- 12. Bảng Showtime: Lịch chiếu phim cụ thể theo phòng và thời gian
CREATE TABLE showtime (
    showtime_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    movie_id BIGINT NOT NULL,                          -- Phim chiếu
    room_id BIGINT NOT NULL,                           -- Chiếu ở phòng nào
    start_at DATETIME(3) NOT NULL,                     -- Thời gian bắt đầu chiếu
    end_at DATETIME(3) NOT NULL,                       -- Thời gian kết thúc
    status VARCHAR(30) NOT NULL DEFAULT 'SCHEDULED',   -- Trạng thái: SCHEDULED, OPEN, CLOSED, CANCELLED
    CONSTRAINT FK_Showtime_Movie FOREIGN KEY (movie_id) REFERENCES movie(movie_id) ON DELETE RESTRICT,
    CONSTRAINT FK_Showtime_Room FOREIGN KEY (room_id) REFERENCES room(room_id) ON DELETE RESTRICT,
    CONSTRAINT CK_Showtime_Status CHECK (status IN ('SCHEDULED', 'OPEN', 'CLOSED', 'CANCELLED'))
);

-- 13. Bảng ShowtimeSeat: Trạng thái từng ghế tương ứng với mỗi suất chiếu cụ thể
CREATE TABLE showtime_seat (
    showtime_seat_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    showtime_id BIGINT NOT NULL,                       -- Suất chiếu nào
    seat_id BIGINT NOT NULL,                           -- Ghế nào
    status VARCHAR(30) NOT NULL DEFAULT 'AVAILABLE',   -- Trạng thái ghế: AVAILABLE (Trống), HELD (Đang giữ), SOLD (Đã bán)
    CONSTRAINT FK_ShowtimeSeat_Showtime FOREIGN KEY (showtime_id) REFERENCES showtime(showtime_id) ON DELETE RESTRICT,
    CONSTRAINT FK_ShowtimeSeat_Seat FOREIGN KEY (seat_id) REFERENCES seat(seat_id) ON DELETE RESTRICT,
    CONSTRAINT CK_ShowtimeSeat_Status CHECK (status IN ('AVAILABLE', 'HELD', 'SOLD')),
    CONSTRAINT UQ_ShowtimeSeat UNIQUE (showtime_id, seat_id)
);

-- =========================================================================
-- NHÓM 3: QUY TẮC TÍNH GIÁ VÉ (PRICING ENGINE)
-- =========================================================================

-- 14. Bảng TimeSlot: Định nghĩa các khung giờ trong ngày (Sáng, Tối, Giờ vàng...)
CREATE TABLE time_slot (
    time_slot_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) NOT NULL UNIQUE,                  -- Tên khung giờ
    start_time TIME NOT NULL,                          -- Giờ bắt đầu
    end_time TIME NOT NULL                             -- Giờ kết thúc
);

-- 15. Bảng SpecialDay: Định nghĩa các ngày lễ, Tết hoặc ngày đặc biệt trong năm
CREATE TABLE special_day (
    special_day_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    special_date DATE NOT NULL UNIQUE,                 -- Ngày cụ thể
    name VARCHAR(120) NOT NULL                         -- Tên sự kiện (Ví dụ: Tết Nguyên Đán, 30/4)
);

-- 16. Bảng PricingRule: Thiết lập quy tắc cấu hình giá vé động linh hoạt
CREATE TABLE pricing_rule (
    pricing_rule_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    time_slot_id BIGINT NULL,                          -- Áp dụng cho khung giờ nào
    seat_type_id BIGINT NULL,                          -- Áp dụng cho loại ghế nào
    special_day_id BIGINT NULL,                        -- Áp dụng cho ngày đặc biệt nào
    day_of_week TINYINT NULL,                          -- Áp dụng cho thứ mấy trong tuần (1-7)
    rule_type VARCHAR(30) NOT NULL,                    -- Loại quy tắc: SPECIAL_DAY, DAY_OF_WEEK, DEFAULT
    price_amount DECIMAL(12,2) NOT NULL,               -- Mức giá hoặc tiền phụ thu
    priority SMALLINT NOT NULL DEFAULT 100,            -- Độ ưu tiên áp dụng quy tắc
    valid_from DATE NULL,                              -- Hiệu lực từ ngày
    valid_to DATE NULL,                                -- Hiệu lực đến ngày
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',      -- Trạng thái quy tắc
    CONSTRAINT FK_PricingRule_TimeSlot FOREIGN KEY (time_slot_id) REFERENCES time_slot(time_slot_id) ON DELETE RESTRICT,
    CONSTRAINT FK_PricingRule_SeatType FOREIGN KEY (seat_type_id) REFERENCES seat_type(seat_type_id) ON DELETE RESTRICT,
    CONSTRAINT FK_PricingRule_SpecialDay FOREIGN KEY (special_day_id) REFERENCES special_day(special_day_id) ON DELETE RESTRICT,
    CONSTRAINT CK_PricingRule_DayOfWeek CHECK (day_of_week BETWEEN 1 AND 7),
    CONSTRAINT CK_PricingRule_Amount CHECK (price_amount >= 0),
    CONSTRAINT CK_PricingRule_Type CHECK (rule_type IN ('SPECIAL_DAY', 'DAY_OF_WEEK', 'DEFAULT')),
    CONSTRAINT CK_PricingRule_TypeLogic CHECK (
        (rule_type = 'SPECIAL_DAY' AND special_day_id IS NOT NULL) OR
        (rule_type = 'DAY_OF_WEEK' AND day_of_week IS NOT NULL) OR
        (rule_type = 'DEFAULT')
    )
);

-- =========================================================================
-- NHÓM 4: ĐẶT VÉ, GIỮ GHẾ, THANH TOÁN & PHÁT HÀNH VÉ
-- =========================================================================

-- 17. Bảng Booking: Quản lý thông tin tổng quan đơn đặt vé của khách hàng
CREATE TABLE booking (
    booking_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,                           -- Khách hàng đặt vé
    booking_code VARCHAR(40) NOT NULL UNIQUE,          -- Mã hóa đơn giao dịch
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',     -- Trạng thái: PENDING (Chờ thanh toán), CONFIRMED (Đã xác nhận), CANCELLED, EXPIRED
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0,     -- Tổng số tiền cần thanh toán
    CONSTRAINT FK_Booking_User FOREIGN KEY (user_id) REFERENCES `user`(user_id) ON DELETE RESTRICT,
    CONSTRAINT CK_Booking_Status CHECK (status IN ('PENDING', 'CONFIRMED', 'CANCELLED', 'EXPIRED'))
);

-- 18. Bảng SeatHold: Cơ chế giữ ghế tạm thời trong lúc khách đang chọn và thanh toán (chống trùng ghế)
CREATE TABLE seat_hold (
    seat_hold_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    showtime_seat_id BIGINT NOT NULL,                  -- Ghế trong suất chiếu đang bị giữ
    user_id BIGINT NOT NULL,                           -- Người giữ ghế
    booking_id BIGINT NULL,                            -- Thuộc đơn đặt vé nào
    held_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    expires_at DATETIME(3) NOT NULL,                   -- Thời gian hết hạn giữ ghế (sau 5-10 phút)
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',      -- Trạng thái: ACTIVE, CONVERTED, EXPIRED, RELEASED
    active_key TINYINT GENERATED ALWAYS AS (IF(status = 'ACTIVE', 1, NULL)) VIRTUAL, -- Cột ảo lọc ghế đang giữ
    CONSTRAINT FK_SeatHold_ShowtimeSeat FOREIGN KEY (showtime_seat_id) REFERENCES showtime_seat(showtime_seat_id) ON DELETE RESTRICT,
    CONSTRAINT FK_SeatHold_User FOREIGN KEY (user_id) REFERENCES `user`(user_id) ON DELETE RESTRICT,
    CONSTRAINT FK_SeatHold_Booking FOREIGN KEY (booking_id) REFERENCES booking(booking_id) ON DELETE SET NULL,
    CONSTRAINT CK_SeatHold_Status CHECK (status IN ('ACTIVE', 'CONVERTED', 'EXPIRED', 'RELEASED')),
    CONSTRAINT UQ_SeatHold_Active UNIQUE (showtime_seat_id, active_key)
);

-- 19. Bảng Payment: Quản lý giao dịch thanh toán gắn liền 1:1 với đơn đặt vé
CREATE TABLE payment (
    payment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL UNIQUE,                 -- Đơn đặt vé tương ứng
    amount DECIMAL(12,2) NOT NULL,                     -- Số tiền thanh toán
    method VARCHAR(40) NOT NULL DEFAULT 'MOCK',        -- Phương thức thanh toán (MOCK, VNPAY, MOMO...)
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',     -- Trạng thái: PENDING, SUCCESS, FAILED
    idempotency_key VARCHAR(100) NULL UNIQUE,          -- Khóa chống lặp giao dịch (Idempotency)
    transaction_reference VARCHAR(120) NULL UNIQUE,    -- Mã giao dịch từ cổng thanh toán bên thứ ba
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NULL ON UPDATE CURRENT_TIMESTAMP(3),
    CONSTRAINT FK_Payment_Booking FOREIGN KEY (booking_id) REFERENCES booking(booking_id) ON DELETE RESTRICT,
    CONSTRAINT CK_Payment_Status CHECK (status IN ('PENDING', 'SUCCESS', 'FAILED'))
);

-- 20. Bảng Ticket: Vé điện tử được phát hành sau khi thanh toán thành công
CREATE TABLE ticket (
    ticket_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL,                        -- Thuộc đơn đặt vé nào
    showtime_seat_id BIGINT NOT NULL,                  -- Ghế tương ứng của vé
    ticket_code VARCHAR(40) NOT NULL UNIQUE,           -- Mã vé hiển thị trên vé
    qr_token VARCHAR(255) NOT NULL UNIQUE,             -- Chuỗi mã hóa dùng để tạo mã QR Code soát vé
    actual_price DECIMAL(12,2) NOT NULL,               -- Giá vé thực tế tại thời điểm mua
    status VARCHAR(30) NOT NULL DEFAULT 'ISSUED',      -- Trạng thái: ISSUED (Đã phát hành), USED (Đã dùng), CANCELLED
    issued_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    valid_key TINYINT GENERATED ALWAYS AS (IF(status IN ('ISSUED', 'USED'), 1, NULL)) VIRTUAL, -- Cột ảo kiểm tra vé hợp lệ
    CONSTRAINT FK_Ticket_Booking FOREIGN KEY (booking_id) REFERENCES booking(booking_id) ON DELETE RESTRICT,
    CONSTRAINT FK_Ticket_ShowtimeSeat FOREIGN KEY (showtime_seat_id) REFERENCES showtime_seat(showtime_seat_id) ON DELETE RESTRICT,
    CONSTRAINT CK_Ticket_Status CHECK (status IN ('ISSUED', 'USED', 'CANCELLED')),
    CONSTRAINT UQ_Ticket_ValidSeat UNIQUE (showtime_seat_id, valid_key)
);

-- =========================================================================
-- NHÓM 5: SOÁT VÉ, HỦY VÉ & ĐÁNH GIÁ/BÌNH LUẬN
-- =========================================================================

-- 21. Bảng TicketValidation: Ghi lại lịch sử quét mã QR soát vé tại cửa phòng chiếu
CREATE TABLE ticket_validation (
    validation_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    ticket_id BIGINT NOT NULL,                         -- Vé được quét
    checker_user_id BIGINT NOT NULL,                   -- Nhân viên soát vé thực hiện
    validated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    result VARCHAR(30) NOT NULL,                       -- Kết quả: VALID, ALREADY_USED, CANCELLED, INVALID, WRONG_SHOWTIME
    note VARCHAR(255) NULL,                            -- Ghi chú thêm
    CONSTRAINT FK_TicketValidation_Ticket FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id) ON DELETE RESTRICT,
    CONSTRAINT FK_TicketValidation_Checker FOREIGN KEY (checker_user_id) REFERENCES `user`(user_id) ON DELETE RESTRICT,
    CONSTRAINT CK_Validation_Result CHECK (result IN ('VALID', 'ALREADY_USED', 'CANCELLED', 'INVALID', 'WRONG_SHOWTIME'))
);

-- 22. Bảng CancellationRequest: Quản lý yêu cầu hủy vé và hoàn tiền của khách hàng
CREATE TABLE cancellation_request (
    cancellation_request_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    ticket_id BIGINT NOT NULL,                         -- Vé xin hủy
    requested_by_user_id BIGINT NOT NULL,              -- Người yêu cầu hủy
    processed_by_user_id BIGINT NULL,                  -- Nhân viên xử lý yêu cầu
    reason TEXT NOT NULL,                              -- Lý do hủy vé
    evidence_reference VARCHAR(500) NULL,              -- Bằng chứng / hình ảnh minh chứng
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',     -- Trạng thái: PENDING, APPROVED, REJECTED
    requested_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    processed_at DATETIME(3) NULL,                     -- Thời điểm xử lý
    CONSTRAINT FK_Cancellation_Ticket FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id) ON DELETE RESTRICT,
    CONSTRAINT FK_Cancellation_ReqUser FOREIGN KEY (requested_by_user_id) REFERENCES `user`(user_id) ON DELETE RESTRICT,
    CONSTRAINT FK_Cancellation_ProcUser FOREIGN KEY (processed_by_user_id) REFERENCES `user`(user_id) ON DELETE RESTRICT,
    CONSTRAINT CK_Cancellation_Status CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED'))
);

-- 23. Bảng Rating: Quản lý điểm đánh giá sao (1-5 sao) cho phim
CREATE TABLE rating (
    rating_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,                           -- Người đánh giá
    movie_id BIGINT NOT NULL,                          -- Phim được đánh giá
    score TINYINT NOT NULL,                            -- Số điểm (1 đến 5)
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    CONSTRAINT FK_Rating_User FOREIGN KEY (user_id) REFERENCES `user`(user_id) ON DELETE RESTRICT,
    CONSTRAINT FK_Rating_Movie FOREIGN KEY (movie_id) REFERENCES movie(movie_id) ON DELETE RESTRICT,
    CONSTRAINT CK_Rating_Score CHECK (score BETWEEN 1 AND 5),
    CONSTRAINT UQ_Rating_User_Movie UNIQUE (user_id, movie_id) -- Mỗi user chỉ được rate 1 lần cho 1 phim
);

-- 24. Bảng Comment: Quản lý bình luận và nhận xét của khán giả về phim
CREATE TABLE comment (
    comment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,                           -- Người bình luận
    movie_id BIGINT NOT NULL,                          -- Bình luận cho phim nào
    content TEXT NOT NULL,                             -- Nội dung bình luận
    status VARCHAR(30) NOT NULL DEFAULT 'VISIBLE',     -- Trạng thái hiển thị: VISIBLE, HIDDEN (Bị ẩn do vi phạm)
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NULL ON UPDATE CURRENT_TIMESTAMP(3),
    CONSTRAINT FK_Comment_User FOREIGN KEY (user_id) REFERENCES `user`(user_id) ON DELETE RESTRICT,
    CONSTRAINT FK_Comment_Movie FOREIGN KEY (movie_id) REFERENCES movie(movie_id) ON DELETE RESTRICT,
    CONSTRAINT CK_Comment_Status CHECK (status IN ('VISIBLE', 'HIDDEN'))
);