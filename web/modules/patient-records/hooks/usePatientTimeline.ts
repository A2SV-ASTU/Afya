'use client';

import { useMemo } from 'react';
import { useStore } from '@/lib/store';
import { TimelineEncounterCardData, TimelinePrescriptionItem } from '../types';

export function usePatientTimeline(patientId: string): TimelineEncounterCardData[] {
  const { encounters } = useStore();

  return useMemo(() => {
    const patientEncounters = encounters.filter((e) => e.patient_id === patientId);

    return patientEncounters
      .map((enc): TimelineEncounterCardData => {
        const primaryVitals = enc.vitals && enc.vitals.length > 0 ? enc.vitals[0] : null;

        const allRxItems: TimelinePrescriptionItem[] = enc.prescriptions
          ? enc.prescriptions.flatMap((rx) =>
              rx.items.map((item) => ({
                medication_name: item.medication_name,
                dose: item.dose,
                route: item.route || 'oral',
                frequency: item.frequency || 'OD',
                duration: item.duration || '7 days',
                instructions: item.instructions,
              }))
            )
          : [];

        const diagnosisSummary =
          enc.diagnoses && enc.diagnoses.length > 0
            ? enc.diagnoses.map((d) => d.diagnosis_text).join(', ')
            : null;

        return {
          encounter_id: enc.id,
          date: enc.started_at,
          chief_complaint: enc.notes || 'Routine Clinical Assessment & Patient Evaluation',
          diagnosis: diagnosisSummary,
          prescription: allRxItems,
          vitals: primaryVitals
            ? {
                systolic_bp: primaryVitals.systolic_bp ?? null,
                diastolic_bp: primaryVitals.diastolic_bp ?? null,
                pulse: primaryVitals.pulse ?? null,
                respiratory_rate: primaryVitals.respiratory_rate ?? null,
                temperature: primaryVitals.temperature ?? null,
                spo2: primaryVitals.spo2 ?? null,
                blood_sugar: primaryVitals.blood_sugar ?? null,
                weight: primaryVitals.weight ?? null,
              }
            : null,
          labs: enc.labs || [],
          diagnosesList: enc.diagnoses || [],
          rawEncounter: enc,
        };
      })
      .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
  }, [encounters, patientId]);
}
