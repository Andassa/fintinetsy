import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../stats/domain/entities/stats_entities.dart';
import '../../../stats/domain/repositories/stats_repository.dart';

class DirectionsMapScreen extends StatefulWidget {
  const DirectionsMapScreen({super.key});

  @override
  State<DirectionsMapScreen> createState() => _DirectionsMapScreenState();
}

class _DirectionsMapScreenState extends State<DirectionsMapScreen> {
  DirectionsData? _data;

  @override
  void initState() {
    super.initState();
    context.read<StatsRepository>().getDirections().then((v) {
      if (mounted) setState(() => _data = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    if (data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            painter: _MapPainter(),
            child: const SizedBox.expand(),
          ),
          Positioned(
            left: MediaQuery.sizeOf(context).width * 0.55,
            top: MediaQuery.sizeOf(context).height * 0.28,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Text(
                data.arrivalLabel,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, bottom + 12),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            data.thumbnailAsset,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.turn_right,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    data.instruction,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data.address,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: AppColors.primary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    data.distanceLeft,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.location_on, color: AppColors.primary),
                            SizedBox(width: 12),
                            Icon(Icons.view_in_ar_outlined,
                                color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Material(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          onTap: () =>
                              context.pushNamed(RouteNames.joggingCompleted),
                          borderRadius: BorderRadius.circular(18),
                          child: const SizedBox(
                            width: 72,
                            height: 56,
                            child: Icon(Icons.close, color: AppColors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF2F2F2),
    );

    final road = Paint()
      ..color = AppColors.white
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.7)
      ..lineTo(size.width * 0.45, size.height * 0.55)
      ..lineTo(size.width * 0.7, size.height * 0.35);
    canvas.drawPath(path, road);

    final route = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, route);

    // start marker
    final start = Offset(size.width * 0.2, size.height * 0.7);
    canvas.drawCircle(start, 22, Paint()..color = AppColors.primary);
    canvas.drawCircle(start, 10, Paint()..color = AppColors.white);

    // end marker
    final end = Offset(size.width * 0.7, size.height * 0.35);
    canvas.drawCircle(
      end,
      18,
      Paint()..color = AppColors.primary.withValues(alpha: 0.25),
    );
    canvas.drawCircle(end, 8, Paint()..color = AppColors.primary);

    // fake street labels
    final labels = ['2nd Ave', '13th St', 'ASHOK NAGAR'];
    final positions = [
      Offset(size.width * 0.1, size.height * 0.45),
      Offset(size.width * 0.55, size.height * 0.62),
      Offset(size.width * 0.65, size.height * 0.2),
    ];
    for (var i = 0; i < labels.length; i++) {
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, positions[i]);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
