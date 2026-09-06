'use client';

import React, { useState } from 'react';
import { useStore } from '@/lib/store';
import { useSearchParams } from 'next/navigation';
import {
  Stethoscope,
  CheckCircle2,
  AlertCircle,
  Lock,
  Award,
  ArrowRight,
  Phone as PhoneIcon,
} from 'lucide-react';

export function AcceptInvite() {
  const searchParams = useSearchParams();
  const token = searchParams.get('token') || '';
  
  const { acceptInvite, navigateTo } = useStore();

  const [formData, setFormData] = useState({
    first_name: '',
    last_name: '',
    phone: '+254 7',
    password: '',
    confirmPassword: '',
    specialization: 'General Practice',
    license_number: '',
  });

  const [submitError, setSubmitError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!formData.first_name || !formData.last_name || !formData.phone || !formData.password || !formData.license_number || !formData.specialization) {
      setSubmitError('Please fill all required profile credentials.');
      return;
    }

    if (formData.password !== formData.confirmPassword) {
      setSubmitError('Passwords do not match.');
      return;
    }

    if (!token) {
      setSubmitError('Invalid invitation link - no token found.');
      return;
    }

    setIsSubmitting(true);
    setSubmitError(null);

    const result = await acceptInvite(token, {
      first_name: formData.first_name,
      last_name: formData.last_name,
      phone: formData.phone,
      password: formData.password,
      license_number: formData.license_number,
      specialization: formData.specialization,
    });

    if (!result.success) {
      const errorMsg = result.error || 'Failed to accept invitation';
      if (errorMsg.toLowerCase().includes('expired')) {
        setSubmitError('This invitation has expired. Please request a new invitation from your clinic administrator.');
      } else if (errorMsg.toLowerCase().includes('already') || errorMsg.toLowerCase().includes('used')) {
        setSubmitError('This invitation has already been used. If you already have an account, please log in.');
      } else {
        setSubmitError(errorMsg);
      }
      setIsSubmitting(false);
    } else {
      setSuccess(true);
      setTimeout(() => {
        navigateTo('login');
      }, 2500);
    }
  };

  if (!token) {
    return (
      <div id="accept-invite-page" className="min-h-[85vh] flex items-center justify-center p-4 md:p-8">
        <div className="w-full max-w-xl bg-white rounded-3xl border border-slate-200/80 shadow-xl p-8 text-center space-y-4">
          <div className="w-12 h-12 rounded-2xl bg-rose-50 text-rose-600 flex items-center justify-center mx-auto border border-rose-200">
            <AlertCircle className="w-6 h-6" />
          </div>
          <h2 className="text-lg font-bold text-slate-900">Invalid Invitation Link</h2>
          <p className="text-xs text-slate-500">
            This invitation link is invalid. Please check your email for the correct link or request a new invitation.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div id="accept-invite-page" className="min-h-[85vh] flex items-center justify-center p-4 md:p-8">
      <div className="w-full max-w-xl bg-white rounded-3xl border border-slate-200/80 shadow-xl overflow-hidden animate-in fade-in zoom-in-95 duration-200">
        {/* Top Visual Banner */}
        <div className="p-6 md:p-8 bg-gradient-to-br from-slate-900 via-slate-800 to-emerald-950 text-white space-y-2">
          <span className="px-2.5 py-0.5 rounded-full text-[11px] font-bold tracking-wider uppercase bg-emerald-500/20 text-emerald-300 border border-emerald-500/30">
            Physician Onboarding & Credentialing
          </span>
          <h1 className="text-2xl font-bold tracking-tight text-white">
            Accept Clinic Invitation
          </h1>
          <p className="text-xs text-slate-300">
            Complete your profile to activate your physician account
          </p>
        </div>

        {/* State Banners */}
        {submitError && (
          <div className="m-6 p-4 rounded-2xl bg-rose-50 border border-rose-200 text-rose-800 text-xs flex items-start gap-3">
            <AlertCircle className="w-5 h-5 text-rose-600 shrink-0 mt-0.5" />
            <div>
              <p className="font-bold">Error</p>
              <p className="text-[11px] text-rose-700 mt-0.5">{submitError}</p>
            </div>
          </div>
        )}

        {success && (
          <div className="m-6 p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-900 text-xs flex items-start gap-3">
            <CheckCircle2 className="w-5 h-5 text-emerald-600 shrink-0 mt-0.5" />
            <div>
              <p className="font-bold">Account Created Successfully!</p>
              <p className="text-[11px] text-emerald-800 mt-0.5">
                You can now log in with your credentials. Redirecting to login page...
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
                disabled={success || isSubmitting}
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
                disabled={success || isSubmitting}
                value={formData.last_name}
                onChange={(e) => setFormData({ ...formData, last_name: e.target.value })}
                placeholder="e.g. Mwangi"
                className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 disabled:bg-slate-50"
              />
            </div>
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-slate-700 flex items-center gap-1.5">
              <PhoneIcon className="w-3.5 h-3.5 text-slate-400" />
              <span>Phone Number <span className="text-rose-500">*</span></span>
            </label>
            <input
              id="doc-setup-phone"
              type="tel"
              required
              disabled={success || isSubmitting}
              value={formData.phone}
              onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
              placeholder="+254 7XX XXX XXX"
              className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 disabled:bg-slate-50"
            />
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700 flex items-center gap-1.5">
                <Award className="w-3.5 h-3.5 text-emerald-600" />
                <span>KMPDC License Number <span className="text-rose-500">*</span></span>
              </label>
              <input
                id="doc-setup-license"
                type="text"
                required
                disabled={success || isSubmitting}
                value={formData.license_number}
                onChange={(e) => setFormData({ ...formData, license_number: e.target.value })}
                placeholder="e.g. KMPDC-56421"
                className="w-full px-3.5 py-2 text-xs font-mono bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 disabled:bg-slate-50"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700 flex items-center gap-1.5">
                <Stethoscope className="w-3.5 h-3.5 text-slate-400" />
                <span>Specialization <span className="text-rose-500">*</span></span>
              </label>
              <input
                id="doc-setup-specialization"
                type="text"
                required
                disabled={success || isSubmitting}
                value={formData.specialization}
                onChange={(e) => setFormData({ ...formData, specialization: e.target.value })}
                placeholder="e.g. Cardiology"
                className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 disabled:bg-slate-50"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700 flex items-center gap-1.5">
                <Lock className="w-3.5 h-3.5 text-slate-400" />
                <span>Create Password <span className="text-rose-500">*</span></span>
              </label>
              <input
                id="doc-setup-password"
                type="password"
                required
                disabled={success || isSubmitting}
                value={formData.password}
                onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                placeholder="Min. 8 characters"
                className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 disabled:bg-slate-50"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">
                Confirm Password <span className="text-rose-500">*</span>
              </label>
              <input
                id="doc-setup-confirm-password"
                type="password"
                required
                disabled={success || isSubmitting}
                value={formData.confirmPassword}
                onChange={(e) => setFormData({ ...formData, confirmPassword: e.target.value })}
                placeholder="Re-enter password"
                className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 disabled:bg-slate-50"
              />
            </div>
          </div>

          <div className="pt-2">
            <button
              id="submit-doctor-setup-btn"
              type="submit"
              disabled={success || isSubmitting}
              className="w-full py-3 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl text-xs shadow-md transition-all flex items-center justify-center gap-2 cursor-pointer disabled:opacity-40 disabled:cursor-not-allowed"
            >
              <span>{isSubmitting ? 'Creating Account...' : 'Activate Physician Account'}</span>
              <ArrowRight className="w-4 h-4" />
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
