'use client';

import { useState, useEffect, useMemo } from 'react';
import { clinicsApi } from '@/lib/api/clinics';
import { Clinic } from '@/types/database';
import { AdminAnalytics } from '../types';

export function useAdminStats(providedClinics?: Clinic[]): AdminAnalytics {
  const [fetchedClinics, setFetchedClinics] = useState<Clinic[]>([]);

  useEffect(() => {
    if (providedClinics) return;
    let cancelled = false;
    clinicsApi
      .list()
      .then((res) => {
        if (!cancelled && res?.clinics) {
          setFetchedClinics(res.clinics);
        }
      })
      .catch(() => {});
    return () => {
      cancelled = true;
    };
  }, [providedClinics]);

  const clinics = providedClinics || fetchedClinics;

  return useMemo(() => {
    const activeClinicsCount = clinics.filter((c) => c.status === 'active').length;
    return {
      totalClinics: clinics.length,
      activeClinics: activeClinicsCount,
      totalDoctors: 0,
      totalEncounters: 0,
      totalGrants: 0,
    };
  }, [clinics]);
}
