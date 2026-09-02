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
  total_doctors: number;
  active_grants_count: number;
}

export type InvitationStatus = 'pending' | 'accepted' | 'expired' | 'revoked';

export interface DoctorInvitation {
  id: string;
  clinic_id: string;
  clinic_name: string;
  email: string;
  specialization?: string;
  token: string;
  status: InvitationStatus;
  expires_at: string; // ISO date string (24h)
  created_at: string;
}

export type AccessRequestStatus = 'pending' | 'approved' | 'denied' | 'expired' | 'revoked';

export interface AccessRequest {
  id: string;
  patient_id: string;
  patient_name: string;
  patient_email: string;
  clinic_id: string;
  clinic_name: string;
  submitted_by_doctor_id: string;
  submitted_by_doctor_name: string;
  reason: string;
  status: AccessRequestStatus;
  created_at: string;
  expires_at: string; // ISO date string (5min)
}

export interface Patient {
  id: string;
  first_name: string;
  last_name: string;
  email: string;
  phone: string;
  national_id?: string;
  date_of_birth: string;
  sex: 'Male' | 'Female' | 'Other';
  blood_group: string;
  allergies: string[];
  last_encounter_date?: string;
  active_grant_clinic_ids: string[];
}

export type EncounterType = 'outpatient' | 'inpatient' | 'emergency' | 'telehealth';
export type EncounterStatus = 'open' | 'closed';

export interface VitalSign {
  id: string;
  encounter_id?: string;
  patient_id: string;
  systolic_bp?: number;
  diastolic_bp?: number;
  pulse?: number;
  spo2?: number;
  temperature?: number;
  blood_sugar?: number;
  respiratory_rate?: number;
  weight?: number;
  source: 'clinic' | 'patient';
  notes?: string;
  recorded_at: string;
}

export type LabFlag = 'normal' | 'abnormal' | 'critical';
export type LabCategory = 'Biochemistry' | 'Hematology' | 'Microbiology' | 'Imaging/Radiology' | 'Pathology' | 'Other';

export interface LabResult {
  id: string;
  encounter_id: string;
  test_name: string;
  category: LabCategory;
  summary_notes: string;
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
  clinic_id: string;
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
}

export interface Encounter {
  id: string;
  patient_id: string;
  patient_name: string;
  clinic_id: string;
  clinic_name: string;
  opened_by_doctor_id: string;
  opened_by_doctor_name: string;
  type: EncounterType;
  status: EncounterStatus;
  notes?: string;
  started_at: string;
  closed_at?: string;
  vitals: VitalSign[];
  labs: LabResult[];
  diagnoses: Diagnosis[];
  prescriptions: Prescription[];
  appointment?: Appointment;
}
