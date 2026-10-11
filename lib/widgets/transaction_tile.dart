import 'package:flutter/material.dart';

import '../models/transaction_category.dart';
import '../models/transaction_model.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.data,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  final TransactionModel data;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final category = TransactionCategory.find(
      data.category,
      isExpense: data.isExpense,
    );
    final amount = data.isExpense ? -data.amount : data.amount;
    final dateText = formatDate(DateTime.parse(data.date));

    final subtitle = data.title == data.category
        ? dateText
        : '${data.category} · $dateText';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: category.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(category.icon, size: 22, color: Colors.white),
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
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
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
                color: data.isExpense ? AppColors.expense : AppColors.income,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.inputHint,
            ),
          ],
        ),
      ),
    );
  }
}
