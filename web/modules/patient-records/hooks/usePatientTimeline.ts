'use client';

import { useState, useEffect } from 'react';
import { clinicalEvaluationsApi } from '@/lib/api';
import { Encounter } from '@/types/database';
import { TimelineEncounterCardData, TimelinePrescriptionItem } from '../types';
import { usePatientEncounters } from './usePatientEncounters';

const DEFAULT_CHIEF_COMPLAINT = 'Routine clinical assessment & patient evaluation';

interface UsePatientTimelineResult {
  timeline: TimelineEncounterCardData[];
  isLoading: boolean;
  error: string | null;
}

function toCardData(enc: Encounter, chiefComplaint: string): TimelineEncounterCardData {
  const primaryVitals = enc.vitals && enc.vitals.length > 0 ? enc.vitals[0] : null;

  const prescription: TimelinePrescriptionItem[] = (enc.prescriptions ?? []).flatMap((rx) =>
    (rx.items ?? []).map((item) => ({
      medication_name: item.medication_name,
      dose: item.dose,
      route: item.route || 'oral',
      frequency: item.frequency || 'OD',
      duration: item.duration || '—',
      instructions: item.instructions,
    }))
  );

  const diagnosis =
    enc.diagnoses && enc.diagnoses.length > 0
      ? enc.diagnoses.map((d) => d.diagnosis_text).join(', ')
      : null;

  return {
    encounter_id: enc.id,
    date: enc.started_at || enc.created_at || new Date().toISOString(),
    chief_complaint: chiefComplaint || DEFAULT_CHIEF_COMPLAINT,
    diagnosis,
    prescription,
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
    labs: enc.labs ?? [],
    diagnosesList: enc.diagnoses ?? [],
    rawEncounter: enc,
  };
}

/**
 * Builds the longitudinal timeline for a patient from their real encounter
 * records. The chief complaint for each card comes from that encounter's
 * clinical evaluation (`GET /encounters/:id/clinical-evaluation`).
 */
export function usePatientTimeline(patientId: string): UsePatientTimelineResult {
  const { encounters, isLoading: encountersLoading, error } = usePatientEncounters(patientId);
  const [timeline, setTimeline] = useState<TimelineEncounterCardData[]>([]);
  const [complaintsLoading, setComplaintsLoading] = useState(true);

  useEffect(() => {
    if (encountersLoading) return;

    let cancelled = false;
    setComplaintsLoading(true);

    (async () => {
      const complaints = await Promise.all(
        encounters.map((enc) =>
          clinicalEvaluationsApi
            .getByEncounterId(enc.id)
            .then((res) => res.clinical_evaluation?.chief_complaint ?? '')
            .catch(() => '')
        )
      );

      if (cancelled) return;
      setTimeline(encounters.map((enc, i) => toCardData(enc, complaints[i])));
      setComplaintsLoading(false);
    })();

    return () => {
      cancelled = true;
    };
  }, [encounters, encountersLoading]);

  return { timeline, isLoading: encountersLoading || complaintsLoading, error };
}
