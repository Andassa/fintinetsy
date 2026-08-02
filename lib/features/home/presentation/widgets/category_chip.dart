import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/home_dashboard.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    required this.onTap,
  });

  final HomeCategory category;
  final VoidCallback onTap;

  IconData get _icon {
    return switch (category.iconKey) {
      'favorite' => Icons.favorite_border,
      'local_fire' => Icons.local_fire_department_outlined,
      _ => Icons.water_drop_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final selected = category.isSelected;
    return Material(
      color: selected ? const Color(0xFF3B82F6) : AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _icon,
                size: 18,
                color: selected ? AppColors.white : AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                category.label,
                style: TextStyle(
                  color: selected ? AppColors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
