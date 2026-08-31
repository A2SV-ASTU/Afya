import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:afyamind_mobile/features/vitals_sync/presentation/bloc/vitals_sync_bloc.dart';
import 'package:afyamind_mobile/features/vitals_sync/presentation/bloc/vitals_sync_event.dart';
import 'package:afyamind_mobile/features/vitals_sync/presentation/bloc/vitals_sync_state.dart';
import 'package:afyamind_mobile/features/vitals_sync/presentation/screens/vitals_history_screen.dart';

class MockVitalsSyncBloc
    extends MockBloc<VitalsSyncEvent, VitalsSyncState>
    implements VitalsSyncBloc {}

void main() {
  late MockVitalsSyncBloc mockBloc;

  setUp(() {
    mockBloc = MockVitalsSyncBloc();

    whenListen(
      mockBloc,
      const Stream<VitalsSyncState>.empty(),
      initialState: VitalsInitial(),
    );
  });

  testWidgets(
    'shows home vital source badge',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<VitalsSyncBloc>.value(
            value: mockBloc,
            child: const VitalsHistoryScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(
        find.text('Home'),
        findsOneWidget,
      );
    },
  );
}