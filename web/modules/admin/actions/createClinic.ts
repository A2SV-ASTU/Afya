import { CreateClinicInput, AdminAnalytics } from '../types';
import { Clinic } from '@/types/database';
import { clinicsApi } from '@/lib/api/clinics';

export async function createClinicAction(input: CreateClinicInput): Promise<Clinic> {
  const parts = input.admin_name.trim().split(' ');
  const admin_first_name = parts[0] || 'Clinic';
  const admin_last_name = parts.slice(1).join(' ') || 'Admin';

  const res = await clinicsApi.create({
    name: input.name,
    email: input.email,
    phone: input.phone,
    address: input.address,
    admin_first_name,
    admin_last_name,
  });

  return {
    ...res,
    admin_name: input.admin_name,
    admin_email: input.email,
    total_doctors: 0,
    active_grants_count: 0,
  };
}

export async function toggleClinicStatusAction(
  clinicId: string,
  currentStatus: 'active' | 'deactivated'
): Promise<'active' | 'deactivated'> {
  if (currentStatus === 'active') {
    await clinicsApi.deactivate(clinicId);
    return 'deactivated';
  } else {
    await clinicsApi.activate(clinicId);
    return 'active';
  }
}

export async function getAnalyticsAction(): Promise<AdminAnalytics> {
  const res = await clinicsApi.list();
  const list = res.clinics || [];
  const activeCount = list.filter((c) => c.status === 'active').length;

  return {
    totalClinics: list.length,
    activeClinics: activeCount,
    totalDoctors: 0,
    totalEncounters: 0,
    totalGrants: 0,
  };
}

