import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/circular_icon_button.dart';
import '../../domain/entities/settings_entities.dart';
import '../../domain/repositories/settings_repository.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  SettingsPageData? _data;

  @override
  void initState() {
    super.initState();
    context.read<SettingsRepository>().getSettings().then((v) {
      if (mounted) setState(() => _data = v);
    });
  }

  IconData _icon(String key) => switch (key) {
        'person' => Icons.person_outline,
        'phone' => Icons.phone_outlined,
        'flag' => Icons.flag_outlined,
        'watch' => Icons.watch_outlined,
        'lock' => Icons.lock_outline,
        _ => Icons.notifications_none,
      };

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final theme = context.watch<ThemeController>();
    final top = MediaQuery.paddingOf(context).top;
    if (data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, top + 8, 16, 28),
            decoration: const BoxDecoration(
              color: AppColors.charcoal,
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(64)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircularIconButton(
                  icon: Icons.subdirectory_arrow_left,
                  backgroundColor: const Color(0xFF2A2A2A),
                  iconColor: AppColors.white,
                  onPressed: () => context.pop(),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Account Settings',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ResponsiveConstrained(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                children: [
                  for (final section in data.sections) ...[
                    Text(
                      section.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...section.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: const Color(0xFFEDEDED),
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: item.isToggle
                                ? null
                                : () {
                                    if (item.id == 'notification') {
                                      context.pushNamed(
                                        RouteNames.notifications,
                                      );
                                    } else if (item.id == 'personal') {
                                      context.pushNamed(RouteNames.profile);
                                    } else if (item.id == 'security') {
                                      context.pushNamed(RouteNames.goProGate);
                                    } else if (item.id == 'coach') {
                                      context.pushNamed(RouteNames.aiCoachHub);
                                    } else if (item.id == 'devices') {
                                      context.pushNamed(
                                        RouteNames.permissionDenied,
                                      );
                                    }
                                  },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(_icon(item.iconKey), size: 20),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      item.label,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  if (item.isToggle)
                                    Switch.adaptive(
                                      value: theme.isDark,
                                      activeThumbColor: AppColors.white,
                                      activeTrackColor: AppColors.primary,
                                      onChanged: theme.setDark,
                                    )
                                  else
                                    const Icon(Icons.chevron_right, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
