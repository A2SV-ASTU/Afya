import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Initializes [dotenv] with mock test values.
///
/// Call this in `setUpAll()` before any code that reads [dotenv.env],
/// e.g. dependency injection or widget tests that use [ApiClient].
void loadTestEnv() {
  dotenv.loadFromString(envString: '''
BACKEND_URL=https://api.test.com/api/v1
''');
}
