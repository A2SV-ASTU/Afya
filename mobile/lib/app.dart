import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/router/app_router.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

class AfyaMindApp extends StatelessWidget {
  const AfyaMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = sl<AppRouter>();

    return BlocProvider<AuthBloc>(
      create: (context) => sl<AuthBloc>(),
      child: MaterialApp.router(
        title: 'Afya',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter.router,
      ),
    );
  }
}

