'use client';

import React, { useCallback, useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { ArrowLeft, PlusCircle, Activity, FileText, FlaskConical, Pill } from 'lucide-react';
import { useAuth } from '@/modules/core/context/AuthContext';
import { accessRequestsApi } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api/client';
import {
  AccessRequest,
  getAccessRequestPatientName,
  getAccessRequestPatientEmail,
} from '@/types/database';
import { Button } from '@/modules/core/ui/Button';
import { PatientProfileCard, PatientIdentity } from '@/modules/patient-records/components/PatientProfileCard';
import { VitalsTrendChart } from '@/modules/patient-records/components/VitalsTrendChart';
import { Timeline } from '@/modules/patient-records/components/Timeline';
import { LabHistoryList } from '@/modules/patient-records/components/LabHistoryList';
import { MedicationList } from '@/modules/patient-records/components/MedicationList';

type ChartTab = 'timeline' | 'vitals' | 'labs' | 'medications';

const TABS: { id: ChartTab; label: string; icon: React.ReactNode }[] = [
  { id: 'timeline', label: 'History', icon: <FileText className="w-4 h-4 text-[#2E7D32]" /> },
  { id: 'vitals', label: 'Vitals Trends', icon: <Activity className="w-4 h-4 text-[#2E7D32]" /> },
  { id: 'labs', label: 'Diagnostic Labs', icon: <FlaskConical className="w-4 h-4 text-[#2E7D32]" /> },
  { id: 'medications', label: 'Prescriptions & Meds', icon: <Pill className="w-4 h-4 text-[#2E7D32]" /> },
];

function identityFromGrant(grant: AccessRequest): PatientIdentity {
  const [first, ...rest] = getAccessRequestPatientName(grant).split(' ');
  return {
    id: grant.patient_id,
    first_name: grant.patient?.first_name || grant.first_name || first || 'Patient',
    last_name: grant.patient?.last_name || grant.last_name || rest.join(' '),
    email: getAccessRequestPatientEmail(grant),
  };
}

export default function PatientChartDetailPage() {
  const router = useRouter();
  const params = useParams();
  const patientId = (params?.patientId as string) || '';

  const { currentUser, isReady } = useAuth();
  const clinicId = currentUser?.clinic_id ?? null;

  const [identity, setIdentity] = useState<PatientIdentity | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<ChartTab>('timeline');

  const loadIdentity = useCallback(async () => {
    if (!clinicId) {
      setIsLoading(false);
      setError('Your account is not affiliated with a clinic.');
      return;
    }
    setIsLoading(true);
    setError(null);
    try {
      const res = await accessRequestsApi.listRequests(clinicId, 'approved');
      const grant = (res.access_requests || []).find((r) => r.patient_id === patientId);
      if (!grant) {
        setIdentity(null);
        setError('Your clinic does not hold an active access grant for this patient.');
      } else {
        setIdentity(identityFromGrant(grant));
      }
    } catch (err) {
      setError(getApiErrorMessage(err, 'Failed to load the patient chart.'));
    } finally {
      setIsLoading(false);
    }
  }, [clinicId, patientId]);

  useEffect(() => {
    if (isReady) loadIdentity();
  }, [isReady, loadIdentity]);

  if (isLoading || !isReady) {
    return (
      <div className="p-12 text-center bg-white rounded-3xl border border-slate-200 text-xs text-slate-500">
        Loading patient chart…
      </div>
    );
  }

  if (!identity) {
    return (
      <div className="p-8 text-center bg-white rounded-3xl border border-slate-200 space-y-3">
        <h3 className="text-base font-bold text-slate-900">Patient Chart Unavailable</h3>
        <p className="text-xs text-slate-500">{error || 'Patient record not found.'}</p>
        <Button className="mt-2" onClick={() => router.push('/doctor/patients')}>
          Return to Patients
        </Button>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={() => router.push('/doctor/patients')}
            className="p-2 rounded-xl text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <h1 className="text-xl font-bold text-slate-900">
              {identity.first_name} {identity.last_name} — Longitudinal Medical Chart
            </h1>
            <p className="text-xs text-slate-500">Cross-facility longitudinal health records &amp; encrypted audit trail</p>
          </div>
        </div>

        <div>
          <Link href={`/doctor/encounters/new?patientId=${identity.id}`}>
            <Button size="sm" leftIcon={<PlusCircle className="w-4 h-4" />}>
              Start Encounter
            </Button>
          </Link>
        </div>
      </div>

      <PatientProfileCard patient={identity} />

      <div className="flex flex-wrap items-center gap-2 p-1.5 bg-slate-100/80 rounded-2xl border border-slate-200/80">
        {TABS.map((tab) => (
          <button
            key={tab.id}
            type="button"
            onClick={() => setActiveTab(tab.id)}
            className={`flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-semibold transition-all cursor-pointer ${
              activeTab === tab.id
                ? 'bg-white text-[#1B5E20] shadow-xs border border-slate-200/80'
                : 'text-slate-600 hover:text-slate-900'
            }`}
          >
            {tab.icon}
            <span>{tab.label}</span>
          </button>
        ))}
      </div>

      {activeTab === 'timeline' && <Timeline patientId={identity.id} />}
      {activeTab === 'vitals' && <VitalsTrendChart patientId={identity.id} />}
      {activeTab === 'labs' && <LabHistoryList patientId={identity.id} />}
      {activeTab === 'medications' && <MedicationList patientId={identity.id} />}
    </div>
  );
}
