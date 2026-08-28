'use client';

import React, { useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { ArrowLeft, PlusCircle, Activity, FileText, FlaskConical, Pill } from 'lucide-react';
import { useStore } from '@/lib/store';
import { Button } from '@/modules/core/ui/Button';
import { PatientProfileCard } from '@/modules/patient-records/components/PatientProfileCard';
import { VitalsTrendChart } from '@/modules/patient-records/components/VitalsTrendChart';
import { Timeline } from '@/modules/patient-records/components/Timeline';
import { LabHistoryList } from '@/modules/patient-records/components/LabHistoryList';
import { MedicationList } from '@/modules/patient-records/components/MedicationList';

export default function PatientChartDetailPage() {
  const router = useRouter();
  const params = useParams();
  const patientId = (params?.patientId as string) || '';

  const { patients } = useStore();
  const [activeTab, setActiveTab] = useState<'timeline' | 'vitals' | 'labs' | 'medications'>('timeline');

  const patient = patients.find((p) => p.id === patientId);

  if (!patient) {
    return (
      <div className="p-8 text-center bg-white rounded-3xl border border-slate-200">
        <h3 className="text-base font-bold text-slate-900">Patient Record Not Found</h3>
        <Button className="mt-4" onClick={() => router.push('/doctor/patients')}>
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
              {patient.first_name} {patient.last_name} — Longitudinal Medical Chart
            </h1>
            <p className="text-xs text-slate-500">Cross-facility longitudinal health records & encrypted audit trail</p>
          </div>
        </div>

        <div>
          <Link href={`/doctor/encounters/new?patientId=${patient.id}`}>
            <Button size="sm" leftIcon={<PlusCircle className="w-4 h-4" />}>
              Start Encounter
            </Button>
          </Link>
        </div>
      </div>

      {/* Patient Profile Card */}
      <PatientProfileCard patient={patient} />

      {/* Longitudinal Chart View Tabs */}
      <div className="flex items-center gap-2 p-1.5 bg-slate-100/80 rounded-2xl border border-slate-200/80">
        <button
          type="button"
          onClick={() => setActiveTab('timeline')}
          className={`flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-semibold transition-all cursor-pointer ${activeTab === 'timeline'
            ? 'bg-white text-[#1B5E20] shadow-xs border border-slate-200/80'
            : 'text-slate-600 hover:text-slate-900'
            }`}
        >
          <FileText className="w-4 h-4 text-[#2E7D32]" />
          <span>History</span>
        </button>

        {/* <button
          type="button"
          onClick={() => setActiveTab('vitals')}
          className={`flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-semibold transition-all cursor-pointer ${
            activeTab === 'vitals'
              ? 'bg-white text-[#1B5E20] shadow-xs border border-slate-200/80'
              : 'text-slate-600 hover:text-slate-900'
          }`}
        >
          <Activity className="w-4 h-4 text-[#2E7D32]" />
          <span>Vitals Trends (BP/Pulse)</span>
        </button> */}

        {/* <button
          type="button"
          onClick={() => setActiveTab('labs')}
          className={`flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-semibold transition-all cursor-pointer ${activeTab === 'labs'
              ? 'bg-white text-[#1B5E20] shadow-xs border border-slate-200/80'
              : 'text-slate-600 hover:text-slate-900'
            }`}
        >
          <FlaskConical className="w-4 h-4 text-[#2E7D32]" />
          <span>Diagnostic Labs</span>
        </button> */}

        {/* <button
          type="button"
          onClick={() => setActiveTab('medications')}
          className={`flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-semibold transition-all cursor-pointer ${activeTab === 'medications'
              ? 'bg-white text-[#1B5E20] shadow-xs border border-slate-200/80'
              : 'text-slate-600 hover:text-slate-900'
            }`}
        >
          <Pill className="w-4 h-4 text-[#2E7D32]" />
          <span>Prescriptions & Meds</span>
        </button> */}
      </div>

      {/* Tab Panels */}
      {activeTab === 'timeline' && <Timeline patientId={patient.id} />}
      {activeTab === 'vitals' && <VitalsTrendChart patientId={patient.id} />}
      {activeTab === 'labs' && <LabHistoryList patientId={patient.id} />}
      {activeTab === 'medications' && <MedicationList patientId={patient.id} />}
    </div>
  );
}
