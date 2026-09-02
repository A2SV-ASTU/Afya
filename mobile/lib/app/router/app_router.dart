import '../../features/vitals_sync/presentation/bloc/vitals_sync_bloc.dart';
import '../../features/vitals_sync/presentation/screens/vitals_history_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../core/di/injection_container.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';

import '../../features/clinical_history/presentation/cubit/appointments_cubit.dart';
import '../../features/clinical_history/presentation/cubit/encounter_detail_cubit.dart';
import '../../features/clinical_history/presentation/screens/appointments_screen.dart';
import '../../features/clinical_history/presentation/screens/encounter_detail_screen.dart';
import '../../features/clinical_history/presentation/screens/history_timeline_screen.dart';

import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../view/app_shell.dart';
import '../view/placeholder_screens.dart';
import 'route_paths.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _dashboardNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'dashboard');
final GlobalKey<NavigatorState> _historyNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'history');
final GlobalKey<NavigatorState> _chatNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'chat');
final GlobalKey<NavigatorState> _accessNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'access');
final GlobalKey<NavigatorState> _profileNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'profile');

@lazySingleton
class AppRouter {
  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    routes: [
      // Splash & Auth Routes
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: RoutePaths.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),

      // Email Deep-Link Route for Access Consent
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.accessDecision,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AccessDecisionPlaceholderScreen(id: id);
        },
      ),

      // Encounter Detail Route (Root Navigator for full-screen overlay)
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.encounterDetail,
        builder: (context, state) {
          final encounterId = state.pathParameters['id'] ?? '';
          return BlocProvider(
            create: (context) => sl<EncounterDetailCubit>(),
            child: EncounterDetailScreen(encounterId: encounterId),
          );
        },
      ),

      // Standalone Appointments Route
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.appointments,
        builder: (context, state) {
          return BlocProvider(
            create: (context) => sl<AppointmentsCubit>(),
            child: const AppointmentsScreen(patientId: 'me'),
          );
        },
      ),

      // Persistent Tab Navigation Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _dashboardNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.dashboard,
                builder: (context, state) => BlocProvider(
                  create: (context) => sl<DashboardCubit>()..loadDashboard(),
                  child: const DashboardScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
  navigatorKey: _historyNavigatorKey,
  routes: [
    GoRoute(
      path: RoutePaths.history,
      builder: (context, state) => BlocProvider(
        create: (context) => sl<VitalsSyncBloc>(),
        child: const VitalsHistoryScreen(),
      ),
    ),
  ],
),
          StatefulShellBranch(
            navigatorKey: _chatNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.chat,
                builder: (context, state) => const ChatPlaceholderScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _accessNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.access,
                builder: (context, state) => const AccessPlaceholderScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
