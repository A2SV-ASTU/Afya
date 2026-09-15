import { apiClient } from './client';
import { Appointment, AppointmentStatus } from '@/types/database';

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

/**
 * Statuses the API accepts on a status update. `scheduled` is the state an
 * appointment is created in and cannot be set again.
 */
export type UpdatableAppointmentStatus = Extract<
  AppointmentStatus,
  'attended' | 'missed' | 'cancelled'
>;

export interface UpdateAppointmentStatusPayload {
  status: UpdatableAppointmentStatus;
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

  updateStatus: (appointmentId: string, status: UpdatableAppointmentStatus) =>
    apiClient<AppointmentResponse>(`/appointments/${appointmentId}/status`, {
      method: 'PATCH',
      body: JSON.stringify({ status } satisfies UpdateAppointmentStatusPayload),
    }),
};
