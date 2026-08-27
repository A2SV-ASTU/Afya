'use client';

import React from 'react';
import { useStore } from '@/lib/store';
import { StatCard } from '@/components/ui/StatCard';
import { StatusBadge } from '@/components/ui/Badge';
import {
  Stethoscope,
  Users,
  FolderOpen,
  PlusCircle,
  Calendar,
  Clock,
  ArrowRight,
  CheckCircle2,
  FileCheck2,
  Building2,
  HeartPulse,
  Sparkles,
} from 'lucide-react';

export function DoctorDashboard() {
  const {
    currentUser,
    clinics,
    patients,
    encounters,
    appointments,
    navigateTo,
  } = useStore();

  const activeClinic = clinics.find((c) => c.id === currentUser.clinic_id) || clinics[0];

  // Patients scoped strictly to clinic's active access
  const authorizedPatients = patients.filter((p) =>
    p.active_grant_clinic_ids.includes(activeClinic.id)
  );

  // Encounters
  const openEncounters = encounters.filter((e) => e.status === 'open');
  const recentEncounters = encounters.slice(0, 5);

  // Upcoming Appointments
  const scheduledAppointments = appointments.filter((a) => a.status === 'scheduled');

  return (
    <div id="doctor-dashboard-page" className="p-8 space-y-6 max-w-7xl mx-auto">
      {/* Header Banner */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-bold tracking-tight text-slate-900">
            Doctor Clinical Practice
          </h2>
          <p className="text-sm text-slate-500">
            Dr. {currentUser.first_name} {currentUser.last_name} • {currentUser.specialization || 'Attending Physician'} • {activeClinic.name}
          </p>
        </div>

        {/* Start New Encounter CTA */}
        <div className="flex flex-wrap items-center gap-3">
          <button
            id="doctor-view-patients-btn"
            type="button"
            onClick={() => navigateTo('doctor-patients')}
            className="inline-flex items-center gap-2 px-4 py-2.5 bg-white hover:bg-slate-50 text-slate-700 font-medium rounded-xl text-xs border border-slate-200 shadow-xs transition-colors cursor-pointer"
          >
            <Users className="w-4 h-4 text-[#388E3C]" />
            <span>Patient Charts</span>
          </button>

          <button
            id="doctor-start-encounter-btn"
            type="button"
            onClick={() => navigateTo('doctor-start-encounter')}
            className="inline-flex items-center gap-2 px-5 py-2.5 bg-[#388E3C] hover:bg-[#2E7D32] text-white font-semibold rounded-xl text-xs shadow-xs transition-colors cursor-pointer"
          >
            <PlusCircle className="w-4 h-4" />
            <span>+ Start Clinical Encounter</span>
          </button>
        </div>
      </div>

      {/* Metrics Row */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <StatCard
          id="stat-doc-active-patients"
          title="Active Patient Charts"
          value={authorizedPatients.length}
          subtitle="Patients with active clinical consent"
          badge="Authorized"
          progressPercent={Math.min(100, authorizedPatients.length * 25)}
          progressColor="bg-[#388E3C]"
          icon={<Users className="w-5 h-5" />}
        />
        <StatCard
          id="stat-doc-open-encounters"
          title="Open Encounters"
          value={openEncounters.length}
          subtitle="In-progress active visits"
          badge={openEncounters.length > 0 ? `${openEncounters.length} Active` : 'None'}
          progressPercent={openEncounters.length > 0 ? 80 : 0}
          progressColor="bg-amber-500"
          icon={<HeartPulse className="w-5 h-5" />}
        />
        <StatCard
          id="stat-doc-appointments"
          title="Scheduled Follow-Ups"
          value={scheduledAppointments.length}
          subtitle="Confirmed return visits"
          badge="Scheduled"
          progressPercent={Math.min(100, scheduledAppointments.length * 33)}
          progressColor="bg-[#2E7D32]"
          icon={<Calendar className="w-5 h-5" />}
        />
      </div>

      {/* Three Primary Sections: My Patients + Open Encounters + Follow-Ups */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left Column (2 spans): Open & Recent Encounters */}
        <div className="lg:col-span-2 space-y-6">
          {/* Open Encounters Section */}
          {openEncounters.length > 0 && (
            <div className="bg-white rounded-3xl border border-[#A5D6A7] shadow-sm overflow-hidden">
              <div className="p-6 border-b border-[#C8E6C9] bg-[#E8F5E9]/50 flex items-center justify-between">
                <div className="flex items-center gap-2.5">
                  <span className="w-2.5 h-2.5 rounded-full bg-[#388E3C] animate-ping" />
                  <h3 className="text-base font-bold text-slate-900">
                    Active In-Progress Encounters ({openEncounters.length})
                  </h3>
                </div>
                <span className="text-xs text-[#1B5E20] font-semibold px-2.5 py-0.5 rounded-full bg-[#C8E6C9]">
                  Unlocked Workspace
                </span>
              </div>

              <div className="p-6 divide-y divide-slate-100">
                {openEncounters.map((enc) => (
                  <div
                    key={enc.id}
                    id={`open-encounter-${enc.id}`}
                    className="py-4 first:pt-0 last:pb-0 flex flex-col sm:flex-row sm:items-center justify-between gap-4"
                  >
                    <div className="space-y-1">
                      <div className="flex items-center gap-2">
                        <span className="font-bold text-slate-900 text-sm">{enc.patient_name}</span>
                        <StatusBadge variant={enc.type}>{enc.type}</StatusBadge>
                        <StatusBadge variant="open">IN PROGRESS</StatusBadge>
                      </div>
                      <p className="text-xs text-slate-500">
                        Attending: {enc.opened_by_doctor_name} • Started: {new Date(enc.started_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                      </p>
                      {enc.notes && <p className="text-xs text-slate-600 mt-1 italic line-clamp-1">{enc.notes}</p>}
                    </div>

                    <button
                      type="button"
                      onClick={() => navigateTo('doctor-encounter-workspace', { encounterId: enc.id })}
                      className="px-4 py-2.5 bg-[#388E3C] hover:bg-[#2E7D32] text-white font-semibold text-xs rounded-xl shadow-xs transition-colors shrink-0 flex items-center gap-1.5 cursor-pointer"
                    >
                      <span>Open Workspace</span>
                      <ArrowRight className="w-3.5 h-3.5" />
                    </button>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Recent Encounters List */}
          <div className="bg-white rounded-3xl border border-slate-200 shadow-sm overflow-hidden">
            <div className="p-6 border-b border-slate-100 flex items-center justify-between">
              <div>
                <h3 className="text-base font-bold text-slate-900">Recent Clinical Encounters</h3>
                <p className="text-xs text-slate-500 mt-0.5">
                  Open & finalized patient encounter records.
                </p>
              </div>
              <button
                id="doc-new-encounter-quick"
                type="button"
                onClick={() => navigateTo('doctor-start-encounter')}
                className="text-xs font-semibold text-[#2E7D32] hover:text-[#1B5E20] flex items-center gap-1 cursor-pointer"
              >
                + New Encounter
              </button>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs text-slate-600">
                <thead className="bg-slate-50 border-b border-slate-200 text-[11px] font-semibold text-slate-500 uppercase tracking-wider">
                  <tr>
                    <th className="py-4 px-6">Patient Name</th>
                    <th className="py-4 px-6">Started At</th>
                    <th className="py-4 px-6">Modality / Type</th>
                    <th className="py-4 px-6">Status</th>
                    <th className="py-4 px-6 text-right">Action</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {recentEncounters.map((enc) => (
                    <tr
                      key={enc.id}
                      onClick={() => navigateTo('doctor-encounter-workspace', { encounterId: enc.id })}
                      className="hover:bg-slate-50/80 cursor-pointer transition-colors"
                    >
                      <td className="py-4 px-6 font-bold text-slate-900">
                        {enc.patient_name}
                      </td>
                      <td className="py-4 px-6 font-mono text-[11px] text-slate-500">
                        {new Date(enc.started_at).toLocaleDateString('en-GB', {
                          day: 'numeric',
                          month: 'short',
                          year: 'numeric',
                          hour: '2-digit',
                          minute: '2-digit',
                        })}
                      </td>
                      <td className="py-4 px-6">
                        <span className="uppercase text-[10px] font-semibold tracking-wider px-2.5 py-0.5 rounded-full bg-slate-100 text-slate-700 border border-slate-200">
                          {enc.type}
                        </span>
                      </td>
                      <td className="py-4 px-6">
                        <StatusBadge variant={enc.status === 'open' ? 'open' : 'closed'}>
                          {enc.status === 'open' ? 'IN PROGRESS' : 'SIGNED OFF'}
                        </StatusBadge>
                      </td>
                      <td className="py-4 px-6 text-right">
                        <span className="text-xs font-semibold text-[#2E7D32] hover:text-[#1B5E20]">
                          {enc.status === 'open' ? 'Open Workspace →' : 'View Audit Record →'}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>

        {/* Right Column: "My Patients" Directory & Follow-ups */}
        <div className="space-y-6">
          {/* Patients with Active Grant */}
          <div className="bg-white rounded-3xl border border-slate-200 shadow-sm p-6 space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <h3 className="text-base font-bold text-slate-900">Authorized Patients</h3>
              <button
                id="doc-view-all-patients"
                type="button"
                onClick={() => navigateTo('doctor-patients')}
                className="text-xs font-semibold text-[#2E7D32] hover:text-[#1B5E20] cursor-pointer"
              >
                View All
              </button>
            </div>

            <div className="space-y-2.5">
              {authorizedPatients.map((patient) => (
                <div
                  key={patient.id}
                  id={`doc-pat-card-${patient.id}`}
                  onClick={() => navigateTo('doctor-patient-history', { patientId: patient.id })}
                  className="p-3.5 rounded-2xl bg-slate-50 border border-slate-100 hover:border-[#C8E6C9] hover:bg-[#E8F5E9]/30 transition-colors cursor-pointer flex items-center justify-between"
                >
                  <div className="flex items-center gap-3">
                    <div className="w-9 h-9 rounded-full bg-[#E8F5E9] text-[#2E7D32] font-bold text-xs flex items-center justify-center shrink-0">
                      {patient.first_name[0]}
                      {patient.last_name[0]}
                    </div>
                    <div className="overflow-hidden">
                      <p className="text-xs font-bold text-slate-900 truncate">
                        {patient.first_name} {patient.last_name}
                      </p>
                      <p className="text-[11px] text-slate-400 truncate">
                        {patient.sex} • Blood: {patient.blood_group}
                      </p>
                    </div>
                  </div>

                  <span className="text-xs font-semibold text-[#2E7D32]">Chart →</span>
                </div>
              ))}
            </div>
          </div>

          {/* Upcoming Appointments Summary */}
          <div className="bg-white rounded-3xl border border-slate-200 shadow-sm p-6 space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <h3 className="text-base font-bold text-slate-900">Upcoming Appointments</h3>
              <button
                id="doc-view-appointments"
                type="button"
                onClick={() => navigateTo('doctor-appointments')}
                className="text-xs font-semibold text-[#2E7D32] hover:text-[#1B5E20] cursor-pointer"
              >
                Schedule
              </button>
            </div>

            <div className="space-y-2.5">
              {scheduledAppointments.length === 0 ? (
                <p className="text-xs text-slate-400 text-center py-4">No scheduled follow-ups.</p>
              ) : (
                scheduledAppointments.slice(0, 3).map((apt) => (
                  <div key={apt.id} className="p-3.5 rounded-2xl bg-slate-50 border border-slate-100 text-xs space-y-1">
                    <div className="flex items-center justify-between">
                      <span className="font-bold text-slate-900">{apt.patient_name}</span>
                      <StatusBadge variant={apt.status}>{apt.status}</StatusBadge>
                    </div>
                    <p className="text-slate-500 font-mono text-[11px]">
                      {new Date(apt.scheduled_at).toLocaleDateString('en-GB', {
                        day: 'numeric',
                        month: 'short',
                        hour: '2-digit',
                        minute: '2-digit',
                      })}
                    </p>
                    {apt.notes && <p className="text-slate-600 text-[11px]">{apt.notes}</p>}
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
