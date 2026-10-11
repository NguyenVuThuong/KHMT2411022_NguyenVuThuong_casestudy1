import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/transaction_controller.dart';
import '../theme/app_colors.dart';
import 'add_transaction_screen.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'statistics_screen.dart';
import 'transactions_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  // Trang chủ có nền xanh phía trên → icon status bar màu trắng;
  // các tab còn lại nền sáng → icon màu tối.
  static const SystemUiOverlayStyle _lightIcons = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );
  static const SystemUiOverlayStyle _darkIcons = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  @override
  void initState() {
    super.initState();
    // Đọc dữ liệu từ SQLite 1 lần khi vào app; sau đó controller tự thông báo
    TransactionController.instance.load();
  }

  void _openAddTransaction() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _tab == 0 ? _lightIcons : _darkIcons,
      child: Scaffold(
        backgroundColor: AppColors.screenBackground,
        body: IndexedStack(
          index: _tab,
          children: [
            DashboardScreen(
              onSeeAll: () => setState(() => _tab = 1),
              onOpenProfile: () => setState(() => _tab = 3),
            ),
            const TransactionsScreen(),
            const StatisticsScreen(),
            const ProfileScreen(),
          ],
        ),
        floatingActionButton: _tab == 0
            ? FloatingActionButton(
                onPressed: _openAddTransaction,
                backgroundColor: AppColors.primary,
                elevation: 4,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (index) => setState(() => _tab = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Giao dịch',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Thống kê',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Cá nhân',
            ),
          ],
        ),
      ),
    );
  }
}
