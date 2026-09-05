'use client';

import { useState } from 'react';
import { accessRequestsApi } from '@/lib/api/access-requests';
import { getApiErrorMessage } from '@/lib/api/client';
import { PatientLookupResponse } from '@/types/database';

export function usePatientLookup() {
  const [query, setQuery] = useState('');
  const [foundPatient, setFoundPatient] = useState<PatientLookupResponse | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [hasSearched, setHasSearched] = useState(false);
  const [error, setError] = useState('');

  const executeLookup = async (searchTerm?: string) => {
    const term = (searchTerm !== undefined ? searchTerm : query).trim();
    if (!term) {
      setError('Please enter a citizen email address to search.');
      return null;
    }

    setIsLoading(true);
    setError('');
    setHasSearched(false);

    try {
      // 1. Live call to Go backend: GET /api/v1/patients/lookup?email=...
      const res = await accessRequestsApi.lookupPatient(term);
      if (res && res.id) {
        setFoundPatient(res);
        setHasSearched(true);
        setIsLoading(false);
        return res;
      }
      setError(`No registered citizen found with email "${term}".`);
      setFoundPatient(null);
      setHasSearched(true);
      setIsLoading(false);
      return null;
    } catch (err: unknown) {
      setError(getApiErrorMessage(err, `No registered citizen found with email "${term}".`));
      setFoundPatient(null);
      setHasSearched(true);
      setIsLoading(false);
      return null;
    }
  };

  const resetLookup = () => {
    setQuery('');
    setFoundPatient(null);
    setHasSearched(false);
    setError('');
    setIsLoading(false);
  };

  return {
    query,
    setQuery,
    foundPatient,
    isLoading,
    hasSearched,
    error,
    executeLookup,
    resetLookup,
  };
}

