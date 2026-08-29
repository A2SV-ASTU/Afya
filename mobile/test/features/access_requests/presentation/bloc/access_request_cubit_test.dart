import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/core/errors/exceptions.dart';
import 'package:afyamind_mobile/core/errors/failures.dart';
import 'package:afyamind_mobile/features/access_requests/domain/entities/access_request_entity.dart';
import 'package:afyamind_mobile/features/access_requests/domain/entities/clinic_grant_entity.dart';
import 'package:afyamind_mobile/features/access_requests/domain/usecases/approve_access_request_usecase.dart';
import 'package:afyamind_mobile/features/access_requests/domain/usecases/deny_access_request_usecase.dart';
import 'package:afyamind_mobile/features/access_requests/domain/usecases/get_active_grants_usecase.dart';
import 'package:afyamind_mobile/features/access_requests/domain/usecases/get_pending_access_requests_usecase.dart';
import 'package:afyamind_mobile/features/access_requests/domain/usecases/revoke_clinic_grant_usecase.dart';
import 'package:afyamind_mobile/features/access_requests/presentation/bloc/access_request_cubit.dart';
import 'package:afyamind_mobile/features/access_requests/presentation/bloc/access_request_state.dart';

class MockGetPendingAccessRequestsUseCase extends Mock
    implements GetPendingAccessRequestsUseCase {}

class MockApproveAccessRequestUseCase extends Mock
    implements ApproveAccessRequestUseCase {}

class MockDenyAccessRequestUseCase extends Mock
    implements DenyAccessRequestUseCase {}

class MockGetActiveGrantsUseCase extends Mock
    implements GetActiveGrantsUseCase {}

class MockRevokeClinicGrantUseCase extends Mock
    implements RevokeClinicGrantUseCase {}

