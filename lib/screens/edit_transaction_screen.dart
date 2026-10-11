import 'package:flutter/material.dart';

import '../controllers/transaction_controller.dart';
import '../models/transaction_model.dart';
import '../widgets/transaction_form.dart';

class EditTransactionScreen extends StatelessWidget {
  const EditTransactionScreen({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final controller = TransactionController.instance;

    return TransactionForm(
      title: 'Sửa giao dịch',
      initialData: transaction,
      onSave: (updated) async {
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);

        await controller.update(updated);

        messenger
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(content: Text('Đã cập nhật giao dịch')),
          );
        if (context.mounted) navigator.pop();
      },
      onDelete: () async {
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);

        await controller.delete(transaction);

        messenger
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: const Text('Đã xóa giao dịch'),
              action: SnackBarAction(
                label: 'Hoàn tác',
                onPressed: () => controller.restore(transaction),
              ),
            ),
          );
        if (context.mounted) navigator.pop();
      },
    );
  }
}
