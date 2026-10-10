import 'package:flutter/material.dart';
import '../models/transaction_category.dart';
import '../models/transaction_model.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

/// 1 dòng trong danh sách "Giao dịch gần đây", hiển thị dữ liệu đọc từ SQLite.
/// Icon và màu được tra từ tên danh mục lưu trong cột `category`.
class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.data});

  final TransactionModel data;

  @override
  Widget build(BuildContext context) {
    final category = TransactionCategory.fromLabel(data.category);
    final amount = data.isExpense ? -data.amount : data.amount;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: category.color,
              shape: BoxShape.circle,
            ),
            child: Icon(category.icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                      data.category,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // data.date là chuỗi ISO "2026-10-09" → parse ra DateTime
                    // rồi hiển thị kiểu Việt Nam "09/10/2026"
                    Text(
                      formatDate(DateTime.parse(data.date)),
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
          const SizedBox(width: 8),
          Text(
            formatCurrency(amount, showSign: true),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: data.isExpense ? AppColors.coral : AppColors.secondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}