import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/di/app_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final binding = await buildAppBinding();
  final router = createAppRouter(binding.authSession);
  runApp(FintinetsyApp(binding: binding, router: router));
}

class FintinetsyApp extends StatelessWidget {
  const FintinetsyApp({
    super.key,
    required this.binding,
    required this.router,
  });

  final AppBinding binding;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: binding.providers,
      child: Consumer<ThemeController>(
        builder: (context, theme, _) {
          return MaterialApp.router(
            title: 'Uplift.ai',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: theme.mode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
