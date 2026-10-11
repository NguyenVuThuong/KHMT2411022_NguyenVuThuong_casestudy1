import 'package:flutter/material.dart';

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
  late bool _isExpense; // true = Chi tiêu, false = Thu nhập
  late TransactionCategory _category;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late DateTime _date;
  bool _isSaving = false;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;

    if (data == null) {
      // Chế độ THÊM
      _isExpense = true;
      _category = TransactionCategory.expenseCategories.first;
      _date = DateTime.now();
      _amountController = TextEditingController();
      _noteController = TextEditingController();
    } else {
      // Chế độ SỬA: đổi dữ liệu từ SQLite (String) về kiểu dùng cho giao diện
      _isExpense = data.isExpense;
      _category = TransactionCategory.find(
        data.category,
        isExpense: data.isExpense,
      );
      _date = DateTime.parse(data.date);
      _amountController = TextEditingController(
        text: groupThousands(data.amount.round()),
      );
      // Nếu title chỉ là tên danh mục (do lúc lưu ghi chú để trống) thì để
      // ô ghi chú trống thay vì hiện lặp lại tên danh mục
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

  void _changeType(bool isExpense) {
    if (_isExpense == isExpense) return;
    setState(() {
      _isExpense = isExpense;
      _category = TransactionCategory.forType(isExpense).first;
    });
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();

    // Bước 1: kiểm tra dữ liệu, báo lỗi ngay dưới ô số tiền
    final amount = parseAmount(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() => _amountError = 'Vui lòng nhập số tiền lớn hơn 0');
      return;
    }

    // Bước 2: tạo model. Ghi chú để trống thì dùng tên danh mục làm nội dung
    // (vì cột title trong database là NOT NULL)
    final note = _noteController.text.trim();
    final transaction = TransactionModel(
      id: widget.initialData?.id, // null khi thêm mới, có giá trị khi sửa
      title: note.isEmpty ? _category.name : note,
      amount: amount,
      type: _isExpense ? 'expense' : 'income',
      date: toIsoDate(_date),
      category: _category.name,
    );

    // Bước 3: gọi onSave (màn hình cha sẽ ghi vào SQLite)
    setState(() => _isSaving = true);
    try {
      await widget.onSave(transaction);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không lưu được giao dịch: $e')));
      }
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
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
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
              tooltip: 'Xóa giao dịch',
              icon: const Icon(Icons.delete_outline, color: AppColors.expense),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          // Chạm ra ngoài ô nhập để ẩn bàn phím
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TypeToggle(isExpense: _isExpense, onChanged: _changeType),
                const SizedBox(height: 24),
                const _FieldLabel('Danh mục'),
                const SizedBox(height: 8),
                _CategoryPicker(
                  value: _category,
                  // Chỉ hiện danh mục thuộc loại đang chọn
                  categories: TransactionCategory.forType(_isExpense),
                  onChanged: (c) => setState(() => _category = c),
                ),
                const SizedBox(height: 20),
                const _FieldLabel('Số tiền'),
                const SizedBox(height: 8),
                _InputBox(
                  hasError: _amountError != null,
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    // Gõ 1500000 → tự hiện 1.500.000
                    inputFormatters: [ThousandsInputFormatter()],
                    onChanged: (_) {
                      if (_amountError != null) {
                        setState(() => _amountError = null);
                      }
                    },
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: 'Nhập số tiền',
                      hintStyle: TextStyle(color: AppColors.inputHint),
                      suffixText: 'đ',
                    ),
                  ),
                ),
                if (_amountError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      _amountError!,
                      style: const TextStyle(
                        color: AppColors.expense,
                        fontSize: 12,
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
                            formatDate(_date),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
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
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
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
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Lưu', style: AppTextStyles.button),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
  const _InputBox({required this.child, this.height, this.hasError = false});

  final Widget child;
  final double? height;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(
          color: hasError ? AppColors.expense : AppColors.inputBorder,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.isExpense, required this.onChanged});

  final bool isExpense;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ToggleButton(
            label: 'Chi tiêu',
            selected: isExpense,
            onTap: () => onChanged(true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ToggleButton(
            label: 'Thu nhập',
            selected: !isExpense,
            onTap: () => onChanged(false),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
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
  const _CategoryPicker({
    required this.value,
    required this.categories,
    required this.onChanged,
  });

  final TransactionCategory value;
  final List<TransactionCategory> categories;
  final ValueChanged<TransactionCategory> onChanged;

  Future<void> _openPicker(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<TransactionCategory>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
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
            for (final c in categories)
              ListTile(
                leading: _CategoryIcon(category: c),
                title: Text(c.name),
                trailing: c.name == value.name
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(sheetContext, c),
              ),
          ],
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
            _CategoryIcon(category: value),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value.name,
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

/// Icon tròn nhỏ theo màu của danh mục
class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.category});
  final TransactionCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(category.icon, size: 16, color: category.color),
    );
  }
}
