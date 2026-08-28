'use client';

import React, { useState } from 'react';
import { useStore } from '@/lib/store';
import { CountdownBadge } from '@/components/ui/CountdownBadge';
import { StatusBadge } from '@/components/ui/Badge';
import {
  Smartphone,
  X,
  ShieldCheck,
  Clock,
  CheckCircle2,
  XCircle,
  Building2,
  Stethoscope,
  Heart,
  Pill,
  Calendar,
  AlertTriangle,
  Lock,
} from 'lucide-react';

interface PatientAppSimulatorProps {
  isOpen: boolean;
  onClose: () => void;
}

export function PatientAppSimulator({ isOpen, onClose }: PatientAppSimulatorProps) {
  const {
    patients,
    accessRequests,
    encounters,
    approveAccessRequest,
    denyAccessRequest,
    revokeAccessRequest,
  } = useStore();

  const [selectedPatientId, setSelectedPatientId] = useState<string>(patients[0]?.id || '');
  const activePatient = patients.find((p) => p.id === selectedPatientId) || patients[0];

  if (!isOpen || !activePatient) return null;

  // Requests directed to this patient
  const patientRequests = accessRequests.filter((r) => r.patient_id === activePatient.id);
  const pendingRequest = patientRequests.find((r) => r.status === 'pending');
  const approvedRequests = patientRequests.filter((r) => r.status === 'approved');

  // Encounters for this patient
  const patientEncounters = encounters.filter((e) => e.patient_id === activePatient.id);

  return (
    <div
      id="patient-simulator-backdrop"
      className="fixed inset-0 z-50 bg-slate-950/70 backdrop-blur-xs flex items-center justify-center p-4 overflow-y-auto animate-in fade-in duration-200"
    >
      {/* Mobile Device Frame */}
      <div className="relative w-full max-w-sm bg-slate-950 rounded-[44px] p-3.5 shadow-2xl border-4 border-slate-800 ring-1 ring-white/10">
        {/* Device Notch / Island */}
        <div className="absolute top-6 left-1/2 -translate-x-1/2 w-28 h-4 bg-slate-900 rounded-full z-20 flex items-center justify-center">
          <div className="w-2.5 h-2.5 rounded-full bg-slate-950 mr-2" />
          <div className="w-1.5 h-1.5 rounded-full bg-emerald-500/60" />
        </div>

        {/* Close Button Top Right */}
        <button
          onClick={onClose}
          className="absolute -top-3 -right-3 z-30 p-2 bg-slate-800 text-white hover:bg-slate-700 rounded-full border border-slate-600 shadow-md cursor-pointer"
          title="Close Simulator"
        >
          <X className="w-4 h-4" />
        </button>

        {/* Phone Screen Canvas */}
        <div className="bg-slate-900 rounded-[34px] overflow-hidden text-slate-100 min-h-[640px] max-h-[720px] flex flex-col border border-slate-800">
          {/* Status Bar */}
          <div className="pt-3 px-6 pb-2 flex items-center justify-between text-[11px] font-mono text-slate-400">
            <span>09:41</span>
            <div className="flex items-center gap-1.5 text-[10px]">
              <span>5G</span>
              <span>100%</span>
            </div>
          </div>

          {/* App Header & Patient Switcher */}
          <div className="px-5 pt-3 pb-3 border-b border-slate-800 space-y-2 bg-slate-950/50">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <div className="w-6 h-6 rounded-lg bg-[#388E3C] flex items-center justify-center text-white font-bold text-xs">
                  A
                </div>
                <span className="font-bold text-xs text-white tracking-wide">AfyaMind Mobile</span>
              </div>
              <span className="text-[10px] px-2 py-0.5 rounded-full bg-[#388E3C]/20 text-[#A5D6A7] font-medium border border-[#388E3C]/30">
                Citizen App
              </span>
            </div>

            {/* Switch Active Patient */}
            <div className="space-y-1">
              <label className="text-[10px] text-slate-400 uppercase font-semibold">
                Simulating Citizen:
              </label>
              <select
                value={selectedPatientId}
                onChange={(e) => setSelectedPatientId(e.target.value)}
                className="w-full px-2.5 py-1.5 bg-slate-800 border border-slate-700 rounded-xl text-xs text-white focus:outline-none focus:ring-1 focus:ring-[#388E3C]"
              >
                {patients.map((p) => (
                  <option key={p.id} value={p.id}>
                    {p.first_name} {p.last_name} ({p.phone})
                  </option>
                ))}
              </select>
            </div>
          </div>

          {/* Screen Body */}
          <div className="flex-1 overflow-y-auto p-4 space-y-4 text-xs">
            {/* Urgent Access Request Notification Banner */}
            {pendingRequest ? (
              <div className="p-4 rounded-2xl bg-gradient-to-br from-amber-950/90 to-slate-900 border-2 border-amber-500 shadow-lg space-y-3 animate-in zoom-in-95">
                <div className="flex items-center justify-between">
                  <span className="px-2 py-0.5 rounded text-[10px] font-bold uppercase bg-amber-500 text-slate-950 animate-pulse">
                    Access Consent Request
                  </span>
                  <CountdownBadge expiresAt={pendingRequest.expires_at} type="access_request" className="text-[11px]" />
                </div>

                <div className="space-y-1">
                  <p className="font-bold text-white text-sm">
                    {pendingRequest.clinic_name}
                  </p>
                  <p className="text-[11px] text-amber-200">
                    Requested by <strong>{pendingRequest.submitted_by_doctor_name}</strong>
                  </p>
                  <div className="p-2.5 bg-slate-950/70 rounded-xl border border-amber-900/60 mt-1.5">
                    <p className="text-[11px] text-slate-300 italic">
                      &ldquo;{pendingRequest.reason}&rdquo;
                    </p>
                  </div>
                </div>

                {/* Consent Decision Buttons */}
                <div className="grid grid-cols-2 gap-2 pt-1">
                  <button
                    type="button"
                    onClick={() => approveAccessRequest(pendingRequest.id)}
                    className="py-2 px-3 bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-bold rounded-xl text-xs flex items-center justify-center gap-1.5 shadow-md cursor-pointer"
                  >
                    <CheckCircle2 className="w-3.5 h-3.5" />
                    <span>Authorize</span>
                  </button>

                  <button
                    type="button"
                    onClick={() => denyAccessRequest(pendingRequest.id)}
                    className="py-2 px-3 bg-slate-800 hover:bg-slate-700 text-rose-300 border border-rose-900/50 font-semibold rounded-xl text-xs flex items-center justify-center gap-1.5 cursor-pointer"
                  >
                    <XCircle className="w-3.5 h-3.5" />
                    <span>Decline</span>
                  </button>
                </div>
              </div>
            ) : (
              <div className="p-3 bg-slate-950/40 rounded-xl border border-slate-800 text-[11px] text-slate-400 flex items-center gap-2">
                <ShieldCheck className="w-4 h-4 text-emerald-400 shrink-0" />
                <span>No pending consent requests awaiting your decision.</span>
              </div>
            )}

            {/* Active Grants / Authorized Clinics */}
            <div className="space-y-2">
              <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400 block">
                Clinics with Active Consent ({approvedRequests.length})
              </span>

              {approvedRequests.length === 0 ? (
                <p className="text-[11px] text-slate-500 italic">No clinics currently authorized.</p>
              ) : (
                approvedRequests.map((req) => (
                  <div
                    key={req.id}
                    className="p-3 rounded-xl bg-slate-800/80 border border-slate-700 flex items-center justify-between"
                  >
                    <div>
                      <p className="font-bold text-white text-xs">{req.clinic_name}</p>
                      <p className="text-[10px] text-slate-400">
                        Authorized {new Date(req.created_at).toLocaleDateString()}
                      </p>
                    </div>
                    <button
                      type="button"
                      onClick={() => revokeAccessRequest(req.id)}
                      className="px-2.5 py-1 bg-rose-500/20 text-rose-300 border border-rose-500/30 rounded-lg text-[10px] font-bold hover:bg-rose-500/30 cursor-pointer"
                    >
                      Revoke
                    </button>
                  </div>
                ))
              )}
            </div>

            {/* Health Passport Timeline as seen by patient */}
            <div className="space-y-2 pt-2 border-t border-slate-800">
              <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400 block">
                My Health Records ({patientEncounters.length} Visits)
              </span>

              {patientEncounters.length === 0 ? (
                <p className="text-[11px] text-slate-500 italic">No medical records on file.</p>
              ) : (
                <div className="space-y-2.5">
                  {patientEncounters.map((enc) => (
                    <div key={enc.id} className="p-3 bg-slate-800/50 rounded-xl border border-slate-700/60 space-y-1.5">
                      <div className="flex items-center justify-between">
                        <span className="font-bold text-white text-xs">{enc.clinic_name}</span>
                        <span className="text-[10px] font-mono text-slate-400">
                          {new Date(enc.started_at).toLocaleDateString()}
                        </span>
                      </div>
                      <p className="text-[11px] text-slate-300">
                        Attending: Dr. {enc.opened_by_doctor_name}
                      </p>
                      {enc.diagnoses && enc.diagnoses.length > 0 && (
                        <div className="flex flex-wrap gap-1 pt-1">
                          {enc.diagnoses.map((d) => (
                            <span key={d.id} className="px-1.5 py-0.5 rounded bg-emerald-500/20 text-emerald-300 text-[10px]">
                              {d.diagnosis_text}
                            </span>
                          ))}
                        </div>
                      )}
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Bottom Bar indicator */}
          <div className="py-2 flex justify-center">
            <div className="w-32 h-1 bg-slate-700 rounded-full" />
          </div>
        </div>
      </div>
    </div>
  );
}
