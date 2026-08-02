import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/widgets/circular_icon_button.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/reset_method_entity.dart';
import '../../domain/usecases/get_reset_methods_usecase.dart';
import '../../domain/usecases/request_password_reset_usecase.dart';
import '../widgets/reset_method_card.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  List<ResetMethodEntity> _methods = const [];
  String? _selectedId;
  bool _loading = true;
  bool _submitting = false;

  static const _demoEmail = '221b@gmail.com';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final methods = await context.read<GetResetMethodsUseCase>()();
    if (!mounted) return;
    setState(() {
      _methods = methods;
      _selectedId = methods.isNotEmpty ? methods.first.id : null;
      _loading = false;
    });
  }

  Future<void> _submit() async {
    if (_selectedId == null) return;
    setState(() => _submitting = true);
    try {
      final result = await context.read<RequestPasswordResetUseCase>()(
        methodId: _selectedId!,
        email: _demoEmail,
      );
      if (!mounted) return;
      context.goNamed(
        RouteNames.passwordSent,
        queryParameters: {'email': result.email},
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ResponsiveConstrained(
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -10,
                child: Opacity(
                  opacity: 0.85,
                  child: Image.asset(
                    AppAssets.padlock,
                    width: Responsive.isTabletOrLarger(context) ? 220 : 180,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Padding(
                padding: Responsive.pagePadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircularIconButton(
                      icon: Icons.chevron_left,
                      onPressed: () => context.goNamed(RouteNames.signIn),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Reset Password',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Select what method you'd like to reset.",
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 28),
                    if (_loading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ..._methods.map(
                        (method) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ResetMethodCard(
                            method: method,
                            selected: method.id == _selectedId,
                            onTap: () =>
                                setState(() => _selectedId = method.id),
                          ),
                        ),
                      ),
                    const Spacer(),
                    PrimaryButton(
                      label: 'Reset Password',
                      isLoading: _submitting,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
