'use client';

import React from 'react';
import { User, Phone, Mail, Droplets, Calendar, ShieldCheck, AlertTriangle } from 'lucide-react';
import { Patient } from '@/types/database';
import { calculateAge } from '@/modules/core/lib/utils';

interface PatientProfileCardProps {
  patient: Patient;
}

export function PatientProfileCard({ patient }: PatientProfileCardProps) {
  return (
    <div className="bg-white rounded-3xl border border-slate-200 shadow-xs p-6 space-y-4">
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div className="flex items-center gap-4">
          <div className="w-14 h-14 rounded-2xl bg-[#E8F5E9] text-[#2E7D32] border border-[#C8E6C9] flex items-center justify-center font-bold text-lg">
            {patient.first_name[0]}
            {patient.last_name[0]}
          </div>

          <div>
            <div className="flex items-center gap-2">
              <h2 className="text-lg font-bold text-slate-900">
                {patient.first_name} {patient.last_name}
              </h2>
              <span className="font-mono text-xs px-2 py-0.5 rounded-full bg-slate-100 text-slate-700 font-semibold">
                {patient.id}
              </span>
            </div>

            <p className="text-xs text-slate-500 mt-0.5">
              DOB: {patient.date_of_birth} ({calculateAge(patient.date_of_birth)}) • {patient.sex} • National ID: {patient.national_id || 'KEN-8839210'}
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <span className="inline-flex items-center gap-1 px-3 py-1 bg-rose-50 border border-rose-200 text-rose-700 text-xs font-semibold rounded-full">
            <Droplets className="w-3.5 h-3.5" /> Blood Group: {patient.blood_group}
          </span>
          <span className="inline-flex items-center gap-1 px-3 py-1 bg-[#E8F5E9] border border-[#C8E6C9] text-[#1B5E20] text-xs font-semibold rounded-full">
            <ShieldCheck className="w-3.5 h-3.5" /> Consent Active
          </span>
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 pt-3 border-t border-slate-100 text-xs">
        <div className="p-3 bg-slate-50 rounded-2xl border border-slate-100 space-y-0.5">
          <p className="text-[10px] text-slate-400 font-semibold uppercase">Contact Phone</p>
          <p className="font-semibold text-slate-800">{patient.phone}</p>
        </div>

        <div className="p-3 bg-slate-50 rounded-2xl border border-slate-100 space-y-0.5">
          <p className="text-[10px] text-slate-400 font-semibold uppercase">Email Address</p>
          <p className="font-semibold text-slate-800">{patient.email}</p>
        </div>

        <div className="p-3 bg-rose-50/50 rounded-2xl border border-rose-100 space-y-0.5">
          <p className="text-[10px] text-rose-500 font-semibold uppercase flex items-center gap-1">
            <AlertTriangle className="w-3 h-3" /> Critical Allergies
          </p>
          <p className="font-bold text-rose-700">
            {patient.allergies?.length ? patient.allergies.join(', ') : 'None Reported'}
          </p>
        </div>
      </div>
    </div>
  );
}
