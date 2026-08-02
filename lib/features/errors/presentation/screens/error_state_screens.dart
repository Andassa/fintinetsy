import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/circular_icon_button.dart';
import '../../../../core/widgets/primary_button.dart';

class ErrorStateScreen extends StatelessWidget {
  const ErrorStateScreen({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.secondaryIcon = Icons.usb,
  });

  final String imageAsset;
  final String title;
  final String subtitle;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final IconData secondaryIcon;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final imageW = (width * 0.62).clamp(200.0, 320.0);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: ResponsiveConstrained(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, bottom + 12),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: CircularIconButton(
                    icon: Icons.arrow_back,
                    backgroundColor: const Color(0xFFD1D1D6),
                    iconColor: AppColors.white,
                    onPressed: () => context.pop(),
                  ),
                ),
                const Spacer(flex: 2),
                Image.asset(imageAsset, width: imageW, fit: BoxFit.contain),
                const SizedBox(height: 28),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                ),
                if (secondaryLabel != null) ...[
                  const SizedBox(height: 22),
                  Material(
                    color: const Color(0xFFFFE8E8),
                    borderRadius: BorderRadius.circular(28),
                    child: InkWell(
                      onTap: onSecondary,
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: const Color(0xFFFFD1D1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(secondaryIcon,
                                color: AppColors.error, size: 18),
                            const SizedBox(width: 10),
                            Text(
                              secondaryLabel!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                const Spacer(flex: 3),
                PrimaryButton(
                  label: primaryLabel,
                  style: PrimaryButtonStyle.orange,
                  onPressed: onPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ErrorStateScreen(
      imageAsset: AppAssets.noInternet,
      title: 'Not Found',
      subtitle: "It seems you don't have internet",
      secondaryLabel: 'Refresh or try again',
      onSecondary: () {},
      primaryLabel: 'Take me home',
      onPrimary: () => context.goNamed(RouteNames.home),
    );
  }
}

class PermissionDeniedScreen extends StatelessWidget {
  const PermissionDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ErrorStateScreen(
      imageAsset: AppAssets.trafficCone,
      title: 'Not Found',
      subtitle: "Hey you don't have permission",
      secondaryLabel: 'Contact Support',
      onSecondary: () {},
      primaryLabel: 'Take me home',
      onPrimary: () => context.goNamed(RouteNames.home),
    );
  }
}

class GoProGateScreen extends StatelessWidget {
  const GoProGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ErrorStateScreen(
      imageAsset: AppAssets.proPadlock,
      title: 'Not Found',
      subtitle:
          'Unfortunately, this feature is only available for pro users. Go Pro, Now!',
      primaryLabel: 'Go Pro Now',
      onPrimary: () => context.goNamed(RouteNames.home),
    );
  }
}
