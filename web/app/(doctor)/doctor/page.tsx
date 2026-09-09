'use client';

import React, { useCallback, useEffect, useState } from 'react';
import Link from 'next/link';
import {
  Stethoscope,
  PlusCircle,
  Users,
  Clock,
  ArrowRight,
  ShieldCheck,
} from 'lucide-react';
import { useAuth } from '@/modules/core/context/AuthContext';
import { accessRequestsApi } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api/client';
import {
  AccessRequest,
  getAccessRequestPatientName,
  getAccessRequestPatientEmail,
} from '@/types/database';
import { StatCard } from '@/modules/core/ui/StatCard';
import { Button } from '@/modules/core/ui/Button';
import { PLACEHOLDER_CLINIC_NAME } from '@/modules/clinical-workspace/lib/encounterMappers';

function formatDate(value?: string): string {
  if (!value) return '—';
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return '—';
  return new Intl.DateTimeFormat('en-GB', { day: '2-digit', month: 'short', year: 'numeric' }).format(date);
}

export default function DoctorDashboardPage() {
  const { currentUser, isReady } = useAuth();
  const clinicId = currentUser?.clinic_id ?? null;

  const [approvedGrants, setApprovedGrants] = useState<AccessRequest[]>([]);
  const [pendingCount, setPendingCount] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadDashboard = useCallback(async () => {
    if (!clinicId) {
      setIsLoading(false);
      setError('Your account is not affiliated with a clinic.');
      return;
    }
    setIsLoading(true);
    setError(null);
    try {
      const [approved, pending] = await Promise.all([
        accessRequestsApi.listRequests(clinicId, 'approved'),
        accessRequestsApi.listRequests(clinicId, 'pending'),
      ]);
      setApprovedGrants(approved.access_requests || []);
      setPendingCount((pending.access_requests || []).length);
    } catch (err) {
      setError(getApiErrorMessage(err, 'Failed to load dashboard metrics.'));
    } finally {
      setIsLoading(false);
    }
  }, [clinicId]);

  useEffect(() => {
    if (isReady) loadDashboard();
  }, [isReady, loadDashboard]);

  const clinicName = currentUser?.clinic_name || PLACEHOLDER_CLINIC_NAME;

  return (
    <div className="space-y-6">
      {/* Doctor Header Banner */}
      <div className="bg-white rounded-3xl border border-slate-200 shadow-xs p-6 flex flex-wrap items-center justify-between gap-4">
        <div className="flex items-center gap-4">
          <div className="w-12 h-12 rounded-2xl bg-[#E8F5E9] text-[#2E7D32] border border-[#C8E6C9] flex items-center justify-center font-bold">
            <Stethoscope className="w-6 h-6" />
          </div>
          <div>
            <h1 className="text-xl font-bold text-slate-900">
              Dr. {currentUser?.first_name} {currentUser?.last_name}
            </h1>
            <p className="text-xs text-slate-500 mt-0.5">
              {currentUser?.specialization || 'Attending Physician'} • Facility: {clinicName}
            </p>
          </div>
        </div>

        <Link href="/doctor/encounters/new">
          <Button size="sm" leftIcon={<PlusCircle className="w-4 h-4" />}>
            Start Clinical Encounter
          </Button>
        </Link>
      </div>

      {error && (
        <div className="p-4 rounded-2xl bg-rose-50 border border-rose-200 text-xs text-rose-700">
          {error}
        </div>
      )}

      {/* KPI Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <StatCard
          title="Authorized Patients"
          value={isLoading ? '—' : approvedGrants.length}
          subtitle="Active approved access grants"
          badge="Verified"
          icon={<Users className="w-5 h-5" />}
        />
        <StatCard
          title="Pending Access Requests"
          value={isLoading ? '—' : pendingCount}
          subtitle="Awaiting patient approval"
          badge={pendingCount > 0 ? 'Waiting' : 'Clear'}
          icon={<Clock className="w-5 h-5" />}
        />
        <StatCard
          title="Facility"
          value={clinicName}
          subtitle={currentUser?.specialization || 'Clinical practice'}
          badge="Affiliated"
          icon={<ShieldCheck className="w-5 h-5" />}
        />
      </div>

      {/* Recent Authorized Patients */}
      <div className="bg-white rounded-3xl border border-slate-200 shadow-xs overflow-hidden">
        <div className="p-6 border-b border-slate-100 flex items-center justify-between">
          <div>
            <h2 className="text-base font-bold text-slate-900">Authorized Patient Directory</h2>
            <p className="text-xs text-slate-500">Patients whose records this clinic is cleared to access</p>
          </div>
          <Link
            href="/doctor/patients"
            className="text-xs font-semibold text-[#2E7D32] hover:text-[#1B5E20] inline-flex items-center gap-1"
          >
            View all <ArrowRight className="w-3.5 h-3.5" />
          </Link>
        </div>

        {isLoading ? (
          <div className="p-8 text-center text-xs text-slate-400">Loading authorized patients…</div>
        ) : approvedGrants.length === 0 ? (
          <div className="p-8 text-center text-xs text-slate-500">
            No active access grants yet. Request patient access from the patient directory.
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs border-collapse">
              <thead>
                <tr className="border-b border-slate-100 bg-slate-50/75 text-slate-500 font-semibold uppercase tracking-wider text-[11px]">
                  <th className="py-3 px-6">Patient</th>
                  <th className="py-3 px-6">Patient ID</th>
                  <th className="py-3 px-6">Granted</th>
                  <th className="py-3 px-6">Expires</th>
                  <th className="py-3 px-6 text-right">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 font-medium text-slate-700">
                {approvedGrants.slice(0, 8).map((grant) => (
                  <tr key={grant.id} className="hover:bg-slate-50/60 transition-colors">
                    <td className="py-4 px-6">
                      <p className="font-bold text-slate-900">{getAccessRequestPatientName(grant)}</p>
                      <p className="text-[11px] text-slate-400">{getAccessRequestPatientEmail(grant) || '—'}</p>
                    </td>
                    <td className="py-4 px-6 font-mono text-[11px] text-slate-500">{grant.patient_id}</td>
                    <td className="py-4 px-6">{formatDate(grant.created_at)}</td>
                    <td className="py-4 px-6">{formatDate(grant.expires_at)}</td>
                    <td className="py-4 px-6 text-right">
                      <div className="inline-flex items-center gap-3">
                        <Link
                          href={`/doctor/patients/${grant.patient_id}`}
                          className="font-semibold text-[#2E7D32] hover:text-[#1B5E20]"
                        >
                          View Chart
                        </Link>
                        <Link
                          href={`/doctor/encounters/new?patientId=${grant.patient_id}`}
                          className="font-semibold text-slate-500 hover:text-slate-800"
                        >
                          Start Encounter
                        </Link>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
