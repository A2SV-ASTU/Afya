'use client';

import { useState } from 'react';
import { useStore } from '@/lib/store';
import { Patient } from '@/types/database';

export function usePatientLookup() {
  const { lookupPatientExact } = useStore();
  const [query, setQuery] = useState('');
  const [foundPatient, setFoundPatient] = useState<Patient | null>(null);
  const [hasSearched, setHasSearched] = useState(false);
  const [error, setError] = useState('');

  const executeLookup = (searchTerm?: string) => {
    const term = searchTerm !== undefined ? searchTerm : query;
    if (!term.trim()) {
      setError('Please enter a valid Patient Identifier (e.g. PAT-001, phone, or email).');
      return null;
    }

    setError('');
    const result = lookupPatientExact(term.trim());
    setFoundPatient(result);
    setHasSearched(true);
    return result;
  };

  const resetLookup = () => {
    setQuery('');
    setFoundPatient(null);
    setHasSearched(false);
    setError('');
  };

  return {
    query,
    setQuery,
    foundPatient,
    hasSearched,
    error,
    executeLookup,
    resetLookup,
  };
}
