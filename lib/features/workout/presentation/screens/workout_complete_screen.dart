import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/workout_entities.dart';
import '../../domain/repositories/workout_repository.dart';

class WorkoutCompleteScreen extends StatefulWidget {
  const WorkoutCompleteScreen({super.key});

  @override
  State<WorkoutCompleteScreen> createState() => _WorkoutCompleteScreenState();
}

class _WorkoutCompleteScreenState extends State<WorkoutCompleteScreen> {
  WorkoutCompletePage? _data;

  @override
  void initState() {
    super.initState();
    context.read<WorkoutRepository>().getCompletePage().then((v) {
      if (mounted) setState(() => _data = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    if (data == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    final bottom = MediaQuery.paddingOf(context).bottom;
    final height = MediaQuery.sizeOf(context).height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: height * 0.72,
                width: double.infinity,
                child: AppImage(
                  data.heroAsset,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.35, 0.58, 0.78, 1],
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.92),
                    Colors.black,
                  ],
                ),
              ),
            ),
            SafeArea(
              child: ResponsiveConstrained(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(28, 8, 28, bottom + 12),
                  child: Column(
                    children: [
                      const Spacer(flex: 5),
                      Text(
                        data.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 32,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        data.burnedLabel,
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.95),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 36),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _Metric(value: data.minutes, label: 'Min'),
                          _Metric(value: data.kcal, label: 'Kcal'),
                          _Metric(value: data.bpm, label: 'BPM'),
                        ],
                      ),
                      const Spacer(flex: 2),
                      PrimaryButton(
                        label: 'Complete',
                        style: PrimaryButtonStyle.orange,
                        onPressed: () => context.goNamed(RouteNames.home),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.85),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
