import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/circular_icon_button.dart';
import '../../domain/entities/stats_entities.dart';
import '../../domain/repositories/stats_repository.dart';
import '../widgets/donut_chart.dart';

class UpliftScoreScreen extends StatefulWidget {
  const UpliftScoreScreen({super.key});

  @override
  State<UpliftScoreScreen> createState() => _UpliftScoreScreenState();
}

class _UpliftScoreScreenState extends State<UpliftScoreScreen> {
  UpliftScoreData? _data;

  @override
  void initState() {
    super.initState();
    context.read<StatsRepository>().getUpliftScore().then((v) {
      if (mounted) setState(() => _data = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    if (data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final segments = data.segments
        .map((s) => (label: s.label, percent: s.percent, color: parseHex(s.colorHex)))
        .toList();

    return Scaffold(
      body: SafeArea(
        child: ResponsiveConstrained(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    CircularIconButton(
                      icon: Icons.arrow_back,
                      onPressed: () => context.pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Uplift Score',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            DonutChart(segments: segments, size: 240),
                            Positioned(
                              left: 0,
                              child: _NavArrow(icon: Icons.chevron_left),
                            ),
                            Positioned(
                              right: 0,
                              child: _NavArrow(icon: Icons.chevron_right),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${data.score}',
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        data.message,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: data.segments
                            .map(
                              (s) => Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: parseHex(s.colorHex),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    s.label,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: AppColors.textSecondary),
    );
  }
}
