import { apiClient } from './client';
import { Prescription, PrescriptionItem } from '@/types/database';

export interface CreatePrescriptionItemPayload {
  medication_name: string;
  dose: string;
  route: string;
  frequency: string;
  duration: string;
  instructions?: string;
}

export interface CreatePrescriptionPayload {
  notes?: string;
  items: CreatePrescriptionItemPayload[];
}

export interface PrescriptionResponse {
  prescription: Prescription;
}

export interface PrescriptionsListResponse {
  prescriptions: Prescription[];
}

export interface StatusResponse {
  status: string;
}

export const prescriptionsApi = {
  create: (encounterId: string, payload: CreatePrescriptionPayload) =>
    apiClient<PrescriptionResponse>(`/encounters/${encounterId}/prescriptions`, {
      method: 'POST',
      body: JSON.stringify(payload),
    }),

  listForEncounter: (encounterId: string) =>
    apiClient<PrescriptionsListResponse>(`/encounters/${encounterId}/prescriptions`, {
      method: 'GET',
    }),

  update: (
    prescriptionId: string,
    payload: { notes?: string; items?: PrescriptionItem[] }
  ) =>
    apiClient<PrescriptionResponse>(`/prescriptions/${prescriptionId}`, {
      method: 'PATCH',
      body: JSON.stringify(payload),
    }),

  complete: (prescriptionId: string, itemIds?: string[]) =>
    apiClient<StatusResponse>(`/prescriptions/${prescriptionId}/complete`, {
      method: 'PATCH',
      body: JSON.stringify({ item_ids: itemIds }),
    }),

  deactivate: (prescriptionId: string) =>
    apiClient<StatusResponse>(`/prescriptions/${prescriptionId}/deactivate`, {
      method: 'PATCH',
    }),
};
