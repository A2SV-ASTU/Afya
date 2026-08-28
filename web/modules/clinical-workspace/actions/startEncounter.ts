import {
  VitalsInput,
  LabResultInput,
  DiagnosisInput,
  PrescriptionItemInput,
  ScheduleAppointmentInput,
} from '../types';
import { Encounter, VitalSign, LabResult, Diagnosis, Prescription, Appointment } from '@/types/database';

export async function startEncounterAction(patientId: string, type: 'outpatient' | 'inpatient' | 'emergency' | 'telehealth'): Promise<Encounter> {
  return {
    id: `enc-${Date.now()}`,
    patient_id: patientId,
    patient_name: 'Patient',
    clinic_id: 'cln-01',
    clinic_name: 'St. Jude Healthcare Centre',
    opened_by_doctor_id: 'usr-doc-01',
    opened_by_doctor_name: 'Dr. Jane Muthoni',
    type,
    status: 'open',
    started_at: new Date().toISOString(),
    vitals: [],
    labs: [],
    diagnoses: [],
    prescriptions: [],
  };
}

export async function saveVitalsAction(encounterId: string, vitals: VitalsInput): Promise<VitalSign> {
  return {
    id: `vit-${Date.now()}`,
    encounter_id: encounterId,
    patient_id: 'pat-001',
    ...vitals,
    source: 'clinic',
    recorded_at: new Date().toISOString(),
  };
}

export async function saveLabResultAction(encounterId: string, lab: LabResultInput): Promise<LabResult> {
  return {
    id: `lab-${Date.now()}`,
    encounter_id: encounterId,
    ...lab,
    created_at: new Date().toISOString(),
  };
}

export async function saveDiagnosisAction(encounterId: string, diag: DiagnosisInput): Promise<Diagnosis> {
  return {
    id: `dx-${Date.now()}`,
    encounter_id: encounterId,
    ...diag,
    created_at: new Date().toISOString(),
  };
}

export async function savePrescriptionAction(encounterId: string, item: PrescriptionItemInput): Promise<Prescription> {
  return {
    id: `rx-${Date.now()}`,
    encounter_id: encounterId,
    prescribed_at: new Date().toISOString(),
    items: [
      {
        id: `rx-item-${Date.now()}`,
        prescription_id: `rx-${Date.now()}`,
        ...item,
        status: 'active',
        started_at: new Date().toISOString(),
      },
    ],
  };
}

export async function scheduleAppointmentAction(encounterId: string, appt: ScheduleAppointmentInput): Promise<Appointment> {
  return {
    id: `apt-${Date.now()}`,
    clinic_id: 'cln-01',
    clinic_name: 'St. Jude Healthcare Centre',
    doctor_id: 'usr-doc-01',
    doctor_name: 'Dr. Jane Muthoni',
    patient_id: 'pat-001',
    patient_name: 'Patient',
    scheduled_at: appt.scheduled_at,
    status: 'scheduled',
    notes: appt.notes,
    source_encounter_id: encounterId,
    created_at: new Date().toISOString(),
  };
}

export async function closeEncounterAction(encounterId: string): Promise<boolean> {
  return true;
}
