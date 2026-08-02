import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/app_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FintinetsyApp());
}

class FintinetsyApp extends StatelessWidget {
  const FintinetsyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: buildAppProviders(),
      child: MaterialApp.router(
        title: 'Uplift.ai',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: appRouter,
      ),
    );
  }
}
