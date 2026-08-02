import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/usecases/request_password_reset_usecase.dart';

class PasswordSentScreen extends StatefulWidget {
  const PasswordSentScreen({super.key, required this.email});

  final String email;

  @override
  State<PasswordSentScreen> createState() => _PasswordSentScreenState();
}

class _PasswordSentScreenState extends State<PasswordSentScreen> {
  bool _resending = false;

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      await context.read<RequestPasswordResetUseCase>()(
        methodId: 'reset_email',
        email: widget.email,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password resent successfully')),
      );
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.padlockWithKey,
            fit: BoxFit.cover,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.white.withValues(alpha: 0.45)),
          ),
          SafeArea(
            child: ResponsiveConstrained(
              child: Padding(
                padding: Responsive.pagePadding(context),
                child: Column(
                  children: [
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.successSoft,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: AppColors.success,
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Password Sent!',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text.rich(
                            TextSpan(
                              text: "We've sent the password to ",
                              style: theme.textTheme.bodyLarge,
                              children: [
                                TextSpan(
                                  text: '${widget.email}. ',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      'Resend if the password is not received! 🔥',
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          PrimaryButton(
                            label: 'Re-Send Password',
                            icon: Icons.lock_outline,
                            isLoading: _resending,
                            onPressed: _resend,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Material(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: () => context.goNamed(RouteNames.signIn),
                        borderRadius: BorderRadius.circular(14),
                        child: const SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(Icons.close),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
