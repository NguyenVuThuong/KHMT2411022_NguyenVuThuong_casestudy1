import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/transaction_model.dart';

const bool kSeedSampleData = true;

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'expense.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL
      )
    ''');

    if (kSeedSampleData) {
      await _seedSampleData(db);
    }
  }

  Future<void> _seedSampleData(Database db) async {
    const samples = [
      TransactionModel(
        title: 'Ăn trưa',
        amount: 50000,
        type: 'expense',
        date: '2026-10-09',
        category: 'Ăn uống',
      ),
      TransactionModel(
        title: 'Xăng xe',
        amount: 100000,
        type: 'expense',
        date: '2026-10-09',
        category: 'Di chuyển',
      ),
      TransactionModel(
        title: 'Lương tháng 10',
        amount: 8000000,
        type: 'income',
        date: '2026-10-01',
        category: 'Lương',
      ),
      TransactionModel(
        title: 'Mua sắm',
        amount: 300000,
        type: 'expense',
        date: '2026-09-30',
        category: 'Mua sắm',
      ),
      TransactionModel(
        title: 'Học phí',
        amount: 500000,
        type: 'expense',
        date: '2026-09-29',
        category: 'Hóa đơn',
      ),
    ];

    for (final t in samples) {
      await db.insert('transactions', t.toMap());
    }
  }
}
