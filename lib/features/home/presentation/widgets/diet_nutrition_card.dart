import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_image.dart';
import '../../domain/entities/home_dashboard.dart';

class DietNutritionCard extends StatelessWidget {
  const DietNutritionCard({super.key, required this.diet});

  final HomeDietCard diet;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final height = MediaQuery.sizeOf(context).width >= 600 ? 170.0 : 148.0;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: 8,
            bottom: 8,
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipOval(
                child: AppImage(diet.imageAsset, fit: BoxFit.cover),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 120, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatChip(label: '${diet.proteinG}g Protein'),
                const SizedBox(height: 8),
                _StatChip(label: '${diet.fatsG}g Fats'),
                const Spacer(),
                Text(
                  diet.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${diet.kcal}kcal    ${diet.durationMin}min',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
