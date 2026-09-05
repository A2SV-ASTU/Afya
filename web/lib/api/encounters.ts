import { apiClient } from './client';
import { Encounter, AggregatedEncounterResponse, MedicalHistoryEntry } from '@/types/database';

export interface EncounterResponse {
  encounter: Encounter;
}

export interface EncountersListResponse {
  encounters: Encounter[];
  page: number;
  limit: number;
  total: number;
}

export const encountersApi = {
  open: (patientId: string) =>
    apiClient<EncounterResponse>(`/patients/${patientId}/encounters`, {
      method: 'POST',
    }),

  listForPatient: (patientId: string, page = 1, limit = 20) =>
    apiClient<EncountersListResponse>(`/patients/${patientId}/encounters`, {
      method: 'GET',
      params: { page, limit },
    }),

  getById: (encounterId: string) =>
    apiClient<AggregatedEncounterResponse>(`/encounters/${encounterId}`, {
      method: 'GET',
    }),

  close: (encounterId: string) =>
    apiClient<EncounterResponse>(`/encounters/${encounterId}/close`, {
      method: 'PATCH',
    }),

  getMedicalHistory: (encounterId: string) =>
    apiClient<MedicalHistoryEntry[]>(`/encounters/${encounterId}/medical-history`, {
      method: 'GET',
    }),
};
