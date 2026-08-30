import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/features/access_requests/presentation/bloc/access_request_cubit.dart';
import 'package:afyamind_mobile/features/access_requests/presentation/bloc/access_request_state.dart';
import 'package:afyamind_mobile/features/access_requests/presentation/widgets/revoke_grant_dialog.dart';

class MockAccessRequestCubit extends MockCubit<AccessRequestState>
    implements AccessRequestCubit {}

void main() {
  late MockAccessRequestCubit mockCubit;

  setUp(() {
    mockCubit = MockAccessRequestCubit();
    registerFallbackValue(const AccessRequestInitial());
    when(() => mockCubit.fetchActiveGrants()).thenAnswer((_) async {});
    when(() => mockCubit.revokeGrant(any())).thenAnswer((_) async {});
  });

  tearDown(() {
    mockCubit.close();
  });

  Widget buildTestApp({String? clinicName, String? clinicId}) {
    return MaterialApp(
      home: BlocProvider<AccessRequestCubit>.value(
        value: mockCubit,
        child: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => RevokeGrantDialog.show(
                context: context,
                clinicName: clinicName ?? 'Clinic A',
                clinicId: clinicId ?? 'c1',
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
  }

  group('RevokeGrantDialog', () {
    testWidgets('should display dialog with correct message',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(clinicName: 'Clinic A'));
      await tester.pump();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.text(
            'Are you sure you want to revoke medical record access for Clinic A?'),
        findsOneWidget,
      );
    });

    testWidgets('should display Cancel and Revoke buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Revoke'), findsOneWidget);
    });

    testWidgets('should close dialog when Cancel is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('should call revokeGrant and close dialog when Revoke is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(clinicId: 'c1'));
      await tester.pump();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Revoke'));
      await tester.pumpAndSettle();

      verify(() => mockCubit.revokeGrant('c1')).called(1);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('should show dialog title "Revoke Access"',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Revoke Access'), findsWidgets);
    });
  });
}
