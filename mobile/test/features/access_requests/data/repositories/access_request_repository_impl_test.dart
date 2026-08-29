import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/core/errors/exceptions.dart';
import 'package:afyamind_mobile/core/errors/failures.dart';
import 'package:afyamind_mobile/features/access_requests/data/datasources/access_request_remote_data_source.dart';
import 'package:afyamind_mobile/features/access_requests/data/models/access_request_model.dart';
import 'package:afyamind_mobile/features/access_requests/data/models/clinic_grant_model.dart';
import 'package:afyamind_mobile/features/access_requests/data/repositories/access_request_repository_impl.dart';

class MockAccessRequestRemoteDataSource extends Mock
    implements AccessRequestRemoteDataSource {}

void main() {
  late AccessRequestRepositoryImpl repository;
  late MockAccessRequestRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockAccessRequestRemoteDataSource();
    repository = AccessRequestRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
    );
  });

  final tDateTime = DateTime(2026, 1, 1);
  final tExpiresAt = DateTime(2026, 2, 1);

  final tAccessRequestModel = AccessRequestModel(
    id: '1',
    clinicId: 'c1',
    clinicName: 'Clinic A',
    doctorName: 'Dr. Smith',
    reason: 'Checkup',
    status: 'pending',
    expiresAt: tExpiresAt,
    createdAt: tDateTime,
  );

  final tClinicGrantModel = ClinicGrantModel(
    grantId: 'g1',
    clinicId: 'c1',
    clinicName: 'Clinic A',
    grantedAt: tDateTime,
  );

  group('getPendingAccessRequests', () {
    test('should return Right with list on success', () async {
      when(() => mockRemoteDataSource.getPendingAccessRequests())
          .thenAnswer((_) async => [tAccessRequestModel]);

      final result = await repository.getPendingAccessRequests();

      expect(result, isA<Right<Failure, List<dynamic>>>());
      result.fold(
        (l) => fail('Expected Right'),
        (r) {
          expect(r.length, 1);
          expect(r[0].id, '1');
        },
      );
      verify(() => mockRemoteDataSource.getPendingAccessRequests()).called(1);
    });

    test('should return Left ServerFailure on ServerException', () async {
      when(() => mockRemoteDataSource.getPendingAccessRequests())
          .thenThrow(const ServerException('Server error'));

      final result = await repository.getPendingAccessRequests();

      expect(result, isA<Left<Failure, dynamic>>());
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left'),
      );
    });

    test('should return Left ServerFailure on DioException', () async {
      when(() => mockRemoteDataSource.getPendingAccessRequests()).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Network error',
        ),
      );

      final result = await repository.getPendingAccessRequests();

      expect(result, isA<Left<Failure, dynamic>>());
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left'),
      );
    });
  });

  group('approveAccessRequest', () {
    test('should return Right unit on success', () async {
      when(() => mockRemoteDataSource.approveAccessRequest('1'))
          .thenAnswer((_) async {});

      final result = await repository.approveAccessRequest('1');

      expect(result, isA<Right<Failure, dynamic>>());
      result.fold(
        (l) => fail('Expected Right'),
        (r) => expect(r, unit),
      );
      verify(() => mockRemoteDataSource.approveAccessRequest('1')).called(1);
    });

    test('should return Left ServerFailure on ServerException', () async {
      when(() => mockRemoteDataSource.approveAccessRequest('1'))
          .thenThrow(const ServerException('Server error'));

      final result = await repository.approveAccessRequest('1');

      expect(result, isA<Left<Failure, dynamic>>());
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left'),
      );
    });

    test('should return Left ServerFailure on DioException', () async {
      when(() => mockRemoteDataSource.approveAccessRequest('1')).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Network error',
        ),
      );

      final result = await repository.approveAccessRequest('1');

      expect(result, isA<Left<Failure, dynamic>>());
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left'),
      );
    });
  });

  group('denyAccessRequest', () {
    test('should return Right unit on success', () async {
      when(() => mockRemoteDataSource.denyAccessRequest('1'))
          .thenAnswer((_) async {});

      final result = await repository.denyAccessRequest('1');

      expect(result, isA<Right<Failure, dynamic>>());
      result.fold(
        (l) => fail('Expected Right'),
        (r) => expect(r, unit),
      );
      verify(() => mockRemoteDataSource.denyAccessRequest('1')).called(1);
    });

    test('should return Left ServerFailure on ServerException', () async {
      when(() => mockRemoteDataSource.denyAccessRequest('1'))
          .thenThrow(const ServerException('Server error'));

      final result = await repository.denyAccessRequest('1');

      expect(result, isA<Left<Failure, dynamic>>());
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left'),
      );
    });

    test('should return Left ServerFailure on DioException', () async {
      when(() => mockRemoteDataSource.denyAccessRequest('1')).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Network error',
        ),
      );

      final result = await repository.denyAccessRequest('1');

      expect(result, isA<Left<Failure, dynamic>>());
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left'),
      );
    });
  });

  group('getActiveGrants', () {
    test('should return Right with list on success', () async {
      when(() => mockRemoteDataSource.getActiveGrants())
          .thenAnswer((_) async => [tClinicGrantModel]);

      final result = await repository.getActiveGrants();

      expect(result, isA<Right<Failure, List<dynamic>>>());
      result.fold(
        (l) => fail('Expected Right'),
        (r) {
          expect(r.length, 1);
          expect(r[0].grantId, 'g1');
        },
      );
      verify(() => mockRemoteDataSource.getActiveGrants()).called(1);
    });

    test('should return Left ServerFailure on ServerException', () async {
      when(() => mockRemoteDataSource.getActiveGrants())
          .thenThrow(const ServerException('Server error'));

      final result = await repository.getActiveGrants();

      expect(result, isA<Left<Failure, dynamic>>());
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left'),
      );
    });

    test('should return Left ServerFailure on DioException', () async {
      when(() => mockRemoteDataSource.getActiveGrants()).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Network error',
        ),
      );

      final result = await repository.getActiveGrants();

      expect(result, isA<Left<Failure, dynamic>>());
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left'),
      );
    });
  });

  group('revokeClinicGrant', () {
    test('should return Right unit on success', () async {
      when(() => mockRemoteDataSource.revokeClinicGrant('c1'))
          .thenAnswer((_) async {});

      final result = await repository.revokeClinicGrant('c1');

      expect(result, isA<Right<Failure, dynamic>>());
      result.fold(
        (l) => fail('Expected Right'),
        (r) => expect(r, unit),
      );
      verify(() => mockRemoteDataSource.revokeClinicGrant('c1')).called(1);
    });

    test('should return Left ServerFailure on ServerException', () async {
      when(() => mockRemoteDataSource.revokeClinicGrant('c1'))
          .thenThrow(const ServerException('Server error'));

      final result = await repository.revokeClinicGrant('c1');

      expect(result, isA<Left<Failure, dynamic>>());
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left'),
      );
    });

    test('should return Left ServerFailure on DioException', () async {
      when(() => mockRemoteDataSource.revokeClinicGrant('c1')).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Network error',
        ),
      );

      final result = await repository.revokeClinicGrant('c1');

      expect(result, isA<Left<Failure, dynamic>>());
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left'),
      );
    });
  });
}
