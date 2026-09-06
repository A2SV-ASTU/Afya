import { apiClient } from './client';
import { Diagnosis, DiagnosisType } from '@/types/database';

export interface CreateDiagnosisPayload {
  diagnosis_text: string;
  diagnosis_type: DiagnosisType;
  icd_code?: string;
  notes?: string;
}

export interface DiagnosisResponse {
  diagnosis: Diagnosis;
}

export const diagnosesApi = {
  create: (encounterId: string, payload: CreateDiagnosisPayload) =>
    apiClient<DiagnosisResponse>(`/encounters/${encounterId}/diagnoses`, {
      method: 'POST',
      body: JSON.stringify(payload),
    }),

  listForEncounter: (encounterId: string) =>
    apiClient<Diagnosis[]>(`/encounters/${encounterId}/diagnoses`, {
      method: 'GET',
    }),
};
