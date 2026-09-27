import 'package:casestudy1/widgets/transaction_form.dart';
import 'package:flutter/material.dart';

class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TransactionForm(
      title: 'Thêm giao dịch',
      initialData: null,
      onSave: (data) {
        // TODO: lưu giao dịch mới vào database/state management
        Navigator.pop(context, data);
      },
    );
  }
}
