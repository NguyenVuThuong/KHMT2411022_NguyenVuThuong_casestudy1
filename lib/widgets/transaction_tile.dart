import 'package:flutter/material.dart';
import '../models/transaction_category.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/transaction_form.dart' show TransactionData;

/// 1 dòng trong danh sách "Giao dịch gần đây".
/// [title] là tên giao dịch (VD "Ăn trưa"), lấy từ field `note` của
/// TransactionData; nếu note trống, hiển thị tạm tên danh mục.
class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.data});

  final TransactionData data;

  @override
  Widget build(BuildContext context) {
    final isExpense = data.type == TransactionType.expense;
    final amount = isExpense ? -data.amount : data.amount;
    final title = data.note.isNotEmpty ? data.note : data.category.label;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: data.category.color,
              shape: BoxShape.circle,
            ),
            child: Icon(data.category.icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      data.category.label,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      formatDate(data.date),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            formatCurrency(amount, showSign: true),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: isExpense ? AppColors.coral : AppColors.secondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}