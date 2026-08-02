import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/search_entities.dart';

class SearchResultTile extends StatelessWidget {
  const SearchResultTile({super.key, required this.item, this.onTap});

  final SearchResultItem item;
  final VoidCallback? onTap;

  Color get _iconBg {
    if (item.iconKey == 'notifications') {
      return AppColors.white;
    }
    final hex = item.iconColorHex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  IconData get _icon {
    return switch (item.iconKey) {
      'notifications' => Icons.notifications_none,
      'directions_run' => Icons.directions_run,
      'chat_bubble' => Icons.chat_bubble_outline,
      'fitness_center' => Icons.fitness_center,
      'play_arrow' => Icons.play_arrow_rounded,
      'cloud' => Icons.cloud_outlined,
      _ => Icons.search,
    };
  }

  @override
  Widget build(BuildContext context) {
    final iconFg = item.iconKey == 'notifications'
        ? AppColors.black
        : AppColors.white;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _iconBg,
                      borderRadius: BorderRadius.circular(14),
                      border: item.iconKey == 'notifications'
                          ? Border.all(color: AppColors.border)
                          : null,
                    ),
                    child: Icon(_icon, color: iconFg),
                  ),
                  if (item.badge != null && item.iconKey == 'notifications')
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
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    if (item.progress != null) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: item.progress,
                          minHeight: 6,
                          backgroundColor: AppColors.surfaceAlt,
                          color: const Color(0xFF2F69FF),
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${item.matchPercent}% Match',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.badge != null && item.iconKey != 'notifications')
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
                    item.badge!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              if (item.checked)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.charcoal,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
