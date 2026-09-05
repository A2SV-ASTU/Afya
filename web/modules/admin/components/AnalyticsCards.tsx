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
        badge={stats.activeClinics > 0 ? 'Operational' : 'Onboarding'}
        progressPercent={Math.min(100, stats.totalClinics * 20)}
        progressColor="bg-[#388E3C]"
        icon={<Building2 className="w-5 h-5" />}
      />

      <StatCard
        id="stat-active-clinics"
        title="Active Facilities"
        value={stats.activeClinics}
        subtitle={`${stats.totalClinics - stats.activeClinics} suspended / pending`}
        badge="Accredited"
        progressPercent={stats.totalClinics > 0 ? (stats.activeClinics / stats.totalClinics) * 100 : 0}
        progressColor="bg-[#2E7D32]"
        icon={<ShieldCheck className="w-5 h-5" />}
      />

      <StatCard
        id="stat-data-isolation"
        title="Citizen Data Isolation"
        value="100%"
        subtitle="Zero-knowledge record privacy"
        badge="Zero Visibility"
        progressPercent={100}
        progressColor="bg-emerald-600"
        icon={<Activity className="w-5 h-5" />}
      />

      <StatCard
        id="stat-security-posture"
        title="Regulatory Audit Trail"
        value="Enabled"
        subtitle="Cryptographic consent ledger"
        badge="MOH Compliant"
        progressPercent={100}
        progressColor="bg-teal-600"
        icon={<Stethoscope className="w-5 h-5" />}
      />
    </div>
  );
}
