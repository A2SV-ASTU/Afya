import { apiClient } from './client';
import { User, DoctorInvitation } from '@/types/database';
import type { Doctor } from '@/types/clinics';

export interface InviteDoctorPayload {
  email: string;
}

export interface AcceptInvitationPayload {
  first_name: string;
  last_name: string;
  phone: string;
  password: string;
  license_number?: string;
  specialization?: string;
}

export interface MessageResponse {
  message: string;
}

export const invitationsApi = {
  inviteDoctor: (clinicId: string, payload: InviteDoctorPayload) =>
    apiClient<MessageResponse>(`/clinics/${clinicId}/invitations`, {
      method: 'POST',
      body: JSON.stringify(payload),
    }),

  listClinicInvitations: (clinicId: string) =>
    apiClient<{ invitations: DoctorInvitation[] }>(`/clinics/${clinicId}/invitations`, {
      method: 'GET',
    }),

  acceptInvitation: (token: string, payload: AcceptInvitationPayload) =>
    apiClient<User>(`/invitations/${token}/accept`, {
      method: 'POST',
      body: JSON.stringify(payload),
    }),
};

export async function inviteDoctor(clinicId: string, email: string): Promise<MessageResponse> {
  return invitationsApi.inviteDoctor(clinicId, { email });
}

export async function acceptInvitation(
  token: string,
  payload: AcceptInvitationPayload
): Promise<Doctor> {
  const user = await invitationsApi.acceptInvitation(token, payload);
  return user as unknown as Doctor;
}
