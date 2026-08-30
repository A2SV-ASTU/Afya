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
  });

  tearDown(() {
    mockCubit.close();
  });

  Widget buildTestWidget({required AccessRequestState initialState}) {
    when(() => mockCubit.state).thenReturn(initialState);
    whenListen(
      mockCubit,
      Stream<AccessRequestState>.fromIterable([initialState]),
      initialState: initialState,
    );
    return MaterialApp(
      home: BlocProvider<AccessRequestCubit>.value(
        value: mockCubit,
        child: const Scaffold(
          body: Stack(
            children: [AccessRequestBanner()],
          ),
        ),
      ),
    );
  }

  group('AccessRequestBanner', () {
    testWidgets('should render SizedBox.shrink when state is Initial',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestWidget(initialState: const AccessRequestInitial()));
      await tester.pump();

      expect(find.byType(AccessRequestBanner), findsOneWidget);
      // Banner should render SizedBox.shrink for non-Active states
      // No clinic name or timer text should be visible
      expect(find.text('Clinic A'), findsNothing);
    });

    testWidgets('should display clinic name when state is Active',
        (WidgetTester tester) async {
      final request = tActiveRequest();
      final state =
          AccessRequestActive(request: request, secondsRemaining: 300, formattedTime: '5:00');

      await tester.pumpWidget(buildTestWidget(initialState: state));
      await tester.pump();

      expect(find.text('Clinic A'), findsOneWidget);
      expect(find.text('Requested by Dr. Smith'), findsOneWidget);
    });

    testWidgets('should display formatted time when state is Active',
        (WidgetTester tester) async {
      final request = tActiveRequest();
      final state =
          AccessRequestActive(request: request, secondsRemaining: 245, formattedTime: '4:05');

      await tester.pumpWidget(buildTestWidget(initialState: state));
      await tester.pump();

      expect(find.text('4:05'), findsOneWidget);
    });

    testWidgets('should display zero time when secondsRemaining is 0',
        (WidgetTester tester) async {
      final request = tActiveRequest();
      final state =
          AccessRequestActive(request: request, secondsRemaining: 0, formattedTime: '0:00');

      await tester.pumpWidget(buildTestWidget(initialState: state));
      await tester.pump();

      expect(find.text('0:00'), findsOneWidget);
    });

    testWidgets('should be tappable', (WidgetTester tester) async {
      final request = tActiveRequest();
      final state =
          AccessRequestActive(request: request, secondsRemaining: 300, formattedTime: '5:00');

      await tester.pumpWidget(buildTestWidget(initialState: state));
      await tester.pump();

      final gesture = find.byType(GestureDetector);
      expect(gesture, findsOneWidget);

      // Tap the banner - this will try to open the modal
      await tester.tap(gesture);
      await tester.pump();
    });

    testWidgets('should not render banner content when state is Loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          buildTestWidget(initialState: const AccessRequestLoading()));
      await tester.pump();

      expect(find.byType(AccessRequestBanner), findsOneWidget);
      // No Material container rendered for Loading state
      expect(find.text('Clinic A'), findsNothing);
    });
  });
}
