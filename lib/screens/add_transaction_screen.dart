import 'package:flutter/material.dart';

import '../ widgets/transaction_form.dart';

/// Màn hình "Thêm giao dịch" — tất cả các ô đều trống ban đầu.
class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TransactionForm(
      title: 'Thêm giao dịch',
      initialData: null, // null = không có dữ liệu cũ, form để trống
      onSave: (data) {
        // TODO: lưu giao dịch mới vào database/state management
        Navigator.pop(context, data);
      },
    );
  }
}
