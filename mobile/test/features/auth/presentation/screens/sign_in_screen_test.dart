import 'package:afyamind_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:afyamind_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:afyamind_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:afyamind_mobile/features/auth/presentation/screens/sign_in_screen.dart';
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
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: child,
      ),
    );
  }

  testWidgets('SignInScreen renders title, input fields, and action buttons', (tester) async {
    when(() => mockAuthBloc.state).thenReturn(const Unauthenticated());

    await tester.pumpWidget(buildTestableWidget(const SignInScreen()));

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Unlock with PIN'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
  });

  testWidgets('Shows validation errors when empty form submitted', (tester) async {
    when(() => mockAuthBloc.state).thenReturn(const Unauthenticated());

    await tester.pumpWidget(buildTestableWidget(const SignInScreen()));

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Email address is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });
}
