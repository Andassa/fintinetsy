import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/circular_icon_button.dart';
import '../../../../core/widgets/primary_button.dart';
import '../assessment_session.dart';

class AvatarAssessmentScreen extends StatefulWidget {
  const AvatarAssessmentScreen({super.key});

  @override
  State<AvatarAssessmentScreen> createState() => _AvatarAssessmentScreenState();
}

class _AvatarAssessmentScreenState extends State<AvatarAssessmentScreen> {
  int _selected = 1;

  static const _avatars = [
    AppAssets.avatarLeft,
    AppAssets.avatarCenter,
    AppAssets.avatarRight,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsiveConstrained(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    CircularIconButton(
                      icon: Icons.chevron_left,
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Assessment',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 140,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_avatars.length, (i) {
                      final selected = i == _selected;
                      return GestureDetector(
                        onTap: () => setState(() => _selected = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: selected ? 110 : 88,
                          height: selected ? 110 : 88,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: selected
                                ? const LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primaryLight,
                                    ],
                                  )
                                : null,
                            color: selected ? null : AppColors.surfaceAlt,
                          ),
                          child: Image.asset(_avatars[i], fit: BoxFit.contain),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Select your Avatar',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'We have 23 custom premade avatars, or you can upload profile locally',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CustomPaint(
                    painter: _DashedCirclePainter(),
                    child: const Center(
                      child: Icon(Icons.file_upload_outlined, size: 28),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'or Upload from Local File',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Max 5mb, Format: jpg,png',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const Spacer(),
                PrimaryButton(
                  label: 'Continue',
                  onPressed: () async {
                    final session = context.read<AssessmentSession>();
                    await session.persist();
                    if (!context.mounted) return;
                    context.goNamed(RouteNames.home);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textMuted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const dash = 5.0;
    const gap = 4.0;
    final r = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    final path = Path()..addOval(r);
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final len = (dist + dash).clamp(0, metric.length);
        canvas.drawPath(metric.extractPath(dist, len.toDouble()), paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
