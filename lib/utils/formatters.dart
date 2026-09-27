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

String formatDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  return '$d/$m/${date.year}';
}
