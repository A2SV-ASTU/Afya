'use client';

import React from 'react';
import Link from 'next/link';
import { KeyRound, PlusCircle, Clock, ShieldCheck, CheckCircle2, XCircle } from 'lucide-react';
import { useStore } from '@/lib/store';
import { Button } from '@/modules/core/ui/Button';
import { StatusBadge } from '@/modules/core/ui/StatusBadge';
import { CountdownBadge } from '@/modules/core/ui/CountdownBadge';
import { formatDateTime } from '@/modules/core/lib/utils';

export default function ClinicRequestsPage() {
  const { accessRequests, activeClinic, approveAccessRequest, denyAccessRequest } = useStore();

  const clinicRequests = accessRequests.filter((r) => r.clinic_id === activeClinic.id);

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold text-slate-900">Patient Access Consent Requests</h1>
          <p className="text-xs text-slate-500">
            Time-bounded authorization requests sent to citizens for explicit chart access
          </p>
        </div>

        <Link href="/clinic/requests/new">
          <Button size="sm" leftIcon={<PlusCircle className="w-4 h-4" />}>
            + Request Patient Access
          </Button>
        </Link>
      </div>

      <div className="bg-white rounded-3xl border border-slate-200 shadow-xs overflow-hidden">
        <div className="p-6 border-b border-slate-100 flex items-center justify-between">
          <h2 className="text-base font-bold text-slate-900">All Consent Requests ({clinicRequests.length})</h2>
          <span className="text-xs text-slate-400">Strict 5-minute expiry windows</span>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs border-collapse">
            <thead>
              <tr className="border-b border-slate-100 bg-slate-50/75 text-slate-500 font-semibold uppercase tracking-wider text-[11px]">
                <th className="py-3 px-6">Patient</th>
                <th className="py-3 px-6">Requesting Physician</th>
                <th className="py-3 px-6">Clinical Reason</th>
                <th className="py-3 px-6">Time Window</th>
                <th className="py-3 px-6">Status</th>
                <th className="py-3 px-6 text-right">Simulator Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 font-medium text-slate-700">
              {clinicRequests.map((req) => (
                <tr key={req.id} className="hover:bg-slate-50/60 transition-colors">
                  <td className="py-4 px-6">
                    <p className="font-bold text-slate-900">{req.patient_name}</p>
                    <p className="text-[11px] font-mono text-slate-400">{req.patient_id}</p>
                  </td>
                  <td className="py-4 px-6 text-slate-800">{req.submitted_by_doctor_name}</td>
                  <td className="py-4 px-6 text-slate-600 max-w-xs">{req.reason}</td>
                  <td className="py-4 px-6">
                    {req.status === 'pending' ? (
                      <CountdownBadge expiresAt={req.expires_at} />
                    ) : (
                      <span className="text-[11px] text-slate-400 font-mono">
                        {formatDateTime(req.created_at)}
                      </span>
                    )}
                  </td>
                  <td className="py-4 px-6">
                    <StatusBadge status={req.status} />
                  </td>
                  <td className="py-4 px-6 text-right">
                    {req.status === 'pending' && (
                      <div className="flex items-center justify-end gap-1.5">
                        <button
                          type="button"
                          onClick={() => approveAccessRequest(req.id)}
                          className="px-2.5 py-1 text-xs font-semibold text-[#1B5E20] bg-[#E8F5E9] hover:bg-[#C8E6C9] rounded-lg transition-colors border border-[#A5D6A7] cursor-pointer"
                          title="Simulate Patient App Approve"
                        >
                          Approve (Sim)
                        </button>
                        <button
                          type="button"
                          onClick={() => denyAccessRequest(req.id)}
                          className="px-2.5 py-1 text-xs font-semibold text-rose-700 bg-rose-50 hover:bg-rose-100 rounded-lg transition-colors border border-rose-200 cursor-pointer"
                          title="Simulate Patient App Deny"
                        >
                          Deny
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
