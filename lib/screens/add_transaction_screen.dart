import 'package:flutter/material.dart';

import '../controllers/transaction_controller.dart';
import '../widgets/transaction_form.dart';

class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TransactionForm(
      title: 'Thêm giao dịch',
      onSave: (transaction) async {
        // Lấy sẵn trước khi await để không dùng context sau khoảng chờ bất đồng bộ
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);

        await TransactionController.instance.add(transaction);

        messenger
          ..clearSnackBars()
          ..showSnackBar(const SnackBar(content: Text('Đã thêm giao dịch')));
        if (context.mounted) navigator.pop();
      },
    );
  }
}
