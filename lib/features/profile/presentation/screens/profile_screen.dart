import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_image.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    context.read<ProfileRepository>().getProfile().then((v) {
      if (mounted) setState(() => _profile = v);
    });
  }

  Color _parse(String hex) =>
      Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));

  @override
  Widget build(BuildContext context) {
    final p = _profile;
    if (p == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: ResponsiveConstrained(
        child: Stack(
          children: [
            ListView(
              padding: EdgeInsets.only(bottom: bottom + 90),
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(30),
                      ),
                      child: AppImage(
                        p.coverAsset,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        fallback: AppAssets.profileCover,
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.paddingOf(context).top + 8,
                      left: 16,
                      child: Material(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () => context.pop(),
                          borderRadius: BorderRadius.circular(12),
                          child: const SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(Icons.arrow_back, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -42,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: AppColors.surfaceAlt,
                          child: ClipOval(
                            child: AppImage(
                              p.avatarAsset,
                              width: 92,
                              height: 92,
                              fit: BoxFit.cover,
                              fallback: AppAssets.womanRunning,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 56),
                Text(
                  p.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${p.location}    ${p.membership}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.sports_gymnastics,
                              color: AppColors.primary),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Uplift Score',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'Weekly',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 160,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: p.weeklyScores.map((s) {
                            final highlight = s.day == p.highlightDay;
                            final h = ((s.score - 55) / 50).clamp(0.25, 1.0);
                            return Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (highlight)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 6),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.black,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${s.score}',
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  Container(
                                    height: 110 * h,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: highlight
                                          ? AppColors.black
                                          : AppColors.surfaceAlt,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    s.day,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: p.stats.map((s) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.circle,
                                  size: 12, color: _parse(s.colorHex)),
                              const SizedBox(height: 12),
                              Text(
                                s.value,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                s.label,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: bottom + 12,
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () => context.goNamed(RouteNames.home),
                          icon: const Icon(Icons.home_outlined),
                        ),
                        const SizedBox(width: 48),
                        IconButton(
                          onPressed: () =>
                              context.pushNamed(RouteNames.accountSettings),
                          icon: const Icon(Icons.settings_outlined),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => context.pushNamed(RouteNames.aiCoachIntro),
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surfaceAlt,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),
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
