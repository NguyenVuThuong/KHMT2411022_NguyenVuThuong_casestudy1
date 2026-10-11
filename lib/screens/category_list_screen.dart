import 'package:flutter/material.dart';

import '../models/transaction_category.dart';
import '../theme/app_colors.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.screenBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Danh mục chi tiêu',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: const [
          _Section(
            title: 'Chi tiêu',
            categories: TransactionCategory.expenseCategories,
          ),
          SizedBox(height: 20),
          _Section(
            title: 'Thu nhập',
            categories: TransactionCategory.incomeCategories,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.categories});

  final String title;
  final List<TransactionCategory> categories;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Material(
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.inputBorder),
          ),
          child: Column(
            children: [
              for (var i = 0; i < categories.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    indent: 68,
                    endIndent: 16,
                    color: AppColors.inputBorder,
                  ),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: categories[i].color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      categories[i].icon,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(categories[i].name),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
