import { apiClient } from './client';
import { LabResult, LabFlag } from '@/types/database';

export interface CreateLabResultPayload {
  test_name: string;
  /** Backend enum: laboratory | imaging | pathology | other */
  category: string;
  summary_notes?: string;
  /** Backend expects a JSON object keyed by analyte name. */
  measurements?: Record<string, unknown>;
  flag?: LabFlag;
}

export interface LabResultResponse {
  lab_result: LabResult;
}

export const labsApi = {
  create: (encounterId: string, payload: CreateLabResultPayload) =>
    apiClient<LabResultResponse>(`/encounters/${encounterId}/labs`, {
      method: 'POST',
      body: JSON.stringify(payload),
    }),

  listForEncounter: (encounterId: string) =>
    apiClient<LabResult[]>(`/encounters/${encounterId}/labs`, {
      method: 'GET',
    }),
};
