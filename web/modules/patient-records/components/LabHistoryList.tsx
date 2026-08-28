'use client';

import React from 'react';
import { FlaskConical } from 'lucide-react';
import { useStore } from '@/lib/store';
import { StatusBadge } from '@/modules/core/ui/StatusBadge';
import { formatDateTime } from '@/modules/core/lib/utils';

interface LabHistoryListProps {
  patientId: string;
}

export function LabHistoryList({ patientId }: LabHistoryListProps) {
  const { encounters } = useStore();

  const patientLabs = encounters
    .filter((e) => e.patient_id === patientId)
    .flatMap((e) =>
      (e.labs || []).map((lab) => ({
        ...lab,
        encounterType: e.type,
        clinicName: e.clinic_name,
      }))
    );

  if (patientLabs.length === 0) {
    return (
      <div className="p-8 text-center bg-white rounded-3xl border border-slate-200 text-xs text-slate-500">
        No laboratory reports on file for this patient.
      </div>
    );
  }

  return (
    <div className="bg-white rounded-3xl border border-slate-200 shadow-xs overflow-hidden">
      <div className="p-6 border-b border-slate-100 flex items-center justify-between">
        <h3 className="text-base font-bold text-slate-900 flex items-center gap-2">
          <FlaskConical className="w-5 h-5 text-[#2E7D32]" />
          Diagnostic Laboratory Test Results ({patientLabs.length})
        </h3>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full text-left text-xs border-collapse">
          <thead>
            <tr className="border-b border-slate-100 bg-slate-50/75 text-slate-500 font-semibold uppercase tracking-wider text-[11px]">
              <th className="py-3 px-6">Investigation</th>
              <th className="py-3 px-6">Discipline</th>
              <th className="py-3 px-6">Interpretation Summary</th>
              <th className="py-3 px-6">Flag</th>
              <th className="py-3 px-6">Facility / Date</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 font-medium text-slate-700">
            {patientLabs.map((lab) => (
              <tr key={lab.id} className="hover:bg-slate-50/60 transition-colors">
                <td className="py-4 px-6 font-bold text-slate-900">{lab.test_name}</td>
                <td className="py-4 px-6 text-slate-500 capitalize">{lab.category}</td>
                <td className="py-4 px-6">
                  <p className="font-semibold text-slate-800">{lab.summary_notes}</p>
                  {lab.measurements && <p className="text-[11px] font-mono text-slate-500">{lab.measurements}</p>}
                </td>
                <td className="py-4 px-6">
                  <StatusBadge status={lab.flag} />
                </td>
                <td className="py-4 px-6">
                  <p className="font-semibold text-slate-800">{lab.clinicName}</p>
                  <p className="text-[11px] text-slate-400 font-mono">{formatDateTime(lab.created_at)}</p>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
