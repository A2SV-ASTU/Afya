'use client';

import React, { useState, useEffect } from 'react';
import { useStore } from '@/lib/store';
import { CountdownBadge } from '@/components/ui/CountdownBadge';
import {
  Stethoscope,
  KeyRound,
  ShieldCheck,
  CheckCircle2,
  AlertCircle,
  Building2,
  Lock,
  Award,
  ArrowRight,
} from 'lucide-react';

export function AcceptInvite() {
  const { invitations, acceptInvite, viewParams, navigateTo } = useStore();

  const tokenParam = viewParams?.token || invitations[0]?.token || '';
  const matchedInvite = invitations.find((inv) => inv.token === tokenParam) || invitations[0];

  const [formData, setFormData] = useState({
    first_name: '',
    last_name: '',
    password: '',
    specialization: matchedInvite?.specialization || 'Internal Medicine & Cardiology',
    license_number: 'KMPDC-56421',
  });

  const [submitError, setSubmitError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  // Compute invite validity derived without synchronous effect calls
  let inviteValidityError: string | null = null;
  if (!matchedInvite) {
    inviteValidityError = 'Invalid or non-existent invitation token.';
  } else if (
    matchedInvite.status === 'expired' ||
    new Date(matchedInvite.expires_at).getTime() < new Date().getTime()
  ) {
    inviteValidityError = 'This invite has expired — ask your clinic to send a new one.';
  } else if (matchedInvite.status === 'accepted') {
    inviteValidityError = 'This invite token has already been accepted.';
  }

  const errorMessage = submitError || inviteValidityError;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.first_name || !formData.last_name || !formData.password) {
      setSubmitError('Please fill all required profile credentials.');
      return;
    }

    if (inviteValidityError) {
      return;
    }

    const result = acceptInvite(matchedInvite.token, formData);
    if (!result.success) {
      setSubmitError(result.error || 'Failed to accept invitation.');
    } else {
      setSuccess(true);
      setTimeout(() => {
        navigateTo('doctor-dashboard');
      }, 1500);
    }
  };

  return (
    <div id="accept-invite-page" className="min-h-[85vh] flex items-center justify-center p-4 md:p-8">
      <div className="w-full max-w-xl bg-white rounded-3xl border border-slate-200/80 shadow-xl overflow-hidden animate-in fade-in zoom-in-95 duration-200">
        {/* Top Visual Banner */}
        <div className="p-6 md:p-8 bg-gradient-to-br from-slate-900 via-slate-800 to-emerald-950 text-white space-y-2">
          <div className="flex items-center justify-between">
            <span className="px-2.5 py-0.5 rounded-full text-[11px] font-bold tracking-wider uppercase bg-emerald-500/20 text-emerald-300 border border-emerald-500/30">
              Physician Onboarding & Credentialing
            </span>
            {matchedInvite && (
              <CountdownBadge expiresAt={matchedInvite.expires_at} type="invite" className="bg-slate-800 text-emerald-300 border-slate-700" />
            )}
          </div>
          <h1 className="text-2xl font-bold tracking-tight text-white">
            Accept Clinic Invitation
          </h1>
          <p className="text-xs text-slate-300">
            Invited by <strong className="text-emerald-300">{matchedInvite?.clinic_name || 'Afya Horizon Health Center'}</strong> as an attending clinician.
          </p>
        </div>

        {/* State Banners */}
        {errorMessage && (
          <div className="m-6 p-4 rounded-2xl bg-rose-50 border border-rose-200 text-rose-800 text-xs flex items-start gap-3">
            <AlertCircle className="w-5 h-5 text-rose-600 shrink-0 mt-0.5" />
            <div>
              <p className="font-bold">Invalid or Expired Invitation</p>
              <p className="text-[11px] text-rose-700 mt-0.5">{errorMessage}</p>
            </div>
          </div>
        )}

        {success && (
          <div className="m-6 p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-900 text-xs flex items-start gap-3">
            <CheckCircle2 className="w-5 h-5 text-emerald-600 shrink-0 mt-0.5" />
            <div>
              <p className="font-bold">Physician Profile Provisioned!</p>
              <p className="text-[11px] text-emerald-800 mt-0.5">
                Your medical license and electronic signature have been registered. Redirecting to Doctor Dashboard...
              </p>
            </div>
          </div>
        )}

        {/* Onboarding Form */}
        <form onSubmit={handleSubmit} className="p-6 md:p-8 space-y-5">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">
                First Name <span className="text-rose-500">*</span>
              </label>
              <input
                id="doc-setup-first-name"
                type="text"
                required
                disabled={Boolean(errorMessage) || success}
                value={formData.first_name}
                onChange={(e) => setFormData({ ...formData, first_name: e.target.value })}
                placeholder="e.g. Angela"
                className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 disabled:bg-slate-50"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">
                Last Name <span className="text-rose-500">*</span>
              </label>
              <input
                id="doc-setup-last-name"
                type="text"
                required
                disabled={Boolean(errorMessage) || success}
                value={formData.last_name}
                onChange={(e) => setFormData({ ...formData, last_name: e.target.value })}
                placeholder="e.g. Mwangi"
                className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 disabled:bg-slate-50"
              />
            </div>
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-slate-700">
              Registered Professional Email (Read-Only)
            </label>
            <input
              type="email"
              disabled
              value={matchedInvite?.email || 'dr.angela@afyahorizon.co.ke'}
              className="w-full px-3.5 py-2 text-xs bg-slate-50 border border-slate-200 rounded-xl text-slate-500 cursor-not-allowed"
            />
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700 flex items-center gap-1.5">
                <Award className="w-3.5 h-3.5 text-emerald-600" />
                <span>KMPDC License Number</span>
              </label>
              <input
                id="doc-setup-license"
                type="text"
                disabled={Boolean(errorMessage) || success}
                value={formData.license_number}
                onChange={(e) => setFormData({ ...formData, license_number: e.target.value })}
                placeholder="e.g. KMPDC-56421"
                className="w-full px-3.5 py-2 text-xs font-mono bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 disabled:bg-slate-50"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700 flex items-center gap-1.5">
                <Stethoscope className="w-3.5 h-3.5 text-slate-400" />
                <span>Specialization / Dept</span>
              </label>
              <input
                id="doc-setup-specialization"
                type="text"
                disabled={Boolean(errorMessage) || success}
                value={formData.specialization}
                onChange={(e) => setFormData({ ...formData, specialization: e.target.value })}
                placeholder="Internal Medicine & Cardiology"
                className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 disabled:bg-slate-50"
              />
            </div>
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-slate-700 flex items-center gap-1.5">
              <Lock className="w-3.5 h-3.5 text-slate-400" />
              <span>Set Secure Clinical Password <span className="text-rose-500">*</span></span>
            </label>
            <input
              id="doc-setup-password"
              type="password"
              required
              disabled={Boolean(errorMessage) || success}
              value={formData.password}
              onChange={(e) => setFormData({ ...formData, password: e.target.value })}
              placeholder="••••••••••••"
              className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 disabled:bg-slate-50"
            />
          </div>

          <div className="pt-2">
            <button
              id="submit-doctor-setup-btn"
              type="submit"
              disabled={Boolean(errorMessage) || success}
              className="w-full py-3 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl text-xs shadow-md transition-all flex items-center justify-center gap-2 cursor-pointer disabled:opacity-40 disabled:cursor-not-allowed"
            >
              <span>Activate Physician Account & Enter Practice</span>
              <ArrowRight className="w-4 h-4" />
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
