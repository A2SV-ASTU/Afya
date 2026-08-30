'use client';

import React, { useState } from 'react';
import { useStore } from '@/lib/store';
import { StatusBadge } from '@/components/ui/Badge';
import { ConfirmDialog } from '@/components/ui/Modal';
import {
  Stethoscope,
  ArrowLeft,
  PowerOff,
  Power,
  Mail,
  Award,
  Calendar,
  Building2,
  Phone,
  ShieldAlert,
} from 'lucide-react';

export function DoctorDetail() {
  const { doctors, clinics, viewParams, deactivateDoctor, navigateTo } = useStore();
  const [isDeactivateModalOpen, setIsDeactivateModalOpen] = useState(false);

  const doctorId = viewParams.doctorId || doctors[0]?.id;
  const doctor = doctors.find((d) => d.id === doctorId) || doctors[0];
  const clinic = clinics.find((c) => c.id === doctor?.clinic_id) || clinics[0];

  if (!doctor) {
    return (
      <div className="p-8 text-center">
        <p className="text-sm text-slate-500">Physician record not found.</p>
        <button
          onClick={() => navigateTo('clinic-doctors')}
          className="mt-4 px-4 py-2 bg-slate-900 text-white rounded-lg text-xs"
        >
          Return to Doctors Roster
        </button>
      </div>
    );
  }

  const isActive = doctor.doctor_status === 'active';

  return (
    <div id="doctor-detail-page" className="p-6 md:p-8 max-w-4xl mx-auto space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <button
            id="back-to-roster-btn"
            type="button"
            onClick={() => navigateTo('clinic-doctors')}
            className="p-2 rounded-xl text-slate-500 hover:text-slate-900 hover:bg-slate-100 transition-colors cursor-pointer"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <div className="flex items-center gap-2 text-xs font-semibold text-emerald-700 uppercase tracking-wider">
              <Stethoscope className="w-4 h-4" />
              <span>Physician Profile</span>
            </div>
            <h1 className="text-2xl font-bold tracking-tight text-slate-900">
              Dr. {doctor.first_name} {doctor.last_name}
            </h1>
          </div>
        </div>

        {/* Deactivate Doctor Button */}
        <div>
          <button
            id="deactivate-doctor-btn"
            type="button"
            onClick={() => setIsDeactivateModalOpen(true)}
            className={`inline-flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-semibold border transition-all cursor-pointer shadow-xs ${
              isActive
                ? 'border-rose-300 text-rose-700 bg-rose-50/50 hover:bg-rose-100/70'
                : 'border-emerald-300 text-emerald-700 bg-emerald-50/50 hover:bg-emerald-100/70'
            }`}
          >
            {isActive ? <PowerOff className="w-4 h-4" /> : <Power className="w-4 h-4" />}
            <span>{isActive ? 'Deactivate Doctor' : 'Reactivate Doctor'}</span>
          </button>
        </div>
      </div>

      {/* Read-only Physician Card */}
      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
        <div className="p-6 border-b border-slate-100 bg-slate-50/50 flex items-center justify-between">
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 rounded-2xl bg-emerald-100 text-emerald-800 font-bold text-lg flex items-center justify-center border border-emerald-200">
              {doctor.first_name[0]}
              {doctor.last_name[0]}
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h3 className="text-base font-bold text-slate-900">
                  Dr. {doctor.first_name} {doctor.last_name}
                </h3>
                <StatusBadge variant={doctor.doctor_status || 'active'}>{doctor.doctor_status}</StatusBadge>
              </div>
              <p className="text-xs text-slate-500 mt-0.5">{doctor.specialization}</p>
            </div>
          </div>
        </div>

        <div className="p-6 md:p-8 space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Credentials */}
            <div className="space-y-4">
              <h4 className="text-xs font-bold uppercase tracking-wider text-slate-400">
                Medical Licensure & Details
              </h4>

              <div className="space-y-3 text-xs">
                <div className="flex items-start gap-3 p-3 bg-slate-50 rounded-xl border border-slate-100">
                  <Award className="w-4 h-4 text-emerald-600 shrink-0 mt-0.5" />
                  <div>
                    <span className="text-slate-400 block text-[11px]">KMPDC License Number</span>
                    <span className="font-mono font-bold text-slate-800">
                      {doctor.license_number || 'KMPDC-56421'}
                    </span>
                  </div>
                </div>

                <div className="flex items-start gap-3 p-3 bg-slate-50 rounded-xl border border-slate-100">
                  <Stethoscope className="w-4 h-4 text-slate-400 shrink-0 mt-0.5" />
                  <div>
                    <span className="text-slate-400 block text-[11px]">Primary Specialization</span>
                    <span className="font-semibold text-slate-800">{doctor.specialization}</span>
                  </div>
                </div>

                <div className="flex items-start gap-3 p-3 bg-slate-50 rounded-xl border border-slate-100">
                  <Building2 className="w-4 h-4 text-slate-400 shrink-0 mt-0.5" />
                  <div>
                    <span className="text-slate-400 block text-[11px]">Affiliated Institution</span>
                    <span className="font-semibold text-slate-800">{clinic.name}</span>
                  </div>
                </div>
              </div>
            </div>

            {/* Contact & Status */}
            <div className="space-y-4">
              <h4 className="text-xs font-bold uppercase tracking-wider text-slate-400">
                Contact & Account Information
              </h4>

              <div className="space-y-3 text-xs">
                <div className="flex items-start gap-3 p-3 bg-slate-50 rounded-xl border border-slate-100">
                  <Mail className="w-4 h-4 text-slate-400 shrink-0 mt-0.5" />
                  <div>
                    <span className="text-slate-400 block text-[11px]">Professional Email</span>
                    <span className="font-semibold text-slate-800">{doctor.email}</span>
                  </div>
                </div>

                <div className="flex items-start gap-3 p-3 bg-slate-50 rounded-xl border border-slate-100">
                  <Phone className="w-4 h-4 text-slate-400 shrink-0 mt-0.5" />
                  <div>
                    <span className="text-slate-400 block text-[11px]">Telephone</span>
                    <span className="font-semibold text-slate-800">{doctor.phone || '+254 720 000 000'}</span>
                  </div>
                </div>

                <div className="flex items-start gap-3 p-3 bg-slate-50 rounded-xl border border-slate-100">
                  <Calendar className="w-4 h-4 text-slate-400 shrink-0 mt-0.5" />
                  <div>
                    <span className="text-slate-400 block text-[11px]">Privilege Onboarding Date</span>
                    <span className="font-semibold text-slate-800 font-mono text-[11px]">
                      {new Date(doctor.created_at).toLocaleDateString('en-GB', {
                        day: 'numeric',
                        month: 'long',
                        year: 'numeric',
                      })}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Section 8 Compliance Box */}
          <div className="p-4 bg-slate-50 rounded-xl border border-slate-200 text-xs text-slate-600 flex items-start gap-3">
            <ShieldAlert className="w-5 h-5 text-emerald-600 shrink-0 mt-0.5" />
            <div>
              <p className="font-semibold text-slate-800">
                AfyaMind Section 8 Data Retention Principle
              </p>
              <p className="text-slate-500 mt-0.5 leading-relaxed">
                Deactivating a doctor revokes their login and encounter-writing privileges. All historical consultations, vitals, lab interpretations, and prescriptions previously authored by this physician remain permanently intact and attributed to their medical license.
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Confirmation Dialog */}
      <ConfirmDialog
        isOpen={isDeactivateModalOpen}
        onClose={() => setIsDeactivateModalOpen(false)}
        onConfirm={() => deactivateDoctor(doctor.id)}
        title={isActive ? `Deactivate Dr. ${doctor.last_name}?` : `Reactivate Dr. ${doctor.last_name}?`}
        isDestructive={isActive}
        confirmText={isActive ? 'Yes, Deactivate Physician' : 'Reactivate Physician'}
        description={
          <div className="space-y-2">
            <p>
              {isActive
                ? `Dr. ${doctor.first_name} ${doctor.last_name} will immediately lose active access and cannot initiate or close patient encounters.`
                : `Restores clinical practice and encounter management privileges for Dr. ${doctor.first_name} ${doctor.last_name}.`}
            </p>
            <p className="text-xs text-slate-500 font-medium bg-slate-50 p-2 rounded border border-slate-200">
              Past encounters, prescriptions, and clinical notes remain attributed to this physician.
            </p>
          </div>
        }
      />
    </div>
  );
}
