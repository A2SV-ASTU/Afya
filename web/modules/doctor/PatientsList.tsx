'use client';

import React, { useCallback, useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import {
  AlertCircle,
  ArrowRight,
  Building2,
  FolderOpen,
  RefreshCw,
  Search,
  ShieldCheck,
  Users,
} from 'lucide-react';
import { useAuth } from '@/modules/core/context/AuthContext';
import { accessRequestsApi } from '@/lib/api/access-requests';
import { getApiErrorMessage } from '@/lib/api/client';
import { Button } from '@/modules/core/ui/Button';
import { EmptyState } from '@/modules/core/ui/EmptyState';
import {
  AccessRequest,
  getAccessRequestPatientEmail,
  getAccessRequestPatientName,
} from '@/types/database';

function initialsFor(grant: AccessRequest): string {
  const first = grant.patient?.first_name || grant.first_name || '';
  const last = grant.patient?.last_name || grant.last_name || '';
  const fromNames = `${first.charAt(0)}${last.charAt(0)}`.trim();
  if (fromNames) return fromNames.toUpperCase();
  return getAccessRequestPatientName(grant).slice(0, 2).toUpperCase();
}

function formatGrantedOn(value: string): string {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return 'Unknown date';
  return new Intl.DateTimeFormat('en-GB', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  }).format(date);
}

