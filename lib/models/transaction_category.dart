import 'package:flutter/material.dart';

enum TransactionType { expense, income }

class TransactionCategory {
  const TransactionCategory({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;

  final Color color;

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
