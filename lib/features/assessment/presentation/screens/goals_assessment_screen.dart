import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/assessment_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../assessment_session.dart';

class GoalsAssessmentScreen extends StatelessWidget {
  const GoalsAssessmentScreen({super.key});

  IconData _icon(String key) {
    return switch (key) {
      'scale' => Icons.monitor_weight_outlined,
      'smart_toy' => Icons.smart_toy_outlined,
      'fitness_center' => Icons.fitness_center,
      'favorite' => Icons.favorite_border,
      _ => Icons.phone_iphone,
    };
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AssessmentSession>();
    final goals = session.config?.goals ?? const [];
    final selected = session.profile.goalId ??
        (goals.isNotEmpty ? goals[1].id : null);

    return Scaffold(
      body: SafeArea(
        child: ResponsiveConstrained(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                AssessmentHeader(
                  step: 6,
                  totalSteps: 6,
                  onBack: () => context.goNamed(RouteNames.assessmentVocal),
                ),
                const SizedBox(height: 20),
                Text(
                  "What's your fitness goal/target?",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: ListView.separated(
                    itemCount: goals.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final g = goals[i];
                      final isSelected = g.id == selected;
                      return Material(
                        color:
                            isSelected ? AppColors.primary : AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          onTap: () => session.setGoal(g.id),
                          borderRadius: BorderRadius.circular(18),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _icon(g.iconKey),
                                  color: isSelected
                                      ? AppColors.white
                                      : AppColors.textPrimary,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    g.label,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: isSelected
                                          ? AppColors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.white
                                          : AppColors.textSecondary,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Center(
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: const BoxDecoration(
                                              color: AppColors.white,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                PrimaryButton(
                  label: 'Continue',
                  onPressed: () async {
                    if (selected != null) session.setGoal(selected);
                    await session.persist();
                    if (!context.mounted) return;
                    context.goNamed(RouteNames.assessmentAvatar);
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
