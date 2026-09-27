import 'package:flutter/material.dart';

/// Loại giao dịch: chi tiêu hoặc thu nhập
enum TransactionType { expense, income }

/// Một danh mục giao dịch (VD: Ăn uống, Di chuyển...)
/// Sau này khi làm màn hình danh sách danh mục thật, bạn có thể thay
/// danh sách cứng ở dưới bằng dữ liệu lấy từ database/API.
class TransactionCategory {
  const TransactionCategory({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;

  /// Màu riêng của danh mục — dùng cho icon tròn trong danh sách giao dịch
  final Color color;

  /// Danh sách danh mục mẫu — thêm/bớt tùy nhu cầu thực tế của app
  static const List<TransactionCategory> sample = [
    TransactionCategory(
      label: 'Ăn uống',
      icon: Icons.restaurant,
      color: Color(0xFFFF7A45),
    ),
    TransactionCategory(
      label: 'Di chuyển',
      icon: Icons.directions_car,
      color: Color(0xFF3B82F6),
    ),
    TransactionCategory(
      label: 'Thu nhập',
      icon: Icons.savings,
      color: Color(0xFF4CAF7D),
    ),
    TransactionCategory(
      label: 'Mua sắm',
      icon: Icons.shopping_bag,
      color: Color(0xFF9C6ADE),
    ),
    TransactionCategory(
      label: 'Giáo dục',
      icon: Icons.school,
      color: Color(0xFF16A394),
    ),
  ];
}