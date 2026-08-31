import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/core/errors/failures.dart';
import 'package:afyamind_mobile/features/access_requests/domain/entities/access_request_entity.dart';
import 'package:afyamind_mobile/features/access_requests/domain/repositories/access_request_repository.dart';
import 'package:afyamind_mobile/features/access_requests/domain/usecases/get_pending_access_requests_usecase.dart';

class MockAccessRequestRepository extends Mock
    implements AccessRequestRepository {}

void main() {
  late GetPendingAccessRequestsUseCase useCase;
  late MockAccessRequestRepository mockRepository;

  setUp(() {
    mockRepository = MockAccessRequestRepository();
    useCase = GetPendingAccessRequestsUseCase(mockRepository);
  });

  final tDateTime = DateTime(2026, 1, 1);
  final tExpiresAt = DateTime(2026, 2, 1);

  final tRequests = [
    AccessRequestEntity(
      id: '1',
      clinicId: 'c1',
      clinicName: 'Clinic A',
      doctorName: 'Dr. Smith',
      reason: 'Checkup',
      status: 'pending',
      expiresAt: tExpiresAt,
      createdAt: tDateTime,
    ),
  ];

  group('GetPendingAccessRequestsUseCase', () {
    test('should return list of access requests from repository', () async {
      when(() => mockRepository.getPendingAccessRequests())
          .thenAnswer((_) async => Right(tRequests));

      final result = await useCase();

      expect(result, Right(tRequests));
      verify(() => mockRepository.getPendingAccessRequests()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      const tFailure = ServerFailure('Server error');
      when(() => mockRepository.getPendingAccessRequests())
          .thenAnswer((_) async => const Left(tFailure));

      final result = await useCase();

      expect(result, const Left(tFailure));
      verify(() => mockRepository.getPendingAccessRequests()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
