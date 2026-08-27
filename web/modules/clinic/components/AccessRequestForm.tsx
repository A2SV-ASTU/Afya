'use client';

import React, { useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { KeyRound, ArrowLeft, Clock, ShieldCheck, AlertCircle } from 'lucide-react';
import { useStore } from '@/lib/store';
import { Button } from '@/modules/core/ui/Button';
import { Input } from '@/modules/core/ui/Input';

export function AccessRequestForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const initialPatientId = searchParams.get('patientId') || '';

  const { patients, doctors, activeClinic, createAccessRequest } = useStore();

  const [patientId, setPatientId] = useState(initialPatientId || (patients[0]?.id ?? ''));
  const [doctorId, setDoctorId] = useState(doctors.find((d) => d.clinic_id === activeClinic.id)?.id || doctors[0]?.id || '');
  const [reason, setReason] = useState('Outpatient Consultation & Vitals Review');
  const [error, setError] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const clinicDoctors = doctors.filter((d) => d.clinic_id === activeClinic.id);
  const selectedPatient = patients.find((p) => p.id === patientId);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    if (!patientId || !doctorId || !reason) {
      setError('Please provide all mandatory request details.');
      return;
    }

    setIsSubmitting(true);
    try {
      createAccessRequest(patientId, reason, doctorId);
      router.push('/clinic/requests');
    } catch (err: any) {
      setError(err.message || 'Failed to submit access request.');
      setIsSubmitting(false);
    }
  };

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <div className="flex items-center gap-3">
        <button
          type="button"
          onClick={() => router.push('/clinic/requests')}
          className="p-2 rounded-xl text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition-colors"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <div>
          <h1 className="text-xl font-bold text-slate-900">Initiate Patient Consent Request</h1>
          <p className="text-xs text-slate-500">
            Dispatches an instant authorization prompt to the citizen&apos;s AfyaMind mobile app
          </p>
        </div>
      </div>

      <div className="bg-white rounded-3xl border border-slate-200 shadow-xs p-6 sm:p-8">
        <form onSubmit={handleSubmit} className="space-y-5">
          {error && (
            <div className="p-3.5 rounded-2xl bg-rose-50 border border-rose-200 text-xs text-rose-700 flex items-center gap-2 font-medium">
              <AlertCircle className="w-4 h-4 shrink-0" />
              {error}
            </div>
          )}

          {/* Select Patient */}
          <div className="space-y-1.5">
            <label className="block text-xs font-semibold text-slate-700">Select Target Patient</label>
            <select
              id="request-select-patient"
              value={patientId}
              onChange={(e) => setPatientId(e.target.value)}
              className="w-full px-3.5 py-2.5 text-xs bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C] text-slate-800"
            >
              {patients.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.first_name} {p.last_name} ({p.id} - {p.phone})
                </option>
              ))}
            </select>
          </div>

          {selectedPatient && (
            <div className="p-3.5 rounded-2xl bg-slate-50 border border-slate-100 text-xs flex items-center justify-between">
              <div>
                <p className="font-bold text-slate-900">
                  {selectedPatient.first_name} {selectedPatient.last_name}
                </p>
                <p className="text-[11px] text-slate-500">{selectedPatient.email} • {selectedPatient.phone}</p>
              </div>
              <span className="text-[10px] font-semibold px-2 py-0.5 bg-slate-200 text-slate-700 rounded-md">
                Blood Group: {selectedPatient.blood_group}
              </span>
            </div>
          )}

          {/* Select Requesting Physician */}
          <div className="space-y-1.5">
            <label className="block text-xs font-semibold text-slate-700">Attending Physician</label>
            <select
              id="request-select-doctor"
              value={doctorId}
              onChange={(e) => setDoctorId(e.target.value)}
              className="w-full px-3.5 py-2.5 text-xs bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C] text-slate-800"
            >
              {clinicDoctors.map((doc) => (
                <option key={doc.id} value={doc.id}>
                  Dr. {doc.first_name} {doc.last_name} ({doc.specialization || 'General'})
                </option>
              ))}
            </select>
          </div>

          {/* Clinical Reason */}
          <div className="space-y-1.5">
            <label className="block text-xs font-semibold text-slate-700">Clinical Purpose / Reason</label>
            <textarea
              id="request-reason-text"
              rows={3}
              value={reason}
              onChange={(e) => setReason(e.target.value)}
              placeholder="e.g. Acute hypertension check and review of previous lab biochemistry..."
              className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C] text-slate-800"
              required
            />
          </div>

          {/* 5-minute Bounded Privacy Notice */}
          <div className="p-4 rounded-2xl bg-[#E8F5E9]/60 border border-[#C8E6C9] text-xs text-[#1B5E20] space-y-1">
            <div className="flex items-center gap-1.5 font-bold">
              <Clock className="w-4 h-4 text-[#2E7D32]" />
              <span>Strict 5-Minute Time-Bounded Privacy Policy</span>
            </div>
            <p className="text-[11px] text-[#2E7D32]">
              Upon patient approval in the AfyaMind mobile citizen app, the grant unlocks the chart for exactly 5 minutes. All reads and encounter writes are cryptographically audit-logged.
            </p>
          </div>

          <div className="pt-4 flex items-center justify-end gap-3">
            <Button
              type="button"
              variant="outline"
              onClick={() => router.push('/clinic/requests')}
            >
              Cancel
            </Button>
            <Button
              type="submit"
              isLoading={isSubmitting}
              leftIcon={<KeyRound className="w-4 h-4" />}
            >
              Dispatch Consent Request
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
