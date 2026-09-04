import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/core/errors/exceptions.dart';
import 'package:afyamind_mobile/core/network/api_client.dart';
import 'package:afyamind_mobile/core/storage/cookie_storage_service.dart';
import 'package:afyamind_mobile/features/clinical_history/domain/entities/encounter_detail_entity.dart';
import 'package:afyamind_mobile/features/medication_and_adherence/data/datasources/medication_remote_data_source.dart';

class MockDio extends Mock implements Dio {}

class MockCookieStorageService extends Mock implements CookieStorageService {}

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockDio mockDio;
  late MockApiClient mockApiClient;
  late MedicationRemoteDataSourceImpl remoteDataSource;

  setUp(() {
    mockDio = MockDio();
    mockApiClient = MockApiClient();
    when(() => mockApiClient.dio).thenReturn(mockDio);
    remoteDataSource = MedicationRemoteDataSourceImpl(mockApiClient);
  });

  const encounterId = 'enc-123';
  const prescriptionItemId = 'item-456';

  final sampleItemJson = {
    'id': prescriptionItemId,
    'medication_name': 'Amoxicillin',
    'dose': '500mg',
    'route': 'oral',
    'frequency': 'TID',
    'duration': '7 days',
    'status': 'active',
    'instructions': 'Take with water',
    'started_at': '2026-08-28T08:00:00.000Z',
  };

  group('getPrescriptionsByEncounter', () {
    test('returns items when response is a direct list', () async {
      when(() => mockDio.get('/encounters/$encounterId/prescriptions'))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(
                    path: '/encounters/$encounterId/prescriptions'),
                statusCode: 200,
                data: [sampleItemJson],
              ));

      final result = await remoteDataSource.getPrescriptionsByEncounter(
        encounterId: encounterId,
      );

      expect(result.length, 1);
      expect(result.first.id, prescriptionItemId);
      expect(result.first.medicationName, 'Amoxicillin');
      expect(result.first.status, EncounterPrescriptionStatus.active);
    });

    test('returns items when response is in a {"data": [...]} envelope',
        () async {
      when(() => mockDio.get('/encounters/$encounterId/prescriptions'))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(
                    path: '/encounters/$encounterId/prescriptions'),
                statusCode: 200,
                data: {
                  'data': [sampleItemJson]
                },
              ));

      final result = await remoteDataSource.getPrescriptionsByEncounter(
        encounterId: encounterId,
      );

      expect(result.length, 1);
      expect(result.first.id, prescriptionItemId);
    });

    test('returns items when response contains aggregated prescriptions array',
        () async {
      when(() => mockDio.get('/encounters/$encounterId/prescriptions'))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(
                    path: '/encounters/$encounterId/prescriptions'),
                statusCode: 200,
                data: {
                  'prescriptions': [
                    {
                      'id': 'rx-header-1',
                      'items': [sampleItemJson],
                    }
                  ]
                },
              ));

      final result = await remoteDataSource.getPrescriptionsByEncounter(
        encounterId: encounterId,
      );

      expect(result.length, 1);
      expect(result.first.medicationName, 'Amoxicillin');
      expect(result.first.prescriptionId, 'rx-header-1');
    });

    test('throws ServerException on DioException with response error body',
        () async {
      when(() => mockDio.get('/encounters/$encounterId/prescriptions'))
          .thenThrow(DioException(
        requestOptions:
            RequestOptions(path: '/encounters/$encounterId/prescriptions'),
        response: Response(
          requestOptions:
              RequestOptions(path: '/encounters/$encounterId/prescriptions'),
          statusCode: 404,
          data: {
            'error': {'code': 'not_found', 'message': 'Encounter not found'}
          },
        ),
      ));

      expect(
        () => remoteDataSource.getPrescriptionsByEncounter(
            encounterId: encounterId),
        throwsA(isA<ServerException>().having(
          (e) => e.message,
          'message',
          'Encounter not found',
        )),
      );
    });
  });

  group('completePrescription', () {
    const prescriptionId = 'rx-header-123';

    test('returns completed model on successful PATCH with item payload',
        () async {
      final completedJson = {
        ...sampleItemJson,
        'prescription_id': prescriptionId,
        'status': 'completed',
      };

      when(() => mockDio.patch(
            '/prescriptions/$prescriptionId/complete',
            data: {'item_ids': [prescriptionItemId]},
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(
                path: '/prescriptions/$prescriptionId/complete'),
            statusCode: 200,
            data: {'data': completedJson},
          ));

      final result = await remoteDataSource.completePrescription(
        prescriptionId: prescriptionId,
        prescriptionItemId: prescriptionItemId,
      );

      expect(result.id, prescriptionItemId);
      expect(result.prescriptionId, prescriptionId);
      expect(result.status, EncounterPrescriptionStatus.completed);
    });

    test('returns completed synthetic model on successful empty or status response',
        () async {
      when(() => mockDio.patch(
            '/prescriptions/$prescriptionId/complete',
            data: {'item_ids': [prescriptionItemId]},
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(
                path: '/prescriptions/$prescriptionId/complete'),
            statusCode: 200,
            data: {'status': 'completed'},
          ));

      final result = await remoteDataSource.completePrescription(
        prescriptionId: prescriptionId,
        prescriptionItemId: prescriptionItemId,
      );

      expect(result.id, prescriptionItemId);
      expect(result.prescriptionId, prescriptionId);
      expect(result.status, EncounterPrescriptionStatus.completed);
    });

    test('throws ServerException when PATCH returns 500 error', () async {
      when(() => mockDio.patch(
            '/prescriptions/$prescriptionId/complete',
            data: {'item_ids': [prescriptionItemId]},
          )).thenThrow(DioException(
        requestOptions:
            RequestOptions(path: '/prescriptions/$prescriptionId/complete'),
        response: Response(
          requestOptions: RequestOptions(
              path: '/prescriptions/$prescriptionId/complete'),
          statusCode: 500,
          data: {
            'error': {'code': 'internal_error', 'message': 'Database failure'}
          },
        ),
      ));

      expect(
        () => remoteDataSource.completePrescription(
          prescriptionId: prescriptionId,
          prescriptionItemId: prescriptionItemId,
        ),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
