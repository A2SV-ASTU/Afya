import { InviteDoctorInput, AccessRequestInput, ClinicProfileInput } from '../types';
import { DoctorInvitation, AccessRequest, Patient } from '@/types/database';
import { api } from '@/modules/core/lib/api-client';

export async function inviteDoctorAction(input: InviteDoctorInput): Promise<DoctorInvitation> {
  const token = `inv-${Math.random().toString(36).substring(2, 9)}`;
  const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();

  const newInvitation: DoctorInvitation = {
    id: `inv-rec-${Date.now()}`,
    clinic_id: input.clinicId || 'cln-01',
    clinic_name: 'St. Jude Healthcare Centre',
    email: input.email,
    specialization: input.specialization,
    token,
    status: 'pending',
    expires_at: expiresAt,
    created_at: new Date().toISOString(),
  };

  return newInvitation;
}

export async function deactivateDoctorAction(doctorId: string): Promise<boolean> {
  return true;
}

export async function lookupPatientAction(nationalIdOrPhone: string): Promise<Patient | null> {
  return null;
}

export async function sendAccessRequestAction(input: AccessRequestInput): Promise<AccessRequest> {
  const expiresAt = new Date(Date.now() + 5 * 60 * 1000).toISOString();
  return {
    id: `req-${Date.now()}`,
    patient_id: input.patientId,
    patient_name: 'Selected Patient',
    patient_email: 'patient@afyamind.org',
    clinic_id: 'cln-01',
    clinic_name: 'St. Jude Healthcare Centre',
    submitted_by_doctor_id: input.doctorId,
    submitted_by_doctor_name: 'Attending Doctor',
    reason: input.reason,
    status: 'pending',
    created_at: new Date().toISOString(),
    expires_at: expiresAt,
  };
}

export async function updateClinicProfileAction(clinicId: string, input: ClinicProfileInput): Promise<boolean> {
  return true;
}
