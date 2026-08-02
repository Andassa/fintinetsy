import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/assessment_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../assessment_session.dart';

class VocalAssessmentScreen extends StatelessWidget {
  const VocalAssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AssessmentSession>();
    final vocal = session.config?.vocal;
    if (session.loading || vocal == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final rest = vocal.prompt.replaceFirst(vocal.highlightedWords, '').trim();

    return Scaffold(
      body: SafeArea(
        child: ResponsiveConstrained(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                AssessmentHeader(
                  step: 5,
                  totalSteps: 6,
                  onBack: () => context.goNamed(RouteNames.assessmentGender),
                ),
                const SizedBox(height: 28),
                Text(
                  'AI Vocal Analysis',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  vocal.subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                const _VoiceWaveform(),
                const Spacer(),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            vocal.highlightedWords,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      TextSpan(
                        text: ' $rest',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              height: 1.4,
                            ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                PrimaryButton(
                  label: 'Continue',
                  onPressed: () async {
                    session.completeVocal();
                    await session.persist();
                    if (!context.mounted) return;
                    context.goNamed(RouteNames.assessmentGoals);
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

class _VoiceWaveform extends StatelessWidget {
  const _VoiceWaveform();

  static const _heights = [
    18.0,
    28.0,
    40.0,
    52.0,
    68.0,
    86.0,
    110.0,
    86.0,
    68.0,
    52.0,
    40.0,
    28.0,
    18.0,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(_heights.length, (i) {
        final mid = _heights.length ~/ 2;
        final dist = (i - mid).abs();
        final color = dist == 0
            ? AppColors.black
            : Color.lerp(
                AppColors.black,
                AppColors.surfaceAlt,
                dist / mid,
              )!;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 10,
          height: _heights[i],
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}
