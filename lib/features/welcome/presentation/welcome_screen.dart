import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/auth_text_link.dart';
import '../../../core/widgets/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              AppAssets.welcomeBackground,
              fit: BoxFit.cover,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.78),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
            SafeArea(
              child: ResponsiveConstrained(
                child: Padding(
                  padding: Responsive.pagePadding(context),
                  child: Column(
                    children: [
                      const Spacer(flex: 3),
                      const AppLogo(size: 64, variant: AppLogoVariant.white),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome To\nUplift.ai',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 34,
                              height: 1.15,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your personal fitness AI Assistant 🤖',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.white.withValues(alpha: 0.9),
                              fontSize: 16,
                            ),
                      ),
                      const Spacer(flex: 2),
                      PrimaryButton(
                        label: 'Get Started',
                        style: PrimaryButtonStyle.orange,
                        onPressed: () => context.goNamed(RouteNames.signUp),
                      ),
                      const SizedBox(height: 18),
                      AuthTextLink(
                        prefix: 'Already have account? ',
                        linkLabel: 'Sign In',
                        onTap: () => context.goNamed(RouteNames.signIn),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
