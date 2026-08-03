import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_image.dart';
import '../../domain/entities/workout_entities.dart';
import '../../domain/repositories/workout_repository.dart';

class WorkoutPreviewScreen extends StatefulWidget {
  const WorkoutPreviewScreen({super.key});

  @override
  State<WorkoutPreviewScreen> createState() => _WorkoutPreviewScreenState();
}

class _WorkoutPreviewScreenState extends State<WorkoutPreviewScreen> {
  WorkoutPreviewPage? _data;

  @override
  void initState() {
    super.initState();
    context.read<WorkoutRepository>().getPreviewPage().then((v) {
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            AppImage(
              data.heroAsset,
              fit: BoxFit.cover,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.2, 0.55, 1],
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.88),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: ResponsiveConstrained(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 8, 24, bottom + 12),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Material(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => context.pop(),
                            borderRadius: BorderRadius.circular(12),
                            child: const SizedBox(
                              width: 40,
                              height: 40,
                              child: Icon(
                                Icons.arrow_back,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(flex: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.white),
                        ),
                        child: Text(
                          data.totalLabel,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        data.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 34,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.coachLabel,
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.9),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 36),
                      Row(
                        children: [
                          _Stat(value: data.timeValue, label: 'Time'),
                          _Divider(),
                          _Stat(value: data.calorieValue, label: 'Calorie'),
                          _Divider(),
                          _Stat(value: data.setsValue, label: 'Sets'),
                        ],
                      ),
                      const SizedBox(height: 36),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 54,
                              child: OutlinedButton(
                                onPressed: () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.goNamed(RouteNames.workoutCategory);
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.white,
                                  side: const BorderSide(
                                    color: AppColors.white,
                                    width: 1.4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: const Text(
                                  'Details',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                onPressed: () => context
                                    .pushNamed(RouteNames.workoutComplete),
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: const Text(
                                  'Start',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.75),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.white.withValues(alpha: 0.55),
    );
  }
}
