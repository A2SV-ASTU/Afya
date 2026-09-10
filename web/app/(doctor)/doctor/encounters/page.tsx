'use client';

import React, { useCallback, useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import {
  FolderOpen,
  PlusCircle,
  Activity,
  Lock,
  Search,
  RefreshCw,
  ExternalLink,
  AlertCircle,
  Clock,
  ArrowRight,
} from 'lucide-react';
import { useAuth } from '@/modules/core/context/AuthContext';
import { accessRequestsApi, encountersApi } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api/client';
import { StatusBadge } from '@/modules/core/ui/StatusBadge';
import { Button } from '@/modules/core/ui/Button';
import { EmptyState } from '@/modules/core/ui/EmptyState';
import { formatDateTime } from '@/modules/core/lib/utils';
import {
  AccessRequest,
  Encounter,
  getAccessRequestPatientName,
  getAccessRequestPatientEmail,
} from '@/types/database';

interface EnrichedEncounter extends Encounter {
  patient_email?: string;
}

export default function DoctorEncountersPage() {
  const { currentUser, isReady } = useAuth();
  const clinicId = currentUser?.clinic_id ?? null;

  const [encounters, setEncounters] = useState<EnrichedEncounter[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [statusFilter, setStatusFilter] = useState<'all' | 'open' | 'closed'>('all');
  const [searchTerm, setSearchTerm] = useState('');

  const fetchEncounters = useCallback(async () => {
    if (!clinicId) {
      setIsLoading(false);
      setError('Your account is not attached to an active clinic.');
      return;
    }

    setIsLoading(true);
    setError(null);

    try {
      // 1. Fetch authorized patients for this clinic
      const res = await accessRequestsApi.listRequests(clinicId, 'approved');
      const liveGrants = (res.access_requests || []).filter(
        (g) => g.status === 'approved' && !g.revoked_at
      );

      // Deduplicate by patient_id
      const uniqueGrants = new Map<string, AccessRequest>();
      for (const g of liveGrants) {
        if (!uniqueGrants.has(g.patient_id) || new Date(g.created_at) > new Date(uniqueGrants.get(g.patient_id)!.created_at)) {
          uniqueGrants.set(g.patient_id, g);
        }
      }

      const grantsList = Array.from(uniqueGrants.values());
      if (grantsList.length === 0) {
        setEncounters([]);
        setIsLoading(false);
        return;
      }

      // 2. Fetch encounters for each authorized patient
      const outcomes = await Promise.allSettled(
        grantsList.map(async (grant) => {
          const encRes = await encountersApi.listForPatient(grant.patient_id);
          const patientName = getAccessRequestPatientName(grant);
          const patientEmail = getAccessRequestPatientEmail(grant);

          return (encRes.encounters || []).map((enc) => ({
            ...enc,
            patient_name: enc.patient_name || patientName,
            patient_email: patientEmail,
            opened_by_doctor_name:
              enc.opened_by_doctor_name ||
              (currentUser ? `Dr. ${currentUser.first_name} ${currentUser.last_name}` : 'Attending Physician'),
          }));
        })
      );

      const allEncounters: EnrichedEncounter[] = [];
      for (const out of outcomes) {
        if (out.status === 'fulfilled') {
          allEncounters.push(...out.value);
        }
      }

      // Sort: open sessions first, then newest first
      allEncounters.sort((a, b) => {
        if (a.status === 'open' && b.status !== 'open') return -1;
        if (a.status !== 'open' && b.status === 'open') return 1;
        return new Date(b.started_at).getTime() - new Date(a.started_at).getTime();
      });

      setEncounters(allEncounters);
    } catch (err) {
      setError(getApiErrorMessage(err, 'Failed to retrieve clinical encounters.'));
    } finally {
      setIsLoading(false);
    }
  }, [clinicId, currentUser]);

  useEffect(() => {
    if (isReady) fetchEncounters();
  }, [isReady, fetchEncounters]);

  const filteredEncounters = useMemo(() => {
    return encounters.filter((enc) => {
      if (statusFilter !== 'all' && enc.status !== statusFilter) {
        return false;
      }
      if (searchTerm.trim()) {
        const q = searchTerm.toLowerCase().trim();
        const name = (enc.patient_name || '').toLowerCase();
        const email = (enc.patient_email || '').toLowerCase();
        const id = enc.id.toLowerCase();
        const patId = enc.patient_id.toLowerCase();
        return name.includes(q) || email.includes(q) || id.includes(q) || patId.includes(q);
      }
      return true;
    });
  }, [encounters, statusFilter, searchTerm]);

  const openCount = encounters.filter((e) => e.status === 'open').length;
  const closedCount = encounters.filter((e) => e.status === 'closed').length;

  return (
    <div className="space-y-6">
      {/* Header Banner */}
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 text-xs font-semibold text-[#2E7D32] uppercase tracking-wider mb-1">
            <FolderOpen className="w-4 h-4" />
            <span>Clinical Encounter Sessions</span>
          </div>
          <h1 className="text-xl font-bold text-slate-900">Encounters Directory</h1>
          <p className="text-xs text-slate-500 mt-0.5">
            Active in-progress consultations, diagnostic sessions, and historical sealed encounter records
          </p>
        </div>

        <div className="flex items-center gap-2.5">
          <Button
            size="sm"
            variant="outline"
            onClick={fetchEncounters}
            disabled={isLoading}
            leftIcon={<RefreshCw className={`w-3.5 h-3.5 ${isLoading ? 'animate-spin' : ''}`} />}
          >
            Refresh
          </Button>
          <Link href="/doctor/encounters/new">
            <Button size="sm" leftIcon={<PlusCircle className="w-4 h-4" />}>
              Start Encounter
            </Button>
          </Link>
        </div>
      </div>

      {error && (
        <div className="p-4 rounded-2xl bg-rose-50 border border-rose-200 text-xs text-rose-700 flex items-start gap-2.5">
          <AlertCircle className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
          <span>{error}</span>
        </div>
      )}

      {/* Filter and Search Bar */}
      <div className="bg-white rounded-3xl border border-slate-200 p-4 shadow-xs flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center gap-1.5">
          <button
            type="button"
            onClick={() => setStatusFilter('all')}
            className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition-colors cursor-pointer ${
              statusFilter === 'all'
                ? 'bg-[#E8F5E9] text-[#1B5E20] border border-[#C8E6C9]'
                : 'text-slate-600 hover:bg-slate-100'
            }`}
          >
            All Encounters ({encounters.length})
          </button>
          <button
            type="button"
            onClick={() => setStatusFilter('open')}
            className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition-colors cursor-pointer flex items-center gap-1.5 ${
              statusFilter === 'open'
                ? 'bg-emerald-100 text-emerald-900 border border-emerald-300 font-bold'
                : 'text-slate-600 hover:bg-slate-100'
            }`}
          >
            <Activity className="w-3.5 h-3.5 text-emerald-600" />
            <span>Active Open ({openCount})</span>
          </button>
          <button
            type="button"
            onClick={() => setStatusFilter('closed')}
            className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition-colors cursor-pointer flex items-center gap-1.5 ${
              statusFilter === 'closed'
                ? 'bg-slate-200 text-slate-800 border border-slate-300'
                : 'text-slate-600 hover:bg-slate-100'
            }`}
          >
            <Lock className="w-3.5 h-3.5 text-slate-500" />
            <span>Sealed &amp; Closed ({closedCount})</span>
          </button>
        </div>

        <div className="relative w-full sm:w-64">
          <Search className="w-3.5 h-3.5 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <input
            type="text"
            placeholder="Search patient, ID..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-8 pr-3 py-1.5 text-xs bg-slate-50 border border-slate-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-[#388E3C]"
          />
        </div>
      </div>

      {/* Encounters Table */}
      <div className="bg-white rounded-3xl border border-slate-200 shadow-xs overflow-hidden">
        <div className="p-6 border-b border-slate-100 flex items-center justify-between">
          <h2 className="text-base font-bold text-slate-900">
            Encounter Records ({filteredEncounters.length})
          </h2>
          {openCount > 0 && (
            <span className="text-xs text-emerald-800 font-semibold bg-emerald-50 px-2.5 py-0.5 rounded-full border border-emerald-200 flex items-center gap-1">
              <Activity className="w-3 h-3 text-emerald-600 animate-pulse" />
              {openCount} in progress
            </span>
          )}
        </div>

        {isLoading ? (
          <div className="p-12 text-center text-xs text-slate-400">
            <RefreshCw className="w-5 h-5 animate-spin mx-auto mb-2 text-[#2E7D32]" />
            Loading clinical encounters…
          </div>
        ) : filteredEncounters.length === 0 ? (
          <div className="p-12">
            <EmptyState
              icon={<FolderOpen className="w-8 h-8 text-slate-300" />}
              title="No clinical encounters found"
              description="Start a new clinical consultation for an authorized patient to begin recording vitals, evaluations, and prescriptions."
            />
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs border-collapse">
              <thead>
                <tr className="border-b border-slate-100 bg-slate-50/75 text-slate-500 font-semibold uppercase tracking-wider text-[11px]">
                  <th className="py-3 px-6">Patient</th>
                  <th className="py-3 px-6">Encounter ID</th>
                  <th className="py-3 px-6">Date Opened</th>
                  <th className="py-3 px-6">Status</th>
                  <th className="py-3 px-6">Attending Physician</th>
                  <th className="py-3 px-6 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 font-medium text-slate-700">
                {filteredEncounters.map((enc) => {
                  const isOpen = enc.status === 'open';
                  return (
                    <tr
                      key={enc.id}
                      className={`hover:bg-slate-50/60 transition-colors ${
                        isOpen ? 'bg-emerald-50/20' : ''
                      }`}
                    >
                      <td className="py-4 px-6">
                        <Link
                          href={`/doctor/patients/${enc.patient_id}`}
                          className="font-bold text-slate-900 hover:text-[#2E7D32] inline-flex items-center gap-1 group"
                        >
                          {enc.patient_name}
                          <ExternalLink className="w-3 h-3 text-slate-300 group-hover:text-[#2E7D32]" />
                        </Link>
                        {enc.patient_email && (
                          <p className="text-[11px] text-slate-400">{enc.patient_email}</p>
                        )}
                        <p className="text-[10px] font-mono text-slate-400 mt-0.5">{enc.patient_id}</p>
                      </td>
                      <td className="py-4 px-6 font-mono text-slate-600 text-[11px]">
                        {enc.id}
                      </td>
                      <td className="py-4 px-6">
                        <p className="font-mono text-slate-800">{formatDateTime(enc.started_at)}</p>
                        {enc.ended_at && (
                          <p className="text-[10px] text-slate-400">
                            Sealed: {formatDateTime(enc.ended_at)}
                          </p>
                        )}
                      </td>
                      <td className="py-4 px-6">
                        <StatusBadge status={enc.status} />
                      </td>
                      <td className="py-4 px-6 text-slate-700">
                        {enc.opened_by_doctor_name || 'Attending Physician'}
                      </td>
                      <td className="py-4 px-6 text-right">
                        <div className="inline-flex items-center gap-2.5">
                          {isOpen ? (
                            <Link href={`/doctor/encounters/${enc.id}`}>
                              <Button size="sm" variant="brand">
                                Resume Consultation ➔
                              </Button>
                            </Link>
                          ) : (
                            <Link
                              href={`/doctor/patients/${enc.patient_id}`}
                              className="font-semibold text-[#2E7D32] hover:text-[#1B5E20] inline-flex items-center gap-1"
                            >
                              Open Chart <ArrowRight className="w-3 h-3" />
                            </Link>
                          )}
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
