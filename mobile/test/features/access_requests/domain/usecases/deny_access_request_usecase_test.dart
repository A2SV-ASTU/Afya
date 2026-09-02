import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/core/errors/failures.dart';
import 'package:afyamind_mobile/features/access_requests/domain/repositories/access_request_repository.dart';
import 'package:afyamind_mobile/features/access_requests/domain/usecases/deny_access_request_usecase.dart';

class MockAccessRequestRepository extends Mock
    implements AccessRequestRepository {}

void main() {
  late DenyAccessRequestUseCase useCase;
  late MockAccessRequestRepository mockRepository;

  setUp(() {
    mockRepository = MockAccessRequestRepository();
    useCase = DenyAccessRequestUseCase(mockRepository);
  });

  const tRequestId = '1';

  group('DenyAccessRequestUseCase', () {
    test('should deny access request from repository', () async {
      when(() => mockRepository.denyAccessRequest(tRequestId))
          .thenAnswer((_) async => const Right(unit));

      final result = await useCase(tRequestId);

      expect(result, const Right(unit));
      verify(() => mockRepository.denyAccessRequest(tRequestId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      const tFailure = ServerFailure('Server error');
      when(() => mockRepository.denyAccessRequest(tRequestId))
          .thenAnswer((_) async => const Left(tFailure));

      final result = await useCase(tRequestId);

      expect(result, const Left(tFailure));
      verify(() => mockRepository.denyAccessRequest(tRequestId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
