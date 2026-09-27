import 'package:flutter/material.dart';

class WalletIcon extends StatelessWidget {
  const WalletIcon({super.key, this.size = 140});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _WalletIconPainter()),
    );
  }
}

class _WalletIconPainter extends CustomPainter {
  // ---- Chỉnh màu & hình dáng ở đây ----
  static const Color walletColor = Color(0xFF2E88E6);
  static const Color claspColor = Color(0xFF1B5FC4);
  static const Color billBackColor = Color(0xFF43A047);
  static const Color billFrontColor = Color(0xFF81C784);

  // Góc nghiêng của 2 tờ tiền (radian). Đổi số để chỉnh độ xòe.
  static const double billBackAngle = -0.55;
  static const double billFrontAngle = -0.30;
  // --------------------------------------

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 512;
    final scaleY = size.height / 512;
    canvas.save();
    canvas.scale(scaleX, scaleY);

    _drawBill(canvas, billBackColor, billBackAngle, const Offset(215, 300));
    _drawBill(canvas, billFrontColor, billFrontAngle, const Offset(255, 300));
    _drawWalletBody(canvas);
    _drawClasp(canvas);

    canvas.restore();
  }

  void _drawBill(Canvas canvas, Color color, double angle, Offset anchor) {
    canvas.save();
    canvas.translate(anchor.dx, anchor.dy);
    canvas.rotate(angle);
    final rect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-45, -230, 90, 300),
      const Radius.circular(14),
    );
    canvas.drawRRect(rect, Paint()..color = color);
    canvas.restore();
  }

  void _drawWalletBody(Canvas canvas) {
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(20, 150, 472, 320),
      const Radius.circular(56),
    );
    canvas.drawRRect(body, Paint()..color = walletColor);
  }

  void _drawClasp(Canvas canvas) {
    final clasp = RRect.fromRectAndCorners(
      const Rect.fromLTWH(400, 300, 100, 90),
      topRight: const Radius.circular(45),
      bottomRight: const Radius.circular(45),
    );
    canvas.drawRRect(clasp, Paint()..color = claspColor);
  }

  @override
  bool shouldRepaint(covariant _WalletIconPainter oldDelegate) => false;
}
