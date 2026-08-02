import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CircularIconButton extends StatelessWidget {
  const CircularIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 40,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: backgroundColor ??
          (isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: size * 0.45,
            color: iconColor ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
