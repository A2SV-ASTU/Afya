'use client';

import React, { useState, useEffect, useRef } from 'react';
import { useRouter } from 'next/navigation';
import {
  Stethoscope,
  ArrowLeft,
  Activity,
  ShieldCheck,
  CheckCircle2,
  User,
  Building2,
  Clock,
  ArrowRight,
  AlertCircle,
  PlusCircle,
  Search,
  X,
  ChevronDown,
  Check,
} from 'lucide-react';
import { useStore } from '@/lib/store';
import { Button } from '@/modules/core/ui/Button';
import { EncounterType, Patient, Encounter } from '@/types/database';

export default function NewEncounterPage() {
  const router = useRouter();
  const { currentUser, clinics, patients, encounters, createEncounter } = useStore();

  const activeClinic = clinics.find((c) => c.id === currentUser?.clinic_id) || clinics[0];

  // Patients who granted active access to this clinic
  const authorizedPatients = activeClinic
    ? patients.filter((p) => p.active_grant_clinic_ids.includes(activeClinic.id))
    : [];

  // Filter out patients who currently have an active/open encounter
  const availablePatients = authorizedPatients.filter(
    (p) => !encounters.some((e) => e.patient_id === p.id && e.status === 'open')
  );

  // List of patients who currently HAVE an active open encounter
  const patientsWithActiveEncounters = authorizedPatients
    .map((p) => ({
      patient: p,
      activeEncounter: encounters.find((e) => e.patient_id === p.id && e.status === 'open'),
    }))
    .filter(
      (item): item is { patient: Patient; activeEncounter: Encounter } =>
        item.activeEncounter !== undefined
    );

  const [patientId, setPatientId] = useState<string>('');
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [type, setType] = useState<EncounterType>('outpatient');
  const [chiefComplaint, setChiefComplaint] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Search & Combobox states
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const comboboxRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (comboboxRef.current && !comboboxRef.current.contains(e.target as Node)) {
        setIsDropdownOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const filteredPatients = availablePatients.filter((pat) => {
    if (!searchQuery.trim()) return true;
    const q = searchQuery.toLowerCase().trim();
    const fullName = `${pat.first_name} ${pat.last_name}`.toLowerCase();
    return (
      fullName.includes(q) ||
      pat.phone.toLowerCase().includes(q) ||
      pat.email.toLowerCase().includes(q) ||
      (pat.national_id && pat.national_id.toLowerCase().includes(q))
    );
  });

  const selectedPatient = availablePatients.find((p) => p.id === patientId);

  const handleSelectPatient = (pat: Patient) => {
    setPatientId(pat.id);
    setSearchQuery(`${pat.first_name} ${pat.last_name}`);
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

    if (selectedPatient && val !== `${selectedPatient.first_name} ${selectedPatient.last_name}`) {
      setPatientId('');
    }
  };

  const handleStart = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!patientId || !selectedPatient) return;

    setIsSubmitting(true);
    try {
      const newEnc = await createEncounter(patientId, type, chiefComplaint);
      router.push(`/doctor/encounters/${newEnc.id}`);
    } catch {
      setIsSubmitting(false);
    }
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

      {/* 1. Active Open Encounters Banner */}
      {patientsWithActiveEncounters.length > 0 && (
        <div className="p-5 rounded-2xl bg-amber-50/90 border border-amber-200 shadow-2xs space-y-3">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Clock className="w-4 h-4 text-amber-600 animate-pulse" />
              <span className="font-bold text-xs text-amber-900">
                Patients Currently in Active Encounters ({patientsWithActiveEncounters.length})
              </span>
            </div>
            <span className="text-[10px] font-bold text-amber-800 bg-amber-100 px-2.5 py-0.5 rounded-full border border-amber-300 uppercase">
              Session Open
            </span>
          </div>

          <p className="text-xs text-amber-800 leading-relaxed">
            The patient(s) below already have an active open consultation session. To avoid duplicate encounters, you can resume their existing recording workspace directly:
          </p>

          <div className="space-y-2.5 pt-1">
            {patientsWithActiveEncounters.map(({ patient: pat, activeEncounter: enc }) => (
              <div
                key={pat.id}
                className="p-3.5 bg-white rounded-xl border border-amber-200 flex flex-col sm:flex-row sm:items-center justify-between gap-3 shadow-2xs"
              >
                <div className="space-y-1">
                  <div className="flex flex-wrap items-center gap-2">
                    <span className="font-bold text-slate-900 text-xs">
                      {pat.first_name} {pat.last_name}
                    </span>
                    <span className="px-2 py-0.5 rounded text-[10px] font-bold uppercase bg-[#E8F5E9] text-[#1B5E20] border border-[#C8E6C9]">
                      {enc.type}
                    </span>
                    <span className="text-[10px] text-slate-400 font-mono">
                      Phone: {pat.phone}
                    </span>
                  </div>
                  <p className="text-xs text-slate-600 italic">
                    Chief Complaint: &ldquo;{enc.notes || 'Active consultation in progress'}&rdquo;
                  </p>
                </div>

                <button
                  type="button"
                  onClick={() => router.push(`/doctor/encounters/${enc.id}`)}
                  className="px-4 py-2 bg-[#2E7D32] hover:bg-[#1B5E20] text-white font-bold text-xs rounded-xl flex items-center justify-center gap-1.5 transition-colors cursor-pointer shrink-0 shadow-2xs"
                >
                  <span>Resume Consultation</span>
                  <ArrowRight className="w-3.5 h-3.5 text-white" />
                </button>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* 2. Form Card */}
      <div className="bg-white rounded-3xl border border-slate-200 shadow-2xs overflow-hidden">
        <div className="p-5 border-b border-slate-100 bg-slate-50/60 flex items-center justify-between">
          <div>
            <h3 className="text-sm font-bold text-slate-900">Clinical Consultation Parameters</h3>
            <p className="text-xs text-slate-500">
              Type a patient&apos;s name to search and select their chart for consultation.
            </p>
          </div>
          <span className="text-xs font-mono font-semibold px-2.5 py-1 rounded-lg bg-slate-100 text-slate-700 border border-slate-200">
            {availablePatients.length} Eligible
          </span>
        </div>

        <form onSubmit={handleStart} className="p-6 sm:p-8 space-y-6">
          {/* SEARCHABLE PATIENT COMBOBOX INPUT */}
          <div className="space-y-2 relative" ref={comboboxRef}>
            <label className="text-xs font-semibold text-slate-800 flex items-center justify-between">
              <span className="flex items-center gap-1.5">
                <User className="w-4 h-4 text-[#2E7D32]" />
                <span>Search Patient by Name <span className="text-rose-500">*</span></span>
              </span>
              {selectedPatient ? (
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

            {availablePatients.length === 0 ? (
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
                    placeholder="Type patient's name, phone, or ID to filter..."
                    className={`w-full pl-10 pr-16 py-2.5 text-xs bg-white border rounded-xl text-slate-900 focus:outline-none transition-all shadow-2xs font-medium ${
                      selectedPatient
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

                {/* Filtered Search Results Dropdown Overlay */}
                {isDropdownOpen && (
                  <div className="absolute left-0 right-0 top-full mt-1.5 z-30 bg-white rounded-2xl border border-slate-200 shadow-xl max-h-64 overflow-y-auto p-2 space-y-1 animate-in fade-in zoom-in-95 duration-100">
                    <div className="px-2 py-1 text-[10px] font-bold uppercase tracking-wider text-slate-400 border-b border-slate-100 flex items-center justify-between">
                      <span>Eligible Patients ({filteredPatients.length})</span>
                      <span>Click to Select</span>
                    </div>

                    {filteredPatients.length === 0 ? (
                      <div className="p-4 text-center text-xs text-slate-400 italic">
                        No eligible patients match &ldquo;{searchQuery}&rdquo;
                      </div>
                    ) : (
                      filteredPatients.map((pat) => {
                        const isSelected = pat.id === patientId;
                        return (
                          <div
                            key={pat.id}
                            onClick={() => handleSelectPatient(pat)}
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
                                {pat.first_name[0]}
                                {pat.last_name[0]}
                              </div>
                              <div>
                                <p className="font-bold text-xs text-slate-900">
                                  {pat.first_name} {pat.last_name}
                                </p>
                                <p className="text-[11px] text-slate-500">
                                  Phone: {pat.phone} • DOB: {pat.date_of_birth} ({pat.sex}) • Blood: {pat.blood_group}
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

          {/* Selected Patient Preview Card */}
          {selectedPatient && (
            <div className="p-4 rounded-2xl bg-[#E8F5E9]/50 border border-[#C8E6C9] text-xs space-y-2 animate-in fade-in duration-150">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-[#388E3C] text-white font-bold flex items-center justify-center text-sm shadow-2xs">
                    {selectedPatient.first_name[0]}
                    {selectedPatient.last_name[0]}
                  </div>
                  <div>
                    <h4 className="font-bold text-slate-900 text-sm">
                      {selectedPatient.first_name} {selectedPatient.last_name}
                    </h4>
                    <p className="text-[11px] text-slate-500">
                      DOB: {selectedPatient.date_of_birth} ({selectedPatient.sex}) • Phone: {selectedPatient.phone}
                    </p>
                  </div>
                </div>

                <span className="text-[11px] font-bold px-2.5 py-1 bg-white text-[#1B5E20] border border-[#C8E6C9] rounded-lg shadow-2xs flex items-center gap-1">
                  <CheckCircle2 className="w-3.5 h-3.5 text-[#2E7D32]" />
                  Consent Verified
                </span>
              </div>

              <div className="pt-2 border-t border-[#C8E6C9]/60 grid grid-cols-2 sm:grid-cols-3 gap-2 text-[11px]">
                <div>
                  <span className="text-slate-400 block text-[10px]">Blood Group:</span>
                  <span className="font-bold text-slate-800">{selectedPatient.blood_group}</span>
                </div>
                <div>
                  <span className="text-slate-400 block text-[10px]">Allergies:</span>
                  <span className="font-bold text-rose-700">
                    {selectedPatient.allergies?.join(', ') || 'None Known'}
                  </span>
                </div>
                <div>
                  <span className="text-slate-400 block text-[10px]">Active Status:</span>
                  <span className="font-bold text-emerald-800">Ready for Consultation</span>
                </div>
              </div>
            </div>
          )}

          {/* Encounter Type */}
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
                  onClick={() => setType(t.id)}
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

          {/* Chief Complaint */}
          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-slate-800">
              Initial Chief Complaint / Presenting Symptoms
            </label>
            <textarea
              id="new-encounter-chief-complaint"
              rows={3}
              value={chiefComplaint}
              onChange={(e) => setChiefComplaint(e.target.value)}
              placeholder="e.g. Patient presents with 3-day history of throbbing frontal headache, episodic nausea, and elevated home blood pressure readings..."
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
              disabled={availablePatients.length === 0 || !patientId}
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
