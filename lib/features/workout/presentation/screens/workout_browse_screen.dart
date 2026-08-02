import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/workout_entities.dart';
import '../../domain/repositories/workout_repository.dart';

class WorkoutBrowseScreen extends StatefulWidget {
  const WorkoutBrowseScreen({super.key});

  @override
  State<WorkoutBrowseScreen> createState() => _WorkoutBrowseScreenState();
}

class _WorkoutBrowseScreenState extends State<WorkoutBrowseScreen> {
  WorkoutBrowsePage? _data;

  @override
  void initState() {
    super.initState();
    context.read<WorkoutRepository>().getBrowsePage().then((v) {
      if (mounted) setState(() => _data = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    if (data == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    final bottom = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              data.heroAsset,
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.2),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.35, 0.7, 1],
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black,
                  ],
                ),
              ),
            ),
            SafeArea(
              child: ResponsiveConstrained(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(28, 8, 28, bottom + 12),
                  child: Column(
                    children: [
                      const Spacer(flex: 5),
                      Text(
                        data.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 30,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        data.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.92),
                          fontSize: 15,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(data.dotCount, (i) {
                          final active = i == data.activeDotIndex;
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: active
                                  ? AppColors.white
                                  : AppColors.white.withValues(alpha: 0.28),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 28),
                      PrimaryButton(
                        label: 'Browse Workouts',
                        style: PrimaryButtonStyle.white,
                        onPressed: () =>
                            context.pushNamed(RouteNames.workoutCategory),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
