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
    final dataSource = GeminiRemoteDataSourceImpl();
    final response = await dataSource.generateHealthResponse(
      'What are some good tips for staying hydrated?',
      [],
    );

    expect(response, isNotEmpty);
  });
}
