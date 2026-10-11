import 'package:flutter/material.dart';

import '../controllers/transaction_controller.dart';
import '../models/transaction_filter.dart';
import '../models/transaction_model.dart';
import '../theme/app_colors.dart';
import '../widgets/app_chip.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_tile.dart';
import 'edit_transaction_screen.dart';
import 'filter_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  TransactionFilter _filter = const TransactionFilter();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilter() async {
    FocusScope.of(context).unfocus();
    final result = await Navigator.of(context).push<TransactionFilter>(
      MaterialPageRoute(builder: (_) => FilterScreen(initial: _filter)),
    );
    if (result != null) setState(() => _filter = result);
  }

  void _setType(TransactionTypeFilter type) {
    setState(() => _filter = _filter.withType(type));
  }

  void _clearAll() {
    _searchController.clear();
    setState(() => _filter = const TransactionFilter());
  }

  void _openEdit(TransactionModel transaction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditTransactionScreen(transaction: transaction),
      ),
    );
  }

  Future<void> _delete(TransactionModel transaction) async {
    final controller = TransactionController.instance;
    final messenger = ScaffoldMessenger.of(context);

    await controller.delete(transaction);

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('Đã xóa "${transaction.title}"'),
          action: SnackBarAction(
            label: 'Hoàn tác',
            onPressed: () => controller.restore(transaction),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final controller = TransactionController.instance;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              'Giao dịch',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: _buildSearchField()),
                const SizedBox(width: 12),
                _FilterButton(
                  active: _filter.hasAdvancedFilter,
                  onTap: _openFilter,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                AppChip(
                  label: 'Tất cả',
                  selected: _filter.type == TransactionTypeFilter.all,
                  onTap: () => _setType(TransactionTypeFilter.all),
                ),
                const SizedBox(width: 8),
                AppChip(
                  label: 'Thu nhập',
                  selected: _filter.type == TransactionTypeFilter.income,
                  onTap: () => _setType(TransactionTypeFilter.income),
                ),
                const SizedBox(width: 8),
                AppChip(
                  label: 'Chi tiêu',
                  selected: _filter.type == TransactionTypeFilter.expense,
                  onTap: () => _setType(TransactionTypeFilter.expense),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) => _buildList(controller),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      onChanged: (value) {
        setState(() => _filter = _filter.withKeyword(value));
      },
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Tìm kiếm giao dịch...',
        hintStyle: const TextStyle(color: AppColors.inputHint, fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        suffixIcon: _filter.keyword.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _filter = _filter.withKeyword(''));
                },
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildList(TransactionController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final all = controller.items;
    if (all.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'Chưa có giao dịch nào',
          message: 'Bấm nút + ở Trang chủ để thêm giao dịch đầu tiên.',
        ),
      );
    }

    final results = _filter.apply(all);
    if (results.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.search_off,
          title: 'Không tìm thấy giao dịch',
          message: 'Thử đổi từ khóa hoặc nới lỏng bộ lọc.',
          actionLabel: 'Xóa bộ lọc',
          onAction: _clearAll,
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 12, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${results.length} giao dịch',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              if (_filter.isFiltering)
                TextButton(
                  onPressed: _clearAll,
                  child: const Text('Xóa bộ lọc'),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final transaction = results[index];
              return Dismissible(
                key: ValueKey(transaction.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _delete(transaction),
                background: Container(
                  color: AppColors.expense,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                child: Material(
                  color: AppColors.screenBackground,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TransactionTile(
                        data: transaction,
                        onTap: () => _openEdit(transaction),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      const Divider(
                        height: 1,
                        indent: 76,
                        endIndent: 20,
                        color: AppColors.inputBorder,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: active ? AppColors.primary : AppColors.inputBorder,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.tune,
                color: active ? AppColors.primary : AppColors.textSecondary,
              ),
              if (active)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: AppColors.expense,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
