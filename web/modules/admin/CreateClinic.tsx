'use client';

import React, { useState } from 'react';
import { useStore } from '@/lib/store';
import { Building2, ArrowLeft, ShieldCheck, CheckCircle, Lock } from 'lucide-react';

export function CreateClinic() {
  const { createClinic, navigateTo } = useStore();

  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '+254 ',
    address: '',
    admin_name: '',
    admin_password: '',
  });

  const [errors, setErrors] = useState<Record<string, string>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  const validate = () => {
    const errs: Record<string, string> = {};
    if (!formData.name.trim()) errs.name = 'Clinic legal name is required';
    if (!formData.email.trim() || !formData.email.includes('@')) errs.email = 'Valid official clinic email is required';
    if (!formData.phone.trim() || formData.phone.length < 9) errs.phone = 'Valid phone number is required';
    if (!formData.address.trim()) errs.address = 'Physical address and facility suite is required';
    if (!formData.admin_name.trim()) errs.admin_name = 'Administrator full name is required';
    if (!formData.admin_password.trim() || formData.admin_password.length < 6) {
      errs.admin_password = 'Password must be at least 6 characters';
    }
    setErrors(errs);
    return Object.keys(errs).length === 0;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!validate()) return;

    setIsSubmitting(true);
    setTimeout(() => {
      const newClinic = createClinic({
        name: formData.name,
        email: formData.email,
        phone: formData.phone,
        address: formData.address,
        admin_name: formData.admin_name,
        admin_password: formData.admin_password,
      });
      setIsSubmitting(false);
      navigateTo('admin-clinic-detail', { clinicId: newClinic.id });
    }, 400);
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

          {/* Section 2: Clinic Admin Account Credentials */}
          <div className="space-y-4">
            <h4 className="text-xs font-bold uppercase tracking-wider text-slate-400">
              2. Facility Administrator Credentials
            </h4>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-slate-700">
                  Administrator Full Name <span className="text-rose-500">*</span>
                </label>
                <input
                  id="input-admin-name"
                  type="text"
                  value={formData.admin_name}
                  onChange={(e) => setFormData({ ...formData, admin_name: e.target.value })}
                  placeholder="e.g. Faith Mwenda"
                  className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500"
                />
                {errors.admin_name && <p className="text-[11px] text-rose-500">{errors.admin_name}</p>}
              </div>

              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-slate-700">
                  Initial Admin Password <span className="text-rose-500">*</span>
                </label>
                <div className="relative">
                  <Lock className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                  <input
                    id="input-admin-password"
                    type="password"
                    value={formData.admin_password}
                    onChange={(e) => setFormData({ ...formData, admin_password: e.target.value })}
                    placeholder="••••••••••••"
                    className="w-full pl-9 pr-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500"
                  />
                </div>
                {errors.admin_password && <p className="text-[11px] text-rose-500">{errors.admin_password}</p>}
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
