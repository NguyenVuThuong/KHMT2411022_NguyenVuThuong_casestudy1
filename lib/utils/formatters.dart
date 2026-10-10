/// Định dạng số tiền theo kiểu Việt Nam: 5000000 → "5.000.000 đ"
/// Nếu [showSign] = true, số dương sẽ có dấu "+" phía trước (dùng cho
/// khoản thu), số âm sẽ có dấu "-" (dùng cho khoản chi).
String formatCurrency(double amount, {bool showSign = false}) {
  final isNegative = amount < 0;
  final intPart = amount.abs().truncate().toString();

  final buffer = StringBuffer();
  for (int i = 0; i < intPart.length; i++) {
    if (i != 0 && (intPart.length - i) % 3 == 0) buffer.write('.');
    buffer.write(intPart[i]);
  }

  final sign = isNegative ? '-' : (showSign ? '+' : '');
  return '$sign$buffer đ';
}

/// Định dạng ngày theo kiểu Việt Nam: DateTime(2024,9,3) → "03/09/2024"
String formatDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  return '$d/$m/${date.year}';
}

/// Đổi DateTime sang chuỗi ISO 'yyyy-MM-dd' để LƯU vào SQLite.
/// DateTime(2026,10,9) → "2026-10-09"
String toIsoDate(DateTime date) {
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '${date.year}-$m-$d';
}