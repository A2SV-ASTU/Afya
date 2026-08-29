import 'package:afyamind_mobile/features/auth/presentation/widgets/pin_login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PinLoginView renders title, subtitle, keypad numbers, and switch button', (tester) async {
    String? submittedPin;
    bool switchPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PinLoginView(
            onSubmitPin: (pin) => submittedPin = pin,
            onSwitchToPasswordLogin: () => switchPressed = true,
          ),
        ),
      ),
    );

    expect(find.text('Afya'), findsOneWidget);
    expect(find.text('Enter your PIN'), findsOneWidget);
    expect(find.text('No internet connection. Enter your PIN to continue using Afya.'), findsOneWidget);
    expect(find.text('Sign in with internet'), findsOneWidget);

    // Tap digits 1, 2, 3, 4
    await tester.tap(find.text('1'));
    await tester.pump();
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('3'));
    await tester.pump();
    await tester.tap(find.text('4'));
    await tester.pump();

    expect(submittedPin, equals('1234'));

    // Tap switch button
    await tester.tap(find.text('Sign in with internet'));
    await tester.pump();
    expect(switchPressed, isTrue);
  });
}
