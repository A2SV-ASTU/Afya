'use client';

import { useMemo } from 'react';
import { useStore } from '@/lib/store';
import { AdminAnalytics } from '../types';

export function useAdminStats(): AdminAnalytics {
  const { clinics, doctors, encounters, accessRequests } = useStore();

  return useMemo(() => {
    const activeClinicsCount = clinics.filter((c) => c.status === 'active').length;
    const activeGrantsCount = accessRequests.filter((r) => r.status === 'approved').length;
    return {
      totalClinics: clinics.length,
      activeClinics: activeClinicsCount,
      totalDoctors: doctors.length,
      totalEncounters: encounters.length,
      totalGrants: activeGrantsCount,
    };
  }, [clinics, doctors, encounters, accessRequests]);
}
