import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/offline/offline_status.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/home_dashboard.dart';
import '../../domain/usecases/get_home_dashboard_usecase.dart';
import '../widgets/activity_blobs_card.dart';
import '../widgets/ai_coach_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/diet_nutrition_card.dart';
import '../widgets/home_header.dart';
import '../widgets/workout_hero_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeDashboard? _data;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await context.read<GetHomeDashboardUseCase>()();
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = math.max(MediaQuery.paddingOf(context).bottom, 16.0);
    final offline = context.watch<OfflineStatus>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : const Color(0xFFF7F7F8),
        body: Column(
          children: [
            OfflineBanner(status: offline),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.wifi_off_rounded,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _error.toString(),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: _load,
                                  child: const Text('Retry'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      context.pushNamed(RouteNames.noInternet),
                                  child: const Text('Check connection'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            slivers: [
                        // Home dashboard content from REST /home/dashboard
                        SliverToBoxAdapter(
                          child: HomeHeader(
                            user: _data!.user,
                            onSearchTap: () =>
                                context.pushNamed(RouteNames.search),
                            onNotificationTap: () =>
                                context.pushNamed(RouteNames.notifications),
                            onProfileTap: () =>
                                context.pushNamed(RouteNames.profile),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: Responsive.isTabletOrLarger(context)
                                ? 28
                                : 22,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SectionHeader(
                            title: 'Browse Category',
                            onAction: () =>
                                context.pushNamed(RouteNames.calorieStats),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 14)),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 44,
                            child: ListView.separated(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              scrollDirection: Axis.horizontal,
                              itemCount: _data!.categories.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, i) {
                                final c = _data!.categories[i];
                                return CategoryChip(
                                  category: c,
                                  onTap: () {
                                    switch (c.id) {
                                      case 'hydration':
                                        context.pushNamed(RouteNames.hydration);
                                      case 'score':
                                        context
                                            .pushNamed(RouteNames.upliftScore);
                                      case 'calorie':
                                        context.pushNamed(
                                          RouteNames.calorieIntake,
                                        );
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 26)),
                        SliverToBoxAdapter(
                          child: SectionHeader(
                            title: 'Workouts',
                            onAction: () =>
                                context.pushNamed(RouteNames.workoutBrowse),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 14)),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: GestureDetector(
                              onTap: () =>
                                  context.pushNamed(RouteNames.workoutPreview),
                              child: WorkoutHeroCard(workout: _data!.workout),
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 26)),
                        SliverToBoxAdapter(
                          child: SectionHeader(
                            title: 'Diet & Nutrition',
                            onAction: () =>
                                context.pushNamed(RouteNames.addMeal),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 14)),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: GestureDetector(
                              onTap: () =>
                                  context.pushNamed(RouteNames.calorieStats),
                              child: DietNutritionCard(diet: _data!.diet),
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 26)),
                        SliverToBoxAdapter(
                          child: SectionHeader(
                            title: 'Activities',
                            onAction: () =>
                                context.pushNamed(RouteNames.noActivities),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 14)),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ActivityBlobsCard(
                              blobs: _data!.activities,
                              onTap: () =>
                                  context.pushNamed(RouteNames.activityStatus),
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 26)),
                        SliverToBoxAdapter(
                          child: SectionHeader(
                            title: 'Virtual AI Coach',
                            onAction: () =>
                                context.pushNamed(RouteNames.aiCoachHub),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 14)),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: GestureDetector(
                              onTap: () =>
                                  context.pushNamed(RouteNames.aiCoachIntro),
                              child: AiCoachCard(coach: _data!.aiCoach),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(height: bottomPad + 24),
                        ),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
