'use client';

import { useState, useEffect } from 'react';
import { vitalsApi } from '@/lib/api';
import { VitalsTrendPoint } from '../types';

interface UseVitalsTrendsResult {
  trends: VitalsTrendPoint[];
  isLoading: boolean;
  error: string | null;
}

/**
 * Loads a patient's recorded vital signs (`GET /patients/:id/vitals`) and shapes
 * them into chart points for the longitudinal BP / pulse / glucose trend chart.
 */
export function useVitalsTrends(patientId: string): UseVitalsTrendsResult {
  const [trends, setTrends] = useState<VitalsTrendPoint[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!patientId) {
      setIsLoading(false);
      return;
    }

    let cancelled = false;
    setIsLoading(true);
    setError(null);

    vitalsApi
      .listForPatient(patientId)
      .then((res) => {
        if (cancelled) return;
        const timeOf = (v: { recorded_at?: string; created_at?: string }) =>
          new Date(v.recorded_at || v.created_at || 0).getTime();

        const points: VitalsTrendPoint[] = (res.vital_signs ?? [])
          .filter(
            (v) =>
              v.systolic_bp != null ||
              v.diastolic_bp != null ||
              v.pulse != null ||
              v.blood_sugar != null
          )
          .sort((a, b) => timeOf(a) - timeOf(b))
          .map((v) => ({
            date: new Date(timeOf(v)).toLocaleDateString(undefined, {
              month: 'short',
              day: 'numeric',
            }),
            systolic: v.systolic_bp ?? null,
            diastolic: v.diastolic_bp ?? null,
            pulse: v.pulse ?? null,
            bloodSugar: v.blood_sugar ?? null,
          }));

        setTrends(points);
        setIsLoading(false);
      })
      .catch((err) => {
        if (cancelled) return;
        setError(err instanceof Error ? err.message : 'Failed to load vitals trends.');
        setIsLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, [patientId]);

  return { trends, isLoading, error };
}
