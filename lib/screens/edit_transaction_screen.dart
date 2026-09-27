import 'package:flutter/material.dart';

import '../ widgets/transaction_form.dart';
import '../widgets/transaction_form.dart';

/// Màn hình "Sửa giao dịch" — nhận vào 1 giao dịch có sẵn để điền trước
/// lên form, khác với AddTransactionScreen chỉ ở việc có [transaction].
class EditTransactionScreen extends StatelessWidget {
  const EditTransactionScreen({super.key, required this.transaction});

  final TransactionData transaction;

  @override
  Widget build(BuildContext context) {
    return TransactionForm(
      title: 'Sửa giao dịch',
      initialData: transaction, // có dữ liệu cũ → form tự điền sẵn
      onSave: (data) {
        // TODO: cập nhật giao dịch trong database/state management
        Navigator.pop(context, data);
      },
    );
  }
}
