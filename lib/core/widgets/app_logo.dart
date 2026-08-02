import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_assets.dart';
import '../theme/app_colors.dart';

enum AppLogoVariant { white, orangeBadge, orangeOnTransparent }

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 72,
    this.variant = AppLogoVariant.white,
  });

  final double size;
  final AppLogoVariant variant;

  @override
  Widget build(BuildContext context) {
    final logo = SvgPicture.asset(
      AppAssets.logo,
      width: size,
      height: size,
      colorFilter: variant == AppLogoVariant.orangeOnTransparent
          ? null
          : const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
    );

    if (variant == AppLogoVariant.orangeBadge) {
      return Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.18),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(size * 0.22),
        ),
        child: SvgPicture.asset(
          AppAssets.logo,
          colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
        ),
      );
    }

    return logo;
  }
}
