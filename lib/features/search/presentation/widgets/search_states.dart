import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

/// Animated loader using the provided SVG asset (acts as GIF replacement).
class SearchLoadingIndicator extends StatefulWidget {
  const SearchLoadingIndicator({super.key, this.size = 96});

  final double size;

  @override
  State<SearchLoadingIndicator> createState() => _SearchLoadingIndicatorState();
}

class _SearchLoadingIndicatorState extends State<SearchLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = Curves.easeInOut.transform(_controller.value);
            return Transform.translate(
              offset: Offset(0, -6 + 12 * t),
              child: Transform.scale(
                scale: 0.92 + 0.08 * t,
                child: child,
              ),
            );
          },
          child: SvgPicture.asset(
            AppAssets.searchLoading,
            width: widget.size,
            height: widget.size * 0.89,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Loading...',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF404040),
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class SearchNotFoundView extends StatelessWidget {
  const SearchNotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final imageW = width.clamp(280.0, 420.0) * 0.62;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppAssets.searchNotFound,
            width: imageW,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          Text(
            'Not Found',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Whoops Coach U can’t fin this page :(',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
