import '../database/database_helper.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  const TransactionRepository();

  static const String _table = 'transactions';

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert(_table, transaction.toMap());
  }

  Future<List<TransactionModel>> getTransactions() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(_table, orderBy: 'date DESC, id DESC');
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<List<TransactionModel>> searchTransactions(String keyword) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      _table,
      where: 'title LIKE ?',
      whereArgs: ['%$keyword%'],
      orderBy: 'date DESC, id DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      _table,
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC, id DESC',
    );
    return maps.map((map) => TransactionModel.fromMap(map)).toList();
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      _table,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
