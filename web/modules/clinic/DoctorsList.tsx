'use client';

import React, { useState } from 'react';
import { useStore } from '@/lib/store';
import { StatusBadge } from '@/components/ui/Badge';
import { CountdownBadge } from '@/components/ui/CountdownBadge';
import { Modal } from '@/components/ui/Modal';
import {
  Stethoscope,
  UserPlus,
  Search,
  ChevronRight,
  Copy,
  Check,
  RotateCw,
  Mail,
  Award,
  Calendar,
  AlertCircle,
} from 'lucide-react';

export function DoctorsList() {
  const {
    currentUser,
    clinics,
    doctors,
    doctorsLoading,
    doctorsError,
    invitations,
    inviteDoctor,
    activateDoctor,
    deactivateDoctor,
    refetchDoctors,
    resendInvite,
    viewParams,
    navigateTo,
    activeClinic,
  } = useStore();

  // Doctors are now already fetched scoped to the active clinic
  const clinicDoctors = doctors;
  const clinicInvitations = invitations.filter((inv) => inv.clinic_id === activeClinic.id);

  const [searchTerm, setSearchTerm] = useState('');
  const [isInviteModalOpen, setIsInviteModalOpen] = useState(
    Boolean(viewParams?.openInvite)
  );
  const [inviteEmail, setInviteEmail] = useState('');
  const [inviteSpecialization, setInviteSpecialization] = useState('General Practice & Family Medicine');
  const [generatedInvite, setGeneratedInvite] = useState<{
    token: string;
    expires_at: string;
  } | null>(null);
  const [copiedToken, setCopiedToken] = useState(false);

  const filteredDoctors = clinicDoctors.filter(
    (d) =>
      `${d.first_name} ${d.last_name}`.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (d.specialization && d.specialization.toLowerCase().includes(searchTerm.toLowerCase())) ||
      (d.license_number && d.license_number.toLowerCase().includes(searchTerm.toLowerCase()))
  );

  const handleInviteSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!inviteEmail.trim()) return;

    try {
      await inviteDoctor(activeClinic.id, inviteEmail);
      // Backend only returns { message }, not the full invitation
      // For now, just close the modal with a success message
      setGeneratedInvite({
        token: 'invitation_sent',
        expires_at: new Date(Date.now() + 24 * 3600 * 1000).toISOString(),
      });
      setInviteEmail('');
    } catch (err) {
      console.error('Failed to send invitation:', err);
    }
  };

  const copyToClipboard = (token: string) => {
    const link = `${window.location.origin}/doctor/accept-invite?token=${token}`;
    navigator.clipboard.writeText(link);
    setCopiedToken(true);
    setTimeout(() => setCopiedToken(false), 2000);
  };

  return (
    <div id="doctors-list-page" className="p-6 md:p-8 space-y-8 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 text-xs font-semibold text-emerald-700 uppercase tracking-wider mb-1">
            <Stethoscope className="w-4 h-4" />
            <span>Clinical Governance</span>
          </div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">
            Facility Doctors & Clinicians
          </h1>
          <p className="text-xs text-slate-500 mt-1">
            Manage attending physicians, issue invites, and administer practice privileges.
          </p>
        </div>

        <div className="flex items-center gap-2">
          <button
            type="button"
            onClick={() => refetchDoctors()}
            className="inline-flex items-center gap-2 px-4 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-semibold shadow-xs transition-colors cursor-pointer"
            title="Refresh doctors list"
          >
            <RotateCw className="w-4 h-4" />
            <span>Refresh</span>
          </button>
          <button
            id="open-invite-doctor-modal-btn"
            type="button"
            onClick={() => {
              setGeneratedInvite(null);
              setIsInviteModalOpen(true);
            }}
            className="inline-flex items-center gap-2 px-4 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-semibold shadow-xs transition-colors cursor-pointer"
          >
            <UserPlus className="w-4 h-4" />
            <span>+ Invite Physician</span>
          </button>
        </div>
      </div>

      {/* Active Doctors Table */}
      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
        <div className="p-5 border-b border-slate-100 flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-slate-50/40">
          <div>
            <h3 className="text-sm font-bold text-slate-900">Physicians on Active Roster</h3>
            <p className="text-xs text-slate-500">
              Doctors licensed under {activeClinic.name} with charting permissions.
            </p>
          </div>

          <div className="relative min-w-[260px]">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              id="search-doctors-input"
              type="text"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              placeholder="Search by physician name, license, or department..."
              className="w-full pl-9 pr-3 py-1.5 bg-white border border-slate-200 rounded-xl text-xs text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500"
            />
          </div>
        </div>

        {doctorsLoading ? (
          <div className="text-center py-12 text-slate-500">
            <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-600 mb-3"></div>
            <p className="text-sm font-medium">Loading doctors...</p>
          </div>
        ) : doctorsError ? (
          <div className="p-6 text-center">
            <div className="inline-flex items-center justify-center w-12 h-12 rounded-full bg-rose-50 text-rose-600 mb-3">
              <AlertCircle className="w-6 h-6" />
            </div>
            <p className="text-sm font-semibold text-slate-900 mb-1">Failed to load doctors</p>
            <p className="text-xs text-slate-500">{doctorsError}</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs text-slate-600">
              <thead className="bg-slate-50 border-b border-slate-200/80 text-[11px] font-semibold text-slate-500 uppercase tracking-wider">
                <tr>
                  <th className="py-3.5 px-5">Physician Name & Specialization</th>
                  <th className="py-3.5 px-5">License & Email</th>
                  <th className="py-3.5 px-5">Status</th>
                  <th className="py-3.5 px-5">Joined Date</th>
                  <th className="py-3.5 px-5 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {filteredDoctors.length === 0 ? (
                  <tr>
                    <td colSpan={5} className="text-center py-10 text-slate-400">
                      <Stethoscope className="w-8 h-8 mx-auto mb-2 text-slate-300" />
                      <p className="font-medium text-slate-600">No doctors match search query</p>
                    </td>
                  </tr>
                ) : (
                  filteredDoctors.map((doc) => (
                    <tr
                      key={doc.id}
                      id={`doctor-row-${doc.id}`}
                      onClick={() => navigateTo('clinic-doctor-detail', { doctorId: doc.id })}
                      className="hover:bg-slate-50/80 cursor-pointer transition-colors group"
                    >
                      <td className="py-4 px-5">
                        <div className="flex items-center gap-3">
                          <div className="w-8 h-8 rounded-full bg-emerald-100 text-emerald-800 font-bold flex items-center justify-center shrink-0">
                            {doc.first_name[0]}
                          </div>
                          <div>
                            <p className="font-bold text-slate-900 group-hover:text-emerald-700 transition-colors">
                              Dr. {doc.first_name} {doc.last_name}
                            </p>
                            <p className="text-[11px] text-slate-500">{doc.specialization}</p>
                          </div>
                        </div>
                      </td>
                      <td className="py-4 px-5">
                        <p className="font-mono text-slate-800 font-medium">{doc.license_number || 'KMPDC-PENDING'}</p>
                        <p className="text-[11px] text-slate-400">{doc.email}</p>
                      </td>
                      <td className="py-4 px-5">
                        <StatusBadge variant={doc.doctor_status || 'active'}>{doc.doctor_status}</StatusBadge>
                      </td>
                      <td className="py-4 px-5 font-mono text-[11px] text-slate-500">
                        {new Date(doc.created_at).toLocaleDateString('en-GB', {
                          day: 'numeric',
                          month: 'short',
                          year: 'numeric',
                        })}
                      </td>
                      <td className="py-4 px-5 text-right">
                        <div className="flex items-center justify-end gap-3">
                          <button
                            type="button"
                            onClick={(e) => {
                              e.stopPropagation();
                              if (doc.doctor_status === 'active') {
                                deactivateDoctor(activeClinic.id, doc.id);
                              } else {
                                activateDoctor(activeClinic.id, doc.id);
                              }
                            }}
                            className={`px-3 py-1.5 rounded-lg text-[11px] font-semibold transition-colors cursor-pointer ${
                              doc.doctor_status === 'active'
                                ? 'bg-rose-50 text-rose-600 hover:bg-rose-100'
                                : 'bg-emerald-50 text-emerald-600 hover:bg-emerald-100'
                            }`}
                          >
                            {doc.doctor_status === 'active' ? 'Deactivate' : 'Activate'}
                          </button>
                          <span className="inline-flex items-center gap-1 text-xs font-semibold text-emerald-700 group-hover:text-emerald-800 transition-colors">
                            View Details
                            <ChevronRight className="w-4 h-4" />
                          </span>
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Pending Invitations Section (Page 4) */}
      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
        <div className="p-5 border-b border-slate-100 bg-slate-50/50 flex items-center justify-between">
          <div>
            <h3 className="text-sm font-bold text-slate-900">Pending Doctor Invitations</h3>
            <p className="text-xs text-slate-500">
              Invitations are hard-capped to 24 hours per Section 5.1 of AfyaMind PRD.
            </p>
          </div>
          <span className="px-2.5 py-0.5 rounded-full text-xs font-bold bg-amber-50 text-amber-700 border border-amber-200">
            {clinicInvitations.filter((i) => i.status === 'pending').length} Pending
          </span>
        </div>

        <div className="divide-y divide-slate-100">
          {clinicInvitations.length === 0 ? (
            <p className="text-center text-xs text-slate-400 py-8">No pending doctor invitations.</p>
          ) : (
            clinicInvitations.map((inv) => (
              <div key={inv.id} className="p-4 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                <div className="space-y-1">
                  <div className="flex items-center gap-2">
                    <span className="font-semibold text-slate-900 text-xs">{inv.email}</span>
                    <span className="text-[11px] text-slate-500">({inv.specialization})</span>
                    <StatusBadge variant={inv.status}>{inv.status}</StatusBadge>
                  </div>
                  <p className="text-[11px] font-mono text-slate-400">
                    Token: <span className="text-slate-600 font-bold">{inv.token}</span>
                  </p>
                </div>

                <div className="flex items-center gap-3">
                  <CountdownBadge expiresAt={inv.expires_at} type="invite" />

                  {inv.status === 'pending' && (
                    <>
                      <button
                        type="button"
                        onClick={() => copyToClipboard(inv.token)}
                        className="px-2.5 py-1 text-xs font-medium text-slate-700 bg-slate-100 hover:bg-slate-200 rounded-lg flex items-center gap-1 transition-colors cursor-pointer"
                        title="Copy Shareable Invite Link"
                      >
                        <Copy className="w-3.5 h-3.5" />
                        <span>Copy Link</span>
                      </button>
                      <button
                        type="button"
                        onClick={() => resendInvite(inv.id)}
                        className="px-2.5 py-1 text-xs font-medium text-emerald-700 bg-emerald-50 hover:bg-emerald-100 rounded-lg flex items-center gap-1 transition-colors cursor-pointer"
                        title="Reset 24h timer and re-issue"
                      >
                        <RotateCw className="w-3.5 h-3.5" />
                        <span>Resend</span>
                      </button>
                    </>
                  )}

                  {inv.status === 'expired' && (
                    <button
                      type="button"
                      onClick={() => resendInvite(inv.id)}
                      className="px-2.5 py-1 text-xs font-medium text-emerald-700 bg-emerald-50 hover:bg-emerald-100 rounded-lg flex items-center gap-1 transition-colors cursor-pointer"
                    >
                      <RotateCw className="w-3.5 h-3.5" />
                      <span>Re-issue Invite</span>
                    </button>
                  )}
                </div>
              </div>
            ))
          )}
        </div>
      </div>

      {/* Invite Doctor Modal (Page 4 Form) */}
      <Modal
        isOpen={isInviteModalOpen}
        onClose={() => setIsInviteModalOpen(false)}
        title="Invite Physician to Clinic"
        subtitle="Generates a 24-hour secure onboarding registration token"
        maxWidth="md"
      >
        {!generatedInvite ? (
          <form onSubmit={handleInviteSubmit} className="space-y-4">
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">
                Official Professional Email <span className="text-rose-500">*</span>
              </label>
              <div className="relative">
                <Mail className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                <input
                  id="invite-doctor-email-input"
                  type="email"
                  required
                  value={inviteEmail}
                  onChange={(e) => setInviteEmail(e.target.value)}
                  placeholder="e.g. dr.wanjiru@gmail.com"
                  className="w-full pl-9 pr-3 py-2 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500"
                />
              </div>
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">
                Specialization / Department
              </label>
              <input
                id="invite-doctor-spec-input"
                type="text"
                value={inviteSpecialization}
                onChange={(e) => setInviteSpecialization(e.target.value)}
                placeholder="e.g. Obstetrics & Gynecology, Pediatrics, Cardiology"
                className="w-full px-3 py-2 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500"
              />
            </div>

            <div className="p-3 rounded-xl bg-slate-50 border border-slate-200 text-[11px] text-slate-600 space-y-1">
              <p className="font-semibold text-slate-700 flex items-center gap-1.5">
                <AlertCircle className="w-3.5 h-3.5 text-emerald-600" />
                24-Hour Expiration Rule
              </p>
              <p>
                Per Section 4, doctors never self-register. Accounts are strictly provisioned upon accepting a facility invitation before its 24h expiry.
              </p>
            </div>

            <div className="flex items-center justify-end gap-2 pt-3 border-t border-slate-100">
              <button
                type="button"
                onClick={() => setIsInviteModalOpen(false)}
                className="px-4 py-2 text-xs font-medium text-slate-600 hover:bg-slate-100 rounded-xl transition-colors cursor-pointer"
              >
                Cancel
              </button>
              <button
                id="submit-invite-btn"
                type="submit"
                className="px-4 py-2 text-xs font-bold text-white bg-emerald-600 hover:bg-emerald-700 rounded-xl shadow-xs transition-colors cursor-pointer"
              >
                Generate Invite Token
              </button>
            </div>
          </form>
        ) : (
          <div className="space-y-4 text-center">
            <div className="w-12 h-12 rounded-full bg-emerald-100 text-emerald-700 flex items-center justify-center mx-auto">
              <Check className="w-6 h-6" />
            </div>
            <div>
              <h4 className="text-base font-bold text-slate-900">Invitation Sent!</h4>
              <p className="text-xs text-slate-500 mt-2">
                Invitation sent to <span className="font-semibold text-slate-700">{inviteEmail}</span>.
              </p>
              <p className="text-xs text-slate-500 mt-1">
                They&apos;ll receive an email with instructions to complete their registration within 24 hours.
              </p>
            </div>

            <div className="flex items-center justify-center pt-2">
              <button
                type="button"
                onClick={() => {
                  setGeneratedInvite(null);
                  setIsInviteModalOpen(false);
                }}
                className="px-4 py-2 text-xs font-bold text-white bg-emerald-600 hover:bg-emerald-700 rounded-xl transition-colors cursor-pointer"
              >
                Close
              </button>
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
}
