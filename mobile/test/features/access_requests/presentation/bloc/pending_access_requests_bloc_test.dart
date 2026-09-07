import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/core/errors/failures.dart';
import 'package:afyamind_mobile/features/access_requests/domain/entities/access_request_entity.dart';
import 'package:afyamind_mobile/features/access_requests/domain/usecases/approve_access_request_usecase.dart';
import 'package:afyamind_mobile/features/access_requests/domain/usecases/deny_access_request_usecase.dart';
import 'package:afyamind_mobile/features/access_requests/domain/usecases/get_pending_access_requests_usecase.dart';
import 'package:afyamind_mobile/features/access_requests/presentation/bloc/pending_access_requests_bloc.dart';

class MockGetPendingAccessRequestsUseCase extends Mock
    implements GetPendingAccessRequestsUseCase {}

class MockApproveAccessRequestUseCase extends Mock
    implements ApproveAccessRequestUseCase {}

class MockDenyAccessRequestUseCase extends Mock
    implements DenyAccessRequestUseCase {}

AccessRequestEntity _makeRequest({
  String id = 'req-1',
  String clinicName = 'St. Paul Hospital',
  required DateTime expiresAt,
}) =>
    AccessRequestEntity(
      id: id,
      clinicId: 'clinic-1',
      clinicName: clinicName,
      doctorName: 'Dr. Test',
      reason: 'Checkup',
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 4, seconds: 58)),
      expiresAt: expiresAt,
    );

void main() {
  late PendingAccessRequestsBloc bloc;
  late MockGetPendingAccessRequestsUseCase mockGetPendingUseCase;
  late MockApproveAccessRequestUseCase mockApproveUseCase;
  late MockDenyAccessRequestUseCase mockDenyUseCase;

  setUp(() {
    mockGetPendingUseCase = MockGetPendingAccessRequestsUseCase();
    mockApproveUseCase = MockApproveAccessRequestUseCase();
    mockDenyUseCase = MockDenyAccessRequestUseCase();

    bloc = PendingAccessRequestsBloc(
      getPendingUseCase: mockGetPendingUseCase,
      approveUseCase: mockApproveUseCase,
      denyUseCase: mockDenyUseCase,
    );
  });

  tearDown(() => bloc.close());

  group('FetchPendingAccessRequestsEvent', () {
    blocTest<PendingAccessRequestsBloc, PendingAccessRequestsState>(
      'emits Loading then Loaded with valid requests',
      build: () {
        final request = _makeRequest(
          expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        );
        when(() => mockGetPendingUseCase())
            .thenAnswer((_) async => Right([request]));
        return bloc;
      },
      act: (b) => b.add(FetchPendingAccessRequestsEvent()),
      expect: () => [
        isA<PendingAccessRequestsLoading>(),
        isA<PendingAccessRequestsLoaded>()
            .having((s) => s.requests.length, 'count', 1),
      ],
    );

    blocTest<PendingAccessRequestsBloc, PendingAccessRequestsState>(
      'emits Loading then Empty when all fetched requests are already expired',
      build: () {
        final expiredRequest = _makeRequest(
          expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
        );
        when(() => mockGetPendingUseCase())
            .thenAnswer((_) async => Right([expiredRequest]));
        return bloc;
      },
      act: (b) => b.add(FetchPendingAccessRequestsEvent()),
      expect: () => [
        isA<PendingAccessRequestsLoading>(),
        isA<PendingAccessRequestsEmpty>(),
      ],
    );

    blocTest<PendingAccessRequestsBloc, PendingAccessRequestsState>(
      'emits Error on use-case failure',
      build: () {
        when(() => mockGetPendingUseCase()).thenAnswer(
            (_) async => const Left(ServerFailure('Network error')));
        return bloc;
      },
      act: (b) => b.add(FetchPendingAccessRequestsEvent()),
      expect: () => [
        isA<PendingAccessRequestsLoading>(),
        isA<PendingAccessRequestsError>()
            .having((s) => s.message, 'message', 'Network error'),
      ],
    );
  });

  group('AccessRequestExpiredEvent – simulating 5-minute expiry', () {
    blocTest<PendingAccessRequestsBloc, PendingAccessRequestsState>(
      'removes the expired request and emits Loaded without it',
      build: () {
        final req1 = _makeRequest(
          id: 'req-1',
          clinicName: 'Hospital A',
          expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        );
        final req2 = _makeRequest(
          id: 'req-2',
          clinicName: 'Hospital B',
          expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        );
        when(() => mockGetPendingUseCase())
            .thenAnswer((_) async => Right([req1, req2]));
        return bloc;
      },
      act: (b) async {
        b.add(FetchPendingAccessRequestsEvent());
        await Future.delayed(const Duration(milliseconds: 50));
        // Simulate timer expiry for req-1 after ~5 minutes
        b.add(const AccessRequestExpiredEvent('req-1', 'Hospital A'));
      },
      expect: () => [
        isA<PendingAccessRequestsLoading>(),
        isA<PendingAccessRequestsLoaded>()
            .having((s) => s.requests.length, 'initial count', 2),
        isA<PendingAccessRequestsLoaded>()
            .having((s) => s.requests.length, 'after expiry', 1)
            .having((s) => s.requests.first.id, 'remaining id', 'req-2')
            .having((s) => s.autoExpiredClinicName, 'expired clinic name', 'Hospital A'),
      ],
    );

    blocTest<PendingAccessRequestsBloc, PendingAccessRequestsState>(
      'emits PendingAccessRequestsEmpty when last request expires',
      build: () {
        final req = _makeRequest(
          id: 'req-1',
          clinicName: 'Only Clinic',
          expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        );
        when(() => mockGetPendingUseCase())
            .thenAnswer((_) async => Right([req]));
        return bloc;
      },
      act: (b) async {
        b.add(FetchPendingAccessRequestsEvent());
        await Future.delayed(const Duration(milliseconds: 50));
        b.add(const AccessRequestExpiredEvent('req-1', 'Only Clinic'));
      },
      expect: () => [
        isA<PendingAccessRequestsLoading>(),
        isA<PendingAccessRequestsLoaded>()
            .having((s) => s.requests.length, 'initial count', 1),
        isA<PendingAccessRequestsEmpty>()
            .having((s) => s.autoExpiredClinicName, 'clinic name', 'Only Clinic'),
      ],
    );
  });

  group('Internal ticker integration – auto-dispatch on expiresAt', () {
    test('dispatches AccessRequestExpiredEvent when ticker detects past expiresAt', () async {
      // Request expires in 2 seconds from now
      final soonExpiringRequest = _makeRequest(
        id: 'req-soon',
        clinicName: 'Fast Expiry Clinic',
        expiresAt: DateTime.now().add(const Duration(seconds: 2)),
      );

      when(() => mockGetPendingUseCase())
          .thenAnswer((_) async => Right([soonExpiringRequest]));

      final states = <PendingAccessRequestsState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(FetchPendingAccessRequestsEvent());

      // Wait for fetch to settle
      await Future.delayed(const Duration(milliseconds: 100));
      expect(states.last, isA<PendingAccessRequestsLoaded>());

      // Wait for the 2-second expiry to be caught by the ticker
      await Future.delayed(const Duration(seconds: 3));

      // The final state should be Empty (last request expired)
      expect(states.last, isA<PendingAccessRequestsEmpty>());
      expect(
        (states.last as PendingAccessRequestsEmpty).autoExpiredClinicName,
        'Fast Expiry Clinic',
      );

      await sub.cancel();
    });
  });
}
