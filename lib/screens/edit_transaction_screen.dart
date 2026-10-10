import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';
import '../widgets/transaction_form.dart';

class EditTransactionScreen extends StatelessWidget {
  const EditTransactionScreen({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    const repository = TransactionRepository();

    return TransactionForm(
      title: 'Sửa giao dịch',
      initialData: transaction,
      onSave: (updated) async {
        await repository.updateTransaction(updated);
        if (context.mounted) Navigator.pop(context, true);
      },
      onDelete: () async {
        await repository.deleteTransaction(transaction.id!);
        if (context.mounted) Navigator.pop(context, true);
      },
    );
  }
}
