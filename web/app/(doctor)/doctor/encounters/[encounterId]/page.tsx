'use client';

import React, { useState, useEffect, useCallback } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';

import {
  ArrowLeft,
  CheckCircle2,
  Lock,
  AlertCircle,
} from 'lucide-react';
import { encountersApi } from '@/lib/api/encounters';
import { accessRequestsApi } from '@/lib/api/access-requests';
import { prescriptionsApi } from '@/lib/api/prescriptions';
import { getApiErrorMessage } from '@/lib/api/client';
import { closeEncounterAction } from '@/modules/clinical-workspace/actions/startEncounter';
import { mapAggregatedEncounter } from '@/modules/clinical-workspace/lib/encounterMappers';
import { Encounter, EncounterStatus } from '@/types/database';
import { Button } from '@/modules/core/ui/Button';
import { StatusBadge } from '@/modules/core/ui/StatusBadge';
import { EncounterTabs } from '@/modules/clinical-workspace/components/EncounterTabs';
import { WorkspaceTab } from '@/modules/clinical-workspace/types';
import { VitalsRecorder } from '@/modules/clinical-workspace/components/VitalsRecorder';
import { LabResultsForm } from '@/modules/clinical-workspace/components/LabResultsForm';
import { DiagnosisPicker } from '@/modules/clinical-workspace/components/DiagnosisPicker';
import { PrescriptionBuilder } from '@/modules/clinical-workspace/components/PrescriptionBuilder';
import { AppointmentScheduler } from '@/modules/clinical-workspace/components/AppointmentScheduler';
import { MedicalHistoryViewer } from '@/modules/clinical-workspace/components/MedicalHistoryViewer';
import { CloseEncounterModal } from '@/modules/clinical-workspace/components/CloseEncounterModal';
import { ClinicalEvaluationForm } from '@/modules/clinical-workspace/components/ClinicalEvaluationForm';
import { formatDateTime } from '@/modules/core/lib/utils';

