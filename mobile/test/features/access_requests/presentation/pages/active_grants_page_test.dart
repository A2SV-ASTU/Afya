import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/features/access_requests/domain/entities/clinic_grant_entity.dart';
import 'package:afyamind_mobile/features/access_requests/presentation/bloc/access_request_cubit.dart';
import 'package:afyamind_mobile/features/access_requests/presentation/bloc/access_request_state.dart';
import 'package:afyamind_mobile/features/access_requests/presentation/pages/active_grants_page.dart';

class MockAccessRequestCubit extends MockCubit<AccessRequestState>
    implements AccessRequestCubit {}

ClinicGrantEntity tGrant({
  String? clinicId,
  String? clinicName,
  DateTime? grantedAt,
}) {
  return ClinicGrantEntity(
    grantId: 'g1',
    clinicId: clinicId ?? 'c1',
    clinicName: clinicName ?? 'Clinic A',
    grantedAt: grantedAt ?? DateTime(2026, 1, 15),
  );
}

void main() {
  late MockAccessRequestCubit mockCubit;

  setUp(() {
    mockCubit = MockAccessRequestCubit();
    registerFallbackValue(const AccessRequestInitial());
    when(() => mockCubit.fetchActiveGrants()).thenAnswer((_) async {});
  });

  tearDown(() {
    mockCubit.close();
  });

  Widget buildTestPage({AccessRequestState? cubitState}) {
    final state = cubitState ?? const ActiveGrantsLoading();
    when(() => mockCubit.state).thenReturn(state);
    whenListen(
      mockCubit,
      Stream<AccessRequestState>.fromIterable([state]),
      initialState: state,
    );

    return MaterialApp(
      home: BlocProvider<AccessRequestCubit>.value(
        value: mockCubit,
        child: const ActiveGrantsPage(),
      ),
    );
  }

  group('ActiveGrantsPage', () {
    testWidgets('should show loading indicator when state is ActiveGrantsLoading',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestPage(
        cubitState: const ActiveGrantsLoading(),
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error message and retry button on failure',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestPage(
        cubitState: const ActiveGrantsFailure(message: 'Failed to load grants'),
      ));
      await tester.pump();

      expect(find.text('Failed to load grants'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should call fetchActiveGrants when Retry is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestPage(
        cubitState: const ActiveGrantsFailure(message: 'Failed'),
      ));
      await tester.pump();

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => mockCubit.fetchActiveGrants()).called(2);
    });

    testWidgets('should display grants list when loaded',
        (WidgetTester tester) async {
      final grants = [tGrant(), tGrant(clinicId: 'c2', clinicName: 'Clinic B')];

      whenListen(
        mockCubit,
        Stream<AccessRequestState>.fromIterable([
          ActiveGrantsLoaded(grants: grants),
        ]),
        initialState: ActiveGrantsLoaded(grants: grants),
      );
      when(() => mockCubit.state)
          .thenReturn(ActiveGrantsLoaded(grants: grants));

      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<AccessRequestCubit>.value(
          value: mockCubit,
          child: const ActiveGrantsPage(),
        ),
      ));
      await tester.pump();

      expect(find.text('Clinic A'), findsOneWidget);
      expect(find.text('Clinic B'), findsOneWidget);
    });

    testWidgets('should show empty state when no grants',
        (WidgetTester tester) async {
      whenListen(
        mockCubit,
        Stream<AccessRequestState>.fromIterable([
          const ActiveGrantsLoaded(grants: []),
        ]),
        initialState: const ActiveGrantsLoaded(grants: []),
      );
      when(() => mockCubit.state)
          .thenReturn(const ActiveGrantsLoaded(grants: []));

      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<AccessRequestCubit>.value(
          value: mockCubit,
          child: const ActiveGrantsPage(),
        ),
      ));
      await tester.pump();

      expect(find.text('No active clinic access grants.'), findsOneWidget);
    });

    testWidgets('should display AppBar title',
        (WidgetTester tester) async {
      whenListen(
        mockCubit,
        Stream<AccessRequestState>.fromIterable([
          const ActiveGrantsLoaded(grants: []),
        ]),
        initialState: const ActiveGrantsLoaded(grants: []),
      );
      when(() => mockCubit.state)
          .thenReturn(const ActiveGrantsLoaded(grants: []));

      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<AccessRequestCubit>.value(
          value: mockCubit,
          child: const ActiveGrantsPage(),
        ),
      ));
      await tester.pump();

      expect(find.text('Active Grants'), findsOneWidget);
    });

    testWidgets('should show revoke button for each grant',
        (WidgetTester tester) async {
      final grants = [tGrant(), tGrant(clinicId: 'c2', clinicName: 'Clinic B')];

      whenListen(
        mockCubit,
        Stream<AccessRequestState>.fromIterable([
          ActiveGrantsLoaded(grants: grants),
        ]),
        initialState: ActiveGrantsLoaded(grants: grants),
      );
      when(() => mockCubit.state)
          .thenReturn(ActiveGrantsLoaded(grants: grants));

      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<AccessRequestCubit>.value(
          value: mockCubit,
          child: const ActiveGrantsPage(),
        ),
      ));
      await tester.pump();

      expect(find.text('Revoke Access'), findsNWidgets(2));
    });
  });
}
