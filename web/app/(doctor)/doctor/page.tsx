'use client';

import React from 'react';
import Link from 'next/link';
import {
  Stethoscope,
  PlusCircle,
  Users,
  Calendar,
  Activity,
  ArrowRight,
  ShieldCheck,
} from 'lucide-react';
import { useStore } from '@/lib/store';
import { StatCard } from '@/modules/core/ui/StatCard';
import { StatusBadge } from '@/modules/core/ui/StatusBadge';
import { Button } from '@/modules/core/ui/Button';
import { formatDateTime } from '@/modules/core/lib/utils';

export default function DoctorDashboardPage() {
  const {
    currentUser,
    activeClinic,
    encounters,
    patients,
    appointments,
  } = useStore();

  const openEncounters = encounters.filter(
    (e) => e.opened_by_doctor_id === currentUser?.id && e.status === 'open'
  );
  const scheduledAppointments = appointments.filter(
    (a) => a.doctor_id === currentUser?.id && a.status === 'scheduled'
  );
  const doctorEncounters = encounters.filter(
    (e) => e.opened_by_doctor_id === currentUser?.id
  );

  return (
    <div className="space-y-6">
      {/* Doctor Header Banner */}
      <div className="bg-white rounded-3xl border border-slate-200 shadow-xs p-6 flex flex-wrap items-center justify-between gap-4">
        <div className="flex items-center gap-4">
          <div className="w-12 h-12 rounded-2xl bg-[#E8F5E9] text-[#2E7D32] border border-[#C8E6C9] flex items-center justify-center font-bold">
            <Stethoscope className="w-6 h-6" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-xl font-bold text-slate-900">
                Dr. {currentUser?.first_name} {currentUser?.last_name}
              </h1>
              <span className="px-2.5 py-0.5 bg-[#E8F5E9] text-[#2E7D32] border border-[#C8E6C9] rounded-full text-xs font-semibold">
                KMPDC Registered
              </span>
            </div>
            <p className="text-xs text-slate-500 mt-0.5">
              {currentUser?.specialization || 'Attending Physician'} • Facility: {activeClinic.name}
            </p>
          </div>
        </div>

        <div className="flex items-center gap-3">
          <Link href="/doctor/encounters/new">
            <Button size="sm" leftIcon={<PlusCircle className="w-4 h-4" />}>
              + Start Clinical Encounter
            </Button>
          </Link>
        </div>
      </div>

      {/* KPI Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          title="Active Open Encounters"
          value={openEncounters.length}
          subtitle="Awaiting sign-off & closure"
          badge={openEncounters.length > 0 ? 'In Progress' : 'Clean'}
          progressPercent={openEncounters.length * 30}
          icon={<Activity className="w-5 h-5" />}
        />

        <StatCard
          title="Patient Directory"
          value={patients.length}
          subtitle="Accessible longitudinal charts"
          badge="Verified"
          icon={<Users className="w-5 h-5" />}
        />

        <StatCard
          title="Upcoming Appointments"
          value={scheduledAppointments.length}
          subtitle="Follow-up consult reviews"
          badge="Booked"
          icon={<Calendar className="w-5 h-5" />}
        />

        <StatCard
          title="Total Consults Signed"
          value={doctorEncounters.length}
          subtitle="Immutable longitudinal records"
          badge="Audited"
          icon={<ShieldCheck className="w-5 h-5" />}
        />
      </div>

      {/* Active Open Encounters Alert */}
      {openEncounters.length > 0 && (
        <div className="bg-[#E8F5E9]/50 border border-[#C8E6C9] rounded-3xl p-6 space-y-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Activity className="w-5 h-5 text-[#2E7D32]" />
              <h2 className="text-sm font-bold text-[#1B5E20]">
                Active In-Progress Clinical Encounters ({openEncounters.length})
              </h2>
            </div>
            <span className="text-xs text-[#2E7D32] font-semibold">Active Session</span>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {openEncounters.map((enc) => (
              <div
                key={enc.id}
                className="bg-white p-5 rounded-2xl border border-slate-200 shadow-2xs space-y-3"
              >
                <div className="flex items-center justify-between">
                  <div>
                    <h3 className="font-bold text-slate-900 text-sm">{enc.patient_name}</h3>
                    <p className="text-[11px] font-mono text-slate-400">{enc.id}</p>
                  </div>
                  <span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-amber-50 text-amber-800 border border-amber-200">
                    Open / Draft
                  </span>
                </div>

                <div className="text-xs text-slate-600 space-y-1">
                  <p>Type: <strong className="uppercase">{enc.type}</strong></p>
                  <p>Recorded Vitals: {enc.vitals?.length || 0} • Labs: {enc.labs?.length || 0} • Diagnoses: {enc.diagnoses?.length || 0}</p>
                </div>

                <div className="pt-2 flex justify-end">
                  <Link href={`/doctor/encounters/${enc.id}`}>
                    <Button size="sm" leftIcon={<Stethoscope className="w-3.5 h-3.5" />}>
                      Resume Encounter Workspace
                    </Button>
                  </Link>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Recent Signed Encounters */}
      <div className="bg-white rounded-3xl border border-slate-200 shadow-xs overflow-hidden">
        <div className="p-6 border-b border-slate-100 flex items-center justify-between">
          <div>
            <h2 className="text-base font-bold text-slate-900">Signed Clinical Records</h2>
            <p className="text-xs text-slate-500">Historical encounters authored and cryptographically signed</p>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs border-collapse">
            <thead>
              <tr className="border-b border-slate-100 bg-slate-50/75 text-slate-500 font-semibold uppercase tracking-wider text-[11px]">
                <th className="py-3 px-6">Patient Name</th>
                <th className="py-3 px-6">Encounter Type</th>
                <th className="py-3 px-6">Clinical Payload</th>
                <th className="py-3 px-6">Date / Facility</th>
                <th className="py-3 px-6">Status</th>
                <th className="py-3 px-6 text-right">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 font-medium text-slate-700">
              {doctorEncounters.map((enc) => (
                <tr key={enc.id} className="hover:bg-slate-50/60 transition-colors">
                  <td className="py-4 px-6">
                    <p className="font-bold text-slate-900">{enc.patient_name}</p>
                    <p className="text-[11px] font-mono text-slate-400">{enc.patient_id}</p>
                  </td>
                  <td className="py-4 px-6 uppercase font-bold text-slate-700">{enc.type}</td>
                  <td className="py-4 px-6 text-slate-600">
                    {enc.diagnoses?.[0]?.diagnosis_text || 'Standard Consultation'}
                  </td>
                  <td className="py-4 px-6">
                    <p className="font-semibold text-slate-800">{enc.clinic_name}</p>
                    <p className="text-[11px] text-slate-400 font-mono">{formatDateTime(enc.started_at)}</p>
                  </td>
                  <td className="py-4 px-6">
                    <StatusBadge status={enc.status} />
                  </td>
                  <td className="py-4 px-6 text-right">
                    <Link
                      href={`/doctor/patients/${enc.patient_id}`}
                      className="inline-flex items-center gap-1 font-semibold text-[#2E7D32] hover:text-[#1B5E20] text-xs"
                    >
                      View Chart <ArrowRight className="w-3.5 h-3.5" />
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
