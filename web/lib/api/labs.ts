import { apiClient } from './client';
import { LabResult, LabFlag, LabCategory } from '@/types/database';

export interface CreateLabResultPayload {
  test_name: string;
  category: LabCategory;
  summary_notes?: string;
  measurements: Record<string, unknown> | string;
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
