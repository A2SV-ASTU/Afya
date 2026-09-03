'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { Mail, ArrowRight, Stethoscope, Copy, CheckCircle2 } from 'lucide-react';
import { useStore } from '@/lib/store';
import { StatusBadge } from '@/modules/core/ui/StatusBadge';
import { Button } from '@/modules/core/ui/Button';
import { InviteTokenGenerator } from './InviteTokenGenerator';

export function DoctorRoster() {
  const { doctors, doctorsLoading, doctorsError, invitations, activeClinic, resendInvite } = useStore();
  const [showInviteModal, setShowInviteModal] = useState(false);
  const [copiedToken, setCopiedToken] = useState<string | null>(null);

  // Doctors are already scoped to activeClinic by the store's fetch logic
  const clinicDoctors = doctors;
  const clinicInvitations = invitations.filter((i) => i.clinic_id === activeClinic.id);

  const handleCopyLink = (token: string) => {
    const url = `${window.location.origin}/accept-invite?token=${token}`;
    navigator.clipboard.writeText(url);
    setCopiedToken(token);
    setTimeout(() => setCopiedToken(null), 3000);
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold text-slate-900">Physicians & Clinical Staff</h1>
          <p className="text-xs text-slate-500">Manage licensed doctors and onboarding invitations for {activeClinic.name}</p>
        </div>

        <Button
          id="btn-open-invite-modal"
          onClick={() => setShowInviteModal(true)}
          leftIcon={<Mail className="w-4 h-4" />}
        >
          + Invite Licensed Doctor
        </Button>
      </div>

      {/* Active Staff Roster */}
      <div className="bg-white rounded-3xl border border-slate-200 shadow-xs overflow-hidden">
        <div className="p-6 border-b border-slate-100 flex items-center justify-between">
          <h2 className="text-base font-bold text-slate-900">Credentialed Physicians ({clinicDoctors.length})</h2>
          <span className="text-xs text-[#2E7D32] font-semibold bg-[#E8F5E9] px-2.5 py-0.5 rounded-full border border-[#C8E6C9]">
            Active KMPDC Licenses
          </span>
        </div>

        {doctorsLoading ? (
          <div className="py-12 text-center text-slate-500">
            <div className="inline-block h-8 w-8 animate-spin rounded-full border-b-2 border-[#2E7D32] mb-3" />
            <p className="text-sm font-medium">Loading physicians...</p>
          </div>
        ) : doctorsError ? (
          <div className="py-12 px-6 text-center">
            <p className="text-sm font-semibold text-slate-900">Failed to load physicians</p>
            <p className="mt-1 text-xs text-slate-500">{doctorsError}</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs border-collapse">
              <thead>
                <tr className="border-b border-slate-100 bg-slate-50/75 text-slate-500 font-semibold uppercase tracking-wider text-[11px]">
                  <th className="py-3 px-6">Physician Name</th>
                  <th className="py-3 px-6">Specialization</th>
                  <th className="py-3 px-6">KMPDC License</th>
                  <th className="py-3 px-6">Contact Email</th>
                  <th className="py-3 px-6">Status</th>
                  <th className="py-3 px-6 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 font-medium text-slate-700">
                {clinicDoctors.length === 0 ? (
                  <tr>
                    <td colSpan={6} className="py-12 text-center text-slate-500">
                      <Stethoscope className="mx-auto mb-2 h-8 w-8 text-slate-300" />
                      <p className="text-sm font-medium">No physicians found for this clinic.</p>
                    </td>
                  </tr>
                ) : (
                  clinicDoctors.map((doc) => (
                    <tr key={doc.id} className="hover:bg-slate-50/60 transition-colors">
                      <td className="py-4 px-6">
                        <div className="flex items-center gap-3">
                          <div className="w-9 h-9 rounded-xl bg-[#E8F5E9] text-[#2E7D32] flex items-center justify-center font-bold text-xs shrink-0 border border-[#C8E6C9]">
                            <Stethoscope className="w-4 h-4" />
                          </div>
                          <div>
                            <p className="font-bold text-slate-900">
                              Dr. {doc.first_name} {doc.last_name}
                            </p>
                            <p className="text-[11px] text-slate-400">{doc.phone || '+254 700 000000'}</p>
                          </div>
                        </div>
                      </td>
                      <td className="py-4 px-6 font-medium text-slate-800">{doc.specialization || 'General Practice'}</td>
                      <td className="py-4 px-6 font-mono text-slate-600">{doc.license_number || 'KMPDC-REG'}</td>
                      <td className="py-4 px-6 text-slate-500">{doc.email}</td>
                      <td className="py-4 px-6">
                        <StatusBadge status={doc.doctor_status || 'active'} />
                      </td>
                      <td className="py-4 px-6 text-right">
                        <Link
                          href={`/clinic/doctors/${doc.id}`}
                          className="inline-flex items-center gap-1 font-semibold text-[#2E7D32] hover:text-[#1B5E20] text-xs"
                        >
                          Manage Doctor <ArrowRight className="w-3.5 h-3.5" />
                        </Link>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Invitations Table */}
      {clinicInvitations.length > 0 && (
        <div className="bg-white rounded-3xl border border-slate-200 shadow-xs overflow-hidden">
          <div className="p-6 border-b border-slate-100 flex items-center justify-between">
            <h2 className="text-base font-bold text-slate-900">Pending & Issued Invitations ({clinicInvitations.length})</h2>
            <span className="text-xs text-slate-500 font-medium">24-hour cryptographic invite links</span>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs border-collapse">
              <thead>
                <tr className="border-b border-slate-100 bg-slate-50/75 text-slate-500 font-semibold uppercase tracking-wider text-[11px]">
                  <th className="py-3 px-6">Invited Email</th>
                  <th className="py-3 px-6">Specialization</th>
                  <th className="py-3 px-6">Token</th>
                  <th className="py-3 px-6">Status</th>
                  <th className="py-3 px-6 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 font-medium text-slate-700">
                {clinicInvitations.map((inv) => (
                  <tr key={inv.id} className="hover:bg-slate-50/60 transition-colors">
                    <td className="py-4 px-6 font-semibold text-slate-900">{inv.email}</td>
                    <td className="py-4 px-6 text-slate-600">{inv.specialization || 'General'}</td>
                    <td className="py-4 px-6 font-mono text-slate-500">{inv.token}</td>
                    <td className="py-4 px-6">
                      <StatusBadge status={inv.status} />
                    </td>
                    <td className="py-4 px-6 text-right">
                      {inv.status === 'pending' && (
                        <div className="flex items-center justify-end gap-2">
                          <button
                            type="button"
                            onClick={() => handleCopyLink(inv.token)}
                            className="px-2.5 py-1 text-xs font-semibold text-[#2E7D32] bg-[#E8F5E9] hover:bg-[#C8E6C9] rounded-lg transition-colors inline-flex items-center gap-1 cursor-pointer border border-[#C8E6C9]"
                          >
                            {copiedToken === inv.token ? (
                              <>
                                <CheckCircle2 className="w-3 h-3 text-[#2E7D32]" />
                                Copied
                              </>
                            ) : (
                              <>
                                <Copy className="w-3 h-3" />
                                Copy Invite Link
                              </>
                            )}
                          </button>
                          <button
                            type="button"
                            onClick={() => resendInvite(inv.id)}
                            className="px-2.5 py-1 text-xs font-semibold text-slate-600 hover:bg-slate-100 rounded-lg transition-colors cursor-pointer"
                          >
                            Resend
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
      )}

      {showInviteModal && (
        <InviteTokenGenerator
          isOpen={showInviteModal}
          onClose={() => setShowInviteModal(false)}
        />
      )}
    </div>
  );
}
