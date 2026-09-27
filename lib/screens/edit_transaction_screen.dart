import 'package:flutter/material.dart';

import 'package:casestudy1/widgets/transaction_form.dart';

class EditTransactionScreen extends StatelessWidget {
  const EditTransactionScreen({super.key, required this.transaction});

  final TransactionData transaction;

  @override
  Widget build(BuildContext context) {
    return TransactionForm(
      title: 'Sửa giao dịch',
      initialData: transaction, //
      onSave: (data) {
        // TODO: cập nhật giao dịch trong database/state management
        Navigator.pop(context, data);
      },
    );
  }
}
