import { apiClient } from './client';
import { AccessRequest, PatientLookupResponse } from '@/types/database';

export interface CreateAccessRequestPayload {
  patient_id: string;
  reason: string;
}

export interface AccessRequestsListResponse {
  access_requests: AccessRequest[];
}

export interface StatusResponse {
  status: string;
}

export const accessRequestsApi = {
  lookupPatient: (email: string) =>
    apiClient<PatientLookupResponse>('/patients/lookup', {
      method: 'GET',
      params: { email },
    }),

  createRequest: (clinicId: string, payload: CreateAccessRequestPayload) =>
    apiClient<AccessRequest>(`/clinics/${clinicId}/access-requests`, {
      method: 'POST',
      body: JSON.stringify(payload),
    }),

  listRequests: (clinicId: string, status?: string) =>
    apiClient<AccessRequestsListResponse>(`/clinics/${clinicId}/access-requests`, {
      method: 'GET',
      params: status ? { status } : undefined,
    }),

  revokeRequest: (clinicId: string, requestId: string) =>
    apiClient<StatusResponse>(`/clinics/${clinicId}/access-requests/${requestId}/revoke`, {
      method: 'POST',
    }),
};
