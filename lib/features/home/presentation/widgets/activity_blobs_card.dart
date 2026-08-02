import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/home_dashboard.dart';

class ActivityBlobsCard extends StatelessWidget {
  const ActivityBlobsCard({
    super.key,
    required this.blobs,
    this.onTap,
  });

  final List<HomeActivityBlob> blobs;
  final VoidCallback? onTap;

  Color _parse(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final height = MediaQuery.sizeOf(context).width >= 600 ? 200.0 : 168.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(24),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: blobs.map((blob) {
                final w = constraints.maxWidth * blob.widthFactor;
                final h = constraints.maxHeight * blob.heightFactor;
                final isLight = blob.colorHex.toUpperCase() == '#EBEBEB';
                return Align(
                  alignment: Alignment(blob.alignment.x, blob.alignment.y),
                  child: Transform.rotate(
                    angle: blob.rotationDeg * math.pi / 180,
                    child: Container(
                      width: w,
                      height: h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _parse(blob.colorHex),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        blob.hoursLabel,
                        style: TextStyle(
                          color: isLight ? AppColors.black : AppColors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: w < 70 ? 16 : 22,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
