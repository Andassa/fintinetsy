import 'package:flutter/material.dart';

enum AppBreakpoint { mobile, tablet, desktop }

abstract final class Responsive {
  static const double tabletMin = 600;
  static const double desktopMin = 1024;

  static AppBreakpoint of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= desktopMin) return AppBreakpoint.desktop;
    if (width >= tabletMin) return AppBreakpoint.tablet;
    return AppBreakpoint.mobile;
  }

  static bool isTabletOrLarger(BuildContext context) =>
      of(context) != AppBreakpoint.mobile;

  static double contentMaxWidth(BuildContext context) {
    switch (of(context)) {
      case AppBreakpoint.mobile:
        return double.infinity;
      case AppBreakpoint.tablet:
        return 520;
      case AppBreakpoint.desktop:
        return 480;
    }
  }

  static EdgeInsets pagePadding(BuildContext context) {
    final isWide = isTabletOrLarger(context);
    return EdgeInsets.symmetric(
      horizontal: isWide ? 48 : 24,
      vertical: isWide ? 32 : 16,
    );
  }
}

class ResponsiveConstrained extends StatelessWidget {
  const ResponsiveConstrained({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = Responsive.contentMaxWidth(context);
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: child,
          ),
        );
      },
    );
  }
}
