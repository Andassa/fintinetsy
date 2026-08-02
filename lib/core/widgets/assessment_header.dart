import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import 'circular_icon_button.dart';

class AssessmentHeader extends StatelessWidget {
  const AssessmentHeader({
    super.key,
    required this.step,
    required this.totalSteps,
    this.title = 'Assessment',
    this.onBack,
  });

  final int step;
  final int totalSteps;
  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
      child: Row(
        children: [
          CircularIconButton(
            icon: Icons.chevron_left,
            onPressed: onBack ?? () => context.pop(),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.badgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$step of $totalSteps',
              style: const TextStyle(
                color: AppColors.badgeText,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
