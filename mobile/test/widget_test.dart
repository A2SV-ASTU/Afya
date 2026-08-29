import 'package:afyamind_mobile/app/router/app_router.dart';
import 'package:afyamind_mobile/core/di/injection_container.dart';
import 'package:afyamind_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:afyamind_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:afyamind_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    if (!sl.isRegistered<AppRouter>()) {
      sl.registerLazySingleton<AppRouter>(() => AppRouter());
    }
    if (!sl.isRegistered<AuthBloc>()) {
      sl.registerLazySingleton<AuthBloc>(() => mockAuthBloc);
    }
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('App renders splash route initial screen', (tester) async {
    when(() => mockAuthBloc.state).thenReturn(const Unauthenticated());

    final appRouter = AppRouter();

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: MaterialApp.router(
          routerConfig: appRouter.router,
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Afya'), findsWidgets);
  });
}
