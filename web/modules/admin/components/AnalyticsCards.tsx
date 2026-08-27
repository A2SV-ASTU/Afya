'use client';

import React from 'react';
import { Building2, Stethoscope, Activity, ShieldCheck } from 'lucide-react';
import { StatCard } from '@/modules/core/ui/StatCard';
import { useAdminStats } from '../hooks/useAdminStats';

export function AnalyticsCards() {
  const stats = useAdminStats();

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      <StatCard
        id="stat-total-clinics"
        title="Accredited Clinics"
        value={stats.totalClinics}
        subtitle={`${stats.activeClinics} active in network`}
        badge="Active"
        progressPercent={Math.min(100, stats.totalClinics * 20)}
        progressColor="bg-[#388E3C]"
        icon={<Building2 className="w-5 h-5" />}
      />

      <StatCard
        id="stat-licensed-doctors"
        title="Licensed Doctors"
        value={stats.totalDoctors}
        subtitle="Active physician credentials"
        badge="KMPDC Verified"
        progressPercent={Math.min(100, stats.totalDoctors * 15)}
        progressColor="bg-[#2E7D32]"
        icon={<Stethoscope className="w-5 h-5" />}
      />

      <StatCard
        id="stat-clinical-encounters"
        title="Clinical Encounters"
        value={stats.totalEncounters}
        subtitle="Audit-signed encounters recorded"
        badge="Immutable"
        progressPercent={Math.min(100, stats.totalEncounters * 5)}
        progressColor="bg-emerald-600"
        icon={<Activity className="w-5 h-5" />}
      />

      <StatCard
        id="stat-patient-grants"
        title="Active Consents"
        value={stats.totalGrants}
        subtitle="5-minute citizen authorizations"
        badge="Zero Visibility"
        progressPercent={Math.min(100, stats.totalGrants * 25)}
        progressColor="bg-teal-600"
        icon={<ShieldCheck className="w-5 h-5" />}
      />
    </div>
  );
}
