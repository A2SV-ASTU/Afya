import { apiClient } from './client';
import { VitalSign } from '@/types/database';

export interface RecordVitalsPayload {
  systolic_bp?: number;
  diastolic_bp?: number;
  pulse?: number;
  spo2?: number;
  temperature?: number;
  blood_sugar?: number;
  respiratory_rate?: number;
  weight?: number;
  notes?: string;
}

export interface VitalSignResponse {
  vital_sign: VitalSign;
}

export interface VitalSignsListResponse {
  vital_signs: VitalSign[];
}

export const vitalsApi = {
  recordForEncounter: (encounterId: string, payload: RecordVitalsPayload) =>
    apiClient<VitalSignResponse>(`/encounters/${encounterId}/vitals`, {
      method: 'POST',
      body: JSON.stringify(payload),
    }),

  listForPatient: (
    patientId: string,
    query?: { from?: string; to?: string; source?: string }
  ) =>
    apiClient<VitalSignsListResponse>(`/patients/${patientId}/vitals`, {
      method: 'GET',
      params: query,
    }),
};
