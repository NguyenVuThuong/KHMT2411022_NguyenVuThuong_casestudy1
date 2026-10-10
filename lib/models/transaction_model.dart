class TransactionModel {
  const TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    required this.category,
  });

  final int? id;

  final String title;

  final double amount;

  final String type;

  final String date;

  final String category;

  bool get isExpense => type == 'expense';
  bool get isIncome => type == 'income';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'date': date,
      'category': category,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      title: map['title'] as String,

      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      date: map['date'] as String,
      category: map['category'] as String,
    );
  }
}
