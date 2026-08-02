import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/circular_icon_button.dart';
import '../../domain/entities/settings_entities.dart';
import '../../domain/repositories/settings_repository.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationsPageData? _data;
  bool _today = true;

  @override
  void initState() {
    super.initState();
    context.read<SettingsRepository>().getNotifications().then((v) {
      if (mounted) setState(() => _data = v);
    });
  }

  Color _parse(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  IconData _icon(String key) => switch (key) {
        'score' => Icons.bubble_chart_outlined,
        'water' => Icons.water_drop,
        'dumbbell' => Icons.fitness_center,
        'apple' => Icons.apple,
        'data' => Icons.hub_outlined,
        _ => Icons.notifications_none,
      };

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final top = MediaQuery.paddingOf(context).top;
    if (data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final list = _today ? data.today : data.past;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, top + 8, 16, 22),
            decoration: const BoxDecoration(
              color: AppColors.charcoal,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircularIconButton(
                  icon: Icons.arrow_back,
                  backgroundColor: const Color(0xFF2A2A2A),
                  iconColor: AppColors.white,
                  onPressed: () => context.pop(),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Notifications',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _Tab(
                        label: 'Today',
                        selected: _today,
                        onTap: () => setState(() => _today = true),
                      ),
                      _Tab(
                        label: 'Past',
                        selected: !_today,
                        onTap: () => setState(() => _today = false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ResponsiveConstrained(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                children: [
                  Text(
                    _today ? 'Earlier Today' : 'Earlier',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...list.map((n) {
                    final bg = _parse(n.colorHex);
                    final isWhite = n.colorHex.toUpperCase() == '#FFFFFF';
                    return Material(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          switch (n.iconKey) {
                            case 'notifications':
                              context.pushNamed(RouteNames.aiChatThread);
                            case 'score':
                              context.pushNamed(RouteNames.upliftScore);
                            case 'water':
                              context.pushNamed(RouteNames.hydration);
                            case 'dumbbell':
                              context.pushNamed(RouteNames.workoutComplete);
                            case 'apple':
                              context.pushNamed(RouteNames.addMeal);
                            case 'data':
                              context.pushNamed(RouteNames.calorieStats);
                            default:
                              context.pushNamed(RouteNames.aiCoachHub);
                          }
                        },
                        child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: bg,
                                  borderRadius: BorderRadius.circular(14),
                                  border: isWhite
                                      ? Border.all(color: AppColors.border)
                                      : null,
                                ),
                                child: Icon(
                                  _icon(n.iconKey),
                                  color: isWhite
                                      ? AppColors.black
                                      : AppColors.white,
                                ),
                              ),
                              if (n.trailing == NotificationTrailing.badge &&
                                  n.badge != null &&
                                  isWhite)
                                Positioned(
                                  right: -4,
                                  top: -4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      n.badge!,
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  n.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  n.subtitle,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                                if (n.progress != null) ...[
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: n.progress,
                                      minHeight: 6,
                                      backgroundColor: AppColors.surfaceAlt,
                                      color: AppColors.chartBlue,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (n.trailing == NotificationTrailing.badge &&
                              !isWhite &&
                              n.badge != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                n.badge!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          if (n.trailing == NotificationTrailing.check)
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.charcoal,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.check,
                                color: AppColors.white,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? const Color(0xFF3A3A3A) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white.withValues(alpha: selected ? 1 : 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
