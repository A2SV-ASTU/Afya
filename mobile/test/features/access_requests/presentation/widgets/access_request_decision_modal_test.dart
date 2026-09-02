import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/features/access_requests/domain/entities/access_request_entity.dart';
import 'package:afyamind_mobile/features/access_requests/presentation/bloc/access_request_cubit.dart';
import 'package:afyamind_mobile/features/access_requests/presentation/bloc/access_request_state.dart';
import 'package:afyamind_mobile/features/access_requests/presentation/widgets/access_request_banner.dart';
import 'package:afyamind_mobile/features/access_requests/presentation/widgets/access_request_decision_modal.dart';

class MockAccessRequestCubit extends MockCubit<AccessRequestState>
    implements AccessRequestCubit {}

AccessRequestEntity tActiveRequest({DateTime? expiresAt}) {
  return AccessRequestEntity(
    id: '1',
    clinicId: 'c1',
    clinicName: 'Clinic A',
    doctorName: 'Dr. Smith',
    reason: 'Checkup',
    status: 'pending',
    expiresAt:
        expiresAt ?? DateTime.now().toUtc().add(const Duration(minutes: 5)),
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  late MockAccessRequestCubit mockCubit;

  setUp(() {
    mockCubit = MockAccessRequestCubit();
    registerFallbackValue(const AccessRequestInitial());
    // Stub the async methods to return a completed future
    when(() => mockCubit.approveRequest(any()))
        .thenAnswer((_) async {});
    when(() => mockCubit.denyRequest(any()))
        .thenAnswer((_) async {});
  });

  tearDown(() {
    mockCubit.close();
  });

  Widget buildTestModal({
    AccessRequestState? cubitState,
    int secondsRemaining = 300,
  }) {
    final state = cubitState ??
        AccessRequestActive(
          request: tActiveRequest(),
          secondsRemaining: secondsRemaining,
        );
    when(() => mockCubit.state).thenReturn(state);
    whenListen(
      mockCubit,
      Stream<AccessRequestState>.fromIterable([state]),
      initialState: state,
    );

    return MaterialApp(
      home: BlocProvider<AccessRequestCubit>.value(
        value: mockCubit,
        child: Scaffold(
          body: AccessRequestDecisionModal(
            request: tActiveRequest(),
            secondsRemaining: secondsRemaining,
          ),
        ),
      ),
    );
  }

  group('AccessRequestDecisionModal', () {
    testWidgets('should display top accent bar in Gentle Coral',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestModal());
      await tester.pump();

      // The accent bar is a Container with kGentleCoral color
      final containers = tester.widgetList<Container>(find.byType(Container));
      final accentBar = containers.firstWhere(
        (c) {
          final decoration = c.decoration;
          if (decoration is BoxDecoration &&
              decoration.color == kGentleCoral) {
            return true;
          }
          return false;
        },
        orElse: () => throw Exception('Accent bar not found'),
      );
      expect(accentBar, isNotNull);
    });

    testWidgets('should display circular countdown container',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestModal());
      await tester.pump();

      // Find the circle container
      final containers = tester.widgetList<Container>(find.byType(Container));
      final circleContainer = containers.firstWhere(
        (c) {
          final decoration = c.decoration;
          if (decoration is BoxDecoration &&
              decoration.shape == BoxShape.circle) {
            return true;
          }
          return false;
        },
        orElse: () => throw Exception('Circle container not found'),
      );
      expect(circleContainer, isNotNull);
    });

    testWidgets('should display formatted time in circle',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestModal(secondsRemaining: 245));
      await tester.pump();

      expect(find.text('4:05'), findsOneWidget);
    });

    testWidgets('should display title "Access Request"',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestModal());
      await tester.pump();

      expect(find.text('Access Request'), findsOneWidget);
    });

    testWidgets('should display clinic name in bold',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestModal());
      await tester.pump();

      expect(find.text('Clinic A'), findsOneWidget);
    });

    testWidgets('should display doctor name and reason',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestModal());
      await tester.pump();

      expect(find.text('Dr. Smith • Checkup'), findsOneWidget);
    });

    testWidgets('should display consent info box',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestModal());
      await tester.pump();

      expect(
        find.text(
          'Approving this request gives doctors at this clinic access to your full medical history.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('should display info icon in consent box',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestModal());
      await tester.pump();

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('should display Approve Access button',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestModal());
      await tester.pump();

      expect(find.text('Approve Access'), findsOneWidget);
    });

    testWidgets('should display Deny button', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestModal());
      await tester.pump();

      expect(find.text('Deny'), findsOneWidget);
    });

    testWidgets('should call approveRequest when Approve is tapped',
        (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(
        AccessRequestActive(
          request: tActiveRequest(),
          secondsRemaining: 300,
        ),
      );

      await tester.pumpWidget(buildTestModal());
      await tester.pump();

      await tester.tap(find.text('Approve Access'));
      await tester.pump();

      verify(() => mockCubit.approveRequest('1')).called(1);
    });

    testWidgets('should call denyRequest when Deny is tapped',
        (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(
        AccessRequestActive(
          request: tActiveRequest(),
          secondsRemaining: 300,
        ),
      );

      await tester.pumpWidget(buildTestModal());
      await tester.pump();

      await tester.tap(find.text('Deny'));
      await tester.pump();

      verify(() => mockCubit.denyRequest('1')).called(1);
    });

    testWidgets('should disable buttons when state is ActionInFlight',
        (WidgetTester tester) async {
      when(() => mockCubit.state)
          .thenReturn(const AccessRequestActionInFlight());

      await tester.pumpWidget(buildTestModal(
        cubitState: const AccessRequestActionInFlight(),
      ));
      await tester.pump();

      final approveButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(approveButton.onPressed, isNull);

      final denyButton = tester.widget<OutlinedButton>(
        find.byType(OutlinedButton),
      );
      expect(denyButton.onPressed, isNull);
    });

    testWidgets('should disable buttons when state is Expired',
        (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const AccessRequestExpired());

      await tester.pumpWidget(buildTestModal(
        cubitState: const AccessRequestExpired(),
      ));
      await tester.pump();

      final approveButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(approveButton.onPressed, isNull);

      final denyButton = tester.widget<OutlinedButton>(
        find.byType(OutlinedButton),
      );
      expect(denyButton.onPressed, isNull);
    });

    testWidgets('should show loading indicator when ActionInFlight',
        (WidgetTester tester) async {
      when(() => mockCubit.state)
          .thenReturn(const AccessRequestActionInFlight());

      await tester.pumpWidget(buildTestModal(
        cubitState: const AccessRequestActionInFlight(),
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });
}
