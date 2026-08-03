import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_image.dart';
import '../../domain/entities/home_dashboard.dart';

class AiCoachCard extends StatelessWidget {
  const AiCoachCard({super.key, required this.coach});

  final HomeAiCoachCard coach;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).width >= 600 ? 210.0 : 176.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppImage(coach.imageAsset, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coach.conversationsLabel,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 28,
                          ),
                        ),
                        Text(
                          coach.subtitle,
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_forward, size: 20),
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
