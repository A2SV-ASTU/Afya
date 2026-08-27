'use client';

import React from 'react';
import Link from 'next/link';
import { ShieldCheck, ArrowRight, UserCheck, Stethoscope } from 'lucide-react';
import { useStore } from '@/lib/store';
import { CountdownBadge } from '@/modules/core/ui/CountdownBadge';
import { Button } from '@/modules/core/ui/Button';

export default function ClinicActiveAccessPage() {
  const { accessRequests, activeClinic, revokeAccessRequest } = useStore();
  const activeGrants = accessRequests.filter(
    (r) => r.clinic_id === activeClinic.id && r.status === 'approved'
  );

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold text-slate-900">Active Patient Consent Grants</h1>
          <p className="text-xs text-slate-500">
            Citizens who have granted your clinic 5-minute authorized access to longitudinal clinical records
          </p>
        </div>
      </div>

      {activeGrants.length === 0 ? (
        <div className="bg-white rounded-3xl border border-slate-200 p-12 text-center space-y-3">
          <div className="w-12 h-12 rounded-2xl bg-slate-50 border border-slate-100 flex items-center justify-center text-slate-400 mx-auto">
            <ShieldCheck className="w-6 h-6" />
          </div>
          <h3 className="text-sm font-bold text-slate-900">No Active Patient Consent Grants</h3>
          <p className="text-xs text-slate-500 max-w-sm mx-auto">
            When a patient approves an access request in their AfyaMind mobile app, their unlocked chart will appear here for 5 minutes.
          </p>
          <Link href="/clinic/requests/new">
            <Button size="sm" className="mt-2">
              Request Patient Access
            </Button>
          </Link>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {activeGrants.map((grant) => (
            <div
              key={grant.id}
              className="bg-white rounded-3xl border border-[#A5D6A7] shadow-xs p-6 space-y-4 hover:shadow-sm transition-all"
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-[#E8F5E9] text-[#2E7D32] border border-[#C8E6C9] flex items-center justify-center font-bold">
                    <UserCheck className="w-5 h-5" />
                  </div>
                  <div>
                    <h3 className="text-sm font-bold text-slate-900">{grant.patient_name}</h3>
                    <p className="text-[11px] font-mono text-slate-400">{grant.patient_id}</p>
                  </div>
                </div>

                <CountdownBadge expiresAt={grant.expires_at} />
              </div>

              <div className="p-3 bg-slate-50 rounded-2xl border border-slate-100 text-xs text-slate-600">
                <span className="font-semibold text-slate-700">Access Scope: </span>
                <span>Complete Longitudinal Record & Encounter Recording</span>
              </div>

              <div className="flex items-center justify-between pt-2 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => revokeAccessRequest(grant.id)}
                  className="text-xs font-semibold text-rose-600 hover:text-rose-800 cursor-pointer"
                >
                  Revoke Early
                </button>

                <Link href={`/doctor/patients/${grant.patient_id}`}>
                  <Button size="sm" leftIcon={<Stethoscope className="w-3.5 h-3.5" />}>
                    Open Patient Chart
                  </Button>
                </Link>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
