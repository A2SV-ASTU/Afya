'use client';

import React from 'react';
import { Calendar, Clock, CheckCircle2, User, Building2, ArrowRight } from 'lucide-react';
import { useStore } from '@/lib/store';
import { StatusBadge } from '@/modules/core/ui/StatusBadge';
import { formatDateTime } from '@/modules/core/lib/utils';

export default function DoctorAppointmentsPage() {
  const { appointments, updateAppointmentStatus, activeClinic } = useStore();

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold text-slate-900">Follow-up Consultations & Review Schedule</h1>
          <p className="text-xs text-slate-500">
            Chronological appointment diary for patient reviews, vitals rechecks, and medication evaluations
          </p>
        </div>
      </div>

      <div className="bg-white rounded-3xl border border-slate-200 shadow-xs overflow-hidden">
        <div className="p-6 border-b border-slate-100 flex items-center justify-between">
          <h2 className="text-base font-bold text-slate-900">Scheduled Reviews ({appointments.length})</h2>
          <span className="text-xs text-[#2E7D32] font-semibold bg-[#E8F5E9] px-2.5 py-0.5 rounded-full border border-[#C8E6C9]">
            {appointments.filter((a) => a.status === 'scheduled').length} Upcoming
          </span>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs border-collapse">
            <thead>
              <tr className="border-b border-slate-100 bg-slate-50/75 text-slate-500 font-semibold uppercase tracking-wider text-[11px]">
                <th className="py-3 px-6">Patient</th>
                <th className="py-3 px-6">Scheduled Date & Time</th>
                <th className="py-3 px-6">Clinical Review Purpose</th>
                <th className="py-3 px-6">Attending Physician</th>
                <th className="py-3 px-6">Status</th>
                <th className="py-3 px-6 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 font-medium text-slate-700">
              {appointments.map((appt) => (
                <tr key={appt.id} className="hover:bg-slate-50/60 transition-colors">
                  <td className="py-4 px-6 font-bold text-slate-900">
                    <p>{appt.patient_name}</p>
                    <p className="text-[11px] font-mono text-slate-400">{appt.patient_id}</p>
                  </td>
                  <td className="py-4 px-6 font-mono text-slate-800">
                    {formatDateTime(appt.scheduled_at)}
                  </td>
                  <td className="py-4 px-6 text-slate-600 max-w-xs">{appt.notes || 'Routine Follow-up'}</td>
                  <td className="py-4 px-6 text-slate-800">{appt.doctor_name}</td>
                  <td className="py-4 px-6">
                    <StatusBadge status={appt.status} />
                  </td>
                  <td className="py-4 px-6 text-right">
                    {appt.status === 'scheduled' && (
                      <div className="flex items-center justify-end gap-2">
                        <button
                          type="button"
                          onClick={() => updateAppointmentStatus(appt.id, 'attended')}
                          className="px-2.5 py-1 text-xs font-semibold text-[#1B5E20] bg-[#E8F5E9] hover:bg-[#C8E6C9] rounded-lg transition-colors border border-[#C8E6C9] cursor-pointer"
                        >
                          Mark Attended
                        </button>
                        <button
                          type="button"
                          onClick={() => updateAppointmentStatus(appt.id, 'missed')}
                          className="px-2.5 py-1 text-xs font-semibold text-slate-600 hover:bg-slate-100 rounded-lg transition-colors cursor-pointer"
                        >
                          Missed
                        </button>
                      </div>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
