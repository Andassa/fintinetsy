import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AuthTextLink extends StatelessWidget {
  const AuthTextLink({
    super.key,
    required this.prefix,
    required this.linkLabel,
    required this.onTap,
  });

  final String prefix;
  final String linkLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: prefix,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkTextSecondary
              : AppColors.textSecondary,
          fontSize: 14,
        ),
        children: [
          TextSpan(
            text: linkLabel,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
            ),
            recognizer: TapGestureRecognizer()..onTap = onTap,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
