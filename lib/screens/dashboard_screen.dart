import 'package:flutter/material.dart';

import '../models/transaction_category.dart';
import '../theme/app_colors.dart';
import '../widgets/balance_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_form.dart' show TransactionData;
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';
import 'edit_transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentTab = 0;

  // Dữ liệu mẫu — sau này thay bằng dữ liệu thật lấy từ database/API.
  final List<TransactionData> _transactions = [
    TransactionData(
      type: TransactionType.expense,
      category: TransactionCategory.sample[0], // Ăn uống
      amount: 50000,
      date: DateTime(2024, 9, 3),
      note: 'Ăn trưa',
    ),
    TransactionData(
      type: TransactionType.expense,
      category: TransactionCategory.sample[1], // Di chuyển
      amount: 100000,
      date: DateTime(2024, 9, 3),
      note: 'Xăng xe',
    ),
    TransactionData(
      type: TransactionType.income,
      category: TransactionCategory.sample[2], // Thu nhập
      amount: 8000000,
      date: DateTime(2024, 9, 1),
      note: 'Lương tháng 9',
    ),
    TransactionData(
      type: TransactionType.expense,
      category: TransactionCategory.sample[3], // Mua sắm
      amount: 300000,
      date: DateTime(2024, 8, 31),
      note: 'Mua sắm',
    ),
    TransactionData(
      type: TransactionType.expense,
      category: TransactionCategory.sample[4], // Giáo dục
      amount: 500000,
      date: DateTime(2024, 8, 30),
      note: 'Học phí',
    ),
  ];

  double get _totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get _totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get _balance => _totalIncome - _totalExpense;

  Future<void> _openAddTransaction() async {
    final result = await Navigator.of(context).push<TransactionData>(
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
    if (result != null) {
      setState(() => _transactions.insert(0, result));
    }
  }

  Future<void> _openEditTransaction(int index) async {
    final result = await Navigator.of(context).push<TransactionData>(
      MaterialPageRoute(
        builder: (_) =>
            EditTransactionScreen(transaction: _transactions[index]),
      ),
    );
    if (result != null) {
      setState(() => _transactions[index] = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            _buildTopBar(),
            const SizedBox(height: 18),
            BalanceCard(balance: _balance),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    label: 'TỔNG THU NHẬP',
                    amount: _totalIncome,
                    icon: Icons.arrow_downward,
                    backgroundColor: AppColors.glowGreen,
                    accentColor: AppColors.secondaryDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    label: 'TỔNG CHI TIÊU',
                    amount: _totalExpense,
                    icon: Icons.arrow_upward,
                    backgroundColor: AppColors.coralLight,
                    accentColor: AppColors.coral,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Giao dịch gần đây',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ..._transactions.asMap().entries.map(
              (entry) => GestureDetector(
                onTap: () => _openEditTransaction(entry.key),
                child: TransactionTile(data: entry.value),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTransaction,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (i) => setState(() => _currentTab = i),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Giao dịch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline),
            label: 'Thống kê',
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        const Icon(Icons.menu, color: AppColors.textPrimary),
        const SizedBox(width: 12),
        const Text(
          'Quản lý thu chi',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_none, color: AppColors.textPrimary),
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppColors.coral,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                child: const Text(
                  '3',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
