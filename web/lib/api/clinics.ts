import { apiClient } from './client';
import { Clinic, DoctorResponse, DoctorInvitation } from '@/types/database';
import type { Doctor } from '@/types/clinics';

export interface CreateClinicPayload {
  name: string;
  email: string;
  phone: string;
  address: string;
  admin_first_name: string;
  admin_last_name: string;
}

export interface ClinicsListResponse {
  clinics: Clinic[];
}

export interface ClinicResponse {
  clinic: Clinic;
}

export interface ClinicDoctorsResponse {
  doctors: DoctorResponse[];
}

export interface ClinicInvitationsResponse {
  invitations: DoctorInvitation[];
}

export interface StatusResponse {
  status: string;
}

export const clinicsApi = {
  create: (payload: CreateClinicPayload) =>
    apiClient<Clinic>('/clinics', {
      method: 'POST',
      body: JSON.stringify(payload),
    }),

  list: () =>
    apiClient<ClinicsListResponse>('/clinics', {
      method: 'GET',
    }),

  getById: (clinicId: string) =>
    apiClient<ClinicResponse>(`/clinics/${clinicId}`, {
      method: 'GET',
    }),

  activate: (clinicId: string) =>
    apiClient<StatusResponse>(`/clinics/${clinicId}/activate`, {
      method: 'PATCH',
    }),

  deactivate: (clinicId: string) =>
    apiClient<StatusResponse>(`/clinics/${clinicId}/deactivate`, {
      method: 'PATCH',
    }),

  listDoctors: (clinicId: string) =>
    apiClient<ClinicDoctorsResponse>(`/clinics/${clinicId}/doctors`, {
      method: 'GET',
    }),

  activateDoctor: (clinicId: string, doctorId: string) =>
    apiClient<StatusResponse>(`/clinics/${clinicId}/doctors/${doctorId}/activate`, {
      method: 'PATCH',
    }),

  deactivateDoctor: (clinicId: string, doctorId: string) =>
    apiClient<StatusResponse>(`/clinics/${clinicId}/doctors/${doctorId}/deactivate`, {
      method: 'PATCH',
    }),

  listInvitations: (clinicId: string) =>
    apiClient<ClinicInvitationsResponse>(`/clinics/${clinicId}/invitations`, {
      method: 'GET',
    }),
};

// Standalone function exports for compatibility
export async function createClinic(payload: CreateClinicPayload): Promise<Clinic> {
  return clinicsApi.create(payload);
}

export async function getClinics(): Promise<Clinic[]> {
  const res = await clinicsApi.list();
  return res.clinics || [];
}

export async function getClinic(clinicId: string): Promise<Clinic> {
  const res = await clinicsApi.getById(clinicId);
  return (res as unknown as { data?: Clinic }).data || res.clinic || (res as unknown as Clinic);
}

export async function activateClinic(clinicId: string): Promise<{ status: string }> {
  return clinicsApi.activate(clinicId);
}

export async function deactivateClinic(clinicId: string): Promise<{ status: string }> {
  return clinicsApi.deactivate(clinicId);
}

export async function getDoctors(clinicId: string): Promise<Doctor[]> {
  const res = await clinicsApi.listDoctors(clinicId);
  return (res.doctors || []) as unknown as Doctor[];
}

export async function activateDoctor(clinicId: string, doctorId: string): Promise<{ status: string }> {
  return clinicsApi.activateDoctor(clinicId, doctorId);
}

export async function deactivateDoctor(clinicId: string, doctorId: string): Promise<{ status: string }> {
  return clinicsApi.deactivateDoctor(clinicId, doctorId);
}
