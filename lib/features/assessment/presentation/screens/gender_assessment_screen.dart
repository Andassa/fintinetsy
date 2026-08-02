import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/assessment_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/assessment_entities.dart';
import '../assessment_session.dart';

class GenderAssessmentScreen extends StatelessWidget {
  const GenderAssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AssessmentSession>();
    final selected = session.profile.gender;

    return Scaffold(
      body: SafeArea(
        child: ResponsiveConstrained(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                AssessmentHeader(
                  step: 4,
                  totalSteps: 6,
                  onBack: () =>
                      context.goNamed(RouteNames.assessmentFitnessLevel),
                ),
                const SizedBox(height: 20),
                Text(
                  'What is your gender?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 24),
                _GenderCard(
                  label: 'Male',
                  symbol: '♂',
                  image: AppAssets.manRunning,
                  selected: selected == GenderOption.male,
                  onTap: () => session.setGender(GenderOption.male),
                ),
                const SizedBox(height: 14),
                _GenderCard(
                  label: 'Female',
                  symbol: '♀',
                  image: AppAssets.womanRunning,
                  selected: selected == GenderOption.female,
                  onTap: () => session.setGender(GenderOption.female),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      session.setGender(GenderOption.skipped);
                      await session.persist();
                      if (!context.mounted) return;
                      context.goNamed(RouteNames.assessmentVocal);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.skipSoft,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Prefer to skip, thanks!',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.close, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Continue',
                  onPressed: () async {
                    await session.persist();
                    if (!context.mounted) return;
                    context.goNamed(RouteNames.assessmentVocal);
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

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.label,
    required this.symbol,
    required this.image,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String symbol;
  final String image;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.white : AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: selected
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                right: -10,
                top: 0,
                bottom: 0,
                width: 160,
                child: Image.asset(image, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$symbol  $label',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.charcoal,
                          width: 1.5,
                        ),
                      ),
                      child: selected
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColors.black,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
