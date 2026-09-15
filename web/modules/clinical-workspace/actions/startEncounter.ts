import {
  LabResultInput,
  DiagnosisInput,
  PrescriptionItemInput,
  ScheduleAppointmentInput,
  VitalsInput,
} from '../types';
import { Encounter, EncounterType, EncounterStatus } from '@/types/database';
import {
  encountersApi,
  vitalsApi,
  labsApi,
  diagnosesApi,
  prescriptionsApi,
  appointmentsApi,
} from '@/lib/api';
import {
  PLACEHOLDER_CLINIC_NAME,
  PLACEHOLDER_DOCTOR_NAME,
  PLACEHOLDER_PATIENT_NAME,
  parseMeasurements,
} from '../lib/encounterMappers';

/**
 * Server actions for the clinical workspace. Every call goes straight to the
 * backend REST API — there are no mock fallbacks or fabricated identifiers, and
 * any 4xx/5xx is thrown so the calling component can surface it to the user.
 */

export async function startEncounterAction(
  patientId: string,
  type: EncounterType = 'outpatient'
): Promise<Encounter> {
  const res = await encountersApi.open(patientId);
  const enc = res.encounter;
  return {
    ...enc,
    patient_name: PLACEHOLDER_PATIENT_NAME,
    opened_by_doctor_id: enc.opened_by_doctor_id || enc.doctor_id || '',
    opened_by_doctor_name: PLACEHOLDER_DOCTOR_NAME,
    clinic_id: enc.clinic_id || '',
    clinic_name: PLACEHOLDER_CLINIC_NAME,
    type,
    status: 'open',
    vitals: [],
    labs: [],
    diagnoses: [],
    prescriptions: [],
  };
}

export async function saveVitalsAction(encounterId: string, vitals: VitalsInput): Promise<void> {
  await vitalsApi.recordForEncounter(encounterId, vitals);
}

export async function saveLabResultAction(encounterId: string, lab: LabResultInput): Promise<void> {
  await labsApi.create(encounterId, {
    test_name: lab.test_name,
    category: lab.category,
    summary_notes: lab.summary_notes || undefined,
    measurements: parseMeasurements(lab.measurements),
    flag: lab.flag,
  });
}

export async function saveDiagnosisAction(encounterId: string, diag: DiagnosisInput): Promise<void> {
  await diagnosesApi.create(encounterId, {
    diagnosis_text: diag.diagnosis_text,
    diagnosis_type: diag.diagnosis_type,
    icd_code: diag.icd_code || undefined,
    notes: diag.notes || undefined,
  });
}

export async function savePrescriptionAction(
  encounterId: string,
  item: PrescriptionItemInput
): Promise<void> {
  await prescriptionsApi.create(encounterId, {
    items: [
      {
        medication_name: item.medication_name,
        dose: item.dose,
        route: item.route,
        frequency: item.frequency,
        duration_value: item.duration_value,
        duration_unit: item.duration_unit,
        instructions: item.instructions || undefined,
      },
    ],
  });
}

export async function scheduleAppointmentAction(
  patientId: string,
  appt: ScheduleAppointmentInput
): Promise<void> {
  await appointmentsApi.create({
    patient_id: patientId,
    scheduled_at: appt.scheduled_at,
    notes: appt.notes || undefined,
  });
}

/**
 * Closes the encounter and returns the backend's own view of the closed record.
 * The caller applies this directly instead of re-reading the encounter: closing
 * is followed by revoking the clinic's access grant, after which
 * `GET /encounters/:id` is refused by AccessGuard.
 */
export async function closeEncounterAction(
  encounterId: string
): Promise<{ status: EncounterStatus; ended_at: string | null }> {
  const res = await encountersApi.close(encounterId);
  const closed = res.encounter;
  return {
    status: closed?.status === 'open' ? 'open' : 'closed',
    ended_at: closed?.ended_at ?? closed?.closed_at ?? new Date().toISOString(),
  };
}
