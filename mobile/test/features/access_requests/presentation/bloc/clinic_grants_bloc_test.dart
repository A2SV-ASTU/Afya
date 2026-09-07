import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';

import 'package:afyamind_mobile/features/access_requests/domain/usecases/get_active_grants_usecase.dart';
import 'package:afyamind_mobile/features/access_requests/domain/usecases/revoke_clinic_grant_usecase.dart';
import 'package:afyamind_mobile/features/access_requests/presentation/bloc/clinic_grants_bloc.dart';
import 'package:afyamind_mobile/features/access_requests/domain/entities/clinic_grant_entity.dart';

class MockGetActiveGrantsUseCase extends Mock implements GetActiveGrantsUseCase {}
class MockRevokeClinicGrantUseCase extends Mock implements RevokeClinicGrantUseCase {}

void main() {
  late ClinicGrantsBloc bloc;
  late MockGetActiveGrantsUseCase mockGetActiveGrantsUseCase;
  late MockRevokeClinicGrantUseCase mockRevokeClinicGrantUseCase;

  setUp(() {
    mockGetActiveGrantsUseCase = MockGetActiveGrantsUseCase();
    mockRevokeClinicGrantUseCase = MockRevokeClinicGrantUseCase();

    bloc = ClinicGrantsBloc(
      getActiveGrantsUseCase: mockGetActiveGrantsUseCase,
      revokeClinicGrantUseCase: mockRevokeClinicGrantUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('ClinicGrantsBloc', () {
    test('should emit loaded with remaining seconds and tick down to 0, then revoke', () async {
      final tGrant = ClinicGrantEntity(
        grantId: '1',
        clinicId: 'c1',
        clinicName: 'Clinic',
        // Grant created 4 minutes and 58 seconds ago, meaning it expires in 2 seconds
        grantedAt: DateTime.now().subtract(const Duration(minutes: 4, seconds: 58)),
      );

      when(() => mockGetActiveGrantsUseCase())
          .thenAnswer((_) async => Right([tGrant]));
      when(() => mockRevokeClinicGrantUseCase(any()))
          .thenAnswer((_) async => const Right(unit));

      final states = <ClinicGrantsState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(FetchActiveGrantsEvent());

      // Wait for fetch and ticks past 0
      await Future.delayed(const Duration(seconds: 3));

      // Verify that at some point an auto-expired state was emitted
      expect(
        states.any((s) => s is ClinicGrantsLoaded && s.autoExpiredClinicId == 'c1'),
        isTrue,
      );

      // Verify that revoke was called for the expired clinic
      verify(() => mockRevokeClinicGrantUseCase('c1')).called(1);

      await sub.cancel();
    });

    blocTest<ClinicGrantsBloc, ClinicGrantsState>(
      'should recalculate and revoke when app resumes after expiry',
      build: () {
        final tExpiredGrant = ClinicGrantEntity(
          grantId: '1',
          clinicId: 'c1',
          clinicName: 'Clinic',
          // Grant created 6 minutes ago, meaning it is already expired
          grantedAt: DateTime.now().subtract(const Duration(minutes: 6)),
        );
        when(() => mockGetActiveGrantsUseCase())
            .thenAnswer((_) async => Right([tExpiredGrant]));
        when(() => mockRevokeClinicGrantUseCase(any()))
            .thenAnswer((_) async => const Right(unit));
        return bloc;
      },
      act: (bloc) async {
        bloc.add(FetchActiveGrantsEvent());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(RecalculateTimersEvent());
        await Future.delayed(const Duration(milliseconds: 100));
      },
      verify: (_) {
        verify(() => mockRevokeClinicGrantUseCase('c1')).called(1);
      },
    );
  });
}
