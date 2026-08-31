import 'package:afyamind_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:afyamind_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:afyamind_mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:afyamind_mobile/features/auth/presentation/screens/sign_up_screen.dart';
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

  testWidgets('SignUpScreen renders title and required input fields', (tester) async {
    tester.view.physicalSize = const Size(1080, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    when(() => mockAuthBloc.state).thenReturn(const Unauthenticated());

    await tester.pumpWidget(buildTestableWidget(const SignUpScreen()));

    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('First Name'), findsOneWidget);
    expect(find.text('Last Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Register Account'), findsOneWidget);
  });

  testWidgets('SignUpScreen validates empty fields on submit', (tester) async {
    tester.view.physicalSize = const Size(1080, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    when(() => mockAuthBloc.state).thenReturn(const Unauthenticated());

    await tester.pumpWidget(buildTestableWidget(const SignUpScreen()));

    await tester.tap(find.text('Register Account'));
    await tester.pumpAndSettle();

    expect(find.text('First name is required'), findsOneWidget);
    expect(find.text('Last name is required'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Phone number is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });
}
