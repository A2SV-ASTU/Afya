'use client';

import React, { useState } from 'react';
import { useStore } from '@/lib/store';
import { Building2, ArrowLeft, ShieldCheck, CheckCircle } from 'lucide-react';
import { getErrorMessage } from '@/lib/api/errors';

export function CreateClinic() {
  const { createClinic, navigateTo } = useStore();

  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '+254 ',
    address: '',
    admin_first_name: '',
    admin_last_name: '',
  });

  const [errors, setErrors] = useState<Record<string, string>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [apiError, setApiError] = useState<string | null>(null);

  const validate = () => {
    const errs: Record<string, string> = {};
    if (!formData.name.trim()) errs.name = 'Clinic legal name is required';
    if (!formData.email.trim() || !formData.email.includes('@')) errs.email = 'Valid official clinic email is required';
    if (!formData.phone.trim() || formData.phone.length < 9) errs.phone = 'Valid phone number is required';
    if (!formData.address.trim()) errs.address = 'Physical address and facility suite is required';
    if (!formData.admin_first_name.trim()) errs.admin_first_name = 'Administrator first name is required';
    if (!formData.admin_last_name.trim()) errs.admin_last_name = 'Administrator last name is required';
    setErrors(errs);
    return Object.keys(errs).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validate()) return;

    setIsSubmitting(true);
    setApiError(null);

    try {
      const newClinic = await createClinic({
        name: formData.name,
        email: formData.email,
        phone: formData.phone,
        address: formData.address,
        admin_first_name: formData.admin_first_name,
        admin_last_name: formData.admin_last_name,
      });
      navigateTo('admin-clinic-detail', { clinicId: newClinic.id });
    } catch (err: unknown) {
      let errorMessage = 'Failed to create clinic. Please try again.';
      
      if (err && typeof err === 'object' && 'code' in err) {
        const errorCode = (err as { code: string }).code;
        if (errorCode === 'conflict') {
          errorMessage = 'A clinic with this email already exists';
        } else if (errorCode === 'validation_error') {
          errorMessage = 'Please check the form for errors';
        } else {
          errorMessage = getErrorMessage(errorCode);
        }
      } else if (err instanceof Error) {
        errorMessage = err.message;
      }

      setApiError(errorMessage);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div id="create-clinic-page" className="p-6 md:p-8 max-w-4xl mx-auto space-y-6">
      {/* Navigation Header */}
      <div className="flex items-center gap-3">
        <button
          id="back-to-dashboard-btn"
          type="button"
          onClick={() => navigateTo('admin-dashboard')}
          className="p-2 rounded-xl text-slate-500 hover:text-slate-900 hover:bg-slate-100 transition-colors cursor-pointer"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <div>
          <div className="flex items-center gap-2 text-xs font-semibold text-emerald-700 uppercase tracking-wider">
            <ShieldCheck className="w-4 h-4" />
            <span>SuperAdmin Provisioning</span>
          </div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">
            Onboard New Healthcare Facility
          </h1>
        </div>
      </div>

      {/* Main Creation Form Card */}
      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
        <div className="p-6 border-b border-slate-100 bg-slate-50/50 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="p-2.5 rounded-xl bg-emerald-100 text-emerald-800 border border-emerald-200">
              <Building2 className="w-5 h-5" />
            </div>
            <div>
              <h3 className="text-sm font-bold text-slate-900">Facility Onboarding Specification</h3>
              <p className="text-xs text-slate-500">
                Creates the clinic record and provisions its dedicated Clinic Administrator credential.
              </p>
            </div>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="p-6 md:p-8 space-y-6">
          {apiError && (
            <div className="p-4 bg-rose-50 border border-rose-200 rounded-xl">
              <p className="text-xs text-rose-700 font-medium">{apiError}</p>
            </div>
          )}

          {/* Section 1: Facility Information */}
          <div className="space-y-4">
            <h4 className="text-xs font-bold uppercase tracking-wider text-slate-400">
              1. Facility Information
            </h4>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="md:col-span-2 space-y-1.5">
                <label className="text-xs font-semibold text-slate-700">
                  Clinic / Facility Official Name <span className="text-rose-500">*</span>
                </label>
                <input
                  id="input-clinic-name"
                  type="text"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  placeholder="e.g. Westlands Premier Medical Center"
                  className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500"
                />
                {errors.name && <p className="text-[11px] text-rose-500">{errors.name}</p>}
              </div>

              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-slate-700">
                  Official Clinic Email <span className="text-rose-500">*</span>
                </label>
                <input
                  id="input-clinic-email"
                  type="email"
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  placeholder="contact@westlandsmed.co.ke"
                  className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500"
                />
                {errors.email && <p className="text-[11px] text-rose-500">{errors.email}</p>}
              </div>

              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-slate-700">
                  Phone / Support Line <span className="text-rose-500">*</span>
                </label>
                <input
                  id="input-clinic-phone"
                  type="text"
                  value={formData.phone}
                  onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                  placeholder="+254 711 000 111"
                  className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500"
                />
                {errors.phone && <p className="text-[11px] text-rose-500">{errors.phone}</p>}
              </div>

              <div className="md:col-span-2 space-y-1.5">
                <label className="text-xs font-semibold text-slate-700">
                  Physical Address & Suite <span className="text-rose-500">*</span>
                </label>
                <input
                  id="input-clinic-address"
                  type="text"
                  value={formData.address}
                  onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                  placeholder="e.g. Parklands Road, Next to Aga Khan Hospital, Suite 3B"
                  className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500"
                />
                {errors.address && <p className="text-[11px] text-rose-500">{errors.address}</p>}
              </div>
            </div>
          </div>

          <div className="h-px bg-slate-100" />

          {/* Section 2: Facility Administrator Credentials */}
          <div className="space-y-4">
            <h4 className="text-xs font-bold uppercase tracking-wider text-slate-400">
              2. Facility Administrator Information
            </h4>
            <p className="text-xs text-slate-600">
              The clinic administrator will receive their login credentials by email.
            </p>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-slate-700">
                  Administrator First Name <span className="text-rose-500">*</span>
                </label>
                <input
                  id="input-admin-first-name"
                  type="text"
                  value={formData.admin_first_name}
                  onChange={(e) => setFormData({ ...formData, admin_first_name: e.target.value })}
                  placeholder="e.g. Faith"
                  className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500"
                />
                {errors.admin_first_name && <p className="text-[11px] text-rose-500">{errors.admin_first_name}</p>}
              </div>

              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-slate-700">
                  Administrator Last Name <span className="text-rose-500">*</span>
                </label>
                <input
                  id="input-admin-last-name"
                  type="text"
                  value={formData.admin_last_name}
                  onChange={(e) => setFormData({ ...formData, admin_last_name: e.target.value })}
                  placeholder="e.g. Mwenda"
                  className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500"
                />
                {errors.admin_last_name && <p className="text-[11px] text-rose-500">{errors.admin_last_name}</p>}
              </div>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="flex items-center justify-end gap-3 pt-6 border-t border-slate-100">
            <button
              id="cancel-create-clinic-btn"
              type="button"
              onClick={() => navigateTo('admin-dashboard')}
              className="px-4 py-2 text-xs font-medium text-slate-700 bg-slate-100 hover:bg-slate-200 rounded-xl transition-colors cursor-pointer"
            >
              Cancel
            </button>
            <button
              id="save-create-clinic-btn"
              type="submit"
              disabled={isSubmitting}
              className="inline-flex items-center gap-2 px-5 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-semibold shadow-xs transition-colors cursor-pointer disabled:opacity-50"
            >
              <CheckCircle className="w-4 h-4" />
              <span>{isSubmitting ? 'Onboarding...' : 'Complete Onboarding & Activate'}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
