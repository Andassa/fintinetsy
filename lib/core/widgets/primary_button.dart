import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum PrimaryButtonStyle { black, orange, white }

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward,
    this.showIcon = true,
    this.style = PrimaryButtonStyle.black,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool showIcon;
  final PrimaryButtonStyle style;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (style) {
      PrimaryButtonStyle.black => (AppColors.black, AppColors.white),
      PrimaryButtonStyle.orange => (AppColors.primary, AppColors.white),
      PrimaryButtonStyle.white => (AppColors.white, AppColors.black),
    };

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: bg.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: fg,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: fg,
                    ),
                  ),
                  if (showIcon && icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(icon, size: 20, color: fg),
                  ],
                ],
              ),
      ),
    );
  }
}
