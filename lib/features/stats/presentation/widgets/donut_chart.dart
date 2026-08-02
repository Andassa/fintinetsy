import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.segments,
    this.size = 220,
    this.strokeWidth = 28,
  });

  final List<({String label, int percent, Color color})> segments;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(segments: segments, strokeWidth: strokeWidth),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.segments, required this.strokeWidth});
  final List<({String label, int percent, Color color})> segments;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth;
    var start = -math.pi / 2;
    final total = segments.fold<int>(0, (a, b) => a + b.percent);

    for (final s in segments) {
      final sweep = (s.percent / total) * math.pi * 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        Paint()
          ..color = s.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt,
      );

      final mid = start + sweep / 2;
      final bubble = Offset(
        center.dx + math.cos(mid) * radius,
        center.dy + math.sin(mid) * radius,
      );
      canvas.drawCircle(bubble, 16, Paint()..color = AppColors.white);
      final tp = TextPainter(
        text: TextSpan(
          text: '${s.percent}%',
          style: const TextStyle(
            color: AppColors.black,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, bubble - Offset(tp.width / 2, tp.height / 2));
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => true;
}

Color parseHex(String hex) {
  final h = hex.replaceFirst('#', '');
  return Color(int.parse('FF$h', radix: 16));
}
