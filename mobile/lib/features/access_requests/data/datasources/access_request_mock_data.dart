import '../models/clinic_grant_model.dart';

/// Mock data for Active Clinic Grants.
///
/// The Access Screen only shows active/granted clinics.
/// Pending/unapproved requests are no longer displayed.
class AccessRequestMockData {
  // ---------------------------------------------------------------------------
  // Active Clinic Grants
  // ---------------------------------------------------------------------------

  static List<ClinicGrantModel> get sampleClinicGrants => [
        ClinicGrantModel(
          grantId: 'grant_001',
          clinicId: 'clinic_afya',
          clinicName: 'Afya Hospital',
          grantedAt: DateTime(2026, 9, 5),
          status: 'Active',
        ),
        ClinicGrantModel(
          grantId: 'grant_002',
          clinicId: 'clinic_aamc',
          clinicName: 'Addis Ababa Medical Center',
          grantedAt: DateTime(2026, 9, 2),
          status: 'Active',
        ),
      ];
}
