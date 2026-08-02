import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/assessment_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../assessment_session.dart';

class AgeAssessmentScreen extends StatefulWidget {
  const AgeAssessmentScreen({super.key});

  @override
  State<AgeAssessmentScreen> createState() => _AgeAssessmentScreenState();
}

class _AgeAssessmentScreenState extends State<AgeAssessmentScreen> {
  FixedExtentScrollController? _controller;
  int _age = 19;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = context.read<AssessmentSession>();
    if (_controller == null && session.config != null) {
      _age = session.profile.age ?? session.config!.defaultAge;
      final min = session.config!.minAge;
      _controller = FixedExtentScrollController(initialItem: _age - min);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AssessmentSession>();
    final config = session.config;
    if (session.loading || config == null || _controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final ages = List.generate(
      config.maxAge - config.minAge + 1,
      (i) => config.minAge + i,
    );

    return Scaffold(
      body: SafeArea(
        child: ResponsiveConstrained(
          child: Column(
            children: [
              const AssessmentHeader(step: 1, totalSteps: 6),
              const SizedBox(height: 24),
              Text(
                "What's your Age?",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              Expanded(
                child: ListWheelScrollView.useDelegate(
                  controller: _controller,
                  itemExtent: 72,
                  perspective: 0.002,
                  diameterRatio: 1.6,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (i) {
                    setState(() => _age = ages[i]);
                    session.setAge(_age);
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: ages.length,
                    builder: (context, index) {
                      final value = ages[index];
                      final selected = value == _age;
                      final distance = (value - _age).abs();
                      final opacity = distance == 0
                          ? 1.0
                          : distance == 1
                              ? 0.55
                              : 0.28;
                      return Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: selected ? 88 : 64,
                          height: selected ? 72 : 56,
                          alignment: Alignment.center,
                          decoration: selected
                              ? BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(16),
                                )
                              : null,
                          child: Text(
                            '$value',
                            style: TextStyle(
                              fontSize: selected ? 36 : 28,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'serif',
                              color: selected
                                  ? AppColors.white
                                  : AppColors.textSecondary
                                      .withValues(alpha: opacity),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: PrimaryButton(
                  label: 'Continue',
                  onPressed: () async {
                    session.setAge(_age);
                    await session.persist();
                    if (!context.mounted) return;
                    context.goNamed(RouteNames.assessmentWeight);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
