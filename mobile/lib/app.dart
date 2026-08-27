import 'package:flutter/material.dart';
import 'app/router/app_router.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';

class AfyaMindApp extends StatelessWidget {
  const AfyaMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = sl<AppRouter>();

    return MaterialApp.router(
      title: 'AfyaMind',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter.router,
    );
  }
}
