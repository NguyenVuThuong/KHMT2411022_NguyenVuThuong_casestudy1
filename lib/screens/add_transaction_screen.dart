import 'package:flutter/material.dart';

import '../repositories/transaction_repository.dart';
import '../widgets/transaction_form.dart';

class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const repository = TransactionRepository();

    return TransactionForm(
      title: 'Thêm giao dịch',
      onSave: (transaction) async {
        await repository.insertTransaction(transaction);
        if (context.mounted) Navigator.pop(context, true);
      },
    );
  }
}
