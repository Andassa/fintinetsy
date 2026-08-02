import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/circular_icon_button.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/meal_entities.dart';
import '../../domain/repositories/nutrition_repository.dart';

class FoodScanScreen extends StatefulWidget {
  const FoodScanScreen({super.key});

  @override
  State<FoodScanScreen> createState() => _FoodScanScreenState();
}

class _FoodScanScreenState extends State<FoodScanScreen>
    with SingleTickerProviderStateMixin {
  ScanSession? _session;
  late final AnimationController _scan;

  @override
  void initState() {
    super.initState();
    _scan = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _load();
  }

  Future<void> _load() async {
    final s = await context.read<NutritionRepository>().getScanSession();
    if (!mounted) return;
    setState(() => _session = s);
  }

  @override
  void dispose() {
    _scan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    if (session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    CircularIconButton(
                      icon: Icons.arrow_back,
                      onPressed: () => context.pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Analysis',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    CircularIconButton(
                      icon: Icons.more_horiz,
                      onPressed: () =>
                          context.pushNamed(RouteNames.calorieStats),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(session.imageAsset, fit: BoxFit.cover),
                  AnimatedBuilder(
                    animation: _scan,
                    builder: (context, _) {
                      final t = _scan.value;
                      return Stack(
                        children: [
                          Align(
                            alignment: Alignment(0, -1 + 2 * t),
                            child: Container(
                              height: MediaQuery.sizeOf(context).height *
                                  (1 - t) *
                                  0.55,
                              color: AppColors.white.withValues(alpha: 0.45),
                            ),
                          ),
                          Align(
                            alignment: Alignment(0, -1 + 2 * t),
                            child: Container(
                              height: 3,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.paddingOf(context).bottom + 16,
              ),
              child: PrimaryButton(
                label: session.statusLabel,
                style: PrimaryButtonStyle.orange,
                showIcon: false,
                onPressed: () => context.pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
