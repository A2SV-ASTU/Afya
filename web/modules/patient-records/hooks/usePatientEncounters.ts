'use client';

import { useState, useEffect } from 'react';
import { encountersApi } from '@/lib/api';
import { Encounter } from '@/types/database';
import { mapAggregatedEncounter } from '@/modules/clinical-workspace/lib/encounterMappers';

interface UsePatientEncountersResult {
  encounters: Encounter[];
  isLoading: boolean;
  error: string | null;
  /**
   * Encounters whose clinical detail could not be fetched. They are still listed,
   * but with no vitals/labs/diagnoses — callers MUST warn, never let an empty
   * card read as "this visit had no findings".
   */
  incompleteCount: number;
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
  const [incompleteCount, setIncompleteCount] = useState(0);

  useEffect(() => {
    if (!patientId) {
      setIsLoading(false);
      return;
    }

    let cancelled = false;
    setIsLoading(true);
    setError(null);
    setIncompleteCount(0);

    (async () => {
      try {
        const list = await encountersApi.listForPatient(patientId);
        const summaries = list.encounters ?? [];

        const settled = await Promise.allSettled(
          summaries.map((summary) => encountersApi.getById(summary.id))
        );

        let incomplete = 0;
        const detailed = settled.map((outcome, i) => {
          if (outcome.status === 'fulfilled') {
            return mapAggregatedEncounter(outcome.value);
          }
          incomplete += 1;
          return mapAggregatedEncounter({ encounter: summaries[i] });
        });

        detailed.sort(
          (a, b) => new Date(b.started_at).getTime() - new Date(a.started_at).getTime()
        );

        if (!cancelled) {
          setEncounters(detailed);
          setIncompleteCount(incomplete);
        }
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

  return { encounters, isLoading, error, incompleteCount };
}
