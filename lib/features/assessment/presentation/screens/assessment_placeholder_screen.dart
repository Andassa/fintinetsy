import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/circular_icon_button.dart';
import '../../../../core/widgets/primary_button.dart';

/// Placeholder until assessment feature is fully built.
class AssessmentPlaceholderScreen extends StatelessWidget {
  const AssessmentPlaceholderScreen({
    super.key,
    required this.title,
    required this.step,
    required this.totalSteps,
    required this.nextRouteName,
  });

  final String title;
  final int step;
  final int totalSteps;
  final String nextRouteName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ResponsiveConstrained(
          child: Padding(
            padding: Responsive.pagePadding(context),
            child: Column(
              children: [
                Row(
                  children: [
                    CircularIconButton(
                      icon: Icons.chevron_left,
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                    Text(
                      'Assessment',
                      style: theme.textTheme.titleLarge,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.badgeBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$step of $totalSteps',
                        style: const TextStyle(
                          color: AppColors.badgeText,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (step == 4) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            AppAssets.manRunning,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            AppAssets.womanRunning,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Coming next — full pixel-perfect assessment UI.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const Spacer(),
                PrimaryButton(
                  label: 'Continue',
                  onPressed: () {
                    if (nextRouteName == RouteNames.home) {
                      context.goNamed(RouteNames.home);
                    } else {
                      context.goNamed(nextRouteName);
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePlaceholderScreen extends StatelessWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: Responsive.pagePadding(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Home',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Dashboard à venir — auth flow OK ✓',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Back to Welcome',
                  style: PrimaryButtonStyle.orange,
                  onPressed: () => context.goNamed(RouteNames.welcome),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
