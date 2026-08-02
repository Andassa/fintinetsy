import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/reset_method_entity.dart';

class ResetMethodCard extends StatelessWidget {
  const ResetMethodCard({
    super.key,
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final ResetMethodEntity method;
  final bool selected;
  final VoidCallback onTap;

  Color get _iconBg {
    final hex = method.iconColorHex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  IconData get _icon {
    return switch (method.iconKey) {
      'lock' => Icons.lock_outline,
      'gauth' => Icons.local_fire_department_outlined,
      _ => Icons.mail_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: selected
                ? Border.all(color: AppColors.primary, width: 1.5)
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icon, color: AppColors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method.description,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textMuted.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
