import { CreateClinicInput, AdminAnalytics } from '../types';
import { Clinic } from '@/types/database';
import { api } from '@/modules/core/lib/api-client';

export async function createClinicAction(input: CreateClinicInput): Promise<Clinic> {
  // In pure API environment:
  // return await api.post<Clinic>('/api/admin/clinics', input);

  // Return formatted clinic instance
  const newClinic: Clinic = {
    id: `cln-${Date.now()}`,
    name: input.name,
    email: input.email,
    phone: input.phone,
    address: input.address,
    status: 'active',
    admin_name: input.admin_name,
    admin_email: input.email,
    created_at: new Date().toISOString(),
    total_doctors: 0,
    active_grants_count: 0,
  };
  return newClinic;
}

export async function toggleClinicStatusAction(clinicId: string, currentStatus: 'active' | 'deactivated'): Promise<'active' | 'deactivated'> {
  const nextStatus = currentStatus === 'active' ? 'deactivated' : 'active';
  // return await api.patch(`/api/admin/clinics/${clinicId}/status`, { status: nextStatus });
  return nextStatus;
}

export async function getAnalyticsAction(): Promise<AdminAnalytics> {
  // return await api.get<AdminAnalytics>('/api/admin/analytics');
  return {
    totalClinics: 3,
    activeClinics: 3,
    totalDoctors: 8,
    totalEncounters: 142,
    totalGrants: 19,
  };
}
