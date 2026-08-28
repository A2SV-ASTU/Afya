export type UserRole = 'super_admin' | 'clinic_admin' | 'doctor' | 'patient';

export interface RoleConfig {
  role: UserRole;
  label: string;
  badge: string;
  description: string;
  allowedPrefixes: string[];
}

export const ROLE_CONFIGS: Record<UserRole, RoleConfig> = {
  super_admin: {
    role: 'super_admin',
    label: 'Super Admin',
    badge: 'SuperAdmin Console',
    description: 'Central Regulatory & Governance Console',
    allowedPrefixes: ['/admin'],
  },
  clinic_admin: {
    role: 'clinic_admin',
    label: 'Clinic Admin',
    badge: 'Facility Admin',
    description: 'Facility Operations & Patient Consent Gateway',
    allowedPrefixes: ['/clinic'],
  },
  doctor: {
    role: 'doctor',
    label: 'Doctor',
    badge: 'Attending Physician',
    description: 'Clinical Practice, Encounters & Longitudinal History',
    allowedPrefixes: ['/doctor'],
  },
  patient: {
    role: 'patient',
    label: 'Citizen / Patient',
    badge: 'Patient App',
    description: 'Citizen Health Records & Consent Authorization',
    allowedPrefixes: ['/patient'],
  },
};
