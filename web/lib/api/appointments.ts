import { apiClient } from './client';
import { Appointment } from '@/types/database';

export interface CreateAppointmentPayload {
  patient_id: string;
  scheduled_at: string;
  notes?: string;
}

export interface AppointmentResponse {
  appointment: Appointment;
}

export interface AppointmentsListResponse {
  appointments: Appointment[];
}

export const appointmentsApi = {
  create: (payload: CreateAppointmentPayload) =>
    apiClient<AppointmentResponse>('/appointments', {
      method: 'POST',
      body: JSON.stringify(payload),
    }),

  listForPatient: (patientId: string, status?: string) =>
    apiClient<AppointmentsListResponse>(`/patients/${patientId}/appointments`, {
      method: 'GET',
      params: status ? { status } : undefined,
    }),
};
