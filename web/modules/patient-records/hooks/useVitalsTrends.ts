'use client';

import { useMemo } from 'react';
import { useStore } from '@/lib/store';
import { VitalsTrendPoint } from '../types';

export function useVitalsTrends(patientId: string): VitalsTrendPoint[] {
  const { encounters } = useStore();

  return useMemo(() => {
    const patientEncounters = encounters.filter((e) => e.patient_id === patientId);
    const points: VitalsTrendPoint[] = [];

    patientEncounters.forEach((enc) => {
      enc.vitals?.forEach((vit) => {
        if (vit.systolic_bp && vit.diastolic_bp) {
          points.push({
            date: new Date(vit.recorded_at).toLocaleDateString(undefined, {
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
    });

    return points;
  }, [encounters, patientId]);
}
