import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.values,
    required this.colors,
    required this.center,
    this.size = 220,
    this.strokeWidth = 30,
  });

  final List<double> values;
  final List<Color> colors;

  final Widget center;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      // Đổi key khi dữ liệu đổi → animation chạy lại từ đầu
      key: ValueKey(values.join('|')),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size.square(size),
                painter: _DonutPainter(
                  values: values,
                  colors: colors,
                  strokeWidth: strokeWidth,
                  progress: progress,
                ),
              ),
              child!,
            ],
          ),
        );
      },
      child: SizedBox(
        width: size - strokeWidth * 2 - 16,
        child: FittedBox(fit: BoxFit.scaleDown, child: center),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.values,
    required this.colors,
    required this.strokeWidth,
    required this.progress,
  });

  final List<double> values;
  final List<Color> colors;
  final double strokeWidth;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: (size.shortestSide - strokeWidth) / 2,
    );

    // Vòng nền xám nhạt (hiện toàn bộ khi chưa có dữ liệu)
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = AppColors.inputBorder.withValues(alpha: 0.6);
    canvas.drawArc(rect, 0, 2 * math.pi, false, track);

    final total = values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return;

    // Khe hở nhỏ giữa các lát cho dễ phân biệt (không cần khi chỉ có 1 lát)
    final gap = values.length > 1 ? 0.04 : 0.0;
    var start = -math.pi / 2; // bắt đầu từ đỉnh vòng
    final fullSweep = 2 * math.pi * progress;

    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * fullSweep;
      final drawn = sweep - gap;
      if (drawn > 0) {
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = colors[i % colors.length];
        canvas.drawArc(rect, start + gap / 2, drawn, false, paint);
      }
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => true;
}
