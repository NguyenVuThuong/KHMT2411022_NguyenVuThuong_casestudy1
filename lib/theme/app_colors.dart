import 'package:flutter/material.dart';

/// Bảng màu tập trung của app — mọi nơi khác chỉ tham chiếu tới đây,
/// giúp đổi theme (VD sang dark mode) chỉ cần sửa 1 chỗ duy nhất.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2F6FED);
  static const Color primaryDark = Color(0xFF1B4FC4);
  static const Color secondary = Color(0xFF6FCF97);
  static const Color secondaryDark = Color(0xFF4CAF7D);

  static const Color background = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF8D8D9A);

  /// Vệt màu mờ trang trí phía sau icon, tạo chiều sâu nhẹ
  static const Color glowBlue = Color(0xFFEAF1FE);
  static const Color glowGreen = Color(0xFFEAF9F0);

  /// Màu cho tab "Chi tiêu" đang được chọn
  static const Color coral = Color(0xFFF16A6A);
  static const Color coralLight = Color(0xFFFCE7E7);

  /// Màu viền & nền cho các ô nhập liệu trong form
  static const Color inputBorder = Color(0xFFE0E0E6);
  static const Color inputHint = Color(0xFFB3B3BD);
  static const Color labelText = Color(0xFF2E2E3A);

  /// Nền xám rất nhạt cho các màn hình dạng dashboard (khác nền trắng thuần)
  static const Color screenBackground = Color(0xFFF5F6FA);
}
