import { apiClient } from './client';
import { ClinicalEvaluation } from '@/types/database';

export interface CreateClinicalEvaluationPayload {
  chief_complaint: string;
  history_of_present_illness: string;
  past_admissions?: string;
  family_history?: string;
  allergies_notes?: string;
  general_appearance?: string;
  system_examination?: Record<string, unknown>;
}

export interface ClinicalEvaluationResponse {
  clinical_evaluation: ClinicalEvaluation;
}

export const clinicalEvaluationsApi = {
  create: (encounterId: string, payload: CreateClinicalEvaluationPayload) =>
    apiClient<ClinicalEvaluationResponse>(`/encounters/${encounterId}/clinical-evaluation`, {
      method: 'POST',
      body: JSON.stringify(payload),
    }),

  getByEncounterId: (encounterId: string) =>
    apiClient<ClinicalEvaluationResponse>(`/encounters/${encounterId}/clinical-evaluation`, {
      method: 'GET',
    }),
};
