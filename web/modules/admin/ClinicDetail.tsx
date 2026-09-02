'use client';

import React, { useState } from 'react';
import { useStore } from '@/lib/store';
import { StatusBadge } from '@/components/ui/Badge';
import { ConfirmDialog } from '@/components/ui/Modal';
import {
  Building2,
  ArrowLeft,
  ShieldCheck,
  PowerOff,
  Power,
  Mail,
  Phone,
  MapPin,
  Calendar,
  UserCheck,
  ShieldAlert,
  Info,
} from 'lucide-react';

export function ClinicDetail() {
  const { clinics, viewParams, deactivateClinic, activateClinic, navigateTo } = useStore();
  const [isDeactivateModalOpen, setIsDeactivateModalOpen] = useState(false);

  const clinicId = viewParams.clinicId || clinics[0]?.id;
  const clinic = clinics.find((c) => c.id === clinicId) || clinics[0];

  if (!clinic) {
    return (
      <div className="p-8 text-center">
        <p className="text-sm text-slate-500">Clinic record not found.</p>
        <button
          onClick={() => navigateTo('admin-dashboard')}
          className="mt-4 px-4 py-2 bg-slate-900 text-white rounded-lg text-xs"
        >
          Return to Clinics
        </button>
      </div>
    );
  }

  const isActive = clinic.status === 'active';

  return (
    <div id="clinic-detail-page" className="p-6 md:p-8 max-w-4xl mx-auto space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <button
            id="back-to-clinics-btn"
            type="button"
            onClick={() => navigateTo('admin-dashboard')}
            className="p-2 rounded-xl text-slate-500 hover:text-slate-900 hover:bg-slate-100 transition-colors cursor-pointer"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <div className="flex items-center gap-2 text-xs font-semibold text-emerald-700 uppercase tracking-wider">
              <ShieldCheck className="w-4 h-4" />
              <span>Facility Record #{clinic.id.replace('cln_', '')}</span>
            </div>
            <h1 className="text-2xl font-bold tracking-tight text-slate-900">{clinic.name}</h1>
          </div>
        </div>

        {/* Deactivate / Reactivate Action */}
        <div>
          <button
            id="deactivate-clinic-btn"
            type="button"
            onClick={() => setIsDeactivateModalOpen(true)}
            className={`inline-flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-semibold border transition-all cursor-pointer shadow-xs ${
              isActive
                ? 'border-rose-300 text-rose-700 bg-rose-50/50 hover:bg-rose-100/70'
                : 'border-emerald-300 text-emerald-700 bg-emerald-50/50 hover:bg-emerald-100/70'
            }`}
          >
            {isActive ? <PowerOff className="w-4 h-4" /> : <Power className="w-4 h-4" />}
            <span>{isActive ? 'Deactivate Clinic' : 'Reactivate Clinic'}</span>
          </button>
        </div>
      </div>

      {/* Zero Visibility Enforcement Banner */}
      <div className="p-4 bg-slate-900 text-slate-300 rounded-2xl border border-slate-800 flex items-start gap-3">
        <ShieldAlert className="w-5 h-5 text-amber-400 shrink-0 mt-0.5" />
        <div className="text-xs space-y-1">
          <p className="font-semibold text-white">SuperAdmin Minimalist Scope</p>
          <p className="text-slate-400 leading-relaxed">
            Per the spec: No doctor roster, no patient list, and no clinical encounter data is surfaced here. This ensures SuperAdmins operate with near-zero visibility into patient interactions, preserving health data confidentiality.
          </p>
        </div>
      </div>

      {/* Read-Only Facility Card */}
      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
        <div className="p-6 border-b border-slate-100 bg-slate-50/50 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="p-3 rounded-xl bg-emerald-100 text-emerald-800 border border-emerald-200">
              <Building2 className="w-6 h-6" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h3 className="text-base font-bold text-slate-900">{clinic.name}</h3>
                <StatusBadge variant={clinic.status}>{clinic.status}</StatusBadge>
              </div>
              <p className="text-xs text-slate-500 mt-0.5">
                Registered on {new Date(clinic.created_at).toLocaleDateString('en-GB', {
                  day: 'numeric',
                  month: 'long',
                  year: 'numeric',
                })}
              </p>
            </div>
          </div>
        </div>

        <div className="p-6 md:p-8 space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Contact Information */}
            <div className="space-y-4">
              <h4 className="text-xs font-bold uppercase tracking-wider text-slate-400">
                Institutional Contact
              </h4>

              <div className="space-y-3 text-xs">
                <div className="flex items-start gap-3 p-3 bg-slate-50 rounded-xl border border-slate-100">
                  <Mail className="w-4 h-4 text-slate-400 shrink-0 mt-0.5" />
                  <div>
                    <span className="text-slate-400 block text-[11px]">Official Email</span>
                    <span className="font-semibold text-slate-800">{clinic.email}</span>
                  </div>
                </div>

                <div className="flex items-start gap-3 p-3 bg-slate-50 rounded-xl border border-slate-100">
                  <Phone className="w-4 h-4 text-slate-400 shrink-0 mt-0.5" />
                  <div>
                    <span className="text-slate-400 block text-[11px]">Contact Telephone</span>
                    <span className="font-semibold text-slate-800">{clinic.phone}</span>
                  </div>
                </div>

                <div className="flex items-start gap-3 p-3 bg-slate-50 rounded-xl border border-slate-100">
                  <MapPin className="w-4 h-4 text-slate-400 shrink-0 mt-0.5" />
                  <div>
                    <span className="text-slate-400 block text-[11px]">Facility Physical Address</span>
                    <span className="font-semibold text-slate-800">{clinic.address}</span>
                  </div>
                </div>
              </div>
            </div>

            {/* Governance & Admin Account */}
            <div className="space-y-4">
              <h4 className="text-xs font-bold uppercase tracking-wider text-slate-400">
                Administrative Ownership
              </h4>

              <div className="space-y-3 text-xs">
                <div className="flex items-start gap-3 p-3 bg-slate-50 rounded-xl border border-slate-100">
                  <UserCheck className="w-4 h-4 text-slate-400 shrink-0 mt-0.5" />
                  <div>
                    <span className="text-slate-400 block text-[11px]">Facility Administrator</span>
                    <span className="font-semibold text-slate-800">{clinic.admin_name}</span>
                    <span className="text-[11px] text-slate-500 block">{clinic.admin_email}</span>
                  </div>
                </div>

                <div className="flex items-start gap-3 p-3 bg-slate-50 rounded-xl border border-slate-100">
                  <Calendar className="w-4 h-4 text-slate-400 shrink-0 mt-0.5" />
                  <div>
                    <span className="text-slate-400 block text-[11px]">Onboarding Timestamp</span>
                    <span className="font-semibold text-slate-800 font-mono text-[11px]">
                      {new Date(clinic.created_at).toUTCString()}
                    </span>
                  </div>
                </div>

                <div className="p-3 bg-emerald-50/60 rounded-xl border border-emerald-100 text-[11px] text-emerald-900">
                  <span className="font-semibold block mb-0.5">Section 8 Data Retention Compliance:</span>
                  Deactivating this clinic suspends facility login and doctor writing permissions. All historical medical records, diagnoses, and prescriptions remain immutable and legally attributed.
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Confirmation Dialog */}
      <ConfirmDialog
        isOpen={isDeactivateModalOpen}
        onClose={() => setIsDeactivateModalOpen(false)}
        onConfirm={() => {
          if (clinic.status === 'active') {
            deactivateClinic(clinic.id);
          } else {
            activateClinic(clinic.id);
          }
          setIsDeactivateModalOpen(false);
        }}
        title={isActive ? `Deactivate ${clinic.name}?` : `Reactivate ${clinic.name}?`}
        isDestructive={isActive}
        confirmText={isActive ? 'Yes, Deactivate Clinic' : 'Reactivate Clinic'}
        description={
          <div className="space-y-2">
            <p>
              {isActive
                ? `Are you sure you want to deactivate ${clinic.name}? The clinic admin and all affiliated doctors will lose login and write permissions immediately.`
                : `Reactivating ${clinic.name} will restore login capabilities for the facility administrator and its active physicians.`}
            </p>
            <p className="text-xs text-slate-500 font-medium bg-slate-50 p-2 rounded border border-slate-200">
              Note: Past clinical encounters, prescriptions, and patient records are never altered or deleted.
            </p>
          </div>
        }
      />
    </div>
  );
}
