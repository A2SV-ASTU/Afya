'use client';

import React from 'react';
import Link from 'next/link';
import { useStore } from '@/lib/store';
import { StatCard } from '@/components/ui/StatCard';
import { StatusBadge } from '@/components/ui/Badge';
import {
  Building2,
  Stethoscope,
  Send,
  UserCheck,
  UserPlus,
  Search,
  ArrowRight,
  Clock,
  CheckCircle2,
  XCircle,
  AlertCircle,
  Sparkles,
} from 'lucide-react';
import { getAccessRequestPatientName } from '@/types/database';

export function ClinicDashboard() {
  const {
    currentUser,
    clinics,
    doctors,
    accessRequests,
    patients,
    invitations,
    navigateTo,
  } = useStore();

  const activeClinic = clinics.find((c) => c.id === currentUser?.clinic_id) || clinics[0];

  // Scoped metrics for this clinic
  const clinicDoctors = doctors.filter((d) => d.clinic_id === activeClinic.id);
  const activeDoctorsCount = clinicDoctors.filter((d) => d.doctor_status === 'active').length;

  const clinicRequests = accessRequests.filter((r) => r.clinic_id === activeClinic.id);
  const pendingRequestsCount = clinicRequests.filter((r) => r.status === 'pending').length;

  const activeGrantedPatients = patients.filter((p) =>
    p.active_grant_clinic_ids.includes(activeClinic.id)
  );

  return (
    <div id="clinic-dashboard-page" className="p-8 space-y-6 max-w-7xl mx-auto">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-bold tracking-tight text-slate-900">Clinic Dashboard</h2>
          <p className="text-sm text-slate-500">Welcome back, {currentUser?.first_name} • {activeClinic.name}</p>
        </div>

        <div className="flex items-center gap-3">
          <button
            id="clinic-quick-lookup-btn"
            type="button"
            onClick={() => navigateTo('clinic-lookup')}
            className="inline-flex items-center gap-2 px-4 py-2.5 bg-[#388E3C] hover:bg-[#2E7D32] text-white font-medium rounded-xl text-xs shadow-xs transition-colors cursor-pointer"
          >
            <Search className="w-4 h-4" />
            <span>Look Up Patient</span>
          </button>
          <button
            id="clinic-quick-invite-btn"
            type="button"
            onClick={() => navigateTo('clinic-doctors', { openInvite: true })}
            className="inline-flex items-center gap-2 px-4 py-2.5 bg-white hover:bg-slate-50 text-slate-700 font-medium rounded-xl text-xs border border-slate-200 shadow-xs transition-colors cursor-pointer"
          >
            <UserPlus className="w-4 h-4 text-[#388E3C]" />
            <span>Invite Physician</span>
          </button>
        </div>
      </div>

      {/* Summary Cards with Sleek Interface Style */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <StatCard
          id="stat-clinic-active-doctors"
          title="Active Doctors"
          value={activeDoctorsCount}
          subtitle={`${clinicDoctors.length} total registered in facility`}
          badge="+2 this month"
          progressPercent={clinicDoctors.length > 0 ? (activeDoctorsCount / clinicDoctors.length) * 100 : 80}
          progressColor="bg-[#388E3C]"
          icon={<Stethoscope className="w-5 h-5" />}
        />
        <StatCard
          id="stat-clinic-pending-requests"
          title="Pending Consent"
          value={pendingRequestsCount}
          subtitle="5-minute active patient decision timers"
          badge={pendingRequestsCount > 0 ? `${pendingRequestsCount} active` : '0 active'}
          progressPercent={pendingRequestsCount > 0 ? 65 : 0}
          progressColor="bg-amber-500"
          icon={<Clock className="w-5 h-5" />}
        />
        <StatCard
          id="stat-clinic-active-patients"
          title="Authorized Patients"
          value={activeGrantedPatients.length}
          subtitle="Active longitudinal health record access"
          badge="Active Grants"
          progressPercent={Math.min(100, activeGrantedPatients.length * 20)}
          progressColor="bg-[#2E7D32]"
          icon={<UserCheck className="w-5 h-5" />}
        />
      </div>

      {/* Hero Quick Action Banner */}
      <div className="bg-linear-to-r from-[#1B5E20] via-[#2E7D32] to-[#388E3C] p-6 md:p-8 rounded-3xl text-white shadow-lg shadow-[#388E3C]/15 relative overflow-hidden">
        <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-6">
          <div className="space-y-1 max-w-xl">
            <span className="inline-flex items-center gap-1.5 px-3 py-1 bg-white/10 text-white/90 text-xs font-semibold rounded-full backdrop-blur-xs mb-2">
              <Sparkles className="w-3.5 h-3.5 text-[#C8E6C9]" />
              Patient Consent Gateway
            </span>
            <h3 className="text-2xl font-bold tracking-tight text-white">
              Instant Patient Authorization & Chart Access
            </h3>
            <p className="text-[#E8F5E9] text-xs md:text-sm leading-relaxed">
              Dispatch real-time consent requests directly to patients via national ID or email. Once authorized, doctors at {activeClinic.name} receive immediate access to longitudinal medical records.
            </p>
          </div>

          <div className="flex flex-col sm:flex-row gap-3 shrink-0">
            <button
              id="hero-lookup-patient-btn"
              type="button"
              onClick={() => navigateTo('clinic-lookup')}
              className="py-3 px-6 bg-white text-[#1B5E20] hover:bg-[#E8F5E9] font-bold rounded-xl text-xs flex items-center justify-center gap-2 shadow-sm transition-all cursor-pointer"
            >
              <Search className="w-4 h-4 text-[#388E3C]" />
              <span>Look Up Patient</span>
            </button>
            <button
              id="hero-view-requests-btn"
              type="button"
              onClick={() => navigateTo('clinic-requests')}
              className="py-3 px-5 bg-[#1B5E20]/80 hover:bg-[#1B5E20] text-white font-semibold rounded-xl text-xs border border-[#A5D6A7]/30 flex items-center justify-center gap-2 transition-all cursor-pointer"
            >
              <span>Consent Queue</span>
              <ArrowRight className="w-3.5 h-3.5" />
            </button>
          </div>
        </div>
      </div>

      {/* Two Column Section: Recent Activity & Quick Roster */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left Column: Recent Activity Feed */}
        <div className="lg:col-span-2 bg-white rounded-3xl border border-slate-200 shadow-sm overflow-hidden flex flex-col justify-between">
          <div>
            <div className="p-6 border-b border-slate-100 flex items-center justify-between">
              <div>
                <h3 className="text-base font-bold text-slate-900">Recent Operational Activity</h3>
                <p className="text-xs text-slate-500 mt-0.5">
                  Audit log of patient access requests and physician authorizations.
                </p>
              </div>
              <button
                id="view-all-requests-link"
                type="button"
                onClick={() => navigateTo('clinic-requests')}
                className="text-xs font-semibold text-[#2E7D32] hover:text-[#1B5E20] flex items-center gap-1 cursor-pointer"
              >
                All Requests
                <ArrowRight className="w-3.5 h-3.5" />
              </button>
            </div>

            <div className="p-6 divide-y divide-slate-100">
              {clinicRequests.length === 0 && invitations.length === 0 ? (
                <p className="text-center text-xs text-slate-400 py-8">No recent activity logged.</p>
              ) : (
                clinicRequests.slice(0, 5).map((req) => (
                  <div key={req.id} className="py-3.5 first:pt-0 last:pb-0 flex items-start justify-between gap-4">
                    <div className="flex items-start gap-3">
                      <div className="w-8 h-8 rounded-xl bg-slate-50 text-slate-600 flex items-center justify-center shrink-0 mt-0.5 border border-slate-100">
                        {req.status === 'approved' && <CheckCircle2 className="w-4 h-4 text-[#388E3C]" />}
                        {req.status === 'pending' && <Clock className="w-4 h-4 text-amber-600 animate-pulse" />}
                        {req.status === 'denied' && <XCircle className="w-4 h-4 text-rose-600" />}
                        {req.status === 'expired' && <AlertCircle className="w-4 h-4 text-slate-400" />}
                      </div>
                      <div>
                        <div className="flex items-center gap-2">
                          <span className="text-xs font-bold text-slate-900">{getAccessRequestPatientName(req)}</span>
                          <StatusBadge variant={req.status}>{req.status}</StatusBadge>
                        </div>
                        <p className="text-xs text-slate-500 mt-0.5 line-clamp-1">{req.reason}</p>
                        <p className="text-[11px] text-slate-400 mt-0.5">
                          Submitted by Dr. {req.submitted_by_doctor_name}
                        </p>
                      </div>
                    </div>

                    <span className="text-[11px] font-mono text-slate-400 shrink-0">
                      {new Date(req.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                    </span>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>

        {/* Right Column: Doctors Roster Summary */}
        <div className="bg-white rounded-3xl border border-slate-200 shadow-sm p-6 space-y-4 flex flex-col justify-between">
          <div className="space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-4">
              <h3 className="text-base font-bold text-slate-900">Physicians on Roster</h3>
              <Link
                id="manage-doctors-link"
                href="/clinic/doctors"
                className="text-xs font-semibold text-[#2E7D32] hover:text-[#1B5E20] cursor-pointer"
              >
                Manage
              </Link>
            </div>

            <div className="space-y-2.5">
              {clinicDoctors.map((doc) => (
                <div
                  key={doc.id}
                  onClick={() => navigateTo('clinic-doctor-detail', { doctorId: doc.id })}
                  className="p-3.5 rounded-2xl bg-slate-50 border border-slate-100 hover:border-[#C8E6C9] hover:bg-[#E8F5E9]/30 transition-colors cursor-pointer flex items-center justify-between"
                >
                  <div className="overflow-hidden">
                    <p className="text-xs font-bold text-slate-900 truncate">
                      Dr. {doc.first_name} {doc.last_name}
                    </p>
                    <p className="text-[11px] text-slate-500 truncate">{doc.specialization}</p>
                  </div>
                  <StatusBadge variant={doc.doctor_status || 'active'}>{doc.doctor_status}</StatusBadge>
                </div>
              ))}
            </div>
          </div>

          <Link
            id="sidebar-invite-physician-btn"
            href="/clinic/doctors"
            className="w-full py-2.5 bg-[#E8F5E9] text-[#2E7D32] hover:bg-[#C8E6C9] font-semibold rounded-xl text-xs border border-[#C8E6C9] transition-colors flex items-center justify-center gap-2 cursor-pointer mt-4"
          >
            <UserPlus className="w-3.5 h-3.5 text-[#388E3C]" />
            <span>Invite New Physician</span>
          </Link>
        </div>
      </div>
    </div>
  );
}
