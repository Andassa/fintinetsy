import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/circular_icon_button.dart';
import '../../domain/entities/stats_entities.dart';
import '../../domain/repositories/stats_repository.dart';

class CalorieIntakeScreen extends StatefulWidget {
  const CalorieIntakeScreen({super.key});

  @override
  State<CalorieIntakeScreen> createState() => _CalorieIntakeScreenState();
}

class _CalorieIntakeScreenState extends State<CalorieIntakeScreen> {
  CalorieIntakeData? _data;

  @override
  void initState() {
    super.initState();
    context.read<StatsRepository>().getCalorieIntake().then((v) {
      if (mounted) setState(() => _data = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    if (data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: ResponsiveConstrained(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    CircularIconButton(
                      icon: Icons.chevron_left,
                      onPressed: () => context.pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Calorie Intake',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    CircularIconButton(
                      icon: Icons.settings_outlined,
                      onPressed: () =>
                          context.pushNamed(RouteNames.accountSettings),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: '🔥 ', style: TextStyle(fontSize: 28)),
                    TextSpan(
                      text: _fmt(data.totalKcal),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const TextSpan(
                      text: '  Kcal',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Eat ${data.remainingKcal} calorie left.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      data.dateLabel,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Icon(Icons.keyboard_arrow_down, size: 18),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
                  child: CustomPaint(
                    painter: _IntakeChartPainter(data: data),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Macro(
                      color: AppColors.primary,
                      value: '${data.carbsG}g',
                      label: 'Carbs',
                      icon: Icons.circle,
                    ),
                    _Macro(
                      color: AppColors.chartBlue,
                      value: '${data.proteinG}g',
                      label: 'Protein',
                      icon: Icons.spa_outlined,
                    ),
                    _Macro(
                      color: AppColors.chartGreen,
                      value: '${data.fatsG}g',
                      label: 'Fats',
                      icon: Icons.fitness_center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(int n) {
    final s = n.toString();
    if (s.length <= 3) return s;
    return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }
}

class _Macro extends StatelessWidget {
  const _Macro({
    required this.color,
    required this.value,
    required this.label,
    required this.icon,
  });
  final Color color;
  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: AppColors.white),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _IntakeChartPainter extends CustomPainter {
  _IntakeChartPainter({required this.data});
  final CalorieIntakeData data;

  @override
  void paint(Canvas canvas, Size size) {
    final minY = 1600.0;
    final maxY = 2000.0;
    final pts = data.points;
    Offset map(int i, int kcal) {
      final x = size.width * (i / (pts.length - 1));
      final y = size.height * (1 - ((kcal - minY) / (maxY - minY)));
      return Offset(x, y);
    }

    // grid
    for (var v = 1600; v <= 2000; v += 100) {
      final y = size.height * (1 - ((v - minY) / (maxY - minY)));
      canvas.drawLine(
        Offset(40, y),
        Offset(size.width, y),
        Paint()..color = AppColors.border,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: '$v',
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(4, y - 6));
    }

    final path = Path();
    for (var i = 0; i < pts.length; i++) {
      final p = map(i, pts[i].kcal);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.35),
            AppColors.primary.withValues(alpha: 0.0),
          ],
        ).createShader(Offset.zero & size),
    );

    final active = pts[data.activePointIndex];
    final ap = map(data.activePointIndex, active.kcal);
    canvas.drawLine(
      Offset(ap.dx, 0),
      Offset(ap.dx, size.height),
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.5)
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(ap, 6, Paint()..color = AppColors.white);
    canvas.drawCircle(ap, 4, Paint()..color = AppColors.primary);

    final label = '${active.kcal}Kcal';
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: ap.translate(0, -24),
        width: tp.width + 16,
        height: 26,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, Paint()..color = AppColors.primary);
    tp.paint(canvas, ap.translate(-(tp.width / 2), -24 - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
