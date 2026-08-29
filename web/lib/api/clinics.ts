import { apiClient } from './client';
import type { Clinic } from '@/types/clinics';

// POST /clinics -> raw clinic object
export async function createClinic(payload: {
    name: string;
    email: string;
    phone: string;
    address: string;
    admin_first_name: string;
    admin_last_name: string;
}): Promise<Clinic> {
    return apiClient.post<Clinic>('/clinics', payload);
}

// GET /clinics -> { clinics: [...] }
export async function getClinics(): Promise<Clinic[]> {
    const res = await apiClient.get<{ clinics: Clinic[] }>('/clinics');
    return res.clinics;
}

// PATCH .../activate or .../deactivate -> { status: "active" | "deactivated" }
export async function activateClinic(clinicId: string): Promise<{ status: string }> {
    return apiClient.patch<{ status: string }>(`/clinics/${clinicId}/activate`);
}

export async function deactivateClinic(clinicId: string): Promise<{ status: string }> {
    return apiClient.patch<{ status: string }>(`/clinics/${clinicId}/deactivate`);
}

export async function activateDoctor(clinicId: string, doctorId: string): Promise<{ status: string }> {
    return apiClient.patch<{ status: string }>(`/clinics/${clinicId}/doctors/${doctorId}/activate`);
}

export async function deactivateDoctor(clinicId: string, doctorId: string): Promise<{ status: string }> {
    return apiClient.patch<{ status: string }>(`/clinics/${clinicId}/doctors/${doctorId}/deactivate`);
}
