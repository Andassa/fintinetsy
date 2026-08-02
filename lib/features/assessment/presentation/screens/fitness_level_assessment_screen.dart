import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/assessment_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../assessment_session.dart';

class FitnessLevelAssessmentScreen extends StatefulWidget {
  const FitnessLevelAssessmentScreen({super.key});

  @override
  State<FitnessLevelAssessmentScreen> createState() =>
      _FitnessLevelAssessmentScreenState();
}

class _FitnessLevelAssessmentScreenState
    extends State<FitnessLevelAssessmentScreen> {
  int _level = 3;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AssessmentSession>();
    final config = session.config;
    if (session.loading || config == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    _level = session.profile.fitnessLevel.clamp(1, 6);
    final label = config.fitnessLabels[_level - 1];

    return Scaffold(
      body: SafeArea(
        child: ResponsiveConstrained(
          child: Column(
            children: [
              AssessmentHeader(
                step: 3,
                totalSteps: 6,
                onBack: () => context.goNamed(RouteNames.assessmentWeight),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'How would you rate your fitness level?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.help_outline,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Drag to adjust',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ArcFitnessSlider(
                          value: _level,
                          max: 6,
                          onChanged: (v) {
                            setState(() => _level = v);
                            session.setFitnessLevel(v);
                          },
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$_level',
                              style: const TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: PrimaryButton(
                  label: 'Continue',
                  onPressed: () async {
                    session.setFitnessLevel(_level);
                    await session.persist();
                    if (!context.mounted) return;
                    context.goNamed(RouteNames.assessmentGender);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ArcFitnessSlider extends StatelessWidget {
  const ArcFitnessSlider({
    super.key,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onPanUpdate: (d) {
            final box = context.findRenderObject() as RenderBox;
            final local = box.globalToLocal(d.globalPosition);
            final center = Offset(size * 0.15, size * 0.85);
            final dx = local.dx - center.dx;
            final dy = local.dy - center.dy;
            var angle = math.atan2(dy, dx);
            // Map from ~-90deg to ~0deg quadrant-ish to 1..max
            final t = ((angle + math.pi / 2) / (math.pi / 2)).clamp(0.0, 1.0);
            final v = (1 + t * (max - 1)).round().clamp(1, max);
            onChanged(v);
          },
          child: CustomPaint(
            size: Size(size, size),
            painter: _ArcPainter(value: value, max: max),
          ),
        );
      },
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter({required this.value, required this.max});
  final int value;
  final int max;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.2, size.height * 0.85);
    final radius = size.width * 0.72;
    const start = -math.pi / 2;
    const sweep = math.pi / 2;

    final track = Paint()
      ..color = AppColors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    final progress = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      track,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep * ((value - 1) / (max - 1)),
      false,
      progress,
    );

    for (var i = 0; i < max; i++) {
      final a = start + sweep * (i / (max - 1));
      final p1 = Offset(
        center.dx + math.cos(a) * (radius - 14),
        center.dy + math.sin(a) * (radius - 14),
      );
      final p2 = Offset(
        center.dx + math.cos(a) * (radius + 14),
        center.dy + math.sin(a) * (radius + 14),
      );
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = AppColors.textMuted
          ..strokeWidth = 2,
      );
    }

    final a = start + sweep * ((value - 1) / (max - 1));
    final thumb = Offset(
      center.dx + math.cos(a) * radius,
      center.dy + math.sin(a) * radius,
    );
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(center: thumb, width: 44, height: 44),
      const Radius.circular(12),
    );
    canvas.drawRRect(r, Paint()..color = AppColors.primary);
    canvas.drawCircle(thumb, 6, Paint()..color = AppColors.white);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) =>
      oldDelegate.value != value;
}
