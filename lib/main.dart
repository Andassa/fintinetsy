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

  // 1) Local Hive store for offline GET payloads + ETags
  await Hive.initFlutter();

  // 2) DI + AuthSession.bootstrap() (awaits secure token restore)
  final binding = await buildAppBinding();

  // 3) Router only after auth session is ready
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
