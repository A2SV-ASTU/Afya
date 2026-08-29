import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/core/errors/failures.dart';
import 'package:afyamind_mobile/features/access_requests/domain/entities/clinic_grant_entity.dart';
import 'package:afyamind_mobile/features/access_requests/domain/repositories/access_request_repository.dart';
import 'package:afyamind_mobile/features/access_requests/domain/usecases/get_active_grants_usecase.dart';

class MockAccessRequestRepository extends Mock
    implements AccessRequestRepository {}

void main() {
  late GetActiveGrantsUseCase useCase;
  late MockAccessRequestRepository mockRepository;

  setUp(() {
    mockRepository = MockAccessRequestRepository();
    useCase = GetActiveGrantsUseCase(mockRepository);
  });

  final tGrants = [
    ClinicGrantEntity(
      grantId: 'g1',
      clinicId: 'c1',
      clinicName: 'Clinic A',
      grantedAt: DateTime(2026, 1, 1),
    ),
  ];

  group('GetActiveGrantsUseCase', () {
    test('should return list of active grants from repository', () async {
      when(() => mockRepository.getActiveGrants())
          .thenAnswer((_) async => Right(tGrants));

      final result = await useCase();

      expect(result, Right(tGrants));
      verify(() => mockRepository.getActiveGrants()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      const tFailure = ServerFailure('Server error');
      when(() => mockRepository.getActiveGrants())
          .thenAnswer((_) async => const Left(tFailure));

      final result = await useCase();

      expect(result, const Left(tFailure));
      verify(() => mockRepository.getActiveGrants()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