void main() {
  late AccessRequestCubit cubit;
  late MockGetPendingAccessRequestsUseCase mockGetPending;
  late MockApproveAccessRequestUseCase mockApprove;
  late MockDenyAccessRequestUseCase mockDeny;
  late MockGetActiveGrantsUseCase mockGetActiveGrants;
  late MockRevokeClinicGrantUseCase mockRevokeGrant;

  setUp(() {
    mockGetPending = MockGetPendingAccessRequestsUseCase();
    mockApprove = MockApproveAccessRequestUseCase();
    mockDeny = MockDenyAccessRequestUseCase();
    mockGetActiveGrants = MockGetActiveGrantsUseCase();
    mockRevokeGrant = MockRevokeClinicGrantUseCase();
    cubit = AccessRequestCubit(
      getPendingAccessRequestsUseCase: mockGetPending,
      approveAccessRequestUseCase: mockApprove,
      denyAccessRequestUseCase: mockDeny,
      getActiveGrantsUseCase: mockGetActiveGrants,
      revokeClinicGrantUseCase: mockRevokeGrant,
    );
  });

  tearDown(() {
    cubit.close();
  });

  final tDateTime = DateTime(2026, 1, 1);
  final tExpiresAt = DateTime.now().toUtc().add(const Duration(minutes: 5));
  final tExpiredAt = DateTime.now().toUtc().subtract(const Duration(seconds: 1));

  AccessRequestEntity tActiveRequest({DateTime? expiresAt}) {
    return AccessRequestEntity(
      id: '1',
      clinicId: 'c1',
      clinicName: 'Clinic A',
      doctorName: 'Dr. Smith',
      reason: 'Checkup',
      status: 'pending',
      expiresAt: expiresAt ?? tExpiresAt,
      createdAt: tDateTime,
    );
  }

  group('AccessRequestCubit', () {
    test('should have AccessRequestInitial as initial state', () {
      expect(cubit.state, isA<AccessRequestInitial>());
    });

    test('should close timer on close', () async {
      when(() => mockGetPending()).thenAnswer(
        (_) async => Right([tActiveRequest()]),
      );

      await cubit.fetchActiveRequest();
      await cubit.close();

      expect(cubit.state, isA<AccessRequestActive>());
    });
  });

  group('fetchActiveRequest', () {
    blocTest<AccessRequestCubit, AccessRequestState>(
      'should emit [Loading, Active] when request exists',
      build: () {
        when(() => mockGetPending()).thenAnswer(
          (_) async => Right([tActiveRequest()]),
        );
        return cubit;
      },
      act: (cubit) => cubit.fetchActiveRequest(),
      expect: () => [
        isA<AccessRequestLoading>(),
        isA<AccessRequestActive>(),
      ],
      verify: (_) {
        verify(() => mockGetPending()).called(1);
      },
    );

    blocTest<AccessRequestCubit, AccessRequestState>(
      'should emit [Loading, Failure] when no pending requests',
      build: () {
        when(() => mockGetPending()).thenAnswer(
          (_) async => const Right([]),
        );
        return cubit;
      },
      act: (cubit) => cubit.fetchActiveRequest(),
      expect: () => [
        isA<AccessRequestLoading>(),
        isA<AccessRequestFailure>(),
      ],
    );

    blocTest<AccessRequestCubit, AccessRequestState>(
      'should emit [Loading, Failure] when repository returns ServerFailure',
      build: () {
        when(() => mockGetPending()).thenAnswer(
          (_) async => const Left(ServerFailure('Server error')),
        );
        return cubit;
      },
      act: (cubit) => cubit.fetchActiveRequest(),
      expect: () => [
        isA<AccessRequestLoading>(),
        predicate<AccessRequestState>((state) =>
            state is AccessRequestFailure && state.message == 'Server error'),
      ],
    );

    blocTest<AccessRequestCubit, AccessRequestState>(
      'should emit [Loading, Expired] when request is already expired',
      build: () {
        when(() => mockGetPending()).thenAnswer(
          (_) async => Right([tActiveRequest(expiresAt: tExpiredAt)]),
        );
        return cubit;
      },
      act: (cubit) => cubit.fetchActiveRequest(),
      expect: () => [
        isA<AccessRequestLoading>(),
        isA<AccessRequestExpired>(),
      ],
    );
  });

  group('timer ticks down', () {
    blocTest<AccessRequestCubit, AccessRequestState>(
      'should emit updated secondsRemaining on each tick',
      build: () {
        final nearExpiry = DateTime.now().toUtc().add(const Duration(seconds: 3));
        when(() => mockGetPending()).thenAnswer(
          (_) async => Right([tActiveRequest(expiresAt: nearExpiry)]),
        );
        return cubit;
      },
      act: (cubit) async {
        await cubit.fetchActiveRequest();
        await Future<void>.delayed(const Duration(seconds: 2));
      },
      expect: () => [
        isA<AccessRequestLoading>(),
        isA<AccessRequestActive>(),
        isA<AccessRequestActive>(),
        isA<AccessRequestExpired>(),
      ],
      verify: (_) {
        verify(() => mockGetPending()).called(1);
      },
    );
  });

  group('auto-lock on expiry', () {
    blocTest<AccessRequestCubit, AccessRequestState>(
      'should emit Expired when secondsRemaining reaches 0',
      build: () {
        final nearExpiry = DateTime.now().toUtc().add(const Duration(seconds: 2));
        when(() => mockGetPending()).thenAnswer(
          (_) async => Right([tActiveRequest(expiresAt: nearExpiry)]),
        );
        return cubit;
      },
      act: (cubit) async {
        await cubit.fetchActiveRequest();
        await Future<void>.delayed(const Duration(seconds: 3));
      },
      expect: () => [
        isA<AccessRequestLoading>(),
        isA<AccessRequestActive>(),
        isA<AccessRequestExpired>(),
      ],
    );
  });

  group('approveRequest', () {
    blocTest<AccessRequestCubit, AccessRequestState>(
      'should emit [ActionInFlight, Success] on successful approval',
      build: () {
        when(() => mockApprove('1')).thenAnswer(
          (_) async => const Right(unit),
        );
        return cubit;
      },
      act: (cubit) => cubit.approveRequest('1'),
      expect: () => [
        isA<AccessRequestActionInFlight>(),
        isA<AccessRequestSuccess>(),
      ],
      verify: (_) {
        verify(() => mockApprove('1')).called(1);
      },
    );

    blocTest<AccessRequestCubit, AccessRequestState>(
      'should emit [ActionInFlight, Failure] when approval fails',
      build: () {
        when(() => mockApprove('1')).thenAnswer(
          (_) async => const Left(ServerFailure('Approval failed')),
        );
        return cubit;
      },
      act: (cubit) => cubit.approveRequest('1'),
      expect: () => [
        isA<AccessRequestActionInFlight>(),
        predicate<AccessRequestState>((state) =>
            state is AccessRequestFailure &&
            state.message == 'Approval failed'),
      ],
    );

    blocTest<AccessRequestCubit, AccessRequestState>(
      'should emit [ActionInFlight, Expired] on HTTP 410 error',
      build: () {
        when(() => mockApprove('1')).thenThrow(
          const ExpiredException('Request expired'),
        );
        return cubit;
      },
      act: (cubit) => cubit.approveRequest('1'),
      expect: () => [
        isA<AccessRequestActionInFlight>(),
        isA<AccessRequestExpired>(),
      ],
    );
  });

  group('denyRequest', () {
    blocTest<AccessRequestCubit, AccessRequestState>(
      'should emit [ActionInFlight, Success] on successful denial',
      build: () {
        when(() => mockDeny('1')).thenAnswer(
          (_) async => const Right(unit),
        );
        return cubit;
      },
      act: (cubit) => cubit.denyRequest('1'),
      expect: () => [
        isA<AccessRequestActionInFlight>(),
        isA<AccessRequestSuccess>(),
      ],
      verify: (_) {
        verify(() => mockDeny('1')).called(1);
      },
    );

    blocTest<AccessRequestCubit, AccessRequestState>(
      'should emit [ActionInFlight, Failure] when denial fails',
      build: () {
        when(() => mockDeny('1')).thenAnswer(
          (_) async => const Left(ServerFailure('Denial failed')),
        );
        return cubit;
      },
      act: (cubit) => cubit.denyRequest('1'),
      expect: () => [
        isA<AccessRequestActionInFlight>(),
        predicate<AccessRequestState>((state) =>
            state is AccessRequestFailure &&
            state.message == 'Denial failed'),
      ],
    );

    blocTest<AccessRequestCubit, AccessRequestState>(
      'should emit [ActionInFlight, Expired] on HTTP 410 error',
      build: () {
        when(() => mockDeny('1')).thenThrow(
          const ExpiredException('Request expired'),
        );
        return cubit;
      },
      act: (cubit) => cubit.denyRequest('1'),
      expect: () => [
        isA<AccessRequestActionInFlight>(),
        isA<AccessRequestExpired>(),
      ],
    );
  });

  group('timer cancellation on close', () {
    test('should cancel timer when close is called', () async {
      when(() => mockGetPending()).thenAnswer(
        (_) async => Right([tActiveRequest()]),
      );

      await cubit.fetchActiveRequest();

      // Close the cubit — this should cancel the timer without error
      await cubit.close();

      // Verify the cubit was closed successfully
      expect(cubit.isClosed, isTrue);
    });
  });

  // -----------------------------------------------------------------------
  // Active Grants
  // -----------------------------------------------------------------------

  final tGrant1 = ClinicGrantEntity(
    grantId: 'g1',
    clinicId: 'c1',
    clinicName: 'Clinic A',
    grantedAt: DateTime(2026, 1, 15),
  );
  final tGrant2 = ClinicGrantEntity(
    grantId: 'g2',
    clinicId: 'c2',
    clinicName: 'Clinic B',
    grantedAt: DateTime(2026, 3, 10),
  );

  group('fetchActiveGrants', () {
    blocTest<AccessRequestCubit, AccessRequestState>(
      'should emit [ActiveGrantsLoading, ActiveGrantsLoaded] when grants exist',
      build: () {
        when(() => mockGetActiveGrants()).thenAnswer(
          (_) async => Right([tGrant1, tGrant2]),
        );
        return cubit;
      },
      act: (cubit) => cubit.fetchActiveGrants(),
      expect: () => [
        isA<ActiveGrantsLoading>(),
        predicate<AccessRequestState>((state) =>
            state is ActiveGrantsLoaded && state.grants.length == 2),
      ],
      verify: (_) {
        verify(() => mockGetActiveGrants()).called(1);
      },
    );

    blocTest<AccessRequestCubit, AccessRequestState>(
      'should emit [ActiveGrantsLoading, ActiveGrantsLoaded] when grants are empty',
      build: () {
        when(() => mockGetActiveGrants()).thenAnswer(
          (_) async => const Right([]),
        );
        return cubit;
      },
      act: (cubit) => cubit.fetchActiveGrants(),
      expect: () => [
        isA<ActiveGrantsLoading>(),
        predicate<AccessRequestState>((state) =>
            state is ActiveGrantsLoaded && state.grants.isEmpty),
      ],
    );

    blocTest<AccessRequestCubit, AccessRequestState>(
      'should emit [ActiveGrantsLoading, ActiveGrantsFailure] on repository error',
      build: () {
        when(() => mockGetActiveGrants()).thenAnswer(
          (_) async => const Left(ServerFailure('Server error')),
        );
        return cubit;
      },
      act: (cubit) => cubit.fetchActiveGrants(),
      expect: () => [
        isA<ActiveGrantsLoading>(),
        predicate<AccessRequestState>((state) =>
            state is ActiveGrantsFailure &&
            state.message == 'Server error'),
      ],
    );
  });

  group('revokeGrant', () {
    blocTest<AccessRequestCubit, AccessRequestState>(
      'should emit [RevokingGrant, ActiveGrantsLoaded] on successful revocation',
      build: () {
        when(() => mockGetActiveGrants()).thenAnswer(
          (_) async => Right([tGrant1, tGrant2]),
        );
        when(() => mockRevokeGrant('c1')).thenAnswer(
          (_) async => const Right(unit),
        );
        return cubit;
      },
      act: (cubit) async {
        await cubit.fetchActiveGrants();
        await cubit.revokeGrant('c1');
      },
      expect: () => [
        isA<ActiveGrantsLoading>(),
        isA<ActiveGrantsLoaded>(),
        isA<RevokingGrant>(),
        predicate<AccessRequestState>((state) =>
            state is ActiveGrantsLoaded &&
            state.grants.length == 1 &&
            state.grants.first.clinicId == 'c2'),
      ],
      verify: (_) {
        verify(() => mockGetActiveGrants()).called(1);
        verify(() => mockRevokeGrant('c1')).called(1);
      },
    );

    blocTest<AccessRequestCubit, AccessRequestState>(
      'should emit [RevokingGrant, ActiveGrantsFailure] when revocation fails',
      build: () {
        when(() => mockGetActiveGrants()).thenAnswer(
          (_) async => Right([tGrant1]),
        );
        when(() => mockRevokeGrant('c1')).thenAnswer(
          (_) async => const Left(ServerFailure('Revoke failed')),
        );
        return cubit;
      },
      act: (cubit) async {
        await cubit.fetchActiveGrants();
        await cubit.revokeGrant('c1');
      },
      expect: () => [
        isA<ActiveGrantsLoading>(),
        isA<ActiveGrantsLoaded>(),
        isA<RevokingGrant>(),
        predicate<AccessRequestState>((state) =>
            state is ActiveGrantsFailure &&
            state.message == 'Revoke failed'),
      ],
    );
  });
}
