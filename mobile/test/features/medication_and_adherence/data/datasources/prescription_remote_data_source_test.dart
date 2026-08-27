import 'package:afyamind_mobile/core/constants/api_endpoints.dart';
import 'package:afyamind_mobile/core/errors/exceptions.dart';
import 'package:afyamind_mobile/core/network/api_client.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/datasources/prescription_remote_data_source.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/domain/entities/prescription_item_entity.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockDio mockDio;
  late MockApiClient mockApiClient;
  late PrescriptionRemoteDataSourceImpl dataSource;

  setUp(() {
    mockDio = MockDio();
    mockApiClient = MockApiClient();
    when(() => mockApiClient.dio).thenReturn(mockDio);
    dataSource = PrescriptionRemoteDataSourceImpl(mockApiClient);
  });

  group('getPrescriptionsForEncounter', () {
    const tEncounterId = 'enc-999';
    final tEndpoint = ApiEndpoints.encounterPrescriptions(tEncounterId);

    test(
        'should send GET to /encounters/:encounterId/prescriptions and return parsed items',
        () async {
      final responsePayload = {
        'data': [
          {
            'id': 'rx-1',
            'encounter_id': tEncounterId,
            'medication_name': 'Amoxicillin',
            'dosage': '500mg',
            'frequency': 'twice daily',
            'duration_days': 7,
            'status': 'active',
          },
          {
            'id': 'rx-2',
            'encounter_id': tEncounterId,
            'medication_name': 'Paracetamol',
            'dosage': '1000mg',
            'frequency': 'as needed',
            'duration_days': 3,
            'status': 'completed',
          }
        ]
      };

      when(() => mockDio.get(tEndpoint)).thenAnswer(
        (_) async => Response(
          data: responsePayload,
          statusCode: 200,
          requestOptions: RequestOptions(path: tEndpoint),
        ),
      );

      final result =
          await dataSource.getPrescriptionsForEncounter(tEncounterId);

      verify(() => mockDio.get(tEndpoint)).called(1);
      expect(result.length, 2);
      expect(result[0].id, 'rx-1');
      expect(result[0].status, PrescriptionItemStatus.active);
      expect(result[1].id, 'rx-2');
      expect(result[1].status, PrescriptionItemStatus.completed);
    });

    test('should throw ServerException when Dio throws DioException', () async {
      when(() => mockDio.get(tEndpoint)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: tEndpoint),
          response: Response(
            data: {
              'error': {'message': 'Not found'}
            },
            statusCode: 404,
            requestOptions: RequestOptions(path: tEndpoint),
          ),
        ),
      );

      expect(
        () => dataSource.getPrescriptionsForEncounter(tEncounterId),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('completePrescription', () {
    const tPrescriptionId = 'rx-101';
    final tEndpoint = ApiEndpoints.completePrescription(tPrescriptionId);

    test(
        'should send PATCH request to /prescriptions/:id/complete with NO body',
        () async {
      when(() => mockDio.patch(tEndpoint, data: null)).thenAnswer(
        (_) async => Response(
          data: {
            'data': {'message': 'Prescription completed'}
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: tEndpoint),
        ),
      );

      await dataSource.completePrescription(tPrescriptionId);

      verify(() => mockDio.patch(tEndpoint, data: null)).called(1);
    });

    test('should throw ServerException when completion PATCH fails', () async {
      when(() => mockDio.patch(tEndpoint, data: null)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: tEndpoint),
          response: Response(
            data: {
              'error': {'message': 'Invalid prescription state'}
            },
            statusCode: 400,
            requestOptions: RequestOptions(path: tEndpoint),
          ),
        ),
      );

      expect(
        () => dataSource.completePrescription(tPrescriptionId),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
