import 'package:flutter/material.dart';

import '../models/transaction_category.dart';
import '../models/transaction_filter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key, required this.initial});

  final TransactionFilter initial;

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // Loại giao dịch: 2 cờ. Cả hai tắt (hoặc cả hai bật) nghĩa là "Tất cả".
  late bool _income;
  late bool _expense;
  String? _categoryName; // null = tất cả danh mục
  late DatePreset _preset;
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _income = f.type == TransactionTypeFilter.income;
    _expense = f.type == TransactionTypeFilter.expense;
    _categoryName = f.categoryName;
    _preset = f.preset;
    _customRange = f.customRange;
  }

  TransactionTypeFilter get _type {
    if (_income && !_expense) return TransactionTypeFilter.income;
    if (_expense && !_income) return TransactionTypeFilter.expense;
    return TransactionTypeFilter.all;
  }

  List<TransactionCategory> get _categoryOptions {
    return switch (_type) {
      TransactionTypeFilter.income => TransactionCategory.incomeCategories,
      TransactionTypeFilter.expense => TransactionCategory.expenseCategories,
      TransactionTypeFilter.all => [
        ...TransactionCategory.expenseCategories,
        ...TransactionCategory.incomeCategories,
      ],
    };
  }

  void _setTypes({required bool income, required bool expense}) {
    setState(() {
      // Chọn đủ cả Thu nhập lẫn Chi tiêu = không lọc theo loại = "Tất cả"
      if (income && expense) {
        income = false;
        expense = false;
      }
      _income = income;
      _expense = expense;

      // Danh mục đang chọn không thuộc loại mới → bỏ chọn
      if (_categoryName != null &&
          !_categoryOptions.any((c) => c.name == _categoryName)) {
        _categoryName = null;
      }
    });
  }

  Future<void> _pickCategory() async {
    // '' nghĩa là "Tất cả danh mục"; null nghĩa là người dùng đóng sheet
    final picked = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Chọn danh mục',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.apps, color: AppColors.primary),
                title: const Text('Tất cả danh mục'),
                trailing: _categoryName == null
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(sheetContext, ''),
              ),
              for (final c in _categoryOptions)
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c.color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(c.icon, size: 18, color: Colors.white),
                  ),
                  title: Text(c.name),
                  trailing: _categoryName == c.name
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () => Navigator.pop(sheetContext, c.name),
                ),
            ],
          ),
        ),
      ),
    );

    if (picked != null) {
      setState(() => _categoryName = picked.isEmpty ? null : picked);
    }
  }

  Future<void> _selectPreset(DatePreset preset) async {
    if (preset != DatePreset.custom) {
      setState(() => _preset = preset);
      return;
    }
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _customRange,
      helpText: 'Chọn khoảng thời gian',
    );
    if (picked != null) {
      setState(() {
        _preset = DatePreset.custom;
        _customRange = picked;
      });
    }
  }

  void _reset() {
    setState(() {
      _income = false;
      _expense = false;
      _categoryName = null;
      _preset = DatePreset.all;
      _customRange = null;
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      TransactionFilter(
        keyword: widget.initial.keyword, // giữ nguyên từ khóa đang tìm
        type: _type,
        categoryName: _categoryName,
        preset: _preset,
        customRange: _customRange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allTypes = !_income && !_expense;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Bộ lọc',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [TextButton(onPressed: _reset, child: const Text('Đặt lại'))],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Loại giao dịch'),
                    _CheckRow(
                      label: 'Tất cả',
                      checked: allTypes,
                      onTap: () => _setTypes(income: false, expense: false),
                    ),
                    _CheckRow(
                      label: 'Thu nhập',
                      checked: _income,
                      onTap: () =>
                          _setTypes(income: !_income, expense: _expense),
                    ),
                    _CheckRow(
                      label: 'Chi tiêu',
                      checked: _expense,
                      onTap: () =>
                          _setTypes(income: _income, expense: !_expense),
                    ),
                    const SizedBox(height: 20),
                    const _SectionTitle('Danh mục'),
                    GestureDetector(
                      onTap: _pickCategory,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.inputBorder),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _categoryName ?? 'Tất cả danh mục',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _SectionTitle('Khoảng thời gian'),
                    _RadioRow(
                      label: 'Tất cả',
                      selected: _preset == DatePreset.all,
                      onTap: () => _selectPreset(DatePreset.all),
                    ),
                    _RadioRow(
                      label: 'Hôm nay',
                      selected: _preset == DatePreset.today,
                      onTap: () => _selectPreset(DatePreset.today),
                    ),
                    _RadioRow(
                      label: '7 ngày qua',
                      selected: _preset == DatePreset.last7Days,
                      onTap: () => _selectPreset(DatePreset.last7Days),
                    ),
                    _RadioRow(
                      label: 'Tháng này',
                      selected: _preset == DatePreset.thisMonth,
                      onTap: () => _selectPreset(DatePreset.thisMonth),
                    ),
                    _RadioRow(
                      label: 'Tùy chỉnh',
                      subtitle: _customRange == null
                          ? null
                          : '${formatDate(_customRange!.start)} – ${formatDate(_customRange!.end)}',
                      selected: _preset == DatePreset.custom,
                      onTap: () => _selectPreset(DatePreset.custom),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Áp dụng', style: AppTextStyles.button),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.labelText,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.label,
    required this.checked,
    required this.onTap,
  });

  final String label;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // IgnorePointer: để cả dòng nhận cú chạm, tránh bắt sự kiện 2 lần
            IgnorePointer(
              child: Checkbox(
                value: checked,
                onChanged: (_) {},
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Text(label, style: const TextStyle(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  const _RadioRow({
    required this.label,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppColors.primary : AppColors.inputHint,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