export function PatientsList() {
  const { currentUser, isReady } = useAuth();
  const clinicId = currentUser?.clinic_id;

  const [grants, setGrants] = useState<AccessRequest[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState('');
  const [search, setSearch] = useState('');

  const fetchGrants = useCallback(async () => {
    if (!clinicId) {
      setIsLoading(false);
      return;
    }
    setIsLoading(true);
    setErrorMessage('');

    try {
      // GET /api/v1/clinics/:clinicId/access-requests?status=approved
      const res = await accessRequestsApi.listRequests(clinicId, 'approved');
      setGrants(res?.access_requests ?? []);
    } catch (err: unknown) {
      setGrants([]);
      setErrorMessage(
        getApiErrorMessage(err, 'Failed to load the authorized patient directory.')
      );
    } finally {
      setIsLoading(false);
    }
  }, [clinicId]);

  useEffect(() => {
    if (clinicId) {
      fetchGrants();
    } else if (isReady) {
      setIsLoading(false);
    }
  }, [clinicId, isReady, fetchGrants]);

  // Revoking a grant only stamps revoked_at — the row keeps status 'approved',
  // so the server-side status filter alone is not enough to exclude it.
  const authorizedPatients = useMemo(() => {
    const live = grants.filter(
      (g) => g.status === 'approved' && !g.revoked_at
    );

    // A patient may hold several approved grants for this clinic; show the newest.
    const newestPerPatient = new Map<string, AccessRequest>();
    for (const grant of live) {
      const existing = newestPerPatient.get(grant.patient_id);
      if (!existing || new Date(grant.created_at) > new Date(existing.created_at)) {
        newestPerPatient.set(grant.patient_id, grant);
      }
    }
    return Array.from(newestPerPatient.values());
  }, [grants]);

  const filteredPatients = useMemo(() => {
    const term = search.trim().toLowerCase();
    if (!term) return authorizedPatients;
    return authorizedPatients.filter((grant) => {
      const name = getAccessRequestPatientName(grant).toLowerCase();
      const email = getAccessRequestPatientEmail(grant).toLowerCase();
      return (
        name.includes(term) ||
        email.includes(term) ||
        grant.patient_id.toLowerCase().includes(term)
      );
    });
  }, [authorizedPatients, search]);

  const header = (
    <div className="flex flex-wrap items-center justify-between gap-4">
      <div>
        <div className="flex items-center gap-2 text-xs font-semibold text-[#2E7D32] uppercase tracking-wider mb-1">
          <FolderOpen className="w-4 h-4" />
          <span>Clinical Medical Records</span>
        </div>
        <h1 className="text-xl font-bold text-slate-900">
          Patient Directory &amp; Clinical Registry
        </h1>
        <p className="text-xs text-slate-500 mt-1">
          Patients whose records your clinic is currently authorized to open.
        </p>
      </div>

      <div className="flex items-center gap-3">
        <div className="relative">
          <Search className="w-3.5 h-3.5 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <input
            type="text"
            placeholder="Search name, email, patient ID..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            disabled={authorizedPatients.length === 0}
            className="pl-8 pr-3 py-1.5 text-xs bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-1 focus:ring-[#388E3C] w-64 disabled:bg-slate-50 disabled:text-slate-400"
          />
        </div>

        <Button size="sm" variant="outline" onClick={fetchGrants} disabled={isLoading}>
          <RefreshCw className={`w-3.5 h-3.5 ${isLoading ? 'animate-spin' : ''}`} />
          Refresh
        </Button>
      </div>
    </div>
  );

  // A doctor account that was never attached to a clinic cannot hold grants.
  if (isReady && !clinicId) {
    return (
      <div id="doctor-patients-list-page" className="space-y-6">
        {header}
        <EmptyState
          icon={<Building2 className="w-8 h-8 text-slate-300" />}
          title="No clinic assigned to your account"
          description="Patient access is granted to a clinic, not to an individual doctor. Ask your clinic administrator to attach your account to a facility."
        />
      </div>
    );
  }

  return (
    <div id="doctor-patients-list-page" className="space-y-6">
      {header}

      {errorMessage && (
        <div
          role="alert"
          className="flex items-start gap-3 rounded-2xl border border-red-200 bg-red-50 px-4 py-3"
        >
          <AlertCircle className="w-4 h-4 text-red-600 mt-0.5 shrink-0" />
          <div className="space-y-2">
            <p className="text-xs font-semibold text-red-800">{errorMessage}</p>
            <Button size="sm" variant="outline" onClick={fetchGrants}>
              Try again
            </Button>
          </div>
        </div>
      )}

      {isLoading && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {[0, 1, 2].map((i) => (
            <div
              key={i}
              className="bg-white rounded-3xl border border-slate-200 p-6 space-y-4 animate-pulse"
            >
              <div className="flex items-center gap-3">
                <div className="w-11 h-11 rounded-2xl bg-slate-100" />
                <div className="space-y-2">
                  <div className="h-3 w-32 bg-slate-100 rounded" />
                  <div className="h-2 w-20 bg-slate-100 rounded" />
                </div>
              </div>
              <div className="h-2 w-full bg-slate-100 rounded" />
              <div className="h-2 w-2/3 bg-slate-100 rounded" />
            </div>
          ))}
        </div>
      )}

      {!isLoading && !errorMessage && authorizedPatients.length === 0 && (
        <EmptyState
          icon={<Users className="w-8 h-8 text-slate-300" />}
          title="No authorized patients yet"
          description="Your clinic holds no approved access grants. Ask the front desk to look the patient up by their exact email address and request their consent — their chart appears here once they approve."
        />
      )}

      {!isLoading && authorizedPatients.length > 0 && filteredPatients.length === 0 && (
        <EmptyState
          icon={<Search className="w-8 h-8 text-slate-300" />}
          title="No matching patients"
          description="No authorized patient matches that search. Clear the search box to see every patient your clinic can open."
        />
      )}

      {!isLoading && filteredPatients.length > 0 && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {filteredPatients.map((grant) => {
            const name = getAccessRequestPatientName(grant);
            const email = getAccessRequestPatientEmail(grant);

            return (
              <div
                key={grant.patient_id}
                className="bg-white rounded-3xl border border-slate-200 p-6 space-y-4 hover:border-[#A5D6A7] hover:shadow-xs transition-all flex flex-col justify-between"
              >
                <div className="space-y-3">
                  <div className="flex items-start justify-between gap-2">
                    <div className="flex items-center gap-3 min-w-0">
                      <div className="w-11 h-11 rounded-2xl bg-[#E8F5E9] text-[#2E7D32] border border-[#C8E6C9] flex items-center justify-center font-bold text-sm shrink-0">
                        {initialsFor(grant)}
                      </div>
                      <div className="min-w-0">
                        <h3 className="font-bold text-slate-900 text-sm truncate">{name}</h3>
                        {email && (
                          <p className="text-[11px] text-slate-500 truncate">{email}</p>
                        )}
                      </div>
                    </div>

                    <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-[#E8F5E9] text-[#1B5E20] border border-[#C8E6C9] shrink-0">
                      <ShieldCheck className="w-3 h-3" />
                      Access Active
                    </span>
                  </div>

                  <div className="space-y-1 text-xs text-slate-600">
                    <p className="font-mono text-[11px] text-slate-400 truncate">
                      {grant.patient_id}
                    </p>
                    <p>
                      Authorized since{' '}
                      <strong>{formatGrantedOn(grant.created_at)}</strong>
                    </p>
                    {grant.reason && (
                      <p className="text-slate-400 truncate" title={grant.reason}>
                        {grant.reason}
                      </p>
                    )}
                  </div>
                </div>

                <div className="pt-3 border-t border-slate-100 flex items-center justify-between">
                  <Link
                    href={`/doctor/patients/${grant.patient_id}`}
                    className="inline-flex items-center gap-1 font-semibold text-xs text-[#2E7D32] hover:text-[#1B5E20]"
                  >
                    Open Chart <ArrowRight className="w-3.5 h-3.5" />
                  </Link>

                  <Link href={`/doctor/encounters/new?patientId=${grant.patient_id}`}>
                    <Button size="sm" variant="ghost" className="text-xs">
                      + Start Encounter
                    </Button>
                  </Link>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
