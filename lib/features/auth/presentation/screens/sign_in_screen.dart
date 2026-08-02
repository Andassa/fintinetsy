import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_text_link.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/auth_credentials.dart';
import '../../domain/usecases/sign_in_usecase.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController =
      TextEditingController(text: 'elementary221b@gmail.com');
  final _passwordController = TextEditingController(text: 'uplift2024');
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<SignInUseCase>()(
        AuthCredentials(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
      if (!mounted) return;
      context.goNamed(RouteNames.assessmentAge);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.sizeOf(context).height * 0.28,
            child: Opacity(
              opacity: 0.35,
              child: Image.asset(
                AppAssets.welcomeBackground,
                fit: BoxFit.cover,
                color: Colors.white,
                colorBlendMode: BlendMode.softLight,
              ),
            ),
          ),
          SafeArea(
            child: ResponsiveConstrained(
              child: SingleChildScrollView(
                padding: Responsive.pagePadding(context),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    const AppLogo(
                      size: 56,
                      variant: AppLogoVariant.orangeBadge,
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Sign In To Uplift',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Let's personalize your fitness with AI",
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    AppTextField(
                      label: 'Email Address',
                      controller: _emailController,
                      prefixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      label: 'Password',
                      controller: _passwordController,
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscure,
                      autofillHints: const [AutofillHints.password],
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: AppColors.error)),
                    ],
                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: 'Sign In',
                      isLoading: _loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialButton(icon: Icons.camera_alt_outlined, onTap: () {}),
                        const SizedBox(width: 14),
                        _SocialButton(icon: Icons.facebook, onTap: () {}),
                        const SizedBox(width: 14),
                        _SocialButton(icon: Icons.business, onTap: () {}),
                      ],
                    ),
                    const SizedBox(height: 28),
                    AuthTextLink(
                      prefix: "Don't have an account? ",
                      linkLabel: 'Sign Up.',
                      onTap: () => context.goNamed(RouteNames.signUp),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => context.goNamed(RouteNames.resetPassword),
                      child: const Text(
                        'Forgot Password',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.socialBorder),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}
