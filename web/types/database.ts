export type UserRole = 'super_admin' | 'clinic_admin' | 'doctor' | 'patient';

export interface User {
  id: string;
  email: string;
  first_name: string;
  last_name: string;
  role: UserRole;
  phone?: string;
  date_of_birth?: string;
  sex?: string;
  blood_type?: string | null;
  emergency_contact_name?: string | null;
  emergency_contact_phone?: string | null;
  clinic_id?: string | null;
  clinic_status?: 'active' | 'deactivated' | null;
  specialization?: string | null;
  license_number?: string | null;
  doctor_status?: 'active' | 'deactivated' | null;
  created_at: string;
  updated_at?: string;
}

export type ClinicStatus = 'active' | 'deactivated';

export interface Clinic {
  id: string;
  name: string;
  email: string;
  phone: string;
  address: string;
  status: ClinicStatus;
  admin_name: string;
  admin_email: string;
  created_at: string;
  updated_at?: string;
  total_doctors: number;
  active_grants_count: number;
}

export interface DoctorResponse {
  id: string;
  first_name: string;
  last_name: string;
  email: string;
  phone?: string;
  specialization?: string;
  license_number?: string;
  doctor_status: 'active' | 'deactivated';
  created_at: string;
}

export type InvitationStatus = 'pending' | 'accepted' | 'expired' | 'revoked';

export interface DoctorInvitation {
  id: string;
  clinic_id: string;
  clinic_name?: string;
  email: string;
  specialization?: string;
  token?: string;
  status: InvitationStatus;
  expires_at: string; // ISO date string (24h)
  accepted_at?: string | null;
  created_at: string;
}


export type AccessRequestStatus = 'pending' | 'approved' | 'denied' | 'expired' | 'revoked';

export interface AccessRequestPatient {
  id?: string;
  first_name?: string;
  last_name?: string;
  email?: string;
}

export interface AccessRequest {
  id: string;
  patient_id: string;
  patient?: AccessRequestPatient | null;
  first_name?: string;
  last_name?: string;
  patient_name?: string;
  patient_email?: string;
  requesting_clinic_id?: string;
  clinic_id?: string;
  clinic_name?: string;
  submitted_by_doctor_id?: string;
  submitted_by_doctor_name?: string;
  reason: string;
  status: AccessRequestStatus;
  created_at: string;
  expires_at: string;
  revoked_at?: string | null;
  updated_at?: string;
}

export function getAccessRequestPatientName(req: Partial<AccessRequest> | null | undefined): string {
  if (!req) return 'Registered Citizen';

  // 1. Check nested patient object from backend JOIN (u.first_name, u.last_name)
  if (req.patient) {
    const fullName = `${req.patient.first_name || ''} ${req.patient.last_name || ''}`.trim();
    if (fullName) return fullName;
    if (req.patient.email) return req.patient.email;
  }

  // 2. Check top-level first_name and last_name if present
  const directName = `${req.first_name || ''} ${req.last_name || ''}`.trim();
  if (directName) return directName;

  // 3. Check patient_name if present and not the generic placeholder
  if (
    req.patient_name &&
    req.patient_name.trim() &&
    req.patient_name.trim().toLowerCase() !== 'registered citizen'
  ) {
    return req.patient_name.trim();
  }

  // 4. Check patient_email
  if (req.patient_email?.trim()) {
    return req.patient_email.trim();
  }

  return req.patient_name || 'Registered Citizen';
}

export function getAccessRequestPatientEmail(req: Partial<AccessRequest> | null | undefined): string {
  if (!req) return '';
  return req.patient?.email || req.patient_email || '';
}


export interface PatientLookupResponse {
  id: string;
  first_name: string;
  last_name: string;
  email: string;
}

export interface Patient {
  id: string;
  first_name: string;
  last_name: string;
  email: string;
  phone: string;
  national_id?: string;
  date_of_birth: string;
  sex: 'Male' | 'Female' | 'Other' | 'male' | 'female';
  blood_group: string;
  blood_type?: string;
  allergies: string[];
  last_encounter_date?: string;
  active_grant_clinic_ids: string[];
}

