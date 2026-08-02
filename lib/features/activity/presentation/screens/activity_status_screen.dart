import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/circular_icon_button.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../stats/domain/entities/stats_entities.dart';
import '../../../stats/domain/repositories/stats_repository.dart';
import '../../../stats/presentation/widgets/donut_chart.dart';

class ActivityStatusScreen extends StatefulWidget {
  const ActivityStatusScreen({super.key});

  @override
  State<ActivityStatusScreen> createState() => _ActivityStatusScreenState();
}

class _ActivityStatusScreenState extends State<ActivityStatusScreen> {
  ActivityStatusData? _data;

  @override
  void initState() {
    super.initState();
    context.read<StatsRepository>().getActivityStatus().then((v) {
      if (mounted) setState(() => _data = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    if (data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                        'Activity Status',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 14,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: data.items
                    .map(
                      (i) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: parseHex(i.colorHex),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            i.label,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) {
                    return Stack(
                      children: data.items.map((item) {
                        final isLight = item.colorHex.toUpperCase() == '#EBEBEB';
                        return Align(
                          alignment: Alignment(item.dx, item.dy),
                          child: Transform.rotate(
                            angle: item.rotationDeg * math.pi / 180,
                            child: GestureDetector(
                              onTap: () =>
                                  context.pushNamed(RouteNames.heartRate),
                              child: Container(
                                width: item.width *
                                    (c.maxWidth / 390).clamp(0.85, 1.25),
                                height: item.height *
                                    (c.maxWidth / 390).clamp(0.85, 1.25),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: parseHex(item.colorHex),
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Text(
                                  item.hoursLabel,
                                  style: TextStyle(
                                    color: isLight
                                        ? AppColors.black
                                        : AppColors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 28,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: PrimaryButton(
                  label: 'Start Activity',
                  style: PrimaryButtonStyle.orange,
                  onPressed: () => context.pushNamed(RouteNames.directions),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
