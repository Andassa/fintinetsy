import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/circular_icon_button.dart';
import '../../domain/entities/workout_entities.dart';
import '../../domain/repositories/workout_repository.dart';

class WorkoutCategoryScreen extends StatefulWidget {
  const WorkoutCategoryScreen({super.key});

  @override
  State<WorkoutCategoryScreen> createState() => _WorkoutCategoryScreenState();
}

class _WorkoutCategoryScreenState extends State<WorkoutCategoryScreen> {
  WorkoutCategoryPage? _data;

  @override
  void initState() {
    super.initState();
    context.read<WorkoutRepository>().getCategoryPage().then((v) {
      if (mounted) setState(() => _data = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    if (data == null) {
      return const Scaffold(
        backgroundColor: AppColors.charcoal,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    final top = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, top + 8, 16, 36),
              decoration: const BoxDecoration(
                color: AppColors.charcoal,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.4,
                      child: Image.asset(
                        data.headerAsset,
                        fit: BoxFit.cover,
                        alignment: Alignment.topLeft,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircularIconButton(
                        icon: Icons.arrow_back,
                        backgroundColor: const Color(0xFF2A2A2A),
                        iconColor: AppColors.white,
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Text(
                            data.title,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.white.withValues(alpha: 0.85),
                              ),
                            ),
                            child: Text(
                              data.totalLabel,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data.description,
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -22),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(36),
                    ),
                  ),
                  child: ResponsiveConstrained(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'All Workouts',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  context.pushNamed(RouteNames.workoutBrowse),
                              child: const Text(
                                'See All',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...data.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Material(
                              color: const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(28),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(28),
                                onTap: () => context
                                    .pushNamed(RouteNames.workoutPreview),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(18),
                                        child: Image.asset(
                                          item.thumbnailAsset,
                                          width: 72,
                                          height: 72,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              item.totalLabel,
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 13,
                                              ),
                                            ),
                                            Text(
                                              item.repsLabel,
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
