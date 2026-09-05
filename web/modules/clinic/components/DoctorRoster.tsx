'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { Users, Mail, ArrowRight, Stethoscope, Copy, CheckCircle2, RefreshCw, AlertCircle, PowerOff, Power } from 'lucide-react';
import { useAuth } from '@/modules/core/context/AuthContext';
import { clinicsApi } from '@/lib/api/clinics';
import { getApiErrorMessage } from '@/lib/api/client';
import { StatusBadge } from '@/modules/core/ui/StatusBadge';
import { Button } from '@/modules/core/ui/Button';
import { InviteTokenGenerator } from './InviteTokenGenerator';
import { DoctorResponse, DoctorInvitation } from '@/types/database';

export function DoctorRoster() {
  const { currentUser, isReady } = useAuth();
  const clinicId = currentUser?.clinic_id;

  const [liveDoctors, setLiveDoctors] = useState<DoctorResponse[]>([]);
  const [liveInvitations, setLiveInvitations] = useState<DoctorInvitation[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState('');
  const [showInviteModal, setShowInviteModal] = useState(false);

  const fetchRosterData = async () => {
    if (!clinicId) {
      setIsLoading(false);
      return;
    }
    setIsLoading(true);
    setErrorMessage('');

    try {
      // 1. Fetch live doctors: GET /api/v1/clinics/:id/doctors
      const docRes = await clinicsApi.listDoctors(clinicId);
      if (docRes && docRes.doctors) {
        setLiveDoctors(docRes.doctors);
      } else {
        setLiveDoctors([]);
      }

      // 2. Fetch live invitations: GET /api/v1/clinics/:id/invitations
      try {
        const invRes = await clinicsApi.listInvitations(clinicId);
        if (invRes && invRes.invitations) {
          setLiveInvitations(invRes.invitations);
        } else {
          setLiveInvitations([]);
        }
      } catch {
        setLiveInvitations([]);
      }
    } catch (err: unknown) {
      setErrorMessage(getApiErrorMessage(err, 'Failed to retrieve clinic doctor roster.'));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    if (clinicId) {
      fetchRosterData();
    } else if (isReady) {
      setIsLoading(false);
    }
  }, [clinicId, isReady]);

  const handleToggleDoctorStatus = async (doc: DoctorResponse) => {
    if (!clinicId) return;
    const isDocActive = doc.doctor_status === 'active';

    try {
      if (isDocActive) {
        // PATCH /api/v1/clinics/:id/doctors/:doctor_id/deactivate
        await clinicsApi.deactivateDoctor(clinicId, doc.id);
        setLiveDoctors((prev) =>
          prev.map((d) => (d.id === doc.id ? { ...d, doctor_status: 'deactivated' } : d))
        );
      } else {
        // PATCH /api/v1/clinics/:id/doctors/:doctor_id/activate
        await clinicsApi.activateDoctor(clinicId, doc.id);
        setLiveDoctors((prev) =>
          prev.map((d) => (d.id === doc.id ? { ...d, doctor_status: 'active' } : d))
        );
      }
    } catch (err: unknown) {
      setErrorMessage(getApiErrorMessage(err, `Failed to update status for Dr. ${doc.first_name} ${doc.last_name}`));
    }
  };

  const displayedDoctors = liveDoctors;
  const displayedInvitations = liveInvitations;



  return (
    <div className="space-y-6">
      {errorMessage && (
        <div className="p-4 rounded-2xl bg-rose-50 border border-rose-200 text-xs text-rose-700 font-medium flex items-start gap-2.5 animate-in fade-in">
          <AlertCircle className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
          <div className="flex-1">
            <p className="font-bold">Staffing Notice</p>
            <p className="text-rose-600 mt-0.5">{errorMessage}</p>
          </div>
        </div>
      )}

      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold text-slate-900">Physicians & Clinical Staff</h1>
          <p className="text-xs text-slate-500">Manage licensed doctors and onboarding invitations for your healthcare facility</p>
        </div>

        <div className="flex items-center gap-2.5">
          <Button
            variant="outline"
            size="sm"
            onClick={fetchRosterData}
            leftIcon={<RefreshCw className="w-3.5 h-3.5" />}
          >
            Refresh
          </Button>

          <Button
            id="btn-open-invite-modal"
            onClick={() => setShowInviteModal(true)}
            leftIcon={<Mail className="w-4 h-4" />}
          >
            + Invite Licensed Doctor
          </Button>
        </div>
      </div>

      {/* Active Staff Roster */}
      <div className="bg-white rounded-3xl border border-slate-200 shadow-xs overflow-hidden">
        <div className="p-6 border-b border-slate-100 flex items-center justify-between">
          <h2 className="text-base font-bold text-slate-900">Credentialed Physicians ({displayedDoctors.length})</h2>
          <span className="text-xs text-[#2E7D32] font-semibold bg-[#E8F5E9] px-2.5 py-0.5 rounded-full border border-[#C8E6C9]">
            Active KMPDC Licenses
          </span>
        </div>

        {isLoading ? (
          <div className="p-12 text-center text-xs text-slate-400">
            <div className="w-6 h-6 border-2 border-emerald-600 border-t-transparent rounded-full animate-spin mx-auto mb-2" />
            Loading credentialed doctor roster from registry...
          </div>
        ) : displayedDoctors.length === 0 ? (
          <div className="p-12 text-center text-xs text-slate-400">
            No doctors registered yet. Click &quot;+ Invite Licensed Doctor&quot; to send an onboarding magic link.
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
                {displayedDoctors.map((doc) => (
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
                      <div className="flex items-center justify-end gap-2">
                        <button
                          type="button"
                          onClick={() => handleToggleDoctorStatus(doc)}
                          className={`px-2.5 py-1 rounded-lg text-[11px] font-semibold border transition-colors cursor-pointer ${
                            doc.doctor_status === 'active'
                              ? 'bg-rose-50 text-rose-700 border-rose-200 hover:bg-rose-100'
                              : 'bg-emerald-50 text-emerald-700 border-emerald-200 hover:bg-emerald-100'
                          }`}
                        >
                          {doc.doctor_status === 'active' ? 'Deactivate' : 'Activate'}
                        </button>

                        <Link
                          href={`/clinic/doctors/${doc.id}`}
                          className="inline-flex items-center gap-1 font-semibold text-[#2E7D32] hover:text-[#1B5E20] text-xs pl-2"
                        >
                          View <ArrowRight className="w-3.5 h-3.5" />
                        </Link>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Invitations Table */}
      {displayedInvitations.length > 0 && (
        <div className="bg-white rounded-3xl border border-slate-200 shadow-xs overflow-hidden">
          <div className="p-6 border-b border-slate-100 flex items-center justify-between">
            <div>
              <h2 className="text-base font-bold text-slate-900">Pending & Issued Invitations ({displayedInvitations.length})</h2>
              <p className="text-xs text-slate-500 mt-0.5">Secure 24-hour cryptographic onboarding invitations sent to physicians</p>
            </div>
            <span className="text-xs text-slate-500 font-medium px-2.5 py-1 bg-slate-100 rounded-full">
              Automated Email Delivery
            </span>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs border-collapse">
              <thead>
                <tr className="border-b border-slate-100 bg-slate-50/75 text-slate-500 font-semibold uppercase tracking-wider text-[11px]">
                  <th className="py-3 px-6">Invited Physician Email</th>
                  <th className="py-3 px-6">Sent Date</th>
                  <th className="py-3 px-6">Validity / Expiry</th>
                  <th className="py-3 px-6">Onboarding Status</th>
                  <th className="py-3 px-6 text-right">Delivery Mode</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 font-medium text-slate-700">
                {displayedInvitations.map((inv) => {
                  const isExpired = new Date(inv.expires_at).getTime() < Date.now();
                  const effectiveStatus = inv.status === 'pending' && isExpired ? 'expired' : inv.status;

                  return (
                    <tr key={inv.id} className="hover:bg-slate-50/60 transition-colors">
                      <td className="py-4 px-6">
                        <div className="flex items-center gap-2.5">
                          <div className="w-7 h-7 rounded-lg bg-emerald-50 text-emerald-700 flex items-center justify-center border border-emerald-200 shrink-0">
                            <Mail className="w-3.5 h-3.5" />
                          </div>
                          <div>
                            <span className="font-semibold text-slate-900">{inv.email}</span>
                            <span className="text-[10px] text-slate-400 font-mono block">ID: {inv.id}</span>
                          </div>
                        </div>
                      </td>
                      <td className="py-4 px-6 text-slate-600 font-mono text-[11px]">
                        {inv.created_at ? new Date(inv.created_at).toLocaleString() : 'N/A'}
                      </td>
                      <td className="py-4 px-6 font-mono text-[11px]">
                        <span className={effectiveStatus === 'expired' ? 'text-rose-600 font-semibold' : 'text-slate-600'}>
                          {inv.expires_at ? new Date(inv.expires_at).toLocaleString() : '24 Hours'}
                        </span>
                      </td>
                      <td className="py-4 px-6">
                        <StatusBadge status={effectiveStatus} />
                      </td>
                      <td className="py-4 px-6 text-right">
                        <span className="inline-flex items-center gap-1 text-[11px] font-semibold text-emerald-700 bg-emerald-50 px-2.5 py-0.5 rounded-full border border-emerald-200">
                          <CheckCircle2 className="w-3 h-3 text-emerald-600" />
                          Email Dispatched
                        </span>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </div>
      )}


      {showInviteModal && (
        <InviteTokenGenerator
          isOpen={showInviteModal}
          onClose={() => {
            setShowInviteModal(false);
            fetchRosterData();
          }}
        />
      )}
    </div>
  );
}

