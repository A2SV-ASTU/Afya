import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/features/profile/domain/entities/patient_profile_entity.dart';
import 'package:afyamind_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:afyamind_mobile/features/profile/domain/usecases/get_profile_usecase.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  test('gets patient profile', () async {
    final repo = MockProfileRepository();

    final usecase = GetProfileUseCase(repo);

    when(() => repo.getProfile()).thenAnswer(
      (_) async => const PatientProfileEntity(
        id: '1',
        firstName: 'Yehabesha',
        lastName: 'Test',
        email: 'test@test.com',
      ),
    );

    final result = await usecase();

    expect(result.firstName, 'Yehabesha');
  });
}