import 'package:uuid/uuid.dart';

class UuidGenerator {
  UuidGenerator._();
  static const _uuid = Uuid();

  static String generate() => _uuid.v4();
}
