## Giới thiệu

**Flutter_QuanLiChiTieu** là ứng dụng quản lý tài chính cá nhân được phát triển bằng Flutter, giúp người dùng theo dõi các khoản thu nhập, chi tiêu và quản lý ngân sách hiệu quả.

Ứng dụng được xây dựng nhằm hỗ trợ người dùng ghi lại các giao dịch tài chính hằng ngày, thống kê tình hình tài chính và đưa ra cái nhìn trực quan về dòng tiền cá nhân.

---

# Mục tiêu dự án

- Quản lý thu nhập và chi tiêu cá nhân.
- Theo dõi lịch sử giao dịch.
- Thống kê tình hình tài chính.
- Hỗ trợ xây dựng thói quen chi tiêu hợp lý.
- Tăng cường khả năng quản lý ngân sách cá nhân.

---

# Công nghệ sử dụng

| Công nghệ       | Mô tả                                     |
| --------------- | ----------------------------------------- |
| Flutter         | Framework phát triển ứng dụng đa nền tảng |
| Dart            | Ngôn ngữ lập trình chính                  |
| Material Design | Thiết kế giao diện người dùng             |
| Local Storage   | Lưu trữ dữ liệu cục bộ                    |
| Android SDK     | Nền tảng triển khai Android               |
| iOS SDK         | Nền tảng triển khai iOS                   |

---

# Chức năng chính

## 1. Quản lý giao dịch

Người dùng có thể:

- Thêm giao dịch mới.
- Chỉnh sửa giao dịch.
- Xóa giao dịch.
- Lưu thông tin:
  - Số tiền
  - Loại giao dịch
  - Ngày thực hiện
  - Hình ảnh giao dịch (tùy chọn)
  - Ghi chú

---

## 2. Quản lý thu nhập

Cho phép lưu các nguồn thu:

- Lương
- Thưởng
- Kinh doanh
- Đầu tư
- Thu nhập khác

---

## 3. Quản lý chi tiêu

Theo dõi các khoản chi:

- Ăn uống
- Mua sắm
- Di chuyển
- Giải trí
- Học tập
- Sinh hoạt
- Khác

---

## 4. Thống kê tài chính

Hệ thống hỗ trợ:

- Tổng thu nhập.
- Tổng chi tiêu.
- Số dư hiện tại.
- Báo cáo theo ngày.
- Báo cáo theo tháng.
- Báo cáo theo năm.

---

## 5. Lịch sử giao dịch

- Xem danh sách giao dịch.
- Tìm kiếm giao dịch.
- Lọc theo thời gian.
- Theo dõi dòng tiền theo từng giai đoạn.

---

## 6. Giao diện người dùng

Đặc điểm:

- Thiết kế trực quan.
- Dễ sử dụng.
- Responsive trên nhiều kích thước màn hình.
- Tuân thủ Material Design.

---

# Kiến trúc dự án

```text
lib/
│
├── models/
│   ├── transaction.dart
│   └── category.dart
│
├── screens/
│   ├── home_screen.dart
│   ├── add_transaction_screen.dart
│   ├── statistics_screen.dart
│   └── history_screen.dart
│
├── widgets/
│   ├── transaction_card.dart
│   ├── category_item.dart
│   └── custom_button.dart
│
├── services/
│   └── storage_service.dart
│
├── utils/
│   ├── constants.dart
│   └── helper.dart
│
└── main.dart
```

---

# Luồng hoạt động

```text
Người dùng
      │
      ▼
Nhập giao dịch
      │
      ▼
Lưu dữ liệu
      │
      ▼
Cập nhật danh sách
      │
      ▼
Tính toán thống kê
      │
      ▼
Hiển thị báo cáo
```

---

# Ưu điểm

- Giao diện thân thiện.
- Dễ sử dụng.
- Hiệu năng tốt.
- Hỗ trợ đa nền tảng.
- Dễ mở rộng tính năng.
- Phù hợp cho người mới học Flutter.

---

# Hướng phát triển

Các tính năng có thể bổ sung trong tương lai:

## Firebase Authentication

- Đăng ký tài khoản.
- Đăng nhập bằng Email/Password.
- Đăng nhập Google.

## Cloud Database

- Firebase Firestore.
- Đồng bộ dữ liệu đa thiết bị.

## Thông báo

- Nhắc ghi chép chi tiêu.
- Cảnh báo vượt ngân sách.

## Báo cáo nâng cao

- Xuất PDF.
- Xuất Excel.
- Chia sẻ báo cáo.

## AI Finance Assistant

- Phân tích thói quen chi tiêu.
- Đề xuất kế hoạch tiết kiệm.
- Dự đoán ngân sách tương lai.

---

# Đối tượng sử dụng

- Sinh viên.
- Nhân viên văn phòng.
- Người kinh doanh nhỏ.
- Cá nhân muốn quản lý tài chính.

---
