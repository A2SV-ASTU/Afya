'use client';

import { useState, useEffect } from 'react';
import { vitalsApi } from '@/lib/api';
import { VitalsTrendPoint } from '../types';

export function useVitalsTrends(patientId: string) {
  const [trends, setTrends] = useState<VitalsTrendPoint[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    let mounted = true;
    if (!patientId) return;

    vitalsApi.listForPatient(patientId)
      .then((res) => {
        if (!mounted) return;
        const vitals = res.vitals || [];
        const points: VitalsTrendPoint[] = [];

        vitals.forEach((vit) => {
          if (vit.systolic_bp && vit.diastolic_bp) {
            points.push({
              date: new Date(vit.recorded_at || vit.created_at || new Date()).toLocaleDateString(undefined, {
                month: 'short',
                day: 'numeric',
              }),
              systolic: vit.systolic_bp,
              diastolic: vit.diastolic_bp,
              pulse: vit.pulse || 72,
              bloodSugar: vit.blood_sugar,
            });
          }
        });

        // Optionally sort by date here if needed
        setTrends(points);
        setIsLoading(false);
      })
      .catch((err) => {
        if (!mounted) return;
        console.error('Error fetching vitals trends', err);
        setIsLoading(false);
      });

    return () => {
      mounted = false;
    };
  }, [patientId]);

  return { trends, isLoading };
}
