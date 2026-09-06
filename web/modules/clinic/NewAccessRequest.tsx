'use client';

import React, { useState } from 'react';
import { useStore } from '@/lib/store';
import { CountdownBadge } from '@/components/ui/CountdownBadge';
import {
  Send,
  ArrowLeft,
  User,
  Stethoscope,
  Clock,
  CheckCircle2,
  XCircle,
  ShieldCheck,
  AlertTriangle,
} from 'lucide-react';

export function NewAccessRequest() {
  const {
    patients,
    doctors,
    currentUser,
    viewParams,
    createAccessRequest,
    approveAccessRequest,
    denyAccessRequest,
    navigateTo,
  } = useStore();

  const patientId = viewParams.patientId || patients[0]?.id;
  const patient = patients.find((p) => p.id === patientId) || patients[0];

  const activeDoctors = doctors.filter(
    (d) => d.clinic_id === currentUser?.clinic_id && d.doctor_status === 'active'
  );

  const [submittingDoctorId, setSubmittingDoctorId] = useState(
    activeDoctors[0]?.id || doctors[0]?.id || ''
  );
  const [reason, setReason] = useState(
    'Clinical consultation, medical examination, and prescription management.'
  );
  const [submittedRequest, setSubmittedRequest] = useState<{
    id: string;
    expires_at: string;
  } | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!reason.trim() || !patient) return;

    const req = await createAccessRequest(patient.id, reason, submittingDoctorId);
    setSubmittedRequest({
      id: req.id,
      expires_at: req.expires_at,
    });
  };


  return (
    <div id="new-access-request-page" className="p-6 md:p-8 max-w-3xl mx-auto space-y-6">
      {/* Header */}
      <div className="flex items-center gap-3">
        <button
          id="back-to-lookup-btn"
          type="button"
          onClick={() => navigateTo('clinic-lookup')}
          className="p-2 rounded-xl text-slate-500 hover:text-slate-900 hover:bg-slate-100 transition-colors cursor-pointer"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <div>
          <div className="flex items-center gap-2 text-xs font-semibold text-emerald-700 uppercase tracking-wider">
            <ShieldCheck className="w-4 h-4" />
            <span>Consent Protocol Step 2 of 2</span>
          </div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">
            Dispatch Medical Access Request
          </h1>
        </div>
      </div>

      {!submittedRequest ? (
        /* Form Card */
        <div className="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
          <div className="p-6 border-b border-slate-100 bg-slate-50/50">
            <h3 className="text-sm font-bold text-slate-900">Patient Identification & Reason</h3>
            <p className="text-xs text-slate-500">
              The patient will receive this request on their mobile phone with a strict 5-minute approval window.
            </p>
          </div>

          <form onSubmit={handleSubmit} className="p-6 md:p-8 space-y-6">
            {/* Locked Patient Identity Banner */}
            <div className="p-4 rounded-xl bg-slate-50 border border-slate-200 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-emerald-100 text-emerald-800 font-bold flex items-center justify-center">
                  <User className="w-5 h-5" />
                </div>
                <div>
                  <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider block">
                    Verified Patient (Non-Editable)
                  </span>
                  <p className="text-sm font-bold text-slate-900">
                    {patient.first_name} {patient.last_name}
                  </p>
                  <p className="text-xs text-slate-500">{patient.email} • {patient.phone}</p>
                </div>
              </div>

              <button
                type="button"
                onClick={() => navigateTo('clinic-lookup')}
                className="text-xs font-medium text-emerald-700 hover:text-emerald-800 underline cursor-pointer"
              >
                Change Patient
              </button>
            </div>

            {/* Submitting Doctor Field */}
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700 flex items-center gap-1.5">
                <Stethoscope className="w-4 h-4 text-emerald-600" />
                <span>Submitting Physician <span className="text-rose-500">*</span></span>
              </label>
              <select
                id="select-submitting-doctor"
                value={submittingDoctorId}
                onChange={(e) => setSubmittingDoctorId(e.target.value)}
                className="w-full px-3.5 py-2.5 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500"
              >
                {activeDoctors.map((doc) => (
                  <option key={doc.id} value={doc.id}>
                    Dr. {doc.first_name} {doc.last_name} ({doc.specialization})
                  </option>
                ))}
              </select>
              <p className="text-[11px] text-slate-400">
                The requesting doctor is recorded for institutional audit logs.
              </p>
            </div>

            {/* Reason for Access Field */}
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">
                Clinical Reason for Request <span className="text-rose-500">*</span>
              </label>
              <textarea
                id="input-access-reason"
                required
                rows={3}
                value={reason}
                onChange={(e) => setReason(e.target.value)}
                placeholder="Explain the specific clinical purpose for accessing the patient&apos;s full history..."
                className="w-full px-3.5 py-2.5 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500"
              />
              <p className="text-[11px] text-slate-400">
                This reason is displayed directly on the patient&apos;s mobile device consent prompt.
              </p>
            </div>

            {/* 5-minute rule notice */}
            <div className="p-3.5 bg-amber-50 rounded-xl border border-amber-200 text-xs text-amber-900 flex items-start gap-2.5">
              <Clock className="w-4 h-4 text-amber-600 shrink-0 mt-0.5" />
              <div>
                <p className="font-semibold">5-Minute Auto-Expiry Rule</p>
                <p className="text-amber-800/90 text-[11px] mt-0.5">
                  Under Section 5.2, access requests automatically expire in 5 minutes if not answered by the patient, reverting to denied status.
                </p>
              </div>
            </div>

            {/* Actions */}
            <div className="flex items-center justify-end gap-3 pt-4 border-t border-slate-100">
              <button
                type="button"
                onClick={() => navigateTo('clinic-lookup')}
                className="px-4 py-2 text-xs font-medium text-slate-600 hover:bg-slate-100 rounded-xl transition-colors cursor-pointer"
              >
                Cancel
              </button>
              <button
                id="submit-access-request-btn"
                type="submit"
                className="inline-flex items-center gap-2 px-5 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs rounded-xl shadow-xs transition-all cursor-pointer"
              >
                <Send className="w-4 h-4" />
                <span>Dispatch Request to Patient</span>
              </button>
            </div>
          </form>
        </div>
      ) : (
        /* Live 5-minute Countdown & Simulation Screen */
        <div
          id="access-request-active-screen"
          className="bg-white rounded-2xl border border-emerald-200/80 shadow-md p-6 md:p-8 space-y-6 text-center animate-in zoom-in-95 duration-200"
        >
          <div className="w-14 h-14 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center mx-auto shadow-inner">
            <Clock className="w-8 h-8 animate-pulse" />
          </div>

          <div className="space-y-1">
            <h3 className="text-xl font-bold text-slate-900">Access Request Dispatched!</h3>
            <p className="text-xs text-slate-500 max-w-md mx-auto">
              Waiting for patient <strong>{patient.first_name} {patient.last_name}</strong> to approve on their mobile app.
            </p>
          </div>

          {/* Live countdown badge */}
          <div className="inline-block">
            <CountdownBadge expiresAt={submittedRequest.expires_at} type="access_request" className="text-sm px-4 py-2" />
          </div>

          {/* Quick Simulation Options */}
          <div className="p-4 bg-slate-50 rounded-2xl border border-slate-200 text-xs space-y-3 text-left max-w-lg mx-auto">
            <div className="flex items-center gap-2">
              <span className="text-[10px] font-bold uppercase tracking-wider bg-slate-200 text-slate-800 px-2 py-0.5 rounded">
                Interactive Testing Sandbox
              </span>
            </div>
            <p className="text-slate-600 text-[11px]">
              Simulate patient mobile response now, or view ongoing tracking in Access Requests:
            </p>

            <div className="flex flex-wrap items-center gap-2 pt-1">
              <button
                id="sim-patient-approve-btn"
                type="button"
                onClick={() => {
                  approveAccessRequest(submittedRequest.id);
                  navigateTo('clinic-requests');
                }}
                className="flex items-center gap-1.5 px-3.5 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-lg text-xs shadow-xs cursor-pointer"
              >
                <CheckCircle2 className="w-3.5 h-3.5" />
                <span>Simulate Patient Approving</span>
              </button>

              <button
                id="sim-patient-deny-btn"
                type="button"
                onClick={() => {
                  denyAccessRequest(submittedRequest.id);
                  navigateTo('clinic-requests');
                }}
                className="flex items-center gap-1.5 px-3 py-1.5 bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-200 font-semibold rounded-lg text-xs cursor-pointer"
              >
                <XCircle className="w-3.5 h-3.5" />
                <span>Simulate Deny</span>
              </button>
            </div>
          </div>

          <div className="pt-2">
            <button
              id="view-sent-requests-btn"
              type="button"
              onClick={() => navigateTo('clinic-requests')}
              className="text-xs font-semibold text-emerald-700 hover:text-emerald-800 underline cursor-pointer"
            >
              Go to Sent Access Requests Log →
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
