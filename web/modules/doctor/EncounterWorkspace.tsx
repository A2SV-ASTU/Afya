'use client';

import React, { useState } from 'react';
import { useStore } from '@/lib/store';
import { StatusBadge } from '@/components/ui/Badge';
import { ConfirmDialog } from '@/components/ui/Modal';
import {
  Stethoscope,
  Activity,
  FlaskConical,
  FileText,
  Pill,
  Calendar,
  Lock,
  Unlock,
  CheckCircle2,
  AlertTriangle,
  ArrowLeft,
  Clock,
  Plus,
  Trash2,
  Eye,
  Info,
  Building2,
  Heart,
  Save,
  Check,
} from 'lucide-react';
import {
  VitalSign,
  LabResult,
  Diagnosis,
  PrescriptionItem,
  PrescriptionItemStatus,
  DiagnosisType,
  LabFlag,
  LabCategory,
} from '@/types/database';

export function EncounterWorkspace() {
  const {
    encounters,
    patients,
    viewParams,
    addVitals,
    addLabResult,
    addDiagnosis,
    addPrescription,
    deactivatePrescriptionItem,
    addEncounterAppointment,
    closeEncounter,
    navigateTo,
  } = useStore();

  const encounterId = viewParams.encounterId || encounters[0]?.id;
  const encounter = encounters.find((e) => e.id === encounterId) || encounters[0];
  const patient = patients.find((p) => p.id === encounter?.patient_id) || patients[0];

  const [activeTab, setActiveTab] = useState<'vitals' | 'labs' | 'diagnoses' | 'medications' | 'appointment'>('vitals');
  const [isCloseModalOpen, setIsCloseModalOpen] = useState(false);

  // --- Vitals Form State ---
  const [vitalsForm, setVitalsForm] = useState({
    systolic_bp: '124',
    diastolic_bp: '82',
    pulse: '74',
    spo2: '98',
    temperature: '36.8',
    blood_sugar: '5.4',
    respiratory_rate: '16',
    weight: '71.5',
    notes: 'Resting seated vitals taken after 5-minute calm period.',
  });

  // --- Labs Form State ---
  const [labForm, setLabForm] = useState({
    test_name: 'Lipid Profile (Serum)',
    category: 'Biochemistry' as LabCategory,
    measurements: 'Total: 4.8 mmol/L, HDL: 1.4 mmol/L, LDL: 2.8 mmol/L',
    summary_notes: 'Total cholesterol within target therapeutic range.',
    flag: 'normal' as LabFlag,
  });

  // --- Diagnosis Form State ---
  const [diagnosisForm, setDiagnosisForm] = useState({
    diagnosis_text: 'Essential (primary) hypertension',
    icd_code: 'I10',
    diagnosis_type: 'final' as DiagnosisType,
    notes: 'Well-controlled on current medication protocol.',
  });

  // --- Prescription Form State ---
  const [rxForm, setRxForm] = useState({
    medication_name: 'Amlodipine Besylate',
    dose: '5mg',
    route: 'Oral (PO)',
    frequency: 'Once daily (OD)',
    duration: '30 days',
    instructions: 'Take 1 tablet every morning with breakfast and water.',
  });

  // --- Appointment Form State ---
  const [aptForm, setAptForm] = useState(() => ({
    scheduled_at: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000).toISOString().slice(0, 16),
    notes: '2-week blood pressure follow-up and prescription refill review.',
  }));

  if (!encounter || !patient) {
    return (
      <div className="p-8 text-center">
        <p className="text-sm text-slate-500">Encounter not found.</p>
        <button
          onClick={() => navigateTo('doctor-dashboard')}
          className="mt-4 px-4 py-2 bg-slate-900 text-white rounded-lg text-xs"
        >
          Return to Dashboard
        </button>
      </div>
    );
  }

  const isOpen = encounter.status === 'open';

  // Handlers
  const handleAddVitals = (e: React.FormEvent) => {
    e.preventDefault();
    if (!isOpen) return;

    addVitals(encounter.id, {
      systolic_bp: vitalsForm.systolic_bp ? Number(vitalsForm.systolic_bp) : undefined,
      diastolic_bp: vitalsForm.diastolic_bp ? Number(vitalsForm.diastolic_bp) : undefined,
      pulse: vitalsForm.pulse ? Number(vitalsForm.pulse) : undefined,
      spo2: vitalsForm.spo2 ? Number(vitalsForm.spo2) : undefined,
      temperature: vitalsForm.temperature ? Number(vitalsForm.temperature) : undefined,
      blood_sugar: vitalsForm.blood_sugar ? Number(vitalsForm.blood_sugar) : undefined,
      respiratory_rate: vitalsForm.respiratory_rate ? Number(vitalsForm.respiratory_rate) : undefined,
      weight: vitalsForm.weight ? Number(vitalsForm.weight) : undefined,
      notes: vitalsForm.notes,
    });
  };

  const handleAddLab = (e: React.FormEvent) => {
    e.preventDefault();
    if (!isOpen || !labForm.test_name) return;

    addLabResult(encounter.id, labForm);
  };

  const handleAddDiagnosis = (e: React.FormEvent) => {
    e.preventDefault();
    if (!isOpen || !diagnosisForm.diagnosis_text) return;

    addDiagnosis(encounter.id, diagnosisForm);
  };

  const handleAddPrescription = (e: React.FormEvent) => {
    e.preventDefault();
    if (!isOpen || !rxForm.medication_name) return;

    addPrescription(encounter.id, {
      medication_name: rxForm.medication_name,
      dose: rxForm.dose,
      route: rxForm.route,
      frequency: rxForm.frequency,
      duration: rxForm.duration,
      instructions: rxForm.instructions,
    });
  };

  const handleSaveAppointment = (e: React.FormEvent) => {
    e.preventDefault();
    if (!isOpen || !aptForm.scheduled_at) return;

    addEncounterAppointment(encounter.id, {
      scheduled_at: aptForm.scheduled_at,
      notes: aptForm.notes,
    });
  };

  const handleConfirmClose = () => {
    closeEncounter(encounter.id);
  };

  return (
    <div id="encounter-workspace-page" className="p-4 md:p-8 max-w-7xl mx-auto space-y-6">
      {/* Top Bar Navigation */}
      <div className="flex items-center justify-between">
        <button
          id="back-to-history-btn"
          type="button"
          onClick={() => navigateTo('doctor-patient-history', { patientId: patient.id })}
          className="inline-flex items-center gap-2 text-xs font-semibold text-slate-600 hover:text-slate-900 transition-colors cursor-pointer"
        >
          <ArrowLeft className="w-4 h-4" />
          <span>Patient Timeline ({patient.first_name} {patient.last_name})</span>
        </button>

        {isOpen ? (
          <button
            id="close-encounter-btn"
            type="button"
            onClick={() => setIsCloseModalOpen(true)}
            className="inline-flex items-center gap-2 px-4 py-2 bg-emerald-50 hover:bg-emerald-100 text-emerald-800 border-2 border-emerald-500 rounded-xl text-xs font-bold shadow-xs transition-all cursor-pointer"
          >
            <Lock className="w-4 h-4 text-emerald-600" />
            <span>Sign Off & Close Encounter</span>
          </button>
        ) : (
          <div className="inline-flex items-center gap-2 px-3 py-1.5 bg-slate-100 text-slate-700 border border-slate-300 rounded-xl text-xs font-semibold">
            <Lock className="w-3.5 h-3.5 text-slate-500" />
            <span>Signed Off & Immutable</span>
          </div>
        )}
      </div>

      {/* Header Banner */}
      <div
        className={`p-6 rounded-2xl border transition-all shadow-md ${
          isOpen
            ? 'bg-gradient-to-r from-slate-900 via-slate-800 to-emerald-950 text-white border-slate-800'
            : 'bg-slate-900 text-white border-slate-800'
        }`}
      >
        <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-6">
          <div className="space-y-2">
            <div className="flex flex-wrap items-center gap-2">
              <span className="px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider bg-emerald-500/20 text-emerald-300 border border-emerald-500/30">
                {encounter.type} Consultation
              </span>
              <StatusBadge variant={isOpen ? 'open' : 'closed'}>
                {isOpen ? 'IN PROGRESS (OPEN)' : 'PERMANENTLY SEALED (CLOSED)'}
              </StatusBadge>
              <span className="text-xs text-slate-400 font-mono">
                ID: {encounter.id.slice(0, 8)}
              </span>
            </div>

            <div className="flex items-center gap-3">
              <h1 className="text-2xl font-bold tracking-tight text-white">
                {patient.first_name} {patient.last_name}
              </h1>
              <span className="text-xs text-slate-300">
                (DOB: {patient.date_of_birth} • {patient.sex} • Blood: {patient.blood_group})
              </span>
            </div>

            <p className="text-xs text-slate-300">
              Attending Physician: <strong className="text-emerald-300">Dr. {encounter.opened_by_doctor_name}</strong> • Facility: {encounter.clinic_name}
            </p>
          </div>

          <div className="flex flex-col items-start lg:items-end gap-1.5 text-xs text-slate-300">
            <div className="flex items-center gap-2">
              <Clock className="w-4 h-4 text-emerald-400" />
              <span>Started: {new Date(encounter.started_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span>
            </div>
            {encounter.closed_at && (
              <span className="text-[11px] text-slate-400 font-mono">
                Sealed: {new Date(encounter.closed_at).toLocaleDateString()} {new Date(encounter.closed_at).toLocaleTimeString()}
              </span>
            )}
            {patient.allergies && patient.allergies.length > 0 && (
              <div className="flex items-center gap-1.5 mt-1">
                <span className="text-rose-400 font-bold text-[11px]">Allergies:</span>
                <span className="bg-rose-950/80 text-rose-300 border border-rose-800 px-2 py-0.5 rounded text-[10px] font-semibold">
                  {patient.allergies.join(', ')}
                </span>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Workspace Tabs */}
      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
        {/* Tab Navigation */}
        <div className="flex flex-wrap items-center border-b border-slate-200 bg-slate-50/70 p-1.5 gap-1">
          {[
            { id: 'vitals', label: '1. Vitals & Biometrics', icon: Activity, count: encounter.vitals?.length || 0 },
            { id: 'labs', label: '2. Lab Results', icon: FlaskConical, count: encounter.labs?.length || 0 },
            { id: 'diagnoses', label: '3. Diagnoses (ICD-10)', icon: FileText, count: encounter.diagnoses?.length || 0 },
            { id: 'medications', label: '4. Medications (Rx)', icon: Pill, count: encounter.prescriptions?.flatMap((r) => r.items).length || 0 },
            { id: 'appointment', label: '5. Follow-Up Booking', icon: Calendar, count: encounter.appointment ? 1 : 0 },
          ].map((tab) => {
            const Icon = tab.icon;
            const isSelected = activeTab === tab.id;
            return (
              <button
                key={tab.id}
                id={`tab-btn-${tab.id}`}
                type="button"
                onClick={() => setActiveTab(tab.id as typeof activeTab)}
                className={`flex items-center gap-2 px-4 py-2.5 rounded-xl text-xs font-bold transition-all cursor-pointer ${
                  isSelected
                    ? 'bg-white text-emerald-950 shadow-xs border border-slate-200/80'
                    : 'text-slate-600 hover:text-slate-900 hover:bg-slate-100/70'
                }`}
              >
                <Icon className={`w-4 h-4 ${isSelected ? 'text-emerald-600' : 'text-slate-400'}`} />
                <span>{tab.label}</span>
                {tab.count > 0 && (
                  <span
                    className={`px-1.5 py-0.2 rounded-full text-[10px] ${
                      isSelected ? 'bg-emerald-100 text-emerald-800' : 'bg-slate-200 text-slate-700'
                    }`}
                  >
                    {tab.count}
                  </span>
                )}
              </button>
            );
          })}
        </div>

        {/* Tab Content Panes */}
        <div className="p-6 md:p-8">
          {/* ===================== TAB 1: VITALS ===================== */}
          {activeTab === 'vitals' && (
            <div className="space-y-8 animate-in fade-in duration-150">
              {isOpen ? (
                <form onSubmit={handleAddVitals} className="p-6 rounded-2xl bg-slate-50 border border-slate-200/80 space-y-4">
                  <div className="flex items-center justify-between border-b border-slate-200 pb-3">
                    <h3 className="text-xs font-bold uppercase tracking-wider text-slate-800 flex items-center gap-2">
                      <Activity className="w-4 h-4 text-emerald-600" />
                      <span>Record Patient Vital Signs</span>
                    </h3>
                    <span className="text-[11px] text-slate-500">Live clinical charting</span>
                  </div>

                  <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 text-xs">
                    <div className="space-y-1">
                      <label className="font-semibold text-slate-700">BP Systolic (mmHg)</label>
                      <input
                        type="number"
                        value={vitalsForm.systolic_bp}
                        onChange={(e) => setVitalsForm({ ...vitalsForm, systolic_bp: e.target.value })}
                        placeholder="120"
                        className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-slate-900"
                      />
                    </div>
                    <div className="space-y-1">
                      <label className="font-semibold text-slate-700">BP Diastolic (mmHg)</label>
                      <input
                        type="number"
                        value={vitalsForm.diastolic_bp}
                        onChange={(e) => setVitalsForm({ ...vitalsForm, diastolic_bp: e.target.value })}
                        placeholder="80"
                        className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-slate-900"
                      />
                    </div>
                    <div className="space-y-1">
                      <label className="font-semibold text-slate-700">Pulse (bpm)</label>
                      <input
                        type="number"
                        value={vitalsForm.pulse}
                        onChange={(e) => setVitalsForm({ ...vitalsForm, pulse: e.target.value })}
                        placeholder="72"
                        className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-slate-900"
                      />
                    </div>
                    <div className="space-y-1">
                      <label className="font-semibold text-slate-700">Oxygen SpO2 (%)</label>
                      <input
                        type="number"
                        value={vitalsForm.spo2}
                        onChange={(e) => setVitalsForm({ ...vitalsForm, spo2: e.target.value })}
                        placeholder="98"
                        className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-slate-900"
                      />
                    </div>
                    <div className="space-y-1">
                      <label className="font-semibold text-slate-700">Temperature (°C)</label>
                      <input
                        type="number"
                        step="0.1"
                        value={vitalsForm.temperature}
                        onChange={(e) => setVitalsForm({ ...vitalsForm, temperature: e.target.value })}
                        placeholder="36.5"
                        className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-slate-900"
                      />
                    </div>
                    <div className="space-y-1">
                      <label className="font-semibold text-slate-700">Blood Sugar (mmol/L)</label>
                      <input
                        type="number"
                        step="0.1"
                        value={vitalsForm.blood_sugar}
                        onChange={(e) => setVitalsForm({ ...vitalsForm, blood_sugar: e.target.value })}
                        placeholder="5.4"
                        className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-slate-900"
                      />
                    </div>
                    <div className="space-y-1">
                      <label className="font-semibold text-slate-700">Resp Rate (/min)</label>
                      <input
                        type="number"
                        value={vitalsForm.respiratory_rate}
                        onChange={(e) => setVitalsForm({ ...vitalsForm, respiratory_rate: e.target.value })}
                        placeholder="16"
                        className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-slate-900"
                      />
                    </div>
                    <div className="space-y-1">
                      <label className="font-semibold text-slate-700">Weight (kg)</label>
                      <input
                        type="number"
                        step="0.1"
                        value={vitalsForm.weight}
                        onChange={(e) => setVitalsForm({ ...vitalsForm, weight: e.target.value })}
                        placeholder="70"
                        className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-slate-900"
                      />
                    </div>
                  </div>

                  <div className="space-y-1">
                    <label className="font-semibold text-slate-700 text-xs">Vitals Observation Notes</label>
                    <input
                      type="text"
                      value={vitalsForm.notes}
                      onChange={(e) => setVitalsForm({ ...vitalsForm, notes: e.target.value })}
                      placeholder="e.g. Patient rested, no distress noted."
                      className="w-full px-3 py-2 text-xs bg-white border border-slate-200 rounded-xl text-slate-900"
                    />
                  </div>

                  <div className="flex justify-end pt-2">
                    <button
                      id="save-vitals-btn"
                      type="submit"
                      className="inline-flex items-center gap-1.5 px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold cursor-pointer"
                    >
                      <Plus className="w-4 h-4" />
                      <span>Append Vital Signs</span>
                    </button>
                  </div>
                </form>
              ) : (
                <div className="p-4 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-600 flex items-center gap-2">
                  <Lock className="w-4 h-4 text-slate-500" />
                  <span>Encounter is closed. Vital signs are read-only and sealed.</span>
                </div>
              )}

              {/* Recorded Vitals Table */}
              <div className="space-y-3">
                <h4 className="text-xs font-bold uppercase tracking-wider text-slate-400">
                  Recorded Vital Signs in this Session ({encounter.vitals?.length || 0})
                </h4>

                {(!encounter.vitals || encounter.vitals.length === 0) ? (
                  <p className="text-xs text-slate-400 italic">No vitals logged yet for this visit.</p>
                ) : (
                  <div className="space-y-3">
                    {encounter.vitals.map((v) => (
                      <div key={v.id} className="p-4 rounded-xl bg-white border border-slate-200 shadow-2xs space-y-3 text-xs">
                        <div className="flex items-center justify-between border-b border-slate-100 pb-2">
                          <span className="font-mono text-[11px] text-slate-400">
                            Logged: {new Date(v.recorded_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' })}
                          </span>
                          <span className="text-emerald-700 font-bold text-[11px]">VERIFIED</span>
                        </div>

                        <div className="grid grid-cols-2 sm:grid-cols-4 md:grid-cols-8 gap-3 text-center">
                          <div className="p-2 bg-slate-50 rounded-lg">
                            <span className="text-[10px] text-slate-400 block">BP</span>
                            <span className="font-bold text-slate-900">{v.systolic_bp}/{v.diastolic_bp}</span>
                          </div>
                          <div className="p-2 bg-slate-50 rounded-lg">
                            <span className="text-[10px] text-slate-400 block">Pulse</span>
                            <span className="font-bold text-slate-900">{v.pulse} bpm</span>
                          </div>
                          <div className="p-2 bg-slate-50 rounded-lg">
                            <span className="text-[10px] text-slate-400 block">SpO2</span>
                            <span className="font-bold text-slate-900">{v.spo2}%</span>
                          </div>
                          <div className="p-2 bg-slate-50 rounded-lg">
                            <span className="text-[10px] text-slate-400 block">Temp</span>
                            <span className="font-bold text-slate-900">{v.temperature}°C</span>
                          </div>
                          <div className="p-2 bg-slate-50 rounded-lg">
                            <span className="text-[10px] text-slate-400 block">Glucose</span>
                            <span className="font-bold text-slate-900">{v.blood_sugar} mmol/L</span>
                          </div>
                          <div className="p-2 bg-slate-50 rounded-lg">
                            <span className="text-[10px] text-slate-400 block">Resp</span>
                            <span className="font-bold text-slate-900">{v.respiratory_rate}/min</span>
                          </div>
                          <div className="p-2 bg-slate-50 rounded-lg">
                            <span className="text-[10px] text-slate-400 block">Weight</span>
                            <span className="font-bold text-slate-900">{v.weight || '--'} kg</span>
                          </div>
                          <div className="p-2 bg-slate-50 rounded-lg">
                            <span className="text-[10px] text-slate-400 block">Status</span>
                            <span className="font-bold text-emerald-700">Stable</span>
                          </div>
                        </div>

                        {v.notes && <p className="text-slate-600 italic text-[11px]">Notes: &ldquo;{v.notes}&rdquo;</p>}
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
          )}

          {/* ===================== TAB 2: LABS ===================== */}
          {activeTab === 'labs' && (
            <div className="space-y-8 animate-in fade-in duration-150">
              {isOpen ? (
                <form onSubmit={handleAddLab} className="p-6 rounded-2xl bg-slate-50 border border-slate-200/80 space-y-4">
                  <div className="flex items-center justify-between border-b border-slate-200 pb-3">
                    <h3 className="text-xs font-bold uppercase tracking-wider text-slate-800 flex items-center gap-2">
                      <FlaskConical className="w-4 h-4 text-blue-600" />
                      <span>Order or Record Laboratory Investigation</span>
                    </h3>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-xs">
                    <div className="space-y-1 sm:col-span-2">
                      <label className="font-semibold text-slate-700">Test / Panel Name *</label>
                      <input
                        type="text"
                        required
                        value={labForm.test_name}
                        onChange={(e) => setLabForm({ ...labForm, test_name: e.target.value })}
                        placeholder="e.g. HbA1c, Complete Blood Count, Serum Creatinine"
                        className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                      />
                    </div>
                    <div className="space-y-1">
                      <label className="font-semibold text-slate-700">Category</label>
                      <select
                        value={labForm.category}
                        onChange={(e) => setLabForm({ ...labForm, category: e.target.value as LabCategory })}
                        className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                      >
                        <option value="Biochemistry">Biochemistry</option>
                        <option value="Hematology">Hematology</option>
                        <option value="Microbiology">Microbiology</option>
                        <option value="Imaging/Radiology">Imaging/Radiology</option>
                        <option value="Pathology">Pathology</option>
                        <option value="Other">Other</option>
                      </select>
                    </div>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-xs">
                    <div className="space-y-1 sm:col-span-2">
                      <label className="font-semibold text-slate-700">Measured Values & Units *</label>
                      <input
                        type="text"
                        required
                        value={labForm.measurements}
                        onChange={(e) => setLabForm({ ...labForm, measurements: e.target.value })}
                        placeholder="e.g. Total: 4.8 mmol/L, HDL: 1.4, LDL: 2.8"
                        className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                      />
                    </div>
                    <div className="space-y-1">
                      <label className="font-semibold text-slate-700">Clinical Flag</label>
                      <select
                        value={labForm.flag}
                        onChange={(e) => setLabForm({ ...labForm, flag: e.target.value as LabFlag })}
                        className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                      >
                        <option value="normal">Normal</option>
                        <option value="abnormal">Abnormal (Attention)</option>
                        <option value="critical">Critical (Urgent)</option>
                      </select>
                    </div>
                  </div>

                  <div className="space-y-1">
                    <label className="font-semibold text-slate-700 text-xs">Diagnostic Interpretation / Notes</label>
                    <input
                      type="text"
                      value={labForm.summary_notes}
                      onChange={(e) => setLabForm({ ...labForm, summary_notes: e.target.value })}
                      placeholder="Clinical impressions on result..."
                      className="w-full px-3 py-2 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                    />
                  </div>

                  <div className="flex justify-end pt-2">
                    <button
                      id="save-lab-btn"
                      type="submit"
                      className="inline-flex items-center gap-1.5 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl text-xs font-bold shadow-sm transition-colors cursor-pointer"
                    >
                      <Plus className="w-4 h-4" />
                      <span>Record Lab Result</span>
                    </button>
                  </div>
                </form>
              ) : (
                <div className="p-4 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-600 flex items-center gap-2">
                  <Lock className="w-4 h-4 text-slate-500" />
                  <span>Encounter is closed. Lab results are read-only.</span>
                </div>
              )}

              {/* Lab Results Table */}
              <div className="space-y-3">
                <h4 className="text-xs font-bold uppercase tracking-wider text-slate-400">
                  Lab Results in this Encounter ({encounter.labs?.length || 0})
                </h4>

                {(!encounter.labs || encounter.labs.length === 0) ? (
                  <p className="text-xs text-slate-400 italic">No lab investigations logged for this visit.</p>
                ) : (
                  <div className="overflow-x-auto rounded-2xl border border-slate-200">
                    <table className="w-full text-left text-xs text-slate-600">
                      <thead className="bg-slate-50 border-b border-slate-200 text-[11px] font-semibold text-slate-500 uppercase">
                        <tr>
                          <th className="py-3 px-4">Test Name & Category</th>
                          <th className="py-3 px-4">Measurements</th>
                          <th className="py-3 px-4">Flag</th>
                          <th className="py-3 px-4">Summary Notes</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-slate-100">
                        {encounter.labs.map((lab) => (
                          <tr key={lab.id} className="hover:bg-slate-50">
                            <td className="py-3 px-4">
                              <p className="font-bold text-slate-900">{lab.test_name}</p>
                              <span className="text-[10px] text-slate-400">{lab.category}</span>
                            </td>
                            <td className="py-3 px-4 font-bold text-slate-900">
                              {lab.measurements}
                            </td>
                            <td className="py-3 px-4">
                              <StatusBadge variant={lab.flag}>{lab.flag}</StatusBadge>
                            </td>
                            <td className="py-3 px-4 text-slate-600 text-[11px]">
                              {lab.summary_notes || '—'}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* ===================== TAB 3: DIAGNOSES ===================== */}
          {activeTab === 'diagnoses' && (
            <div className="space-y-8 animate-in fade-in duration-150">
              {isOpen ? (
                <form onSubmit={handleAddDiagnosis} className="p-6 rounded-2xl bg-slate-50 border border-slate-200/80 space-y-4">
                  <div className="flex items-center justify-between border-b border-slate-200 pb-3">
                    <h3 className="text-xs font-bold uppercase tracking-wider text-slate-800 flex items-center gap-2">
                      <FileText className="w-4 h-4 text-emerald-600" />
                      <span>Formulate Clinical Diagnosis & ICD-10 Coding</span>
                    </h3>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-xs">
                    <div className="space-y-1 sm:col-span-2">
                      <label className="font-semibold text-slate-700">Diagnosis Description *</label>
                      <input
                        type="text"
                        required
                        value={diagnosisForm.diagnosis_text}
                        onChange={(e) => setDiagnosisForm({ ...diagnosisForm, diagnosis_text: e.target.value })}
                        placeholder="e.g. Essential (primary) hypertension, Type 2 Diabetes"
                        className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-slate-900"
                      />
                    </div>
                    <div className="space-y-1">
                      <label className="font-semibold text-slate-700">ICD-10 Code</label>
                      <input
                        type="text"
                        value={diagnosisForm.icd_code}
                        onChange={(e) => setDiagnosisForm({ ...diagnosisForm, icd_code: e.target.value })}
                        placeholder="e.g. I10, E11.9, J06"
                        className="w-full px-3 py-2 font-mono bg-white border border-slate-200 rounded-xl text-slate-900"
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-xs">
                    <div className="space-y-1">
                      <label className="font-semibold text-slate-700">Diagnosis Classification</label>
                      <select
                        value={diagnosisForm.diagnosis_type}
                        onChange={(e) => setDiagnosisForm({ ...diagnosisForm, diagnosis_type: e.target.value as DiagnosisType })}
                        className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-slate-900"
                      >
                        <option value="final">Final Diagnosis</option>
                        <option value="provisional">Provisional / Working Impression</option>
                      </select>
                    </div>
                    <div className="space-y-1 sm:col-span-2">
                      <label className="font-semibold text-slate-700">Differential / Clinical Notes</label>
                      <input
                        type="text"
                        value={diagnosisForm.notes}
                        onChange={(e) => setDiagnosisForm({ ...diagnosisForm, notes: e.target.value })}
                        placeholder="Diagnostic reasoning and justification..."
                        className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-slate-900"
                      />
                    </div>
                  </div>

                  <div className="flex justify-end pt-2">
                    <button
                      id="save-diag-btn"
                      type="submit"
                      className="inline-flex items-center gap-1.5 px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold cursor-pointer"
                    >
                      <Plus className="w-4 h-4" />
                      <span>Add Diagnosis</span>
                    </button>
                  </div>
                </form>
              ) : (
                <div className="p-4 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-600 flex items-center gap-2">
                  <Lock className="w-4 h-4 text-slate-500" />
                  <span>Encounter is closed. Diagnoses are sealed.</span>
                </div>
              )}

              {/* Running Diagnoses List */}
              <div className="space-y-3">
                <h4 className="text-xs font-bold uppercase tracking-wider text-slate-400">
                  Recorded Diagnoses ({encounter.diagnoses?.length || 0})
                </h4>

                {(!encounter.diagnoses || encounter.diagnoses.length === 0) ? (
                  <p className="text-xs text-slate-400 italic">No clinical diagnoses logged yet.</p>
                ) : (
                  <div className="space-y-2.5">
                    {encounter.diagnoses.map((diag) => (
                      <div key={diag.id} className="p-4 rounded-xl bg-white border border-slate-200 shadow-2xs flex items-start justify-between gap-4">
                        <div className="space-y-1">
                          <div className="flex items-center gap-2">
                            <span className="font-bold text-slate-900 text-sm">{diag.diagnosis_text}</span>
                            {diag.icd_code && (
                              <span className="font-mono text-xs font-bold px-2 py-0.5 rounded bg-emerald-50 text-emerald-800 border border-emerald-200">
                                {diag.icd_code}
                              </span>
                            )}
                            <StatusBadge variant={diag.diagnosis_type}>{diag.diagnosis_type}</StatusBadge>
                          </div>
                          {diag.notes && <p className="text-xs text-slate-600 italic">Notes: {diag.notes}</p>}
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
          )}

          {/* ===================== TAB 4: MEDICATIONS (Rx) ===================== */}
          {activeTab === 'medications' && (
            <div className="space-y-8 animate-in fade-in duration-150">
              {isOpen ? (
                <form onSubmit={handleAddPrescription} className="p-6 rounded-2xl bg-slate-50 border border-slate-200/80 space-y-4">
                  <div className="flex items-center justify-between border-b border-slate-200 pb-3">
                    <h3 className="text-xs font-bold uppercase tracking-wider text-slate-800 flex items-center gap-2">
                      <Pill className="w-4 h-4 text-emerald-600" />
                      <span>Electronic Prescription & Posology Protocol</span>
                    </h3>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-xs">
                    <div className="space-y-1 sm:col-span-2">
                      <label className="font-semibold text-slate-700">Medication Name & Formulation *</label>
                      <input
                        type="text"
                        required
                        value={rxForm.medication_name}
                        onChange={(e) => setRxForm({ ...rxForm, medication_name: e.target.value })}
                        placeholder="e.g. Amlodipine Besylate, Metformin HCl, Amoxicillin"
                        className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-slate-900"
                      />
                    </div>
                    <div className="space-y-1">
                      <label className="font-semibold text-slate-700">Strength / Dose *</label>
                      <input
                        type="text"
                        required
                        value={rxForm.dose}
                        onChange={(e) => setRxForm({ ...rxForm, dose: e.target.value })}
                        placeholder="e.g. 5mg, 500mg, 10ml"
                        className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-slate-900"
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-xs">
                    <div className="space-y-1">
                      <label className="font-semibold text-slate-700">Route</label>
                      <select
                        value={rxForm.route}
                        onChange={(e) => setRxForm({ ...rxForm, route: e.target.value })}
                        className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-slate-900"
                      >
                        <option value="oral">Oral (PO)</option>
                        <option value="iv">Intravenous (IV)</option>
                        <option value="im">Intramuscular (IM)</option>
                        <option value="topical">Topical</option>
                        <option value="inhalation">Inhalation</option>
                        <option value="sublingual">Sublingual</option>
                      </select>
                    </div>
                    <div className="space-y-1">
                      <label className="font-semibold text-slate-700">Dosing Frequency</label>
                      <select
                        value={rxForm.frequency}
                        onChange={(e) => setRxForm({ ...rxForm, frequency: e.target.value })}
                        className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-slate-900"
                      >
                        <option value="Once daily (OD)">Once daily (OD)</option>
                        <option value="Twice daily (BD)">Twice daily (BD)</option>
                        <option value="Three times daily (TDS)">Three times daily (TDS)</option>
                        <option value="Four times daily (QDS)">Four times daily (QDS)</option>
                        <option value="Every 8 hours">Every 8 hours</option>
                        <option value="As needed (PRN)">As needed (PRN)</option>
                      </select>
                    </div>
                    <div className="space-y-1">
                      <label className="font-semibold text-slate-700">Duration</label>
                      <select
                        value={rxForm.duration}
                        onChange={(e) => setRxForm({ ...rxForm, duration: e.target.value })}
                        className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-slate-900"
                      >
                        <option value="3 days">3 days</option>
                        <option value="5 days">5 days</option>
                        <option value="7 days">7 days</option>
                        <option value="14 days">14 days</option>
                        <option value="30 days">30 days (1 month refill)</option>
                        <option value="90 days">90 days (3 month supply)</option>
                      </select>
                    </div>
                  </div>

                  <div className="space-y-1">
                    <label className="font-semibold text-slate-700 text-xs">Patient Dispensing Instructions</label>
                    <input
                      type="text"
                      value={rxForm.instructions}
                      onChange={(e) => setRxForm({ ...rxForm, instructions: e.target.value })}
                      placeholder="e.g. Take with water after breakfast. Avoid grapefruit juice."
                      className="w-full px-3 py-2 text-xs bg-white border border-slate-200 rounded-xl text-slate-900"
                    />
                  </div>

                  <div className="flex justify-end pt-2">
                    <button
                      id="save-rx-btn"
                      type="submit"
                      className="inline-flex items-center gap-1.5 px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold cursor-pointer"
                    >
                      <Plus className="w-4 h-4" />
                      <span>Issue Electronic Prescription</span>
                    </button>
                  </div>
                </form>
              ) : (
                <div className="p-4 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-600 flex items-center gap-2">
                  <Lock className="w-4 h-4 text-slate-500" />
                  <span>Encounter is closed. Prescription is signed off and transmitted.</span>
                </div>
              )}

              {/* Prescribed Items Table */}
              <div className="space-y-3">
                <h4 className="text-xs font-bold uppercase tracking-wider text-slate-400">
                  Prescribed Medications in this Visit
                </h4>

                {(!encounter.prescriptions || encounter.prescriptions.length === 0) ? (
                  <p className="text-xs text-slate-400 italic">No prescriptions issued during this encounter.</p>
                ) : (
                  <div className="space-y-3">
                    {encounter.prescriptions.map((rx) => (
                      <div key={rx.id} className="p-4 rounded-xl bg-white border border-slate-200 shadow-2xs space-y-3">
                        <div className="flex items-center justify-between border-b border-slate-100 pb-2 text-xs">
                          <span className="font-mono text-[11px] text-slate-400">
                            Prescription ID: {rx.id.slice(0, 8)} • Authorized by Dr. {encounter.opened_by_doctor_name}
                          </span>
                          <span className="text-emerald-700 font-bold text-[11px]">TRANSMITTED</span>
                        </div>

                        <div className="divide-y divide-slate-100">
                          {rx.items.map((item) => (
                            <div key={item.id} className="py-2.5 first:pt-0 last:pb-0 flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-xs">
                              <div>
                                <div className="flex items-center gap-2">
                                  <span className="font-bold text-slate-900 text-sm">{item.medication_name}</span>
                                  <span className="font-mono text-xs px-2 py-0.5 bg-slate-100 text-slate-800 rounded font-semibold">
                                    {item.dose} ({item.route})
                                  </span>
                                  <StatusBadge variant={item.status}>{item.status}</StatusBadge>
                                </div>
                                <p className="text-slate-500 mt-0.5">
                                  {item.frequency} • {item.duration} • <span className="italic text-slate-700">&ldquo;{item.instructions}&rdquo;</span>
                                </p>
                              </div>

                              {isOpen && item.status === 'active' && (
                                <button
                                  type="button"
                                  onClick={() => deactivatePrescriptionItem(item.id)}
                                  className="px-2.5 py-1 rounded-lg text-[11px] font-semibold text-rose-700 bg-rose-50 hover:bg-rose-100 border border-rose-200 transition-colors cursor-pointer"
                                >
                                  Deactivate
                                </button>
                              )}
                            </div>
                          ))}
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
          )}

          {/* ===================== TAB 5: APPOINTMENT / FOLLOW-UP ===================== */}
          {activeTab === 'appointment' && (
            <div className="space-y-8 animate-in fade-in duration-150">
              {isOpen ? (
                <form onSubmit={handleSaveAppointment} className="p-6 rounded-2xl bg-slate-50 border border-slate-200/80 space-y-4">
                  <div className="flex items-center justify-between border-b border-slate-200 pb-3">
                    <h3 className="text-xs font-bold uppercase tracking-wider text-slate-800 flex items-center gap-2">
                      <Calendar className="w-4 h-4 text-emerald-600" />
                      <span>Schedule Clinical Follow-Up Appointment</span>
                    </h3>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs">
                    <div className="space-y-1">
                      <label className="font-semibold text-slate-700">Scheduled Date & Time *</label>
                      <input
                        type="datetime-local"
                        required
                        value={aptForm.scheduled_at}
                        onChange={(e) => setAptForm({ ...aptForm, scheduled_at: e.target.value })}
                        className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-slate-900 font-mono"
                      />
                    </div>
                    <div className="space-y-1">
                      <label className="font-semibold text-slate-700">Consultation Objective / Purpose</label>
                      <input
                        type="text"
                        value={aptForm.notes}
                        onChange={(e) => setAptForm({ ...aptForm, notes: e.target.value })}
                        placeholder="e.g. 2-week blood pressure titration review"
                        className="w-full px-3 py-2 bg-white border border-slate-200 rounded-xl text-slate-900"
                      />
                    </div>
                  </div>

                  <div className="flex justify-end pt-2">
                    <button
                      id="save-apt-btn"
                      type="submit"
                      className="inline-flex items-center gap-1.5 px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold cursor-pointer"
                    >
                      <Calendar className="w-4 h-4" />
                      <span>{encounter.appointment ? 'Update Follow-Up Visit' : 'Confirm Follow-Up Booking'}</span>
                    </button>
                  </div>
                </form>
              ) : (
                <div className="p-4 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-600 flex items-center gap-2">
                  <Lock className="w-4 h-4 text-slate-500" />
                  <span>Encounter is closed. Appointment details are saved.</span>
                </div>
              )}

              {/* Scheduled Appointment Card */}
              <div className="space-y-3">
                <h4 className="text-xs font-bold uppercase tracking-wider text-slate-400">
                  Follow-Up Registry Details
                </h4>

                {!encounter.appointment ? (
                  <p className="text-xs text-slate-400 italic">No follow-up return visit scheduled for this encounter.</p>
                ) : (
                  <div className="p-5 rounded-2xl bg-emerald-50/50 border border-emerald-200 shadow-2xs flex flex-col sm:flex-row sm:items-center justify-between gap-4 text-xs">
                    <div className="space-y-1">
                      <div className="flex items-center gap-2">
                        <span className="font-bold text-slate-900 text-sm">
                          {new Date(encounter.appointment.scheduled_at).toLocaleDateString('en-GB', {
                            weekday: 'long',
                            day: 'numeric',
                            month: 'long',
                            year: 'numeric',
                          })}
                        </span>
                        <StatusBadge variant={encounter.appointment.status}>{encounter.appointment.status}</StatusBadge>
                      </div>
                      <p className="text-slate-600">
                        Time: <span className="font-mono font-bold">{new Date(encounter.appointment.scheduled_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span> • Attending: Dr. {encounter.opened_by_doctor_name}
                      </p>
                      {encounter.appointment.notes && (
                        <p className="text-slate-500 italic mt-1 text-[11px]">Notes: {encounter.appointment.notes}</p>
                      )}
                    </div>

                    <button
                      type="button"
                      onClick={() => navigateTo('doctor-appointments')}
                      className="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-bold text-xs shadow-xs"
                    >
                      View in Calendar →
                    </button>
                  </div>
                )}
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Sign Off & Lock Encounter Confirmation Dialog */}
      <ConfirmDialog
        isOpen={isCloseModalOpen}
        onClose={() => setIsCloseModalOpen(false)}
        onConfirm={handleConfirmClose}
        title="Sign Off & Finalize Clinical Encounter?"
        confirmText="Yes, Sign Off & Seal Record"
        isDestructive={false}
        description={
          <div className="space-y-2 text-xs">
            <p>
              Signing off marks this medical consultation as complete under Dr. {encounter.opened_by_doctor_name}&apos;s licensure.
            </p>
            <div className="p-3 bg-amber-50 rounded-xl border border-amber-200 text-amber-900 font-medium">
              Notice: Once closed, all vital signs, lab investigations, ICD-10 diagnoses, and prescriptions become permanently immutable and locked against edits per Kenyan medical data governance.
            </div>
          </div>
        }
      />
    </div>
  );
}
