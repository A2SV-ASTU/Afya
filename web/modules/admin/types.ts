import { Clinic } from '@/types/database';

export interface AdminAnalytics {
  totalClinics: number;
  activeClinics: number;
  totalDoctors: number;
  totalEncounters: number;
  totalGrants: number;
}

export interface CreateClinicInput {
  name: string;
  email: string;
  phone: string;
  address: string;
  admin_name: string;
  admin_password?: string;
}

export interface ClinicFilterOptions {
  searchQuery: string;
  statusFilter: 'all' | 'active' | 'deactivated';
}
