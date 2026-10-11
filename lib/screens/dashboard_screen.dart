import 'package:flutter/material.dart';

import '../controllers/transaction_controller.dart';
import '../models/transaction_model.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_tile.dart';
import 'edit_transaction_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.onSeeAll,
    required this.onOpenProfile,
  });

  final VoidCallback onSeeAll;

  final VoidCallback onOpenProfile;

  static const int _recentLimit = 5;

  void _openEdit(BuildContext context, TransactionModel transaction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditTransactionScreen(transaction: transaction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = TransactionController.instance;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error != null && controller.items.isEmpty) {
          return Center(
            child: EmptyState(
              icon: Icons.error_outline,
              title: 'Không đọc được dữ liệu',
              message: controller.error,
              actionLabel: 'Thử lại',
              onAction: controller.load,
            ),
          );
        }

        final recent = controller.items.take(_recentLimit).toList();

        return ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            _Header(balance: controller.balance, onAvatarTap: onOpenProfile),
            // Chừa chỗ cho phần thẻ số dư thò ra khỏi nền xanh
            const SizedBox(height: 64),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      label: 'Thu nhập',
                      amount: controller.totalIncome,
                      icon: Icons.arrow_upward,
                      backgroundColor: AppColors.incomeBg,
                      accentColor: AppColors.income,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCard(
                      label: 'Chi tiêu',
                      amount: controller.totalExpense,
                      icon: Icons.arrow_downward,
                      backgroundColor: AppColors.expenseBg,
                      accentColor: AppColors.expense,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Giao dịch gần đây',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: onSeeAll,
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Text(
                        'Xem tất cả',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Material(
                color: Colors.white,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.inputBorder),
                ),
                child: recent.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 32,
                          horizontal: 16,
                        ),
                        child: Center(
                          child: Text(
                            'Chưa có giao dịch nào.\nBấm nút + để thêm giao dịch đầu tiên.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          for (var i = 0; i < recent.length; i++) ...[
                            if (i > 0)
                              const Divider(
                                height: 1,
                                indent: 72,
                                endIndent: 16,
                                color: AppColors.inputBorder,
                              ),
                            TransactionTile(
                              data: recent[i],
                              onTap: () => _openEdit(context, recent[i]),
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.balance, required this.onAvatarTap});

  final double balance;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 68),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Hôm nay là một ngày tốt lành!',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onAvatarTap,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white54, width: 1.5),
                  ),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: -44,
          child: _BalanceCard(balance: balance),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Số dư hiện tại',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatCurrency(balance),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      // Số dư âm (chi nhiều hơn thu) hiện màu đỏ để cảnh báo
                      color: balance < 0
                          ? AppColors.expense
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: AppColors.glowBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
