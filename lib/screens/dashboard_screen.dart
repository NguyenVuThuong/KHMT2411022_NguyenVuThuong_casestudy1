import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/balance_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';
import 'edit_transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TransactionRepository _repository = const TransactionRepository();

  int _currentTab = 0;
  bool _isLoading = true;
  List<TransactionModel> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final data = await _repository.getTransactions();
    if (!mounted) return;
    setState(() {
      _transactions = data;
      _isLoading = false;
    });
  }

  double get _totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold<double>(0, (sum, t) => sum + t.amount);

  double get _totalExpense => _transactions
      .where((t) => t.isExpense)
      .fold<double>(0, (sum, t) => sum + t.amount);

  double get _balance => _totalIncome - _totalExpense;

  Future<void> _openAddTransaction() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
    if (changed == true) await _loadTransactions();
  }

  Future<void> _openEditTransaction(TransactionModel transaction) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditTransactionScreen(transaction: transaction),
      ),
    );
    if (changed == true) await _loadTransactions();
  }

  List<Widget> _buildRecentTransactions() {
    if (_transactions.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: Text(
              'Chưa có giao dịch nào.\nBấm nút + để thêm giao dịch đầu tiên.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      ];
    }

    return _transactions
        .take(5)
        .map(
          (t) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _openEditTransaction(t),
            child: TransactionTile(data: t),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
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

  Widget _buildContent() {
    return ListView(
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
        ..._buildRecentTransactions(),
      ],
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
