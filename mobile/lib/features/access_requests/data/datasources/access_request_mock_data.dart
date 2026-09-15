import '../models/clinic_grant_model.dart';

/// Mock data for visited health centers shown on the Access tab.
class AccessRequestMockData {
  // ---------------------------------------------------------------------------
  // Visited Health Centers
  // ---------------------------------------------------------------------------

  static List<ClinicGrantModel> get sampleClinicGrants => [
        ClinicGrantModel(
          grantId: 'grant_001',
          clinicId: 'clinic_tikur',
          clinicName: 'Tikur Anbessa Specialized Hospital',
          grantedAt: DateTime(2026, 9, 10),
          status: 'Visited',
        ),
        ClinicGrantModel(
          grantId: 'grant_002',
          clinicId: 'clinic_afya',
          clinicName: 'Afya Specialized Hospital',
          grantedAt: DateTime(2026, 9, 5),
          status: 'Visited',
        ),
        ClinicGrantModel(
          grantId: 'grant_003',
          clinicId: 'clinic_aamc',
          clinicName: 'Addis Ababa Medical Center',
          grantedAt: DateTime(2026, 8, 28),
          status: 'Visited',
        ),
        ClinicGrantModel(
          grantId: 'grant_004',
          clinicId: 'clinic_stpaul',
          clinicName: 'St. Paul Hospital Millennium Medical College',
          grantedAt: DateTime(2026, 8, 14),
          status: 'Visited',
        ),
        ClinicGrantModel(
          grantId: 'grant_005',
          clinicId: 'clinic_yekatit',
          clinicName: 'Yekatit 12 Hospital Medical College',
          grantedAt: DateTime(2026, 7, 30),
          status: 'Visited',
        ),
      ];
}
