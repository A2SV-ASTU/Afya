import '../models/access_request_model.dart';
import '../models/clinic_grant_model.dart';

/// Realistic mock data for the AccessRequests feature.
///
/// **Pending requests** have `expiresAt` set 3–5 minutes from call-time so the
/// live countdown timer, urgent banner, and approval/rejection modal can be
/// exercised in demo mode.
///
/// **Active grants** represent clinics that already have approved access.
///
/// **Expired / historical requests** have statuses `expired` or `revoked` for
/// testing the full lifecycle display.

class MockAccessRequestData {
  MockAccessRequestData._();

  // ---------------------------------------------------------------------------
  // Pending / Urgent Access Requests (2 requests, expires 3–5 min from now)
  // ---------------------------------------------------------------------------

  static List<AccessRequestModel> pendingRequests({DateTime? now}) {
    final t = now ?? DateTime.now();
    return [
      AccessRequestModel(
        id: 'req-pending-001',
        clinicId: 'clinic-3',
        clinicName: 'St. Paul Hospital Millennium Medical College',
        doctorName: 'Dr. Alemayehu Bekele',
        reason:
            'Annual check-up requested access to blood work and imaging history '
            'for chronic disease management.',
        status: 'pending',
        isUrgent: true,
        createdAt: t.subtract(const Duration(minutes: 12)),
        expiresAt: t.add(const Duration(minutes: 3, seconds: 45)),
      ),
      AccessRequestModel(
        id: 'req-pending-002',
        clinicId: 'clinic-7',
        clinicName: 'Black Lion Specialized Hospital',
        doctorName: 'Dr. Fatima Hassan',
        reason:
            'Pre-surgical assessment – needs access to cardiology reports and '
            'previous anaesthesia records.',
        status: 'pending',
        isUrgent: false,
        createdAt: t.subtract(const Duration(minutes: 8)),
        expiresAt: t.add(const Duration(minutes: 5, seconds: 10)),
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Active Clinic Grants (3 grants)
  // ---------------------------------------------------------------------------

  static List<ClinicGrantModel> activeGrants({DateTime? now}) {
    final t = now ?? DateTime.now();
    return [
      ClinicGrantModel(
        grantId: 'grant-001',
        clinicId: 'clinic-1',
        clinicName: 'Afya Mind Clinic',
        grantedAt: t.subtract(const Duration(days: 2)),
      ),
      ClinicGrantModel(
        grantId: 'grant-002',
        clinicId: 'clinic-2',
        clinicName: 'Addis Ababa Medical Center',
        grantedAt: t.subtract(const Duration(days: 5)),
      ),
      ClinicGrantModel(
        grantId: 'grant-003',
        clinicId: 'clinic-4',
        clinicName: 'Tikur Anbessa Specialized Hospital',
        grantedAt: t.subtract(const Duration(days: 12)),
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Expired / Past Requests (2 historical entries)
  // ---------------------------------------------------------------------------

  static List<AccessRequestModel> expiredRequests({DateTime? now}) {
    final t = now ?? DateTime.now();
    return [
      AccessRequestModel(
        id: 'req-expired-001',
        clinicId: 'clinic-5',
        clinicName: 'Hiwot Fana Specialized University Hospital',
        doctorName: 'Dr. Kebede Tadesse',
        reason: 'Follow-up consultation for diabetes management.',
        status: 'expired',
        isUrgent: false,
        createdAt: t.subtract(const Duration(days: 3)),
        expiresAt: t.subtract(const Duration(days: 2, hours: 23)),
      ),
      AccessRequestModel(
        id: 'req-revoked-001',
        clinicId: 'clinic-6',
        clinicName: 'Gondar University Hospital',
        doctorName: 'Dr. Sara Mekonnen',
        reason: 'One-time referral review – radiology second opinion.',
        status: 'revoked',
        isUrgent: false,
        createdAt: t.subtract(const Duration(days: 7)),
        expiresAt: t.subtract(const Duration(days: 6, hours: 20)),
      ),
    ];
  }
}
