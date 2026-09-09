import 'dart:io';
import 'package:afyamind_mobile/features/chat/data/datasources/gemini_remote_data_source.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

class _RealHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    HttpOverrides.global = _RealHttpOverrides();
    final envFile = File('.env');
    if (envFile.existsSync()) {
      dotenv.loadFromString(envString: envFile.readAsStringSync());
    }
  });

  test('GeminiRemoteDataSource returns response correctly', () async {
    final dataSource = GeminiRemoteDataSourceImpl(enableRemote: false);
    final response = await dataSource.generateHealthResponse(
      'What are some good tips for staying hydrated?',
      [],
    );

    expect(response, isNotEmpty);
  });

  test(
      'GeminiRemoteDataSource provides medication information and missed dose guidance',
      () async {
    final dataSource = GeminiRemoteDataSourceImpl(enableRemote: false);
    final response = await dataSource.generateHealthResponse(
      'What should I do if I missed a dose of my medication?',
      [],
    );

    expect(response, isNotEmpty);
    expect(response.toLowerCase(), contains('afya agent'));
    expect(response.toLowerCase(), contains('dose'));
  });

  test('GeminiRemoteDataSource provides psychology and anxiety coping support',
      () async {
    final dataSource = GeminiRemoteDataSourceImpl(enableRemote: false);
    final response = await dataSource.generateHealthResponse(
      'I am feeling very anxious and stressed today.',
      [],
    );

    expect(response, isNotEmpty);
    expect(response.toLowerCase(), contains('afya agent'));
    expect(response.toLowerCase(), contains('grounding'));
  });

  test('GeminiRemoteDataSource uses patient medication context when asked',
      () async {
    final dataSource = GeminiRemoteDataSourceImpl(enableRemote: false);
    const patientContext =
        'Active Prescriptions in Afya app:\n• Amoxicillin 500mg (Frequency: TDS, Duration: 7 days)';

    final response = await dataSource.generateHealthResponse(
      'What are my medications?',
      [],
      patientContext: patientContext,
    );

    expect(response, isNotEmpty);
    expect(response, contains('Amoxicillin'));
    expect(response, contains('Afya Agent'));
  });

  test(
      'GeminiRemoteDataSource includes non-diagnostic disclaimer in general greeting',
      () async {
    final dataSource = GeminiRemoteDataSourceImpl(enableRemote: false);
    final response = await dataSource.generateHealthResponse(
      'Hello there!',
      [],
    );

    expect(response, isNotEmpty);
    expect(response, contains('Afya Health Assistant (Afya Agent)'));
    expect(response.toLowerCase(), contains('diagnosis'));
  });
}
