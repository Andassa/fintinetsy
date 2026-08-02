import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/assessment_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/assessment_entities.dart';
import '../assessment_session.dart';

class WeightAssessmentScreen extends StatefulWidget {
  const WeightAssessmentScreen({super.key});

  @override
  State<WeightAssessmentScreen> createState() => _WeightAssessmentScreenState();
}

class _WeightAssessmentScreenState extends State<WeightAssessmentScreen> {
  WeightUnit _unit = WeightUnit.kg;
  double _weight = 62;
  late ScrollController _scroll;

  static const _tickWidth = 12.0;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToWeight());
  }

  void _jumpToWeight() {
    if (!_scroll.hasClients) return;
    final session = context.read<AssessmentSession>();
    final min = session.config?.minWeightKg ?? 30;
    _scroll.jumpTo((_weight - min) * _tickWidth);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AssessmentSession>();
    final config = session.config;
    if (session.loading || config == null) {
      return const Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    _weight = session.profile.weightKg ?? config.defaultWeightKg;
    _unit = session.profile.weightUnit;
    final display = _unit == WeightUnit.kg ? _weight : _weight * 2.20462;
    final unitLabel = _unit == WeightUnit.kg ? 'Kg' : 'Lbs';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: ResponsiveConstrained(
            child: Column(
              children: [
                AssessmentHeader(
                  step: 2,
                  totalSteps: 6,
                  onBack: () => context.goNamed(RouteNames.assessmentAge),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    "What's your current weight right now?",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _UnitChip(
                      label: 'Kg',
                      selected: _unit == WeightUnit.kg,
                      onTap: () {
                        session.setWeight(_weight, WeightUnit.kg);
                        setState(() => _unit = WeightUnit.kg);
                      },
                    ),
                    const SizedBox(width: 12),
                    _UnitChip(
                      label: 'Lbs',
                      selected: _unit == WeightUnit.lbs,
                      onTap: () {
                        session.setWeight(_weight, WeightUnit.lbs);
                        setState(() => _unit = WeightUnit.lbs);
                      },
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '${display.round()} $unitLabel',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 90,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      if (n is ScrollUpdateNotification ||
                          n is ScrollEndNotification) {
                        final min = config.minWeightKg;
                        final idx =
                            (_scroll.offset / _tickWidth).round().clamp(
                                  0,
                                  (config.maxWeightKg - min).round(),
                                );
                        final w = min + idx;
                        if (w != _weight) {
                          setState(() => _weight = w.toDouble());
                          session.setWeight(_weight, _unit);
                        }
                      }
                      return false;
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ListView.builder(
                          controller: _scroll,
                          scrollDirection: Axis.horizontal,
                          itemExtent: _tickWidth,
                          itemCount:
                              (config.maxWeightKg - config.minWeightKg).round() +
                                  1,
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.sizeOf(context).width / 2 - _tickWidth,
                          ),
                          itemBuilder: (context, i) {
                            final value = (config.minWeightKg + i).round();
                            final major = value % 5 == 0;
                            return Align(
                              alignment: Alignment.topCenter,
                              child: Column(
                                children: [
                                  Container(
                                    width: major ? 2.5 : 1.2,
                                    height: major ? 36 : 22,
                                    color: AppColors.white
                                        .withValues(alpha: major ? 1 : 0.55),
                                  ),
                                  if (major) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      '$value',
                                      style: TextStyle(
                                        color: AppColors.white
                                            .withValues(alpha: 0.9),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                        Container(
                          width: 3,
                          height: 52,
                          color: AppColors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: PrimaryButton(
                    label: 'Continue',
                    style: PrimaryButtonStyle.white,
                    onPressed: () async {
                      session.setWeight(_weight, _unit);
                      await session.persist();
                      if (!context.mounted) return;
                      context.goNamed(RouteNames.assessmentFitnessLevel);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UnitChip extends StatelessWidget {
  const _UnitChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 72,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: selected
                ? Border.all(color: AppColors.charcoal, width: 1.5)
                : null,
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
