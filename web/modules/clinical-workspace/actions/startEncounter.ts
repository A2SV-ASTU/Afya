import {
  VitalsInput,
  LabResultInput,
  DiagnosisInput,
  PrescriptionItemInput,
  ScheduleAppointmentInput,
} from '../types';
import { Encounter, VitalSign, LabResult, Diagnosis, Prescription, Appointment } from '@/types/database';
import {
  encountersApi,
  vitalsApi,
  labsApi,
  diagnosesApi,
  prescriptionsApi,
  appointmentsApi,
} from '@/lib/api';

export async function startEncounterAction(
  patientId: string,
  type: 'outpatient' | 'inpatient' | 'emergency' | 'telehealth' = 'outpatient'
): Promise<Encounter> {
  const res = await encountersApi.open(patientId);
  return {
    ...res.encounter,
    patient_name: 'Patient', // Assuming the caller will fill these or the API returns it
    opened_by_doctor_id: res.encounter.doctor_id || 'doctor',
    opened_by_doctor_name: 'Attending Physician',
    clinic_id: res.encounter.clinic_id || '',
    clinic_name: 'AfyaMind Clinic (Placeholder)',
    type,
    status: 'open',
    vitals: [],
    labs: [],
    diagnoses: [],
    prescriptions: [],
  };
}

export async function saveVitalsAction(encounterId: string, vitals: VitalsInput): Promise<VitalSign> {
  const res = await vitalsApi.recordForEncounter(encounterId, vitals);
  return res.vital_sign;
}

export async function saveLabResultAction(encounterId: string, lab: LabResultInput): Promise<LabResult> {
  const res = await labsApi.create(encounterId, {
    test_name: lab.test_name,
    category: lab.category,
    summary_notes: lab.summary_notes,
    measurements: lab.measurements,
    flag: lab.flag,
  });
  return res.lab_result;
}

export async function saveDiagnosisAction(encounterId: string, diag: DiagnosisInput): Promise<Diagnosis> {
  const res = await diagnosesApi.create(encounterId, diag);
  return res.diagnosis;
}

export async function savePrescriptionAction(encounterId: string, item: PrescriptionItemInput): Promise<Prescription> {
  const res = await prescriptionsApi.create(encounterId, {
    items: [item],
  });
  return res.prescription;
}

export async function scheduleAppointmentAction(
  encounterId: string,
  appt: ScheduleAppointmentInput,
  patientId = 'pat-001'
): Promise<Appointment> {
  const res = await appointmentsApi.create({
    patient_id: patientId,
    scheduled_at: appt.scheduled_at,
    notes: appt.notes,
  });
  return {
    ...res.appointment,
    clinic_name: 'AfyaMind Clinic (Placeholder)',
    doctor_name: 'Doctor',
    patient_name: 'Patient',
  };
}

export async function closeEncounterAction(encounterId: string): Promise<boolean> {
  await encountersApi.close(encounterId);
  return true;
}
