'use client';

import React, { useState, useEffect, useRef } from 'react';
import { useRouter } from 'next/navigation';
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
} from 'lucide-react';
import { useAuth } from '@/modules/core/context/AuthContext';
import { Button } from '@/modules/core/ui/Button';
import { EncounterType, AccessRequest, getAccessRequestPatientName } from '@/types/database';
import { accessRequestsApi, clinicalEvaluationsApi } from '@/lib/api';
import { ApiError, getApiErrorMessage } from '@/lib/api/client';
import { startEncounterAction } from '@/modules/clinical-workspace/actions/startEncounter';

export default function NewEncounterPage() {
  const router = useRouter();
  const { currentUser, isReady } = useAuth();
  const clinicId = currentUser?.clinic_id ?? null;

  const [authorizedGrants, setAuthorizedGrants] = useState<AccessRequest[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  const [patientId, setPatientId] = useState<string>('');
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [type, setType] = useState<EncounterType>('outpatient');
  const [chiefComplaint, setChiefComplaint] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const comboboxRef = useRef<HTMLDivElement>(null);

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
        if (!cancelled) setAuthorizedGrants(res.access_requests || []);
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

  const selectedGrant = authorizedGrants.find((g) => g.patient_id === patientId);

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
      const newEnc = await startEncounterAction(patientId, type);
      newEncounterId = newEnc.id;
    } catch (err) {
      if (err instanceof ApiError && err.status === 403) {
        setErrorMsg('Patient access grant has expired or has not been approved yet.');
      } else {
        setErrorMsg(getApiErrorMessage(err, 'Failed to initialize encounter.'));
      }
      setIsSubmitting(false);
      return;
    }

    // Persist the initial chief complaint as the encounter's clinical evaluation.
    // A failure here should not strand the doctor — the encounter already exists
    // and the note can be completed from the workspace's Clinical Notes tab.
    if (chiefComplaint.trim()) {
      try {
        await clinicalEvaluationsApi.create(newEncounterId, {
          chief_complaint: chiefComplaint.trim(),
          history_of_present_illness: chiefComplaint.trim(),
        });
      } catch (err) {
        if (!(err instanceof ApiError && err.status === 409)) {
          console.error('Failed to record initial clinical evaluation', err);
        }
      }
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

          <div className="space-y-2">
            <label className="block text-xs font-semibold text-slate-800">Encounter Classification</label>
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-2.5">
              {(
                [
                  { id: 'outpatient', label: 'Outpatient (OPD)', desc: 'Routine consultation & clinic review' },
                  { id: 'inpatient', label: 'Inpatient (IPD)', desc: 'Ward rounds & inpatient review' },
                  { id: 'emergency', label: 'Emergency (ER)', desc: 'Acute urgent triage & care' },
                  { id: 'telehealth', label: 'Telehealth', desc: 'Remote telemedicine session' },
                ] as const
              ).map((t) => (
                <button
                  key={t.id}
                  type="button"
                  onClick={() => setType(t.id as EncounterType)}
                  className={`p-3.5 rounded-xl border text-left transition-all cursor-pointer ${
                    type === t.id
                      ? 'border-[#388E3C] bg-[#E8F5E9]/60 text-[#1B5E20] shadow-2xs font-semibold ring-1 ring-[#388E3C]/30'
                      : 'border-slate-200 bg-white hover:border-slate-300 text-slate-700'
                  }`}
                >
                  <p className="font-bold text-xs">{t.label}</p>
                  <p className="text-[11px] text-slate-500 mt-1 leading-snug">{t.desc}</p>
                </button>
              ))}
            </div>
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-slate-800">
              Initial Chief Complaint / Presenting Symptoms
            </label>
            <textarea
              id="new-encounter-chief-complaint"
              rows={3}
              value={chiefComplaint}
              onChange={(e) => setChiefComplaint(e.target.value)}
              placeholder="e.g. Patient presents with 3-day history of throbbing frontal headache..."
              className="w-full px-3.5 py-2.5 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C] shadow-2xs"
            />
          </div>

          <div className="pt-4 flex items-center justify-end gap-3 border-t border-slate-100">
            <Button
              type="button"
              variant="outline"
              onClick={() => router.push('/doctor')}
            >
              Cancel
            </Button>
            <Button
              type="submit"
              disabled={authorizedGrants.length === 0 || !patientId}
              isLoading={isSubmitting}
              leftIcon={<Stethoscope className="w-4 h-4" />}
            >
              Open Encounter Recording Workspace
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
