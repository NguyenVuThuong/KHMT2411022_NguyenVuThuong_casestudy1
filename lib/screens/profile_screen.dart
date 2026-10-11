import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/transaction_controller.dart';
import '../models/transaction_model.dart';
import '../theme/app_colors.dart';
import 'category_list_screen.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text('Tính năng "$feature" sẽ được bổ sung sau')),
      );
  }

  /// Gom toàn bộ giao dịch thành văn bản CSV
  String _buildCsv(List<TransactionModel> items) {
    final buffer = StringBuffer('id,noi_dung,so_tien,loai,ngay,danh_muc\n');
    for (final t in items) {
      final title = t.title.replaceAll(
        '"',
        '""',
      ); // CSV: nháy kép được viết đôi
      buffer.writeln(
        '${t.id},"$title",${t.amount.round()},${t.type},${t.date},"${t.category}"',
      );
    }
    return buffer.toString();
  }

  Future<void> _backup(BuildContext context) async {
    final items = TransactionController.instance.items;
    await Clipboard.setData(ClipboardData(text: _buildCsv(items)));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Đã sao chép ${items.length} giao dịch (CSV) vào clipboard — '
            'hãy dán vào ghi chú hoặc email để lưu trữ',
          ),
        ),
      );
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text(
          'Bạn có chắc muốn đăng xuất không? Dữ liệu giao dịch vẫn được giữ trên máy.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      // Xóa toàn bộ lịch sử màn hình rồi quay về màn hình chào
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const Text(
            'Cá nhân',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.glowBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nguyễn Văn A',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'nguyenvana@example.com',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Material(
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.inputBorder),
            ),
            child: Column(
              children: [
                _MenuRow(
                  icon: Icons.person_outline,
                  title: 'Thông tin cá nhân',
                  onTap: () => _comingSoon(context, 'Thông tin cá nhân'),
                ),
                const _MenuDivider(),
                _MenuRow(
                  icon: Icons.settings_outlined,
                  title: 'Cài đặt ngân sách',
                  onTap: () => _comingSoon(context, 'Cài đặt ngân sách'),
                ),
                const _MenuDivider(),
                _MenuRow(
                  icon: Icons.category_outlined,
                  title: 'Danh mục chi tiêu',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CategoryListScreen(),
                    ),
                  ),
                ),
                const _MenuDivider(),
                _MenuRow(
                  icon: Icons.cloud_upload_outlined,
                  title: 'Sao lưu dữ liệu',
                  onTap: () => _backup(context),
                ),
                const _MenuDivider(),
                _MenuRow(
                  icon: Icons.lock_outline,
                  title: 'Đổi mật khẩu',
                  onTap: () => _comingSoon(context, 'Đổi mật khẩu'),
                ),
                const _MenuDivider(),
                _MenuRow(
                  icon: Icons.logout,
                  title: 'Đăng xuất',
                  color: AppColors.expense,
                  onTap: () => _logout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 56,
      endIndent: 16,
      color: AppColors.inputBorder,
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = AppColors.textPrimary,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.inputHint),
          ],
        ),
      ),
    );
  }
}
