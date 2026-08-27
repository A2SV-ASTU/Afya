'use client';

import React from 'react';
import Link from 'next/link';
import {
  Building2,
  Users,
  Search,
  KeyRound,
  ShieldCheck,
  PlusCircle,
  Clock,
  ArrowRight,
  Stethoscope,
  Activity,
} from 'lucide-react';
import { useStore } from '@/lib/store';
import { StatCard } from '@/modules/core/ui/StatCard';
import { StatusBadge } from '@/modules/core/ui/StatusBadge';
import { CountdownBadge } from '@/modules/core/ui/CountdownBadge';
import { Button } from '@/modules/core/ui/Button';

export default function ClinicDashboardPage() {
  const {
    activeClinic,
    doctors,
    accessRequests,
    patients,
    encounters,
  } = useStore();

  const clinicDoctors = doctors.filter((d) => d.clinic_id === activeClinic.id);
  const clinicEncounters = encounters.filter((e) => e.clinic_id === activeClinic.id);
  const pendingRequests = accessRequests.filter(
    (r) => r.clinic_id === activeClinic.id && r.status === 'pending'
  );
  const activeGrants = accessRequests.filter(
    (r) => r.clinic_id === activeClinic.id && r.status === 'approved'
  );

  return (
    <div className="space-y-6">
      {/* Clinic Welcome & Status */}
      <div className="bg-white rounded-3xl border border-slate-200 shadow-xs p-6 flex flex-wrap items-center justify-between gap-4">
        <div className="flex items-center gap-4">
          <div className="w-12 h-12 rounded-2xl bg-[#E8F5E9] text-[#2E7D32] border border-[#C8E6C9] flex items-center justify-center font-bold">
            <Building2 className="w-6 h-6" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-xl font-bold text-slate-900">{activeClinic.name}</h1>
              <StatusBadge status={activeClinic.status} />
            </div>
            <p className="text-xs text-slate-500 mt-0.5">
              {activeClinic.address} • Admin: {activeClinic.admin_name} ({activeClinic.admin_email})
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2.5">
          <Link href="/clinic/lookup">
            <Button size="sm" variant="outline" leftIcon={<Search className="w-3.5 h-3.5" />}>
              Patient Lookup
            </Button>
          </Link>
          <Link href="/clinic/requests/new">
            <Button size="sm" leftIcon={<KeyRound className="w-3.5 h-3.5" />}>
              + Request Patient Consent
            </Button>
          </Link>
        </div>
      </div>

      {/* KPI Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          title="Active Doctors Roster"
          value={clinicDoctors.length}
          subtitle="Credentialed physicians"
          badge="Verified"
          icon={<Users className="w-5 h-5" />}
        />

        <StatCard
          title="Active Consent Grants"
          value={activeGrants.length}
          subtitle="5-minute patient authorizations"
          badge="Live"
          progressPercent={activeGrants.length * 20}
          icon={<ShieldCheck className="w-5 h-5" />}
        />

        <StatCard
          title="Pending Consent Requests"
          value={pendingRequests.length}
          subtitle="Awaiting citizen mobile approval"
          badge={pendingRequests.length > 0 ? 'Action Needed' : 'None'}
          icon={<KeyRound className="w-5 h-5" />}
        />

        <StatCard
          title="Facility Encounters"
          value={clinicEncounters.length}
          subtitle="Signed clinical records"
          badge="Immutable"
          icon={<Activity className="w-5 h-5" />}
        />
      </div>

      {/* Quick Access Tiles */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Link
          href="/clinic/doctors"
          className="group p-6 bg-white rounded-3xl border border-slate-200 hover:border-[#A5D6A7] hover:shadow-xs transition-all space-y-3"
        >
          <div className="w-10 h-10 rounded-2xl bg-[#E8F5E9] text-[#2E7D32] flex items-center justify-center group-hover:scale-105 transition-transform">
            <Stethoscope className="w-5 h-5" />
          </div>
          <div>
            <h3 className="text-sm font-bold text-slate-900">Doctors Roster & Invitations</h3>
            <p className="text-xs text-slate-500 mt-1">
              Issue 24-hour cryptographic onboarding tokens to licensed physicians.
            </p>
          </div>
        </Link>

        <Link
          href="/clinic/lookup"
          className="group p-6 bg-white rounded-3xl border border-slate-200 hover:border-[#A5D6A7] hover:shadow-xs transition-all space-y-3"
        >
          <div className="w-10 h-10 rounded-2xl bg-[#E8F5E9] text-[#2E7D32] flex items-center justify-center group-hover:scale-105 transition-transform">
            <Search className="w-5 h-5" />
          </div>
          <div>
            <h3 className="text-sm font-bold text-slate-900">Exact Patient Lookup</h3>
            <p className="text-xs text-slate-500 mt-1">
              Verify citizen identity by National ID, email, or telephone with zero wildcard browsing.
            </p>
          </div>
        </Link>

        <Link
          href="/clinic/active-access"
          className="group p-6 bg-white rounded-3xl border border-slate-200 hover:border-[#A5D6A7] hover:shadow-xs transition-all space-y-3"
        >
          <div className="w-10 h-10 rounded-2xl bg-[#E8F5E9] text-[#2E7D32] flex items-center justify-center group-hover:scale-105 transition-transform">
            <ShieldCheck className="w-5 h-5" />
          </div>
          <div>
            <h3 className="text-sm font-bold text-slate-900">Active 5-Min Patient Grants</h3>
            <p className="text-xs text-slate-500 mt-1">
              Inspect live authorized patient charts before time-bounded consent expires.
            </p>
          </div>
        </Link>
      </div>
    </div>
  );
}
