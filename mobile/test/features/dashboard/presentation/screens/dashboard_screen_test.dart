import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

import 'package:afyamind_mobile/features/auth/domain/entities/patient_user_entity.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/appointment_entity.dart';
import 'package:afyamind_mobile/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:afyamind_mobile/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:afyamind_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/entities/local_dose_record_entity.dart';
import 'package:afyamind_mobile/features/vitals_sync/presentation/bloc/vitals_sync_bloc.dart';
import 'package:afyamind_mobile/features/vitals_sync/presentation/bloc/vitals_sync_state.dart';
import 'package:afyamind_mobile/features/vitals_sync/presentation/screens/log_vital_signs_screen.dart';

class MockDashboardCubit extends MockCubit<DashboardState>
    implements DashboardCubit {}

class MockVitalsSyncBloc extends Mock implements VitalsSyncBloc {}

void main() {
  late MockDashboardCubit mockDashboardCubit;
  late MockVitalsSyncBloc mockVitalsSyncBloc;

  const sampleUser = PatientUserEntity(
    id: 'user-1',
    firstName: 'Alex',
    lastName: 'Morgan',
    phone: '1234567890',
    email: 'alex@example.com',
  );

  final sampleDose = LocalDoseRecordEntity(
    id: 'dose-1',
    prescriptionItemId: 'rx-1',
    medicationName: 'Lisinopril',
    dose: '10mg',
    scheduledTime: DateTime.parse('2026-08-30T08:00:00Z'),
    status: DoseStatus.taken,
  );

  final sampleAppointment = AppointmentEntity(
    id: 'appt-1',
    clinicId: 'clinic-1',
    doctorId: 'doc-1',
    patientId: 'user-1',
    scheduledAt: DateTime.parse('2026-08-31T10:30:00Z'),
    status: AppointmentStatus.scheduled,
    createdAt: DateTime.parse('2026-08-30T00:00:00Z'),
    updatedAt: DateTime.parse('2026-08-30T00:00:00Z'),
  );

  setUp(() {
    mockDashboardCubit = MockDashboardCubit();
    mockVitalsSyncBloc = MockVitalsSyncBloc();

    // Mock the current BLoC state.
    when(() => mockVitalsSyncBloc.state).thenReturn(
      VitalsInitial(),
    );

    // BlocListener needs a non-null stream.
    when(() => mockVitalsSyncBloc.stream).thenAnswer(
      (_) => const Stream<VitalsSyncState>.empty(),
    );

    // DashboardScreen gets VitalsSyncBloc from GetIt.
    final sl = GetIt.instance;

    if (sl.isRegistered<VitalsSyncBloc>()) {
      sl.unregister<VitalsSyncBloc>();
    }

    sl.registerSingleton<VitalsSyncBloc>(
      mockVitalsSyncBloc,
    );
  });

  tearDown(() {
    final sl = GetIt.instance;

    if (sl.isRegistered<VitalsSyncBloc>()) {
      sl.unregister<VitalsSyncBloc>();
    }
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<DashboardCubit>.value(
        value: mockDashboardCubit,
        child: const DashboardScreen(),
      ),
    );
  }

  group('DashboardScreen Widget Tests', () {
    testWidgets(
      'renders loading state indicator',
      (tester) async {
        when(() => mockDashboardCubit.state).thenReturn(
          const DashboardState(
            status: DashboardStatus.loading,
          ),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(),
        );

        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'renders error view on error state',
      (tester) async {
        when(() => mockDashboardCubit.state).thenReturn(
          const DashboardState(
            status: DashboardStatus.error,
            errorMessage: 'Unable to connect to server',
          ),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(),
        );

        expect(
          find.text('Unable to connect to server'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'renders empty dashboard with greetings, empty states, and tip',
      (tester) async {
        when(() => mockDashboardCubit.state).thenReturn(
          const DashboardState(
            status: DashboardStatus.loaded,
            user: sampleUser,
            todayDoses: [],
            nextAppointment: null,
          ),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(),
        );

        // Header
        expect(
          find.text('Welcome back, Alex!'),
          findsOneWidget,
        );

        expect(
          find.text("Here's your health overview for today."),
          findsOneWidget,
        );

        // Empty medication
        expect(
          find.text("Today's Medication"),
          findsOneWidget,
        );

        expect(
          find.text(
            'No reminders buzzing yet — your dose schedule will land here once it\'s set.',
          ),
          findsOneWidget,
        );

        // Empty adherence
        expect(
          find.text("Today's Adherence"),
          findsOneWidget,
        );

        expect(
          find.text(
            'Your adherence summary will appear here once your first medication is prescribed.',
          ),
          findsOneWidget,
        );

        // Empty appointment
        expect(
          find.text('Next Appointment'),
          findsOneWidget,
        );

        expect(
          find.text('No upcoming appointments.'),
          findsOneWidget,
        );

        // Tip
        expect(
          find.text(
            "Tip: Approve a clinic's access request to let your doctor view your health history.",
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'renders populated dashboard with doses, adherence percent, and appointment',
      (tester) async {
        when(() => mockDashboardCubit.state).thenReturn(
          DashboardState(
            status: DashboardStatus.loaded,
            user: sampleUser,
            todayDoses: [sampleDose],
            nextAppointment: sampleAppointment,
          ),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(),
        );

        expect(
          find.text('Welcome back, Alex!'),
          findsOneWidget,
        );

        expect(
          find.text('Lisinopril'),
          findsOneWidget,
        );

        expect(
          find.text('100%'),
          findsOneWidget,
        );

        expect(
          find.text('Taken 1 dose'),
          findsOneWidget,
        );

        expect(
          find.text('Clinic ID: clinic-1'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'renders Log Vital Signs and opens vital input dialog',
      (tester) async {
        when(() => mockDashboardCubit.state).thenReturn(
          const DashboardState(
            status: DashboardStatus.loaded,
            user: sampleUser,
          ),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(),
        );

        // ------------------------------------------
        // 1. Verify dashboard button exists
        // ------------------------------------------
        expect(
          find.text('Log Vital Signs'),
          findsOneWidget,
        );

        expect(
          find.byIcon(Icons.favorite_outline),
          findsOneWidget,
        );

        // ------------------------------------------
        // 2. Tap Log Vital Signs
        // ------------------------------------------
        await tester.tap(
          find.text('Log Vital Signs'),
        );

        // Let the dialog build.
        await tester.pumpAndSettle();

        // ------------------------------------------
        // 3. Verify the actual dialog opened
        // ------------------------------------------
        expect(
          find.byType(VitalSignInputDialog),
          findsOneWidget,
        );

        // ------------------------------------------
        // 4. Verify Save Reading button exists
        // ------------------------------------------
        expect(
          find.text('Save Reading'),
          findsOneWidget,
        );
      },
    );
  });
}