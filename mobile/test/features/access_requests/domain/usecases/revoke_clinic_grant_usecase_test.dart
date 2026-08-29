import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/core/errors/failures.dart';
import 'package:afyamind_mobile/features/access_requests/domain/repositories/access_request_repository.dart';
import 'package:afyamind_mobile/features/access_requests/domain/usecases/revoke_clinic_grant_usecase.dart';

class MockAccessRequestRepository extends Mock
    implements AccessRequestRepository {}

void main() {
  late RevokeClinicGrantUseCase useCase;
  late MockAccessRequestRepository mockRepository;

  setUp(() {
    mockRepository = MockAccessRequestRepository();
    useCase = RevokeClinicGrantUseCase(mockRepository);
  });

  const tClinicId = 'c1';

  group('RevokeClinicGrantUseCase', () {
    test('should revoke clinic grant from repository', () async {
      when(() => mockRepository.revokeClinicGrant(tClinicId))
          .thenAnswer((_) async => const Right(unit));

      final result = await useCase(tClinicId);

      expect(result, const Right(unit));
      verify(() => mockRepository.revokeClinicGrant(tClinicId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      const tFailure = ServerFailure('Server error');
      when(() => mockRepository.revokeClinicGrant(tClinicId))
          .thenAnswer((_) async => const Left(tFailure));

      final result = await useCase(tClinicId);

      expect(result, const Left(tFailure));
      verify(() => mockRepository.revokeClinicGrant(tClinicId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
