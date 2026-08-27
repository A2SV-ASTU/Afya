'use client';

import React from 'react';
import { AnalyticsCards } from '@/modules/admin/components/AnalyticsCards';
import { ClinicsTable } from '@/modules/admin/components/ClinicsTable';
import { ShieldCheck, Lock } from 'lucide-react';

export default function AdminDashboardPage() {
  return (
    <div className="space-y-6">
      {/* Zero Visibility Banner */}

      {/* Analytics Cards */}
      <AnalyticsCards />

      {/* Clinics Directory & Management */}
      <ClinicsTable />
    </div>
  );
}
