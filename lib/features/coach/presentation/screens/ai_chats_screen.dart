import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/circular_icon_button.dart';
import '../../domain/entities/coach_entities.dart';
import '../../domain/repositories/coach_repository.dart';

class AiChatsScreen extends StatefulWidget {
  const AiChatsScreen({super.key});

  @override
  State<AiChatsScreen> createState() => _AiChatsScreenState();
}

class _AiChatsScreenState extends State<AiChatsScreen> {
  AiChatsPageData? _data;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    context.read<CoachRepository>().getChats().then((v) {
      if (mounted) setState(() => _data = v);
    });
  }

  Color _parse(String hex) =>
      Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));

  IconData _icon(String key) => switch (key) {
        'score' => Icons.shield_outlined,
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
                  'My AI Chats',
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
                      for (var i = 0; i < 3; i++)
                        Expanded(
                          child: Material(
                            color: _tab == i
                                ? const Color(0xFF3A3A3A)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () => setState(() => _tab = i),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  ['AI', 'Archived', 'Deleted'][i],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.white.withValues(
                                      alpha: _tab == i ? 1 : 0.55,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
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
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Earlier Today',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.pushNamed(RouteNames.aiCoachHub),
                        child: const Text(
                          'See all',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...data.items.map((item) {
                    final isWhite = item.colorHex.toUpperCase() == '#FFFFFF';
                    return GestureDetector(
                      onTap: () => context.pushNamed(RouteNames.aiChatThread),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEDED),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: _parse(item.colorHex),
                                    borderRadius: BorderRadius.circular(14),
                                    border: isWhite
                                        ? Border.all(color: AppColors.border)
                                        : null,
                                  ),
                                  child: Icon(
                                    _icon(item.iconKey),
                                    color: isWhite
                                        ? AppColors.black
                                        : AppColors.white,
                                  ),
                                ),
                                if (item.badge != null)
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
                                        item.badge!,
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
                                    item.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.subtitle,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 20),
                          ],
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
