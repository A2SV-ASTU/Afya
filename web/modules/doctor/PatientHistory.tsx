'use client';

import React, { useState } from 'react';
import { useStore } from '@/lib/store';
import { StatusBadge } from '@/components/ui/Badge';
import {
  ArrowLeft,
  PlusCircle,
  Stethoscope,
  Activity,
  FlaskConical,
  FileText,
  Pill,
  Calendar,
  Clock,
  ChevronDown,
  ChevronUp,
  ExternalLink,
  ShieldCheck,
  Heart,
  AlertTriangle,
  User,
} from 'lucide-react';
import { Encounter } from '@/types/database';

export function PatientHistory() {
  const { patients, encounters, viewParams, navigateTo } = useStore();

  const patientId = viewParams.patientId || patients[0]?.id;
  const patient = patients.find((p) => p.id === patientId) || patients[0];

  // Encounters for this patient, sorted most recent first
  const patientEncounters = encounters
    .filter((e) => e.patient_id === patient.id)
    .sort((a, b) => new Date(b.started_at).getTime() - new Date(a.started_at).getTime());

  const [expandedEncounterIds, setExpandedEncounterIds] = useState<string[]>(
    patientEncounters.length > 0 ? [patientEncounters[0].id] : []
  );

  const toggleExpand = (id: string) => {
    setExpandedEncounterIds((prev) =>
      prev.includes(id) ? prev.filter((item) => item !== id) : [...prev, id]
    );
  };

  return (
    <div id="patient-history-timeline-page" className="p-6 md:p-8 max-w-5xl mx-auto space-y-6">
      {/* Top Navigation */}
      <div className="flex items-center justify-between">
        <button
          id="back-to-patients-dir-btn"
          type="button"
          onClick={() => navigateTo('doctor-patients')}
          className="inline-flex items-center gap-2 text-xs font-semibold text-slate-600 hover:text-slate-900 transition-colors cursor-pointer"
        >
          <ArrowLeft className="w-4 h-4" />
          <span>Back to Patients Directory</span>
        </button>

        <button
          id="start-encounter-from-history-btn"
          type="button"
          onClick={() => navigateTo('doctor-start-encounter', { preselectedPatientId: patient.id })}
          className="inline-flex items-center gap-2 px-5 py-2 bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs rounded-xl shadow-xs transition-all cursor-pointer"
        >
          <PlusCircle className="w-4 h-4" />
          <span>+ Start New Encounter</span>
        </button>
      </div>

      {/* Patient Demographic Summary Header Card */}
      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-xs p-6 space-y-4">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-emerald-600 to-teal-700 text-white font-bold text-xl flex items-center justify-center shadow-sm">
              {patient.first_name[0]}
              {patient.last_name[0]}
            </div>
            <div>
              <div className="flex items-center gap-2.5">
                <h1 className="text-xl font-bold tracking-tight text-slate-900">
                  {patient.first_name} {patient.last_name}
                </h1>
                <span className="px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-emerald-100 text-emerald-800 border border-emerald-200 uppercase">
                  Verified Chart
                </span>
              </div>
              <p className="text-xs text-slate-500 mt-0.5">
                DOB: 14 Jun 1992 (32 yrs, {patient.sex}) • Phone: {patient.phone} • Email: {patient.email}
              </p>
            </div>
          </div>

          <div className="flex flex-wrap items-center gap-3 text-xs">
            <div className="px-3 py-1.5 rounded-xl bg-slate-50 border border-slate-200 flex items-center gap-2">
              <Heart className="w-4 h-4 text-rose-500" />
              <span className="font-semibold text-slate-800">Blood: {patient.blood_group}</span>
            </div>

            <div className="px-3 py-1.5 rounded-xl bg-rose-50/70 border border-rose-200 flex items-center gap-2">
              <AlertTriangle className="w-4 h-4 text-rose-600" />
              <span className="font-semibold text-rose-800">
                Allergies: {patient.allergies?.join(', ') || 'None Known'}
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Timeline Section */}
      <div className="space-y-4">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-base font-bold text-slate-900">Longitudinal Encounter History</h3>
            <p className="text-xs text-slate-500">
              Chronologically across all authorized clinical visits.
            </p>
          </div>
          <span className="text-xs font-semibold text-slate-500 font-mono">
            {patientEncounters.length} Visits Logged
          </span>
        </div>

        {patientEncounters.length === 0 ? (
          <div className="p-12 text-center bg-white rounded-2xl border border-slate-200/80 space-y-3">
            <Stethoscope className="w-10 h-10 text-slate-300 mx-auto" />
            <h4 className="text-sm font-bold text-slate-800">No Past Encounters</h4>
            <p className="text-xs text-slate-500 max-w-sm mx-auto">
              This patient has an active consent grant, but no visits have been opened yet.
            </p>
            <button
              type="button"
              onClick={() => navigateTo('doctor-start-encounter', { preselectedPatientId: patient.id })}
              className="mt-2 px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs rounded-xl shadow-xs"
            >
              + Start First Clinical Encounter
            </button>
          </div>
        ) : (
          <div className="relative pl-6 sm:pl-8 space-y-6 before:absolute before:left-3 sm:before:left-4 before:top-3 before:bottom-3 before:w-0.5 before:bg-slate-200">
            {patientEncounters.map((encounter) => {
              const isExpanded = expandedEncounterIds.includes(encounter.id);
              const isOpen = encounter.status === 'open';

              const hasVitals = encounter.vitals && encounter.vitals.length > 0;
              const hasLabs = encounter.labs && encounter.labs.length > 0;
              const hasDiag = encounter.diagnoses && encounter.diagnoses.length > 0;
              const hasRx = encounter.prescriptions && encounter.prescriptions.length > 0;
              const hasApt = Boolean(encounter.appointment);

              return (
                <div key={encounter.id} className="relative group">
                  {/* Timeline Dot Indicator */}
                  <div
                    className={`absolute -left-6 sm:-left-8 top-5 w-6 h-6 rounded-full border-2 bg-white flex items-center justify-center transition-colors ${
                      isOpen
                        ? 'border-emerald-500 text-emerald-600 shadow-xs'
                        : 'border-slate-300 text-slate-500'
                    }`}
                  >
                    <div
                      className={`w-2 h-2 rounded-full ${
                        isOpen ? 'bg-emerald-500 animate-pulse' : 'bg-slate-400'
                      }`}
                    />
                  </div>

                  {/* Encounter Card */}
                  <div
                    id={`encounter-card-${encounter.id}`}
                    className={`bg-white rounded-2xl border transition-all overflow-hidden ${
                      isOpen
                        ? 'border-emerald-300 shadow-md ring-2 ring-emerald-500/10'
                        : 'border-slate-200/80 shadow-xs hover:border-slate-300'
                    }`}
                  >
                    {/* Header */}
                    <div
                      onClick={() => toggleExpand(encounter.id)}
                      className="p-5 flex flex-col sm:flex-row sm:items-center justify-between gap-3 cursor-pointer bg-slate-50/40 hover:bg-slate-50 transition-colors"
                    >
                      <div className="space-y-1">
                        <div className="flex flex-wrap items-center gap-2">
                          <span className="font-bold text-slate-900 text-sm">
                            {new Date(encounter.started_at).toLocaleDateString('en-GB', {
                              day: 'numeric',
                              month: 'short',
                              year: 'numeric',
                              hour: '2-digit',
                              minute: '2-digit',
                            })}
                          </span>
                          <StatusBadge variant={isOpen ? 'open' : 'closed'}>
                            {isOpen ? 'IN PROGRESS' : 'SIGNED OFF'}
                          </StatusBadge>
                          <span className="uppercase text-[10px] font-bold px-2 py-0.5 rounded bg-slate-200/80 text-slate-700">
                            {encounter.type}
                          </span>
                        </div>
                        <p className="text-xs text-slate-500">
                          Attending: <strong>{encounter.opened_by_doctor_name}</strong> • {encounter.clinic_name}
                        </p>
                      </div>

                      {/* Linked Entities Badges + Expand Toggle */}
                      <div className="flex items-center gap-3">
                        <div className="flex items-center gap-1.5 text-[11px] font-medium text-slate-600 bg-white px-3 py-1 rounded-xl border border-slate-200 shadow-2xs">
                          <span className={hasVitals ? 'text-emerald-700 font-bold' : 'text-slate-300'}>
                            Vitals {hasVitals ? '✓' : '—'}
                          </span>
                          <span className="text-slate-300">•</span>
                          <span className={hasLabs ? 'text-emerald-700 font-bold' : 'text-slate-300'}>
                            Labs {hasLabs ? '✓' : '—'}
                          </span>
                          <span className="text-slate-300">•</span>
                          <span className={hasDiag ? 'text-emerald-700 font-bold' : 'text-slate-300'}>
                            Diagnosis {hasDiag ? '✓' : '—'}
                          </span>
                          <span className="text-slate-300">•</span>
                          <span className={hasRx ? 'text-emerald-700 font-bold' : 'text-slate-300'}>
                            Rx {hasRx ? '✓' : '—'}
                          </span>
                          <span className="text-slate-300">•</span>
                          <span className={hasApt ? 'text-emerald-700 font-bold' : 'text-slate-300'}>
                            Follow-Up {hasApt ? '✓' : '—'}
                          </span>
                        </div>

                        <button
                          type="button"
                          onClick={(e) => {
                            e.stopPropagation();
                            navigateTo('doctor-encounter-workspace', { encounterId: encounter.id });
                          }}
                          className="px-3 py-1.5 bg-slate-900 hover:bg-slate-800 text-white rounded-xl text-xs font-semibold flex items-center gap-1 transition-colors"
                        >
                          <span>{isOpen ? 'Open Workspace' : 'View Audit Record'}</span>
                          <ExternalLink className="w-3.5 h-3.5 text-slate-400" />
                        </button>

                        <button
                          type="button"
                          className="p-1.5 text-slate-400 hover:text-slate-600"
                        >
                          {isExpanded ? <ChevronUp className="w-4 h-4" /> : <ChevronDown className="w-4 h-4" />}
                        </button>
                      </div>
                    </div>

                    {/* Expanded Clinical Summary Content */}
                    {isExpanded && (
                      <div className="p-5 border-t border-slate-100 space-y-4 text-xs">
                        {encounter.notes && (
                          <div className="p-3 bg-slate-50 rounded-xl text-slate-700 italic border border-slate-200/60">
                            &ldquo;{encounter.notes}&rdquo;
                          </div>
                        )}

                        {/* Diagnoses Preview */}
                        {hasDiag && (
                          <div className="space-y-1.5">
                            <span className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block">
                              Diagnoses & Impressions
                            </span>
                            <div className="space-y-1.5">
                              {encounter.diagnoses.map((d) => (
                                <div
                                  key={d.id}
                                  className="p-2.5 bg-emerald-50/50 border border-emerald-100 rounded-xl flex items-center justify-between"
                                >
                                  <div>
                                    <span className="font-bold text-slate-900">{d.diagnosis_text}</span>
                                    {d.icd_code && (
                                      <span className="ml-2 font-mono text-[10px] bg-white px-1.5 py-0.5 rounded border border-emerald-200 text-emerald-800">
                                        {d.icd_code}
                                      </span>
                                    )}
                                  </div>
                                  <StatusBadge variant={d.diagnosis_type}>{d.diagnosis_type}</StatusBadge>
                                </div>
                              ))}
                            </div>
                          </div>
                        )}

                        {/* Vitals Summary Strip */}
                        {hasVitals && (
                          <div className="space-y-1.5">
                            <span className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block">
                              Latest Vitals
                            </span>
                            <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 text-center">
                              {encounter.vitals[0]?.systolic_bp && (
                                <div className="p-2 bg-slate-50 rounded-xl border border-slate-100">
                                  <span className="text-[10px] text-slate-400 block">Blood Pressure</span>
                                  <span className="font-bold text-slate-900">
                                    {encounter.vitals[0].systolic_bp}/{encounter.vitals[0].diastolic_bp} mmHg
                                  </span>
                                </div>
                              )}
                              {encounter.vitals[0]?.pulse && (
                                <div className="p-2 bg-slate-50 rounded-xl border border-slate-100">
                                  <span className="text-[10px] text-slate-400 block">Pulse</span>
                                  <span className="font-bold text-slate-900">{encounter.vitals[0].pulse} bpm</span>
                                </div>
                              )}
                              {encounter.vitals[0]?.spo2 && (
                                <div className="p-2 bg-slate-50 rounded-xl border border-slate-100">
                                  <span className="text-[10px] text-slate-400 block">SpO2</span>
                                  <span className="font-bold text-slate-900">{encounter.vitals[0].spo2}%</span>
                                </div>
                              )}
                              {encounter.vitals[0]?.temperature && (
                                <div className="p-2 bg-slate-50 rounded-xl border border-slate-100">
                                  <span className="text-[10px] text-slate-400 block">Temperature</span>
                                  <span className="font-bold text-slate-900">{encounter.vitals[0].temperature}°C</span>
                                </div>
                              )}
                            </div>
                          </div>
                        )}

                        {/* Prescriptions Preview */}
                        {hasRx && (
                          <div className="space-y-1.5">
                            <span className="text-[11px] font-bold text-slate-400 uppercase tracking-wider block">
                              Active Prescriptions
                            </span>
                            <div className="space-y-1.5">
                              {encounter.prescriptions.flatMap((rx) => rx.items).map((item) => (
                                <div
                                  key={item.id}
                                  className="p-2.5 bg-slate-50 border border-slate-200/80 rounded-xl flex items-center justify-between"
                                >
                                  <div>
                                    <p className="font-bold text-slate-900">
                                      {item.medication_name} ({item.dose})
                                    </p>
                                    <p className="text-[11px] text-slate-500">
                                      {item.frequency} • {item.duration} • {item.instructions}
                                    </p>
                                  </div>
                                  <StatusBadge variant={item.status}>{item.status}</StatusBadge>
                                </div>
                              ))}
                            </div>
                          </div>
                        )}
                      </div>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}
