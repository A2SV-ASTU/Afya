'use client';

import React from 'react';
import { Pill, CheckCircle2 } from 'lucide-react';
import { useStore } from '@/lib/store';
import { StatusBadge } from '@/modules/core/ui/StatusBadge';
import { formatDateTime } from '@/modules/core/lib/utils';

interface MedicationListProps {
  patientId: string;
}

export function MedicationList({ patientId }: MedicationListProps) {
  const { encounters } = useStore();

  const allItems = encounters
    .filter((e) => e.patient_id === patientId)
    .flatMap((e) =>
      (e.prescriptions || []).flatMap((rx) =>
        (rx.items || []).map((item) => ({
          ...item,
          prescribedAt: rx.prescribed_at,
          clinicName: e.clinic_name,
          doctorName: e.opened_by_doctor_name,
        }))
      )
    );

  if (allItems.length === 0) {
    return (
      <div className="p-8 text-center bg-white rounded-3xl border border-slate-200 text-xs text-slate-500">
        No active or historical medications recorded for this patient.
      </div>
    );
  }

  return (
    <div className="bg-white rounded-3xl border border-slate-200 shadow-xs overflow-hidden">
      <div className="p-6 border-b border-slate-100 flex items-center justify-between">
        <h3 className="text-base font-bold text-slate-900 flex items-center gap-2">
          <Pill className="w-5 h-5 text-[#2E7D32]" />
          Longitudinal E-Prescriptions & Active Medication History ({allItems.length})
        </h3>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full text-left text-xs border-collapse">
          <thead>
            <tr className="border-b border-slate-100 bg-slate-50/75 text-slate-500 font-semibold uppercase tracking-wider text-[11px]">
              <th className="py-3 px-6">Medication & Strength</th>
              <th className="py-3 px-6">Regimen & Route</th>
              <th className="py-3 px-6">Duration & Instructions</th>
              <th className="py-3 px-6">Status</th>
              <th className="py-3 px-6">Prescribing Facility</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 font-medium text-slate-700">
            {allItems.map((item) => (
              <tr key={item.id} className="hover:bg-slate-50/60 transition-colors">
                <td className="py-4 px-6">
                  <p className="font-bold text-slate-900">{item.medication_name}</p>
                  <span className="text-[11px] font-mono px-2 py-0.5 bg-slate-100 text-slate-700 rounded-md font-semibold">
                    {item.dose}
                  </span>
                </td>
                <td className="py-4 px-6">
                  <p className="font-semibold text-slate-800">{item.frequency}</p>
                  <p className="text-[11px] text-slate-400">Route: {item.route}</p>
                </td>
                <td className="py-4 px-6">
                  <p className="text-slate-700">{item.duration}</p>
                  {item.instructions && (
                    <p className="text-[11px] text-slate-400">{item.instructions}</p>
                  )}
                </td>
                <td className="py-4 px-6">
                  <StatusBadge status={item.status || 'active'} />
                </td>
                <td className="py-4 px-6">
                  <p className="font-semibold text-slate-800">{item.clinicName}</p>
                  <p className="text-[11px] text-slate-400">By {item.doctorName}</p>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
