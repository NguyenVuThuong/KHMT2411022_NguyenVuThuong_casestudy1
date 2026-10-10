import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/transaction_category.dart';
import '../models/transaction_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';

class TransactionForm extends StatefulWidget {
  const TransactionForm({
    super.key,
    required this.title,
    this.initialData,
    required this.onSave,
    this.onDelete,
  });

  final String title;

  final TransactionModel? initialData;

  final Future<void> Function(TransactionModel transaction) onSave;

  final Future<void> Function()? onDelete;

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  late TransactionType _type;
  late TransactionCategory _category;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late DateTime _date;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;

    if (data == null) {
      // Chế độ THÊM: giá trị mặc định, ô nhập để trống
      _type = TransactionType.expense;
      _category = TransactionCategory.sample.first;
      _date = DateTime.now();
      _amountController = TextEditingController();
      _noteController = TextEditingController();
    } else {
      // Chế độ SỬA: đổi dữ liệu từ SQLite (String) về kiểu dùng cho giao diện
      _type = data.type == 'income'
          ? TransactionType.income
          : TransactionType.expense;
      _category = TransactionCategory.fromLabel(data.category);
      _date = DateTime.parse(data.date);
      _amountController = TextEditingController(
        text: data.amount.toStringAsFixed(0),
      );

      _noteController = TextEditingController(
        text: data.title == data.category ? '' : data.title,
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _handleSave() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')),
      );
      return;
    }

    final note = _noteController.text.trim();
    final transaction = TransactionModel(
      id: widget.initialData?.id, //
      title: note.isEmpty ? _category.label : note,
      amount: amount,
      type: _type.name, //
      date: toIsoDate(_date),
      category: _category.label,
    );

    setState(() => _isSaving = true);
    try {
      await widget.onSave(transaction);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa giao dịch?'),
        content: const Text('Bạn có chắc muốn xóa giao dịch này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed == true) await widget.onDelete!();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          if (widget.onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.coral),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TypeToggle(
                value: _type,
                onChanged: (t) => setState(() => _type = t),
              ),
              const SizedBox(height: 24),
              const _FieldLabel('Danh mục'),
              const SizedBox(height: 8),
              _CategoryPicker(
                value: _category,
                onChanged: (c) => setState(() => _category = c),
              ),
              const SizedBox(height: 20),
              const _FieldLabel('Số tiền'),
              const SizedBox(height: 8),
              _InputBox(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Nhập số tiền',
                    hintStyle: TextStyle(color: AppColors.inputHint),
                    suffixText: 'đ',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const _FieldLabel('Ngày giao dịch'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: _InputBox(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_date.day.toString().padLeft(2, '0')}/'
                          '${_date.month.toString().padLeft(2, '0')}/'
                          '${_date.year}',
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const _FieldLabel('Ghi chú'),
              const SizedBox(height: 8),
              _InputBox(
                height: 90,
                child: TextField(
                  controller: _noteController,
                  maxLines: 3,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Nhập ghi chú (tùy chọn)',
                    hintStyle: TextStyle(color: AppColors.inputHint),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Lưu', style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- Các widget con dùng nội bộ trong form ----------------

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.labelText,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  const _InputBox({required this.child, this.height});
  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.value, required this.onChanged});
  final TransactionType value;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ToggleButton(
            label: 'Chi tiêu',
            selected: value == TransactionType.expense,
            onTap: () => onChanged(TransactionType.expense),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ToggleButton(
            label: 'Thu nhập',
            selected: value == TransactionType.income,
            onTap: () => onChanged(TransactionType.income),
          ),
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.coral : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.coral : AppColors.inputBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({required this.value, required this.onChanged});
  final TransactionCategory value;
  final ValueChanged<TransactionCategory> onChanged;

  Future<void> _openPicker(BuildContext context) async {
    final picked = await showModalBottomSheet<TransactionCategory>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: TransactionCategory.sample
              .map(
                (c) => ListTile(
                  leading: _CategoryIcon(icon: c.icon),
                  title: Text(c.label),
                  onTap: () => Navigator.pop(context, c),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openPicker(context),
      child: _InputBox(
        child: Row(
          children: [
            _CategoryIcon(icon: value.icon),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value.label,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        color: AppColors.coralLight,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: AppColors.coral),
    );
  }
}
