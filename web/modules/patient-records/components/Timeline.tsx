'use client';

import React, { useState } from 'react';
import {
  Activity,
  FlaskConical,
  Stethoscope,
  Pill,
  Calendar,
  Building2,
  User,
  ChevronDown,
  ChevronUp,
  Heart,
  Wind,
  Thermometer,
  Scale,
  FileText,
  Clock,
  Sparkles,
  ShieldCheck,
  CheckCircle2,
} from 'lucide-react';
import { usePatientTimeline } from '../hooks/usePatientTimeline';
import { formatDateTime } from '@/modules/core/lib/utils';
import { StatusBadge } from '@/modules/core/ui/StatusBadge';

interface TimelineProps {
  patientId: string;
}

export function Timeline({ patientId }: TimelineProps) {
  const encounters = usePatientTimeline(patientId);

  // Default first encounter card expanded
  const [expandedIds, setExpandedIds] = useState<string[]>(() => {
    return encounters.length > 0 ? [encounters[0].encounter_id] : [];
  });

  const toggleExpand = (id: string) => {
    setExpandedIds((prev) =>
      prev.includes(id) ? prev.filter((item) => item !== id) : [...prev, id]
    );
  };

  const expandAll = () => {
    setExpandedIds(encounters.map((e) => e.encounter_id));
  };

  const collapseAll = () => {
    setExpandedIds([]);
  };

  if (encounters.length === 0) {
    return (
      <div className="p-10 text-center bg-white rounded-3xl border border-slate-200 text-xs text-slate-500 shadow-2xs space-y-2">
        <Stethoscope className="w-8 h-8 text-slate-300 mx-auto" />
        <p className="font-semibold text-slate-700">No Longitudinal Health Records</p>
        <p className="text-[11px] text-slate-400">There are no logged encounters or clinical visits for this patient chart yet.</p>
      </div>
    );
  }

  const allExpanded = expandedIds.length === encounters.length;

  return (
    <div className="space-y-4 select-none">
      {/* Header Controls */}
      <div className="flex flex-wrap items-center justify-between gap-3 bg-white p-4 rounded-2xl border border-slate-200 shadow-2xs">
        <div>
          <h3 className="text-base font-bold text-slate-900 flex items-center gap-2">
            <Activity className="w-5 h-5 text-[#2E7D32]" />
            Longitudinal Patient Encounter History
          </h3>
          <p className="text-xs text-slate-500">
            Interactive accordion cards formatted into structured clinical grids.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <span className="text-xs font-mono font-semibold px-3 py-1 rounded-xl bg-slate-100 text-slate-700 border border-slate-200">
            {encounters.length} Visits Logged
          </span>

          <button
            type="button"
            onClick={allExpanded ? collapseAll : expandAll}
            className="px-3.5 py-1.5 rounded-xl bg-[#E8F5E9] hover:bg-[#C8E6C9] text-[#1B5E20] text-xs font-bold transition-colors cursor-pointer border border-[#A5D6A7]"
          >
            {allExpanded ? 'Collapse All' : 'Expand All'}
          </button>
        </div>
      </div>

      {/* Accordion Timeline Container */}
      <div className="relative pl-6 sm:pl-8 space-y-5 before:absolute before:left-3 sm:before:left-4 before:top-3 before:bottom-3 before:w-0.5 before:bg-slate-200">
        {encounters.map((enc) => {
          const isExpanded = expandedIds.includes(enc.encounter_id);
          const isOpen = enc.rawEncounter.status === 'open';

          const hasVitals =
            enc.vitals !== null &&
            (enc.vitals.systolic_bp !== null ||
              enc.vitals.pulse !== null ||
              enc.vitals.spo2 !== null ||
              enc.vitals.temperature !== null);
          const hasRx = enc.prescription && enc.prescription.length > 0;
          const hasLabs = enc.labs && enc.labs.length > 0;
          const hasDiag = enc.diagnosesList && enc.diagnosesList.length > 0;

          return (
            <div key={enc.encounter_id} className="relative group">
              {/* Timeline dot indicator */}
              <div
                className={`absolute -left-6 sm:-left-8 top-5 w-6 h-6 rounded-full border-2 bg-white flex items-center justify-center transition-colors shadow-xs ${
                  isOpen ? 'border-[#388E3C] text-[#2E7D32]' : 'border-slate-300 text-slate-400'
                }`}
              >
                <div
                  className={`w-2 h-2 rounded-full ${
                    isOpen ? 'bg-[#388E3C] animate-pulse' : 'bg-slate-400'
                  }`}
                />
              </div>

              {/* Accordion Main Card */}
              <div
                className={`bg-white rounded-2xl border transition-all duration-200 overflow-hidden ${
                  isExpanded
                    ? 'border-[#81C784] shadow-md ring-2 ring-[#388E3C]/10'
                    : 'border-slate-200/90 shadow-2xs hover:border-slate-300'
                }`}
              >
                {/* 1. COLLAPSED STATE HEADER BAR */}
                <div
                  onClick={() => toggleExpand(enc.encounter_id)}
                  className="p-4 sm:p-5 flex flex-col sm:flex-row sm:items-center justify-between gap-3 cursor-pointer bg-white hover:bg-slate-50/90 transition-colors"
                >
                  <div className="space-y-1.5 flex-1 pr-2">
                    <div className="flex flex-wrap items-center gap-2">
                      <span className="font-bold text-slate-900 text-sm flex items-center gap-1.5">
                        <Calendar className="w-4 h-4 text-[#2E7D32]" />
                        {formatDateTime(enc.date)}
                      </span>

                      <span className="px-2 py-0.5 rounded-md text-[10px] font-bold uppercase tracking-wider bg-slate-100 text-slate-700 border border-slate-200">
                        {enc.rawEncounter.type}
                      </span>

                      <StatusBadge status={isOpen ? 'open' : 'closed'} />
                    </div>

                    {/* Chief Complaint / State Summary */}
                    <div className="text-xs text-slate-700 flex flex-wrap items-center gap-2">
                      <span className="font-semibold text-slate-900">Chief Complaint:</span>
                      <span className="text-slate-600 italic truncate max-w-xl">
                        &ldquo;{enc.chief_complaint}&rdquo;
                      </span>
                    </div>

                    {/* Primary Diagnosis Pill */}
                    {enc.diagnosis && (
                      <div className="flex items-center gap-1.5 pt-0.5">
                        <span className="text-[11px] font-bold text-[#2E7D32] bg-[#E8F5E9] border border-[#C8E6C9] px-2.5 py-0.5 rounded-lg flex items-center gap-1">
                          <Stethoscope className="w-3.5 h-3.5 text-[#2E7D32]" />
                          Diagnosis: {enc.diagnosis}
                        </span>
                      </div>
                    )}

                    {/* Provider & Clinic Meta */}
                    <div className="flex flex-wrap items-center gap-3 text-[11px] text-slate-500 pt-0.5">
                      <span className="flex items-center gap-1 font-medium">
                        <Building2 className="w-3.5 h-3.5 text-slate-400" />
                        {enc.rawEncounter.clinic_name}
                      </span>
                      <span>•</span>
                      <span className="flex items-center gap-1 font-medium">
                        <User className="w-3.5 h-3.5 text-slate-400" />
                        Dr. {enc.rawEncounter.opened_by_doctor_name}
                      </span>
                    </div>
                  </div>

                  {/* Summary Badges & Accordion Toggle Icon */}
                  <div className="flex items-center gap-3 shrink-0 self-start sm:self-center">
                    <div className="hidden lg:flex items-center gap-1.5 text-[11px]">
                      <span
                        className={`px-2.5 py-1 rounded-lg border font-semibold ${
                          hasVitals
                            ? 'bg-[#E8F5E9] text-[#2E7D32] border-[#C8E6C9]'
                            : 'bg-slate-50 text-slate-400 border-slate-200'
                        }`}
                      >
                        Vitals {hasVitals ? '✓' : '—'}
                      </span>
                      <span
                        className={`px-2.5 py-1 rounded-lg border font-semibold ${
                          hasDiag
                            ? 'bg-[#E8F5E9] text-[#2E7D32] border-[#C8E6C9]'
                            : 'bg-slate-50 text-slate-400 border-slate-200'
                        }`}
                      >
                        Diagnosis {hasDiag ? `(${enc.diagnosesList.length})` : '—'}
                      </span>
                      <span
                        className={`px-2.5 py-1 rounded-lg border font-semibold ${
                          hasRx
                            ? 'bg-[#E8F5E9] text-[#2E7D32] border-[#C8E6C9]'
                            : 'bg-slate-50 text-slate-400 border-slate-200'
                        }`}
                      >
                        Rx {hasRx ? `(${enc.prescription.length})` : '—'}
                      </span>
                      <span
                        className={`px-2.5 py-1 rounded-lg border font-semibold ${
                          hasLabs
                            ? 'bg-sky-50 text-sky-700 border-sky-200'
                            : 'bg-slate-50 text-slate-400 border-slate-200'
                        }`}
                      >
                        Labs {hasLabs ? `(${enc.labs.length})` : '—'}
                      </span>
                    </div>

                    <div className="p-2 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 transition-colors">
                      {isExpanded ? (
                        <ChevronUp className="w-4 h-4 text-[#2E7D32]" />
                      ) : (
                        <ChevronDown className="w-4 h-4 text-slate-500" />
                      )}
                    </div>
                  </div>
                </div>

                {/* 2. EXPANDED STATE (GRID DASHBOARD FORMAT) */}
                {isExpanded && (
                  <div className="p-5 sm:p-6 border-t border-slate-200/90 bg-slate-50/70 space-y-6 animate-in fade-in duration-150">
                    {/* Dashboard 2-Column Grid */}
                    <div className="grid grid-cols-1 lg:grid-cols-12 gap-5">
                      {/* Left Column: Chief Complaint & Vitals Telemetry (7 cols) */}
                      <div className="lg:col-span-7 space-y-5">
                        {/* Chief Complaint Box */}
                        <div className="bg-white rounded-2xl p-4 border border-slate-200/90 shadow-2xs space-y-2">
                          <div className="flex items-center justify-between border-b border-slate-100 pb-2">
                            <span className="text-[11px] font-bold text-slate-500 uppercase tracking-wider flex items-center gap-1.5">
                              <FileText className="w-4 h-4 text-[#2E7D32]" />
                              Chief Complaint & Clinical Summary
                            </span>
                            <span className="text-[10px] font-mono text-slate-400">
                              Encounter #{enc.encounter_id.substring(0, 10)}
                            </span>
                          </div>
                          <p className="text-xs text-slate-800 leading-relaxed italic bg-slate-50/80 p-3 rounded-xl border border-slate-100">
                            &ldquo;{enc.chief_complaint}&rdquo;
                          </p>
                        </div>

                        {/* Vitals Telemetry Grid (2x4) */}
                        <div className="bg-white rounded-2xl p-4 border border-slate-200/90 shadow-2xs space-y-3">
                          <div className="flex items-center justify-between border-b border-slate-100 pb-2">
                            <span className="text-[11px] font-bold text-slate-500 uppercase tracking-wider flex items-center gap-1.5">
                              <Activity className="w-4 h-4 text-[#2E7D32]" />
                              Vitals Signs & Telemetry Grid
                            </span>
                            {hasVitals && (
                              <span className="text-[10px] font-semibold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded border border-emerald-200">
                                Recorded at Visit
                              </span>
                            )}
                          </div>

                          {enc.vitals ? (
                            <div className="grid grid-cols-2 sm:grid-cols-4 gap-2.5">
                              {/* Blood Pressure */}
                              <div className="p-3 bg-rose-50/50 rounded-xl border border-rose-100 space-y-1">
                                <span className="text-[10px] font-bold text-rose-700 uppercase flex items-center gap-1">
                                  <Heart className="w-3.5 h-3.5 text-rose-500" />
                                  Blood Pressure
                                </span>
                                <span className="text-xs font-bold text-slate-900 block font-mono">
                                  {enc.vitals.systolic_bp && enc.vitals.diastolic_bp
                                    ? `${enc.vitals.systolic_bp} / ${enc.vitals.diastolic_bp} mmHg`
                                    : '—'}
                                </span>
                              </div>

                              {/* Pulse */}
                              <div className="p-3 bg-emerald-50/50 rounded-xl border border-emerald-100 space-y-1">
                                <span className="text-[10px] font-bold text-emerald-700 uppercase flex items-center gap-1">
                                  <Activity className="w-3.5 h-3.5 text-[#2E7D32]" />
                                  Pulse Rate
                                </span>
                                <span className="text-xs font-bold text-slate-900 block font-mono">
                                  {enc.vitals.pulse ? `${enc.vitals.pulse} bpm` : '—'}
                                </span>
                              </div>

                              {/* SpO2 */}
                              <div className="p-3 bg-sky-50/50 rounded-xl border border-sky-100 space-y-1">
                                <span className="text-[10px] font-bold text-sky-700 uppercase flex items-center gap-1">
                                  <Wind className="w-3.5 h-3.5 text-sky-500" />
                                  Oxygen SpO2
                                </span>
                                <span className="text-xs font-bold text-slate-900 block font-mono">
                                  {enc.vitals.spo2 ? `${enc.vitals.spo2}%` : '—'}
                                </span>
                              </div>

                              {/* Temperature */}
                              <div className="p-3 bg-amber-50/50 rounded-xl border border-amber-100 space-y-1">
                                <span className="text-[10px] font-bold text-amber-700 uppercase flex items-center gap-1">
                                  <Thermometer className="w-3.5 h-3.5 text-amber-500" />
                                  Temperature
                                </span>
                                <span className="text-xs font-bold text-slate-900 block font-mono">
                                  {enc.vitals.temperature ? `${enc.vitals.temperature} °C` : '—'}
                                </span>
                              </div>

                              {/* Resp Rate */}
                              <div className="p-3 bg-purple-50/50 rounded-xl border border-purple-100 space-y-1">
                                <span className="text-[10px] font-bold text-purple-700 uppercase flex items-center gap-1">
                                  <Activity className="w-3.5 h-3.5 text-purple-500" />
                                  Resp. Rate
                                </span>
                                <span className="text-xs font-bold text-slate-900 block font-mono">
                                  {enc.vitals.respiratory_rate ? `${enc.vitals.respiratory_rate} /min` : '—'}
                                </span>
                              </div>

                              {/* Blood Sugar */}
                              <div className="p-3 bg-indigo-50/50 rounded-xl border border-indigo-100 space-y-1">
                                <span className="text-[10px] font-bold text-indigo-700 uppercase flex items-center gap-1">
                                  <FlaskConical className="w-3.5 h-3.5 text-indigo-500" />
                                  Blood Glucose
                                </span>
                                <span className="text-xs font-bold text-slate-900 block font-mono">
                                  {enc.vitals.blood_sugar ? `${enc.vitals.blood_sugar} mmol/L` : '—'}
                                </span>
                              </div>

                              {/* Body Weight */}
                              <div className="p-3 bg-slate-100/70 rounded-xl border border-slate-200 space-y-1 col-span-2 sm:col-span-2">
                                <span className="text-[10px] font-bold text-slate-600 uppercase flex items-center gap-1">
                                  <Scale className="w-3.5 h-3.5 text-slate-500" />
                                  Body Weight
                                </span>
                                <span className="text-xs font-bold text-slate-900 block font-mono">
                                  {enc.vitals.weight ? `${enc.vitals.weight} kg` : '—'}
                                </span>
                              </div>
                            </div>
                          ) : (
                            <div className="p-4 bg-slate-50 rounded-xl text-center text-xs text-slate-400 italic">
                              No vitals logged for this visit.
                            </div>
                          )}
                        </div>

                        {/* Diagnostic Labs Section Grid */}
                        {hasLabs && (
                          <div className="bg-white rounded-2xl p-4 border border-slate-200/90 shadow-2xs space-y-3">
                            <div className="flex items-center justify-between border-b border-slate-100 pb-2">
                              <span className="text-[11px] font-bold text-slate-500 uppercase tracking-wider flex items-center gap-1.5">
                                <FlaskConical className="w-4 h-4 text-sky-600" />
                                Diagnostic Lab Results ({enc.labs.length})
                              </span>
                            </div>

                            <div className="space-y-2.5">
                              {enc.labs.map((lab) => (
                                <div
                                  key={lab.id}
                                  className="p-3 bg-slate-50/80 border border-slate-200/80 rounded-xl space-y-1"
                                >
                                  <div className="flex items-center justify-between">
                                    <div className="flex items-center gap-2">
                                      <span className="font-bold text-slate-900 text-xs">
                                        {lab.test_name}
                                      </span>
                                      <span className="text-[10px] px-2 py-0.5 rounded bg-white text-slate-600 font-semibold border border-slate-200">
                                        {lab.category}
                                      </span>
                                    </div>
                                    <StatusBadge status={lab.flag} />
                                  </div>
                                  {lab.measurements && (
                                    <p className="text-[11px] font-mono text-slate-700 pt-0.5">
                                      {lab.measurements}
                                    </p>
                                  )}
                                  <p className="text-[11px] text-slate-500 italic">
                                    {lab.summary_notes}
                                  </p>
                                </div>
                              ))}
                            </div>
                          </div>
                        )}
                      </div>

                      {/* Right Column: Diagnoses & Prescriptions Grid (5 cols) */}
                      <div className="lg:col-span-5 space-y-5">
                        {/* Diagnoses Panel */}
                        <div className="bg-white rounded-2xl p-4 border border-slate-200/90 shadow-2xs space-y-3">
                          <div className="flex items-center justify-between border-b border-slate-100 pb-2">
                            <span className="text-[11px] font-bold text-slate-500 uppercase tracking-wider flex items-center gap-1.5">
                              <Stethoscope className="w-4 h-4 text-purple-600" />
                              Diagnoses ({enc.diagnosesList.length})
                            </span>
                          </div>

                          {hasDiag ? (
                            <div className="space-y-2.5">
                              {enc.diagnosesList.map((d) => (
                                <div
                                  key={d.id}
                                  className="p-3 bg-purple-50/40 border border-purple-100 rounded-xl space-y-1"
                                >
                                  <div className="flex items-center justify-between">
                                    <span className="font-bold text-slate-900 text-xs">
                                      {d.diagnosis_text}
                                    </span>
                                    <StatusBadge status={d.diagnosis_type} />
                                  </div>
                                  {d.icd_code && (
                                    <span className="inline-block font-mono text-[10px] bg-white text-purple-700 px-1.5 py-0.5 rounded border border-purple-200">
                                      ICD-10: {d.icd_code}
                                    </span>
                                  )}
                                  {d.notes && (
                                    <p className="text-[11px] text-slate-600 pt-0.5">{d.notes}</p>
                                  )}
                                </div>
                              ))}
                            </div>
                          ) : (
                            <div className="p-3 bg-slate-50 rounded-xl text-center text-xs text-slate-400 italic">
                              No diagnosis logged for this visit.
                            </div>
                          )}
                        </div>

                        {/* Prescriptions Panel */}
                        <div className="bg-white rounded-2xl p-4 border border-slate-200/90 shadow-2xs space-y-3">
                          <div className="flex items-center justify-between border-b border-slate-100 pb-2">
                            <span className="text-[11px] font-bold text-slate-500 uppercase tracking-wider flex items-center gap-1.5">
                              <Pill className="w-4 h-4 text-[#2E7D32]" />
                              Prescriptions & Meds ({enc.prescription.length})
                            </span>
                          </div>

                          {hasRx ? (
                            <div className="space-y-2.5">
                              {enc.prescription.map((item, idx) => (
                                <div
                                  key={idx}
                                  className="p-3.5 bg-[#E8F5E9]/50 border border-[#C8E6C9] rounded-xl space-y-1.5"
                                >
                                  <div className="flex flex-wrap items-center justify-between gap-1.5">
                                    <span className="font-bold text-slate-900 text-xs">
                                      {item.medication_name}
                                    </span>
                                    <span className="px-2 py-0.5 rounded bg-white border border-[#C8E6C9] font-mono font-bold text-[10px] text-[#1B5E20]">
                                      {item.dose}
                                    </span>
                                  </div>

                                  {/* Dose Schedule Badges */}
                                  <div className="flex flex-wrap items-center gap-1 text-[10px] font-mono">
                                    <span className="px-1.5 py-0.5 bg-[#388E3C] text-white rounded font-bold uppercase">
                                      {item.frequency}
                                    </span>
                                    <span className="px-1.5 py-0.5 bg-white border border-[#C8E6C9] text-[#2E7D32] rounded font-semibold">
                                      {item.route}
                                    </span>
                                    <span className="px-1.5 py-0.5 bg-white border border-[#C8E6C9] text-[#2E7D32] rounded font-semibold">
                                      {item.duration}
                                    </span>
                                  </div>

                                  {item.instructions && (
                                    <p className="text-[11px] text-[#1B5E20] pt-0.5">
                                      <strong>Notes:</strong> {item.instructions}
                                    </p>
                                  )}
                                </div>
                              ))}
                            </div>
                          ) : (
                            <div className="p-3 bg-slate-50 rounded-xl text-center text-xs text-slate-400 italic">
                              No prescriptions recorded for this visit.
                            </div>
                          )}
                        </div>
                      </div>
                    </div>

                    {/* Bottom Metadata & Audit Trail */}
                    <div className="pt-3 border-t border-slate-200/80 flex flex-wrap items-center justify-between gap-2 text-[10px] font-mono text-slate-400 bg-white p-3 rounded-xl border border-slate-200/60 shadow-2xs">
                      <span className="flex items-center gap-1">
                        <ShieldCheck className="w-3.5 h-3.5 text-[#2E7D32]" />
                        Encounter ID: {enc.encounter_id}
                      </span>
                      <span>Facility: {enc.rawEncounter.clinic_name}</span>
                      <span>Attending: Dr. {enc.rawEncounter.opened_by_doctor_name}</span>
                    </div>
                  </div>
                )}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
