import { DoctorInvitation, AccessRequest, Patient, User } from '@/types/database';

export interface InviteDoctorInput {
  email: string;
  specialization: string;
  clinicId?: string;
}

export interface AccessRequestInput {
  patientId: string;
  doctorId: string;
  reason: string;
}

export interface ClinicProfileInput {
  name: string;
  phone: string;
  address: string;
}

export interface PatientLookupResult {
  patient: Patient | null;
  searched: boolean;
  error?: string;
}
