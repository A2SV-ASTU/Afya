'use client';

import { useState, useEffect } from 'react';
import { encountersApi } from '@/lib/api';
import { Encounter } from '@/types/database';
import { mapAggregatedEncounter } from '@/modules/clinical-workspace/lib/encounterMappers';

interface UsePatientEncountersResult {
  encounters: Encounter[];
  isLoading: boolean;
  error: string | null;
}

/**
 * Loads a patient's full clinical record: the paginated encounter list
 * (`GET /patients/:id/encounters`) hydrated with the aggregated detail for each
 * encounter (`GET /encounters/:id`, which carries vitals, labs, diagnoses and
 * prescriptions). Results are newest-first.
 */
export function usePatientEncounters(patientId: string): UsePatientEncountersResult {
  const [encounters, setEncounters] = useState<Encounter[]>([]);
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

    (async () => {
      try {
        const list = await encountersApi.listForPatient(patientId);
        const summaries = list.encounters ?? [];

        const detailed = await Promise.all(
          summaries.map((summary) =>
            encountersApi
              .getById(summary.id)
              .then((res) => mapAggregatedEncounter(res))
              .catch(() => mapAggregatedEncounter({ encounter: summary }))
          )
        );

        detailed.sort(
          (a, b) => new Date(b.started_at).getTime() - new Date(a.started_at).getTime()
        );

        if (!cancelled) setEncounters(detailed);
      } catch (err) {
        if (!cancelled) {
          setError(err instanceof Error ? err.message : 'Failed to load patient records.');
        }
      } finally {
        if (!cancelled) setIsLoading(false);
      }
    })();

    return () => {
      cancelled = true;
    };
  }, [patientId]);

  return { encounters, isLoading, error };
}
