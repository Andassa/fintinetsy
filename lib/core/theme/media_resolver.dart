import '../theme/app_assets.dart';

/// Maps API / CDN media URLs to bundled Flutter assets.
///
/// The backend seeds use placeholder hosts like `https://cdn.uplift.ai/...`
/// which are not real files. Every HTTP repository should run image fields
/// through [resolve] so screens always get a valid `assets/...` path.
abstract final class MediaResolver {
  static String resolve(String? raw, {String fallback = AppAssets.workoutStrength}) {
    if (raw == null || raw.trim().isEmpty) return fallback;

    final value = raw.trim();

    // Already a local asset.
    if (value.startsWith('assets/')) return value;

    // Real remote URL that is not our fake CDN — keep it for Image.network.
    if ((value.startsWith('http://') || value.startsWith('https://')) &&
        !value.contains('cdn.uplift.ai')) {
      return value;
    }

    final path = value.toLowerCase();

    if (path.contains('salad') ||
        path.contains('meal') ||
        path.contains('food') ||
        path.contains('diet') ||
        path.contains('bowl') ||
        path.contains('power-bowl')) {
      return AppAssets.powerBowl;
    }
    if (path.contains('avocado') || path.contains('egg')) {
      return AppAssets.saladPlate;
    }
    if (path.contains('biryani')) return AppAssets.biryani;

    if (path.contains('coach') || path.contains('ai/') || path.contains('/ai')) {
      return AppAssets.aiCoachHero;
    }
    if (path.contains('robot')) return AppAssets.aiRobot;

    if (path.contains('browse')) return AppAssets.workoutBrowseHero;
    if (path.contains('complete')) return AppAssets.workoutCompleteHero;
    if (path.contains('preview') || path.contains('back-hero')) {
      return AppAssets.workoutPreviewHero;
    }
    if (path.contains('thumb') || path.contains('header') || path.contains('strength')) {
      return AppAssets.workoutStrength;
    }
    if (path.contains('workout') || path.contains('upper')) {
      return AppAssets.workoutStrength;
    }

    if (path.contains('basket') || path.contains('heart') || path.contains('stats')) {
      return AppAssets.basketballPlayer;
    }

    if (path.contains('avatar') || path.contains('profile') || path.contains('user')) {
      return AppAssets.womanRunning;
    }
    if (path.contains('cover') || path.contains('welcome') || path.contains('equipment')) {
      return AppAssets.profileCover;
    }

    if (path.contains('padlock') || path.contains('lock')) return AppAssets.padlock;
    if (path.contains('man') || path.contains('jogger')) return AppAssets.manRunning;
    if (path.contains('woman') || path.contains('running')) {
      return AppAssets.womanRunning;
    }

    return fallback;
  }
}
