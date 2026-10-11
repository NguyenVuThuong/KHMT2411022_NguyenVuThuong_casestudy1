import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';

/// "Nguồn sự thật duy nhất" của dữ liệu giao dịch trong app.
///
/// Mọi màn hình (Trang chủ, Giao dịch, Thống kê...) đều ĐỌC từ đây và LẮNG
/// NGHE nó. Thêm/sửa/xóa ở bất kỳ đâu → controller ghi vào SQLite rồi báo
/// cho tất cả màn hình đang nghe tự cập nhật. Nhờ vậy không còn chuyện
/// "thêm xong mà tab kia chưa đổi".
///
///   Màn hình → TransactionController → Repository → DatabaseHelper → SQLite
class TransactionController extends ChangeNotifier {
  TransactionController._();

  static final TransactionController instance = TransactionController._();

  final TransactionRepository _repository = const TransactionRepository();

  List<TransactionModel> _items = [];
  bool _isLoading = true;
  String? _error;

  /// Toàn bộ giao dịch, mới nhất lên đầu
  UnmodifiableListView<TransactionModel> get items =>
      UnmodifiableListView(_items);

  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalIncome =>
      _items.where((t) => t.isIncome).fold<double>(0, (s, t) => s + t.amount);

  double get totalExpense =>
      _items.where((t) => t.isExpense).fold<double>(0, (s, t) => s + t.amount);

  double get balance => totalIncome - totalExpense;

  /// Đọc lại toàn bộ dữ liệu từ SQLite
  Future<void> load() async {
    try {
      _items = await _repository.getTransactions();
      _error = null;
    } catch (e) {
      _error = '$e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> add(TransactionModel transaction) async {
    await _repository.insertTransaction(transaction);
    await load();
  }

  Future<void> update(TransactionModel transaction) async {
    await _repository.updateTransaction(transaction);
    await load();
  }

  Future<void> delete(TransactionModel transaction) async {
    final id = transaction.id;
    if (id == null) return;

    _items = _items.where((t) => t.id != id).toList();
    notifyListeners();

    try {
      await _repository.deleteTransaction(id);
    } catch (_) {
      await load();
      rethrow;
    }
  }

  Future<void> restore(TransactionModel transaction) async {
    await add(
      TransactionModel(
        title: transaction.title,
        amount: transaction.amount,
        type: transaction.type,
        date: transaction.date,
        category: transaction.category,
      ),
    );
  }
}
