'use client';

import React, { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';

import {
  ArrowLeft,
  Activity,
  CheckCircle2,
  Lock,
  Stethoscope,
  Clock,
  UserCheck,
  AlertTriangle,
  Building2,
} from 'lucide-react';
import { useStore } from '@/lib/store';
import { encountersApi } from '@/lib/api/encounters';
import { Encounter, EncounterType } from '@/types/database';
import { Button } from '@/modules/core/ui/Button';
import { StatusBadge } from '@/modules/core/ui/StatusBadge';
import { EncounterTabs } from '@/modules/clinical-workspace/components/EncounterTabs';
import { WorkspaceTab } from '@/modules/clinical-workspace/types';
import { VitalsRecorder } from '@/modules/clinical-workspace/components/VitalsRecorder';
import { LabResultsForm } from '@/modules/clinical-workspace/components/LabResultsForm';
import { DiagnosisPicker } from '@/modules/clinical-workspace/components/DiagnosisPicker';
import { PrescriptionBuilder } from '@/modules/clinical-workspace/components/PrescriptionBuilder';
import { AppointmentScheduler } from '@/modules/clinical-workspace/components/AppointmentScheduler';
import { CloseEncounterModal } from '@/modules/clinical-workspace/components/CloseEncounterModal';
import { formatDateTime } from '@/modules/core/lib/utils';

export default function EncounterWorkspacePage() {
  const router = useRouter();
  const params = useParams();
  const encounterId = (params?.encounterId as string) || '';

  const { encounters, closeEncounter } = useStore();
  const [activeTab, setActiveTab] = useState<WorkspaceTab>('vitals');
  const [showCloseModal, setShowCloseModal] = useState(false);
  const [liveEncounter, setLiveEncounter] = useState<Encounter | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;
    if (encounterId) {
      encountersApi
        .getById(encounterId)
        .then((res) => {
          if (!cancelled && res) {
            const enc = res.encounter || (res as unknown as Encounter);
            setLiveEncounter({
              id: enc.id,
              patient_id: enc.patient_id,
              patient_name: res.patient_name || enc.patient_name || 'Patient',
              clinic_id: enc.clinic_id || '',
              clinic_name: res.clinic_name || enc.clinic_name || 'Clinic',
              opened_by_doctor_id: enc.opened_by_doctor_id || enc.doctor_id || '',
              opened_by_doctor_name: res.doctor_name || enc.opened_by_doctor_name || 'Attending Physician',
              type: (enc.type as EncounterType) || 'outpatient',
              status: (enc.status as 'open' | 'closed') || 'open',
              notes: enc.notes || '',
              started_at: enc.started_at || enc.created_at || new Date().toISOString(),
              closed_at: enc.closed_at,
              vitals: res.vitals || enc.vitals || [],
              labs: res.labs || enc.labs || [],
              diagnoses: res.diagnoses || enc.diagnoses || [],
              prescriptions: res.prescriptions || enc.prescriptions || [],
            });
            setIsLoading(false);

          }
        })
        .catch(() => {
          if (!cancelled) setIsLoading(false);
        });
    }
    return () => {
      cancelled = true;
    };
  }, [encounterId]);

  const encounter = liveEncounter || encounters.find((e) => e.id === encounterId);

  if (!encounter && isLoading) {
    return (
      <div className="p-12 text-center bg-white rounded-3xl border border-slate-200">
        <div className="w-8 h-8 border-3 border-emerald-600 border-t-transparent rounded-full animate-spin mx-auto mb-3" />
        <p className="text-xs text-slate-500">Loading clinical encounter chart from backend...</p>
      </div>
    );
  }

  if (!encounter) {
    return (
      <div className="p-8 text-center bg-white rounded-3xl border border-slate-200">
        <h3 className="text-base font-bold text-slate-900">Encounter Session Not Found</h3>
        <p className="text-xs text-slate-500 mt-1">The requested clinical encounter ID does not exist.</p>
        <Button className="mt-4" onClick={() => router.push('/doctor')}>
          Return to Doctor Workspace
        </Button>
      </div>
    );
  }

  const isClosed = encounter.status === 'closed';

  const handleConfirmClose = async () => {
    await closeEncounter(encounter.id);
    setLiveEncounter((prev) => (prev ? { ...prev, status: 'closed', closed_at: new Date().toISOString() } : prev));
    setShowCloseModal(false);
  };


  return (
    <div className="space-y-6">
      {/* Workspace Header */}
      <div className="bg-white rounded-3xl border border-slate-200 shadow-xs p-6 flex flex-wrap items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={() => router.push('/doctor')}
            className="p-2 rounded-xl text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>

          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-xl font-bold text-slate-900">{encounter.patient_name}</h1>
              <StatusBadge status={encounter.status} />
              <span className="text-[11px] font-mono uppercase px-2 py-0.5 bg-slate-100 text-slate-700 rounded-md font-semibold">
                {encounter.type}
              </span>
            </div>
            <p className="text-xs text-slate-500 mt-0.5">
              Encounter ID: {encounter.id} • Opened: {formatDateTime(encounter.started_at)} • Facility: {encounter.clinic_name}
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2.5">
          <Link href={`/doctor/patients/${encounter.patient_id}`}>
            <Button size="sm" variant="outline">
              View Longitudinal Chart
            </Button>
          </Link>

          {!isClosed && (
            <Button
              size="sm"
              variant="brand"
              onClick={() => setShowCloseModal(true)}
              leftIcon={<Lock className="w-3.5 h-3.5" />}
            >
              Sign & Seal Encounter
            </Button>
          )}
        </div>
      </div>

      {/* Navigation Tabs */}
      <EncounterTabs
        activeTab={activeTab}
        onTabChange={setActiveTab}
        encounter={encounter}
      />

      {/* Tab Contents */}
      {activeTab === 'vitals' && (
        <div className="space-y-6">
          {!isClosed && <VitalsRecorder encounter={encounter} />}

          {/* Current recorded vitals list */}
          {encounter.vitals && encounter.vitals.length > 0 && (
            <div className="bg-white rounded-3xl border border-slate-200 p-6 space-y-4 shadow-xs">
              <h3 className="text-sm font-bold text-slate-900">Recorded Vitals for this Encounter</h3>
              <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-3">
                {encounter.vitals.map((vit) => (
                  <div key={vit.id} className="p-4 rounded-2xl bg-slate-50 border border-slate-100 text-xs space-y-1">
                    <p className="text-slate-500 font-mono text-[10px]">{formatDateTime(vit.recorded_at)}</p>
                    <p className="text-base font-bold text-slate-900">
                      {vit.systolic_bp}/{vit.diastolic_bp} <span className="text-xs font-normal text-slate-500">mmHg</span>
                    </p>
                    <p className="text-slate-600">Pulse: <strong>{vit.pulse} bpm</strong> • SpO2: <strong>{vit.spo2}%</strong></p>
                    {vit.temperature && <p className="text-slate-600">Temp: {vit.temperature}°C</p>}
                    {vit.notes && <p className="text-[11px] text-slate-500 italic mt-1">&ldquo;{vit.notes}&rdquo;</p>}
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      )}

      {activeTab === 'labs' && (
        <div className="space-y-6">
          {!isClosed && <LabResultsForm encounter={encounter} />}

          {encounter.labs && encounter.labs.length > 0 && (
            <div className="bg-white rounded-3xl border border-slate-200 p-6 space-y-4 shadow-xs">
              <h3 className="text-sm font-bold text-slate-900">Attached Laboratory Investigations</h3>
              <div className="space-y-3">
                {encounter.labs.map((lab) => (
                  <div key={lab.id} className="p-4 rounded-2xl bg-slate-50 border border-slate-100 flex items-start justify-between text-xs">
                    <div className="space-y-1">
                      <div className="flex items-center gap-2">
                        <span className="font-bold text-slate-900">{lab.test_name}</span>
                        <StatusBadge status={lab.flag} />
                      </div>
                      <p className="text-slate-700 font-medium">{lab.summary_notes}</p>
                      {lab.measurements && <p className="text-[11px] font-mono text-slate-500">{lab.measurements}</p>}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      )}

      {activeTab === 'diagnoses' && (
        <div className="space-y-6">
          {!isClosed && <DiagnosisPicker encounter={encounter} />}

          {encounter.diagnoses && encounter.diagnoses.length > 0 && (
            <div className="bg-white rounded-3xl border border-slate-200 p-6 space-y-4 shadow-xs">
              <h3 className="text-sm font-bold text-slate-900">Registered Diagnoses</h3>
              <div className="space-y-3">
                {encounter.diagnoses.map((dx) => (
                  <div key={dx.id} className="p-4 rounded-2xl bg-slate-50 border border-slate-100 flex items-center justify-between text-xs">
                    <div>
                      <p className="font-bold text-slate-900">
                        {dx.icd_code && <span className="font-mono text-[#2E7D32] mr-2">[{dx.icd_code}]</span>}
                        {dx.diagnosis_text}
                      </p>
                      {dx.notes && <p className="text-slate-500 text-[11px] mt-0.5">{dx.notes}</p>}
                    </div>
                    <span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-slate-200 text-slate-700 uppercase">
                      {dx.diagnosis_type}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      )}

      {activeTab === 'prescriptions' && (
        <div className="space-y-6">
          {!isClosed && <PrescriptionBuilder encounter={encounter} />}

          {encounter.prescriptions && encounter.prescriptions.length > 0 && (
            <div className="bg-white rounded-3xl border border-slate-200 p-6 space-y-4 shadow-xs">
              <h3 className="text-sm font-bold text-slate-900">Authorized E-Prescriptions</h3>
              <div className="space-y-3">
                {encounter.prescriptions.flatMap((rx) => rx.items || []).map((item) => (
                  <div key={item.id} className="p-4 rounded-2xl bg-[#E8F5E9]/50 border border-[#C8E6C9] flex items-center justify-between text-xs text-[#1B5E20]">
                    <div>
                      <p className="font-bold text-slate-900">
                        {item.medication_name} — {item.dose}
                      </p>
                      <p className="text-slate-600 mt-0.5">
                        {item.frequency} • Route: {item.route} • Duration: {item.duration}
                      </p>
                      {item.instructions && (
                        <p className="text-[11px] text-slate-500 mt-0.5">Instructions: {item.instructions}</p>
                      )}
                    </div>
                    <StatusBadge status="active" />
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      )}

      {activeTab === 'appointment' && (
        <div className="space-y-6">
          {!isClosed && <AppointmentScheduler encounter={encounter} />}
        </div>
      )}

      {activeTab === 'summary' && (
        <div className="bg-white rounded-3xl border border-slate-200 p-8 space-y-6 shadow-xs">
          <div className="flex items-center justify-between border-b border-slate-100 pb-4">
            <div>
              <h2 className="text-lg font-bold text-slate-900">Encounter Record Audit Summary</h2>
              <p className="text-xs text-slate-500">
                Authoring Physician: {encounter.opened_by_doctor_name} • Facility: {encounter.clinic_name}
              </p>
            </div>
            <StatusBadge status={encounter.status} />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 text-xs">
            <div className="space-y-3">
              <h4 className="font-bold text-slate-800 uppercase text-[11px]">Clinical Diagnoses</h4>
              {encounter.diagnoses?.length ? (
                <ul className="space-y-1.5 text-slate-700">
                  {encounter.diagnoses.map((d) => (
                    <li key={d.id} className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 rounded-full bg-[#388E3C]" />
                      <strong>{d.icd_code || 'DX'}</strong> — {d.diagnosis_text} ({d.diagnosis_type})
                    </li>
                  ))}
                </ul>
              ) : (
                <p className="text-slate-400 italic">No diagnoses registered</p>
              )}
            </div>

            <div className="space-y-3">
              <h4 className="font-bold text-slate-800 uppercase text-[11px]">Authorized Prescriptions</h4>
              {encounter.prescriptions?.flatMap((rx) => rx.items || []).length ? (
                <ul className="space-y-1.5 text-slate-700">
                  {encounter.prescriptions.flatMap((rx) => rx.items || []).map((rx) => (
                    <li key={rx.id} className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 rounded-full bg-[#388E3C]" />
                      <strong>{rx.medication_name}</strong> {rx.dose} ({rx.frequency})
                    </li>
                  ))}
                </ul>
              ) : (
                <p className="text-slate-400 italic">No prescriptions added</p>
              )}
            </div>
          </div>

          {!isClosed ? (
            <div className="pt-4 border-t border-slate-100 flex items-center justify-end">
              <Button
                variant="brand"
                onClick={() => setShowCloseModal(true)}
                leftIcon={<Lock className="w-4 h-4" />}
              >
                Sign & Finalize Encounter
              </Button>
            </div>
          ) : (
            <div className="p-4 rounded-2xl bg-[#E8F5E9] border border-[#C8E6C9] text-xs text-[#1B5E20] flex items-center gap-2 font-semibold">
              <CheckCircle2 className="w-4 h-4 text-[#2E7D32]" />
              This clinical encounter is sealed and signed in the patient&apos;s longitudinal health record.
            </div>
          )}
        </div>
      )}

      {showCloseModal && (
        <CloseEncounterModal
          isOpen={showCloseModal}
          onClose={() => setShowCloseModal(false)}
          onConfirm={handleConfirmClose}
          encounter={encounter}
        />
      )}
    </div>
  );
}
