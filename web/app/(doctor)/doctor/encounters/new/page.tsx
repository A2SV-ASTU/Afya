'use client';

import React, { useState, useEffect, useRef, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import Link from 'next/link';
import {
  Stethoscope,
  ArrowLeft,
  CheckCircle2,
  User,
  AlertCircle,
  Search,
  X,
  ChevronDown,
  Check,
  Activity,
} from 'lucide-react';
import { useAuth } from '@/modules/core/context/AuthContext';
import { Button } from '@/modules/core/ui/Button';
import { AccessRequest, getAccessRequestPatientName } from '@/types/database';
import { accessRequestsApi, encountersApi } from '@/lib/api';
import { ApiError, getApiErrorMessage } from '@/lib/api/client';
import { startEncounterAction } from '@/modules/clinical-workspace/actions/startEncounter';
import { formatDateTime } from '@/modules/core/lib/utils';

interface ActiveOpenEncounter {
  id: string;
  started_at: string;
  doctor_name?: string;
  clinic_name?: string;
}

function NewEncounterContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const initialPatientId = searchParams.get('patientId') || '';

  const { currentUser, isReady } = useAuth();
  const clinicId = currentUser?.clinic_id ?? null;

  const [authorizedGrants, setAuthorizedGrants] = useState<AccessRequest[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [patientId, setPatientId] = useState<string>(initialPatientId);
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Active open encounter state for the selected patient
  const [activeOpenEncounter, setActiveOpenEncounter] = useState<ActiveOpenEncounter | null>(null);
  const [isCheckingOpenEncounter, setIsCheckingOpenEncounter] = useState(false);

  useEffect(() => {
    if (!isReady) return;

    if (!clinicId) {
      setIsLoading(false);
      setErrorMsg('Your account is not affiliated with a clinic, so patient access grants cannot be loaded.');
      return;
    }

    let cancelled = false;
    async function loadData(activeClinicId: string) {
      setIsLoading(true);
      try {
        const res = await accessRequestsApi.listRequests(activeClinicId, 'approved');
        const rawGrants = res.access_requests || [];
        const now = new Date();

        // Exclude revoked access grants
        const activeGrants = rawGrants.filter(
          (g) => g.status === 'approved' && !g.revoked_at
        );

        // Deduplicate by patient_id, keeping the newest active grant
        const newestPerPatient = new Map<string, AccessRequest>();
        for (const grant of activeGrants) {
          const existing = newestPerPatient.get(grant.patient_id);
          if (!existing || new Date(grant.created_at) > new Date(existing.created_at)) {
            newestPerPatient.set(grant.patient_id, grant);
          }
        }

        if (!cancelled) setAuthorizedGrants(Array.from(newestPerPatient.values()));
      } catch (err) {
        if (!cancelled) {
          setErrorMsg(getApiErrorMessage(err, 'Failed to load authorized patients. Please try again.'));
        }
      } finally {
        if (!cancelled) setIsLoading(false);
      }
    }
    loadData(clinicId);
    return () => {
      cancelled = true;
    };
  }, [isReady, clinicId]);

  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const comboboxRef = useRef<HTMLDivElement>(null);

  const selectedGrant = authorizedGrants.find((g) => g.patient_id === patientId);

  // Auto-select patient from URL query param if present
  useEffect(() => {
    if (initialPatientId && authorizedGrants.length > 0 && !patientId) {
      const target = authorizedGrants.find((g) => g.patient_id === initialPatientId);
      if (target) {
        setPatientId(target.patient_id);
        setSearchQuery(getAccessRequestPatientName(target));
      }
    }
  }, [initialPatientId, authorizedGrants, patientId]);

  // Check if the selected patient already has an active open encounter
  useEffect(() => {
    if (!patientId) {
      setActiveOpenEncounter(null);
      return;
    }

    let cancelled = false;
    setIsCheckingOpenEncounter(true);

    encountersApi
      .listForPatient(patientId)
      .then((res) => {
        if (cancelled) return;
        const openEnc = (res.encounters || []).find((e) => e.status === 'open');
        if (openEnc) {
          setActiveOpenEncounter({
            id: openEnc.id,
            started_at: openEnc.started_at,
            doctor_name: openEnc.opened_by_doctor_name,
            clinic_name: openEnc.clinic_name,
          });
        } else {
          setActiveOpenEncounter(null);
        }
      })
      .catch(() => {
        if (!cancelled) setActiveOpenEncounter(null);
      })
      .finally(() => {
        if (!cancelled) setIsCheckingOpenEncounter(false);
      });

    return () => {
      cancelled = true;
    };
  }, [patientId]);

  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (comboboxRef.current && !comboboxRef.current.contains(e.target as Node)) {
        setIsDropdownOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const filteredGrants = authorizedGrants.filter((grant) => {
    if (!searchQuery.trim()) return true;
    const q = searchQuery.toLowerCase().trim();
    const fullName = getAccessRequestPatientName(grant).toLowerCase();
    const email = (grant.patient?.email || '').toLowerCase();
    return fullName.includes(q) || email.includes(q);
  });

  const handleSelectPatient = (grant: AccessRequest) => {
    setPatientId(grant.patient_id);
    setSearchQuery(getAccessRequestPatientName(grant));
    setIsDropdownOpen(false);
  };

  const handleClearSelection = () => {
    setPatientId('');
    setSearchQuery('');
    setIsDropdownOpen(true);
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const val = e.target.value;
    setSearchQuery(val);
    setIsDropdownOpen(true);

    if (selectedGrant && val !== getAccessRequestPatientName(selectedGrant)) {
      setPatientId('');
    }
  };

  const handleStart = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!patientId || !selectedGrant) return;
    setErrorMsg(null);
    setIsSubmitting(true);

    let newEncounterId: string;
    try {
      const newEnc = await startEncounterAction(patientId);
      newEncounterId = newEnc.id;
    } catch (err) {
      if (err instanceof ApiError && err.status === 403) {
        setErrorMsg('Patient access grant has expired or has not been approved yet.');
      } else if (
        err instanceof ApiError &&
        (err.status === 409 || err.code === 'open_encounter_exists' || err.message?.includes('open encounter'))
      ) {
        try {
          const res = await encountersApi.listForPatient(patientId);
          const openEnc = (res.encounters || []).find((e) => e.status === 'open');
          if (openEnc) {
            setActiveOpenEncounter({
              id: openEnc.id,
              started_at: openEnc.started_at,
              doctor_name: openEnc.opened_by_doctor_name,
              clinic_name: openEnc.clinic_name,
            });
          }
        } catch {
          // ignore lookup error
        }
        setErrorMsg('Patient already has an active open encounter in progress. Resume and finalize it first.');
      } else {
        setErrorMsg(getApiErrorMessage(err, 'Failed to initialize encounter.'));
      }
      setIsSubmitting(false);
      return;
    }

    router.push(`/doctor/encounters/${newEncounterId}`);
  };

  return (
    <div className="max-w-3xl mx-auto space-y-6 select-none">
      <div className="flex items-center gap-3">
        <button
          type="button"
          onClick={() => router.push('/doctor')}
          className="p-2 rounded-xl text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition-colors cursor-pointer"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <div>
          <div className="flex items-center gap-2 text-xs font-semibold text-[#2E7D32] uppercase tracking-wider">
            <Stethoscope className="w-4 h-4 text-[#2E7D32]" />
            <span>Clinical Encounter Initialization</span>
          </div>
          <h1 className="text-xl font-bold text-slate-900">Initiate Clinical Encounter</h1>
        </div>
      </div>

      {errorMsg && (
        <div className="p-4 rounded-xl bg-rose-50 border border-rose-200 text-xs text-rose-700 flex items-start gap-2.5 shadow-2xs">
          <AlertCircle className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
          <div>
            <p className="font-bold">Encounter Initialization Failed</p>
            <p className="mt-0.5">{errorMsg}</p>
          </div>
        </div>
      )}

      <div className="bg-white rounded-3xl border border-slate-200 shadow-2xs overflow-hidden">
        <div className="p-5 border-b border-slate-100 bg-slate-50/60 flex items-center justify-between">
          <div>
            <h3 className="text-sm font-bold text-slate-900">Clinical Consultation Parameters</h3>
            <p className="text-xs text-slate-500">
              Type a patient&apos;s name to search and select their chart for consultation.
            </p>
          </div>
          <span className="text-xs font-mono font-semibold px-2.5 py-1 rounded-lg bg-slate-100 text-slate-700 border border-slate-200">
            {authorizedGrants.length} Eligible
          </span>
        </div>

        <form onSubmit={handleStart} className="p-6 sm:p-8 space-y-6">
          <div className="space-y-2 relative" ref={comboboxRef}>
            <label className="text-xs font-semibold text-slate-800 flex items-center justify-between">
              <span className="flex items-center gap-1.5">
                <User className="w-4 h-4 text-[#2E7D32]" />
                <span>Search Patient by Name <span className="text-rose-500">*</span></span>
              </span>
              {selectedGrant ? (
                <span className="text-[11px] font-mono text-[#2E7D32] font-bold flex items-center gap-1">
                  <CheckCircle2 className="w-3.5 h-3.5 text-[#2E7D32]" />
                  Patient Selected
                </span>
              ) : (
                <span className="text-[11px] text-amber-700 font-medium italic">
                  Select a patient from the filtered list below
                </span>
              )}
            </label>

            {isLoading ? (
              <div className="p-4 rounded-xl bg-slate-50 border border-slate-200 text-xs text-slate-400 italic">
                Loading authorized patients...
              </div>
            ) : authorizedGrants.length === 0 ? (
              <div className="p-4 rounded-xl bg-slate-50 border border-slate-200 text-xs text-slate-600 flex items-start gap-2.5">
                <AlertCircle className="w-4 h-4 text-amber-600 shrink-0 mt-0.5" />
                <div>
                  <p className="font-bold text-slate-800">No Patients Available for New Encounters</p>
                  <p className="text-slate-500 mt-0.5">
                    All authorized patients either have active open encounters in progress or require an active consent grant from clinic reception.
                  </p>
                </div>
              </div>
            ) : (
              <div className="relative">
                <div className="relative flex items-center">
                  <Search className="w-4 h-4 text-slate-400 absolute left-3.5 pointer-events-none" />
                  <input
                    type="text"
                    value={searchQuery}
                    onFocus={() => setIsDropdownOpen(true)}
                    onChange={handleInputChange}
                    placeholder="Type patient's name or email to filter..."
                    className={`w-full pl-10 pr-16 py-2.5 text-xs bg-white border rounded-xl text-slate-900 focus:outline-none transition-all shadow-2xs font-medium ${
                      selectedGrant
                        ? 'border-[#81C784] ring-2 ring-[#388E3C]/10 text-[#1B5E20]'
                        : 'border-slate-200 focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C]'
                    }`}
                  />
                  <div className="absolute right-2.5 flex items-center gap-1">
                    {searchQuery && (
                      <button
                        type="button"
                        onClick={handleClearSelection}
                        className="p-1 text-slate-400 hover:text-slate-600 rounded-lg hover:bg-slate-100 transition-colors"
                        title="Clear search"
                      >
                        <X className="w-3.5 h-3.5" />
                      </button>
                    )}
                    <button
                      type="button"
                      onClick={() => setIsDropdownOpen(!isDropdownOpen)}
                      className="p-1 text-slate-400 hover:text-slate-600 rounded-lg hover:bg-slate-100 transition-colors"
                    >
                      <ChevronDown className="w-4 h-4" />
                    </button>
                  </div>
                </div>

                {isDropdownOpen && (
                  <div className="absolute left-0 right-0 top-full mt-1.5 z-30 bg-white rounded-2xl border border-slate-200 shadow-xl max-h-64 overflow-y-auto p-2 space-y-1 animate-in fade-in zoom-in-95 duration-100">
                    <div className="px-2 py-1 text-[10px] font-bold uppercase tracking-wider text-slate-400 border-b border-slate-100 flex items-center justify-between">
                      <span>Eligible Patients ({filteredGrants.length})</span>
                      <span>Click to Select</span>
                    </div>

                    {filteredGrants.length === 0 ? (
                      <div className="p-4 text-center text-xs text-slate-400 italic">
                        No eligible patients match &ldquo;{searchQuery}&rdquo;
                      </div>
                    ) : (
                      filteredGrants.map((grant) => {
                        const isSelected = grant.patient_id === patientId;
                        const pName = getAccessRequestPatientName(grant);
                        return (
                          <div
                            key={grant.id}
                            onClick={() => handleSelectPatient(grant)}
                            className={`p-3 rounded-xl flex items-center justify-between gap-3 cursor-pointer transition-colors ${
                              isSelected
                                ? 'bg-[#E8F5E9] border border-[#C8E6C9] text-[#1B5E20]'
                                : 'hover:bg-slate-50 text-slate-800'
                            }`}
                          >
                            <div className="flex items-center gap-3">
                              <div
                                className={`w-8 h-8 rounded-lg font-bold flex items-center justify-center text-xs ${
                                  isSelected
                                    ? 'bg-[#388E3C] text-white'
                                    : 'bg-slate-100 text-slate-700'
                                }`}
                              >
                                {pName[0]}
                              </div>
                              <div>
                                <p className="font-bold text-xs text-slate-900">
                                  {pName}
                                </p>
                                <p className="text-[11px] text-slate-500">
                                  Email: {grant.patient?.email || 'N/A'}
                                </p>
                              </div>
                            </div>

                            {isSelected && (
                              <Check className="w-4 h-4 text-[#2E7D32] shrink-0" />
                            )}
                          </div>
                        );
                      })
                    )}
                  </div>
                )}
              </div>
            )}
          </div>

          {selectedGrant && (
            <div className="p-4 rounded-2xl bg-[#E8F5E9]/50 border border-[#C8E6C9] text-xs space-y-2 animate-in fade-in duration-150">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-[#388E3C] text-white font-bold flex items-center justify-center text-sm shadow-2xs">
                    {getAccessRequestPatientName(selectedGrant)[0]}
                  </div>
                  <div>
                    <h4 className="font-bold text-slate-900 text-sm">
                      {getAccessRequestPatientName(selectedGrant)}
                    </h4>
                    <p className="text-[11px] text-slate-500">
                      ID: {selectedGrant.patient_id}
                    </p>
                  </div>
                </div>

                <span className="text-[11px] font-bold px-2.5 py-1 bg-white text-[#1B5E20] border border-[#C8E6C9] rounded-lg shadow-2xs flex items-center gap-1">
                  <CheckCircle2 className="w-3.5 h-3.5 text-[#2E7D32]" />
                  Consent Verified
                </span>
              </div>
            </div>
          )}

          {/* Active Open Encounter Alert Banner */}
          {activeOpenEncounter && (
            <div className="p-4 rounded-2xl bg-amber-50 border border-amber-300 text-xs space-y-3 animate-in fade-in duration-150 shadow-xs">
              <div className="flex flex-wrap items-center justify-between gap-3">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-amber-100 text-amber-800 border border-amber-200 flex items-center justify-center shrink-0">
                    <Activity className="w-5 h-5 text-amber-700 animate-pulse" />
                  </div>
                  <div>
                    <h4 className="font-bold text-amber-950 text-sm">
                      Active Encounter Session In Progress
                    </h4>
                    <p className="text-amber-800 text-[11px] mt-0.5">
                      Opened on <strong>{formatDateTime(activeOpenEncounter.started_at)}</strong>
                      {activeOpenEncounter.doctor_name ? ` by Dr. ${activeOpenEncounter.doctor_name}` : ''}
                      {activeOpenEncounter.clinic_name ? ` • ${activeOpenEncounter.clinic_name}` : ''}
                    </p>
                  </div>
                </div>

                <Link href={`/doctor/encounters/${activeOpenEncounter.id}`}>
                  <Button size="sm" variant="brand">
                    Resume Open Encounter ➔
                  </Button>
                </Link>
              </div>
              <p className="text-[11px] text-amber-900/90 leading-relaxed bg-amber-100/60 p-2.5 rounded-xl border border-amber-200/60">
                Afya enforces single-active encounter governance. A new clinical encounter cannot be initialized while this session remains open. Please resume this session to finish your clinical evaluation, vitals, prescriptions, or seal and sign the encounter.
              </p>
            </div>
          )}

          <div className="pt-4 flex items-center justify-end gap-3 border-t border-slate-100">
            <Button
              type="button"
              variant="outline"
              onClick={() => router.push('/doctor')}
            >
              Cancel
            </Button>
            {activeOpenEncounter ? (
              <Link href={`/doctor/encounters/${activeOpenEncounter.id}`}>
                <Button
                  type="button"
                  variant="brand"
                  leftIcon={<Activity className="w-4 h-4 animate-pulse" />}
                >
                  Resume Active Consultation ➔
                </Button>
              </Link>
            ) : (
              <Button
                type="submit"
                disabled={authorizedGrants.length === 0 || !patientId || isCheckingOpenEncounter}
                isLoading={isSubmitting}
                leftIcon={<Stethoscope className="w-4 h-4" />}
              >
                Open Encounter Recording Workspace
              </Button>
            )}
          </div>
        </form>
      </div>
    </div>
  );
}

export default function NewEncounterPage() {
  return (
    <Suspense
      fallback={
        <div className="max-w-3xl mx-auto p-12 text-center bg-white rounded-3xl border border-slate-200 text-xs text-slate-500">
          Loading encounter initialization…
        </div>
      }
    >
      <NewEncounterContent />
    </Suspense>
  );
}