export type EncounterType = 'outpatient' | 'inpatient' | 'emergency' | 'telehealth';
export type EncounterStatus = 'open' | 'closed';

export interface VitalSign {
  id: string;
  encounter_id?: string;
  patient_id?: string;
  systolic_bp?: number;
  diastolic_bp?: number;
  pulse?: number;
  spo2?: number;
  temperature?: number;
  blood_sugar?: number;
  respiratory_rate?: number;
  weight?: number;
  source?: 'clinic' | 'patient';
  notes?: string;
  recorded_at: string;
  created_at?: string;
}

export type LabFlag = 'normal' | 'abnormal' | 'critical';
export type LabCategory = 'Biochemistry' | 'Hematology' | 'Microbiology' | 'Imaging/Radiology' | 'Pathology' | 'Other' | string;

export interface LabResult {
  id: string;
  encounter_id: string;
  test_name: string;
  category: LabCategory;
  summary_notes?: string;
  measurements: string;
  flag: LabFlag;
  created_at: string;
}

export type DiagnosisType = 'provisional' | 'final';

export interface Diagnosis {
  id: string;
  encounter_id: string;
  diagnosis_text: string;
  icd_code?: string;
  diagnosis_type: DiagnosisType;
  notes?: string;
  created_at: string;
}

export interface ClinicalEvaluation {
  id: string;
  encounter_id: string;
  chief_complaint: string;
  history_of_present_illness: string;
  past_admissions?: string;
  family_history?: string;
  allergies_notes?: string;
  general_appearance?: string;
  system_examination?: Record<string, unknown>;
  created_at?: string;
}

export type PrescriptionItemStatus = 'active' | 'completed' | 'deactivated';

export interface PrescriptionItem {
  id: string;
  prescription_id: string;
  medication_name: string;
  dose: string;
  route: string;
  frequency: string;
  duration: string;
  instructions?: string;
  status: PrescriptionItemStatus;
  started_at: string;
  deactivated_at?: string | null;
  completed_at?: string | null;
}

export interface Prescription {
  id: string;
  encounter_id: string;
  notes?: string;
  prescribed_at: string;
  items: PrescriptionItem[];
}

export type AppointmentStatus = 'scheduled' | 'attended' | 'missed' | 'cancelled';

export interface Appointment {
  id: string;
  clinic_id?: string;
  clinic_name: string;
  doctor_id: string;
  doctor_name: string;
  patient_id: string;
  patient_name: string;
  scheduled_at: string;
  status: AppointmentStatus;
  notes?: string;
  source_encounter_id?: string;
  created_at: string;
  updated_at?: string;
}

export interface Encounter {
  id: string;
  patient_id: string;
  patient_name: string;
  doctor_id?: string;
  opened_by_doctor_id: string;
  doctor_name?: string;
  opened_by_doctor_name: string;
  clinic_id: string;
  clinic_name: string;
  type: EncounterType;
  status: EncounterStatus;
  notes?: string;
  started_at: string;
  ended_at?: string | null;
  closed_at?: string | null;
  created_at?: string;
  updated_at?: string;
  vitals: VitalSign[];
  labs: LabResult[];
  diagnoses: Diagnosis[];
  prescriptions: Prescription[];
  appointment?: Appointment;
}

export interface AggregatedEncounterResponse {
  encounter: Encounter;
  patient_name: string;
  doctor_name: string;
  clinic_name: string;
  vitals: VitalSign[];
  labs: LabResult[];
  diagnoses: Diagnosis[];
  prescriptions: Prescription[];
}

export interface MedicalHistoryEntry {
  encounter_id: string;
  encounter_date: string;
  clinic_name: string;
  doctor_name: string;
  diagnoses: string[];
  prescriptions: Array<{
    medication_name: string;
    dose: string;
    frequency: string;
    duration: string;
  }>;
  vitals?: {
    systolic_bp?: number;
    diastolic_bp?: number;
    pulse?: number;
  };
}


