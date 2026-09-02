import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:afyamind_mobile/app/router/route_paths.dart';
import 'package:afyamind_mobile/app/view/app_shell.dart';

void main() {
  Widget createRouterApp() {
    final router = GoRouter(
      initialLocation: RoutePaths.dashboard,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              AppShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RoutePaths.dashboard,
                  builder: (context, state) => const Scaffold(
                    body: Center(child: Text('Home Screen')),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RoutePaths.history,
                  builder: (context, state) => const Scaffold(
                    body: Center(child: Text('History Screen')),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RoutePaths.chat,
                  builder: (context, state) => const Scaffold(
                    body: Center(child: Text('Chat Screen')),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RoutePaths.access,
                  builder: (context, state) => const Scaffold(
                    body: Center(child: Text('Access Screen')),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RoutePaths.profile,
                  builder: (context, state) => const Scaffold(
                    body: Center(child: Text('Profile Screen')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  group('AppShell 5-Item Navigation Bar Tests', () {
    testWidgets('renders exactly 5 navigation items with correct labels',
        (tester) async {
      await tester.pumpWidget(createRouterApp());
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Access'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Home Screen'), findsOneWidget);
    });

    testWidgets('renders icons for all 5 navigation items', (tester) async {
      await tester.pumpWidget(createRouterApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.access_time_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
    });

    testWidgets('tapping navigation item navigates to destination branch',
        (tester) async {
      await tester.pumpWidget(createRouterApp());
      await tester.pumpAndSettle();

      // Tap History
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      expect(find.text('History Screen'), findsOneWidget);

      // Tap Chat
      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();
      expect(find.text('Chat Screen'), findsOneWidget);

      // Tap Access
      await tester.tap(find.text('Access'));
      await tester.pumpAndSettle();
      expect(find.text('Access Screen'), findsOneWidget);

      // Tap Profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Profile Screen'), findsOneWidget);

      // Tap Home
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Home Screen'), findsOneWidget);
    });
  });
}
