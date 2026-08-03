import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_image.dart';
import '../../domain/entities/home_dashboard.dart';

class WorkoutHeroCard extends StatelessWidget {
  const WorkoutHeroCard({super.key, required this.workout});

  final HomeWorkoutCard workout;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).width >= 600 ? 220.0 : 180.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppImage(workout.imageAsset, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.72),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${workout.durationMin}min',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Text(
                        '${workout.kcal}kcal',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout.title,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              workout.subtitle,
                              style: TextStyle(
                                color: AppColors.white.withValues(alpha: 0.75),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