export default function EncounterWorkspacePage() {
  const router = useRouter();
  const params = useParams();
  const encounterId = (params?.encounterId as string) || '';

  const [activeTab, setActiveTab] = useState<WorkspaceTab>('evaluation');
  const [showCloseModal, setShowCloseModal] = useState(false);
  const [encounter, setEncounter] = useState<Encounter | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [closeError, setCloseError] = useState<string | null>(null);
  const [isClosing, setIsClosing] = useState(false);
  const [deactivatingRxId, setDeactivatingRxId] = useState<string | null>(null);

  const handleDeactivatePrescription = async (prescriptionId: string) => {
    setDeactivatingRxId(prescriptionId);
    try {
      await prescriptionsApi.deactivate(prescriptionId);
      await fetchEncounter();
    } catch (err) {
      setLoadError(getApiErrorMessage(err, 'Failed to deactivate prescription.'));
    } finally {
      setDeactivatingRxId(null);
    }
  };

  const fetchEncounter = useCallback(async () => {
    if (!encounterId) return;
    try {
      const res = await encountersApi.getById(encounterId);
      setEncounter((prev) => mapAggregatedEncounter(res, prev ? { type: prev.type } : {}));
      setLoadError(null);
    } catch (err) {
      setLoadError(getApiErrorMessage(err, 'Failed to load the clinical encounter.'));
    } finally {
      setIsLoading(false);
    }
  }, [encounterId]);

  useEffect(() => {
    fetchEncounter();
  }, [fetchEncounter]);

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
        <h3 className="text-base font-bold text-slate-900">Encounter Session Unavailable</h3>
        <p className="text-xs text-slate-500 mt-1">
          {loadError || 'The requested clinical encounter could not be loaded.'}
        </p>
        <div className="mt-4 flex items-center justify-center gap-2">
          <Button variant="outline" onClick={fetchEncounter}>
            Retry
          </Button>
          <Button onClick={() => router.push('/doctor')}>Return to Doctor Workspace</Button>
        </div>
      </div>
    );
  }

  const isClosed = encounter.status === 'closed';

  const handleConfirmClose = async () => {
    if (isClosing) return;
    setCloseError(null);
    setIsClosing(true);

    let closed: { status: EncounterStatus; ended_at: string | null };
    try {
      closed = await closeEncounterAction(encounter.id);
    } catch (err) {
      setCloseError(getApiErrorMessage(err, 'Failed to close the encounter. Please try again.'));
      setIsClosing(false);
      return;
    }

    // Apply the backend's own close response rather than re-reading the
    // encounter: the grant is revoked next, after which AccessGuard refuses
    // GET /encounters/:id for this doctor.
    setEncounter((prev) =>
      prev ? { ...prev, status: closed.status, ended_at: closed.ended_at, closed_at: closed.ended_at } : prev
    );
    setShowCloseModal(false);

    // Clinic policy: closing the encounter terminates the clinic's access to
    // this patient's records. A failure here must not undo the close.
    if (encounter.clinic_id) {
      try {
        const res = await accessRequestsApi.listRequests(encounter.clinic_id, 'approved');
        const activeGrant = res.access_requests?.find((r) => r.patient_id === encounter.patient_id);
        if (activeGrant) {
          await accessRequestsApi.revokeRequest(encounter.clinic_id, activeGrant.id);
        }
      } catch (err) {
        setCloseError(
          getApiErrorMessage(
            err,
            'The encounter was closed, but revoking the patient access grant failed. Ask a clinic admin to revoke it.'
          )
        );
      }
    }

    setIsClosing(false);
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
              {encounter.type && (
                <span className="text-[11px] font-mono uppercase px-2 py-0.5 bg-slate-100 text-slate-700 rounded-md font-semibold">
                  {encounter.type}
                </span>
              )}
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

      {(closeError || loadError) && (
        <div className="p-4 rounded-2xl bg-rose-50 border border-rose-200 text-xs text-rose-700 flex items-start gap-2.5">
          <AlertCircle className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
          <span>{closeError || loadError}</span>
        </div>
      )}

      {isClosed && (
        <div className="p-4 rounded-2xl bg-slate-50 border border-slate-200 text-xs text-slate-600 flex items-start gap-2.5">
          <Lock className="w-4 h-4 text-slate-500 shrink-0 mt-0.5" />
          <span>
            This encounter is sealed. Your clinic&apos;s access grant for this patient has been revoked, so
            these records are no longer editable or retrievable from here.
          </span>
        </div>
      )}

      {/* Navigation Tabs */}
      <EncounterTabs
        activeTab={activeTab}
        onTabChange={setActiveTab}
        encounter={encounter}
      />

      {/* Tab Contents */}
      {activeTab === 'evaluation' && (
        <div className="space-y-6">
          <ClinicalEvaluationForm
            encounterId={encounter.id}
            isClosed={isClosed}
            onSaved={fetchEncounter}
          />
        </div>
      )}

      {activeTab === 'vitals' && (
        <div className="space-y-6">
          {!isClosed && <VitalsRecorder encounter={encounter} onSaved={fetchEncounter} />}

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
          {!isClosed && <LabResultsForm encounter={encounter} onSaved={fetchEncounter} />}

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
          {!isClosed && <DiagnosisPicker encounter={encounter} onSaved={fetchEncounter} />}

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
          {!isClosed && <PrescriptionBuilder encounter={encounter} onSaved={fetchEncounter} />}

          {encounter.prescriptions && encounter.prescriptions.length > 0 && (
            <div className="bg-white rounded-3xl border border-slate-200 p-6 space-y-4 shadow-xs">
              <h3 className="text-sm font-bold text-slate-900">Authorized E-Prescriptions</h3>
              <div className="space-y-3">
                {encounter.prescriptions.map((rx) => {
                  return (
                    <div key={rx.id} className="space-y-2">
                      {(rx.items || []).map((item) => {
                        const isItemActive =
                          item.status === 'active' || (!item.status && !item.deactivated_at);
                        return (
                          <div
                            key={item.id}
                            className={`p-4 rounded-2xl border flex items-center justify-between text-xs ${
                              isItemActive
                                ? 'bg-[#E8F5E9]/50 border-[#C8E6C9] text-[#1B5E20]'
                                : 'bg-slate-50 border-slate-200 text-slate-500'
                            }`}
                          >
                            <div>
                              <div className="flex items-center gap-2">
                                <p
                                  className={`font-bold ${
                                    isItemActive ? 'text-slate-900' : 'text-slate-500 line-through'
                                  }`}
                                >
                                  {item.medication_name} — {item.dose}
                                </p>
                                <StatusBadge status={isItemActive ? 'active' : 'deactivated'} />
                              </div>
                              <p className="text-slate-600 mt-0.5">
                                {item.frequency} • Route: {item.route} • Duration: {item.duration}
                              </p>
                              {item.instructions && (
                                <p className="text-[11px] text-slate-500 mt-0.5">
                                  Instructions: {item.instructions}
                                </p>
                              )}
                              {item.deactivated_at && (
                                <p className="text-[10px] text-slate-400 mt-0.5">
                                  Deactivated on {formatDateTime(item.deactivated_at)}
                                </p>
                              )}
                            </div>
                            {!isClosed && isItemActive && (
                              <Button
                                size="sm"
                                variant="outline"
                                onClick={() => handleDeactivatePrescription(rx.id)}
                                disabled={deactivatingRxId === rx.id}
                                className="text-rose-600 hover:text-rose-700 hover:bg-rose-50 border-rose-200 cursor-pointer text-xs"
                              >
                                {deactivatingRxId === rx.id ? 'Deactivating…' : 'Cancel / Deactivate'}
                              </Button>
                            )}
                          </div>
                        );
                      })}
                    </div>
                  );
                })}
              </div>
            </div>
          )}
        </div>
      )}

      {activeTab === 'appointment' && (
        <div className="space-y-6">
          {!isClosed && <AppointmentScheduler encounter={encounter} onSaved={fetchEncounter} />}
        </div>
      )}

      {activeTab === 'history' && (
        <div className="space-y-6">
          <MedicalHistoryViewer encounterId={encounter.id} patientName={encounter.patient_name} />
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
          isConfirming={isClosing}
        />
      )}
    </div>
  );
}
