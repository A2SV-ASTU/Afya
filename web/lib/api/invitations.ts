import { apiClient } from './client';
import type { Doctor } from '@/types/clinics';

// POST /clinics/:clinicId/invitations -> { message: "..." }
export async function inviteDoctor(clinicId: string, email: string): Promise<{ message: string }> {
  return apiClient.post<{ message: string }>(`/clinics/${clinicId}/invitations`, { email });
}

// POST /invitations/:token/accept -> raw doctor object
export async function acceptInvitation(token: string, payload: {
  first_name: string;
  last_name: string;
  phone: string;
  password: string;
  license_number: string;
  specialization: string;
}): Promise<Doctor> {
  return apiClient.post<Doctor>(`/invitations/${token}/accept`, payload);
}