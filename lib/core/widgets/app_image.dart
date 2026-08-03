import 'package:flutter/material.dart';

import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/media_resolver.dart';

/// Loads a bundled asset or a remote URL.
/// Prefer paths already resolved by [MediaResolver] from HTTP repositories.
class AppImage extends StatelessWidget {
  const AppImage(
    this.source, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.fallback,
  });

  final String source;
  final BoxFit fit;
  final double? width;
  final double? height;
  final String? fallback;

  static bool isNetwork(String path) =>
      path.startsWith('http://') || path.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final path = MediaResolver.resolve(
      source,
      fallback: fallback ?? AppAssets.workoutStrength,
    );

    if (isNetwork(path)) {
      return Image.network(
        path,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, _, _) => Image.asset(
          fallback ?? AppAssets.workoutStrength,
          fit: fit,
          width: width,
          height: height,
        ),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return ColoredBox(
            color: AppColors.surfaceAlt,
            child: SizedBox(
              width: width,
              height: height,
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          );
        },
      );
    }

    return Image.asset(
      path,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, _, _) => Image.asset(
        fallback ?? AppAssets.workoutStrength,
        fit: fit,
        width: width,
        height: height,
      ),
    );
  }
}
