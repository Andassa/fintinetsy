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
import '../../../../core/widgets/error_message_box.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/usecases/sign_up_usecase.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController =
      TextEditingController(text: 'elementary221b@gmail.com');
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<SignUpUseCase>()(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmController.text,
      );
      if (!mounted) return;
      context.goNamed(RouteNames.assessmentAge);
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() => _error = msg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final passwordsMismatch = _confirmController.text.isNotEmpty &&
        _passwordController.text != _confirmController.text;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.sizeOf(context).height * 0.26,
            child: Opacity(
              opacity: 0.3,
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
                    const SizedBox(height: 20),
                    const AppLogo(
                      size: 56,
                      variant: AppLogoVariant.orangeBadge,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Sign Up For Free',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Quickly make your account in 1 minute',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    AppTextField(
                      label: 'Email Address',
                      controller: _emailController,
                      prefixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Password',
                      controller: _passwordController,
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      onChanged: (_) => setState(() {}),
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Confirm Password',
                      controller: _confirmController,
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscureConfirm,
                      hasError: passwordsMismatch || _error != null,
                      onChanged: (_) => setState(() {}),
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _obscureConfirm = !_obscureConfirm,
                        ),
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      ErrorMessageBox(message: _error!),
                    ],
                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: 'Sign Up',
                      isLoading: _loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 24),
                    AuthTextLink(
                      prefix: 'Already have an account? ',
                      linkLabel: 'Sign In.',
                      onTap: () => context.goNamed(RouteNames.signIn),
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
