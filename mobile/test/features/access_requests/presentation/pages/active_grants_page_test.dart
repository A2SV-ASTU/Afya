import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/features/access_requests/domain/entities/clinic_grant_entity.dart';
import 'package:afyamind_mobile/features/access_requests/presentation/bloc/clinic_grants_bloc.dart';
import 'package:afyamind_mobile/features/access_requests/presentation/pages/active_grants_page.dart';

class MockClinicGrantsBloc extends MockBloc<ClinicGrantsEvent, ClinicGrantsState>
    implements ClinicGrantsBloc {}

ClinicGrantEntity tGrant({
  String? clinicId,
  String? clinicName,
  DateTime? grantedAt,
}) {
  return ClinicGrantEntity(
    grantId: 'g1',
    clinicId: clinicId ?? 'c1',
    clinicName: clinicName ?? 'Clinic A',
    grantedAt: grantedAt ?? DateTime.now().subtract(const Duration(minutes: 1)),
  );
}

void main() {
  late MockClinicGrantsBloc mockBloc;

  setUp(() {
    mockBloc = MockClinicGrantsBloc();
    registerFallbackValue(FetchActiveGrantsEvent());
    registerFallbackValue(RecalculateTimersEvent());
  });

  tearDown(() {
    mockBloc.close();
  });

  Widget buildTestPage({ClinicGrantsState? blocState}) {
    final state = blocState ?? ClinicGrantsLoading();
    when(() => mockBloc.state).thenReturn(state);
    whenListen(
      mockBloc,
      Stream<ClinicGrantsState>.fromIterable([state]),
      initialState: state,
    );

    return MaterialApp(
      home: BlocProvider<ClinicGrantsBloc>.value(
        value: mockBloc,
        child: const ActiveGrantsPage(),
      ),
    );
  }

  group('ActiveGrantsPage', () {
    testWidgets('should show loading indicator when state is ClinicGrantsLoading',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestPage(
        blocState: ClinicGrantsLoading(),
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error message and retry button on failure',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestPage(
        blocState: const ClinicGrantsError('Failed to load grants'),
      ));
      await tester.pump();

      expect(find.text('Failed to load grants'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should call fetchActiveGrants when Retry is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestPage(
        blocState: const ClinicGrantsError('Failed'),
      ));
      await tester.pump();

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => mockBloc.add(any(that: isA<FetchActiveGrantsEvent>()))).called(2);
    });

    testWidgets('should display grants list when loaded',
        (WidgetTester tester) async {
      final grants = [tGrant(), tGrant(clinicId: 'c2', clinicName: 'Clinic B')];
      final state = ClinicGrantsLoaded(
        grants: grants,
        remainingSecondsMap: const {'c1': 240, 'c2': 180},
      );

      await tester.pumpWidget(buildTestPage(blocState: state));
      await tester.pump();

      expect(find.text('Clinic A'), findsOneWidget);
      expect(find.text('Clinic B'), findsOneWidget);
    });

    testWidgets('should show empty state when no grants',
        (WidgetTester tester) async {
      const state = ClinicGrantsLoaded(
        grants: [],
        remainingSecondsMap: {},
      );

      await tester.pumpWidget(buildTestPage(blocState: state));
      await tester.pump();

      expect(find.text('No active clinic access grants.'), findsOneWidget);
    });

    testWidgets('should display AppBar title',
        (WidgetTester tester) async {
      const state = ClinicGrantsLoaded(
        grants: [],
        remainingSecondsMap: {},
      );

      await tester.pumpWidget(buildTestPage(blocState: state));
      await tester.pump();

      expect(find.text('Active Grants'), findsOneWidget);
    });

    testWidgets('should show revoke button for each grant',
        (WidgetTester tester) async {
      final grants = [tGrant(), tGrant(clinicId: 'c2', clinicName: 'Clinic B')];
      final state = ClinicGrantsLoaded(
        grants: grants,
        remainingSecondsMap: const {'c1': 240, 'c2': 180},
      );

      await tester.pumpWidget(buildTestPage(blocState: state));
      await tester.pump();

      expect(find.text('Revoke Access'), findsNWidgets(2));
    });
  });
}
