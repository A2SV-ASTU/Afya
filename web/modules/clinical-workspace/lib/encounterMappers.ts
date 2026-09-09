import {
  Encounter,
  EncounterType,
  VitalSign,
  LabResult,
  Diagnosis,
  Prescription,
  PrescriptionItem,
  DiagnosisType,
  LabFlag,
} from '@/types/database';

/**
 * Placeholder facility name. The backend does not yet expose `clinic_name` on the
 * auth/profile or encounter payloads; the clinic team confirmed a placeholder is
 * acceptable until the login/profile endpoints are updated to include it.
 */
export const PLACEHOLDER_CLINIC_NAME = 'AfyaMind Clinic';
export const PLACEHOLDER_DOCTOR_NAME = 'Attending Physician';
export const PLACEHOLDER_PATIENT_NAME = 'Patient';

/** Backend enum: POST /encounters/:id/prescriptions -> items[].route */
export const PRESCRIPTION_ROUTE_OPTIONS = [
  { value: 'oral', label: 'Oral (PO)' },
  { value: 'iv', label: 'Intravenous (IV)' },
  { value: 'im', label: 'Intramuscular (IM)' },
  { value: 'subcutaneous', label: 'Subcutaneous (SC)' },
  { value: 'topical', label: 'Topical' },
  { value: 'other', label: 'Other' },
] as const;

/** Backend enum: POST /encounters/:id/prescriptions -> items[].frequency */
export const PRESCRIPTION_FREQUENCY_OPTIONS = [
  { value: 'OD', label: 'OD — Once daily' },
  { value: 'BD', label: 'BD — Twice daily' },
  { value: 'TDS', label: 'TDS — Three times daily' },
  { value: 'QID', label: 'QID — Four times daily' },
  { value: 'QHS', label: 'QHS — At bedtime' },
  { value: 'PRN', label: 'PRN — As needed' },
  { value: 'STAT', label: 'STAT — Immediately, once' },
  { value: 'Q4H', label: 'Q4H — Every 4 hours' },
  { value: 'Q6H', label: 'Q6H — Every 6 hours' },
  { value: 'Q8H', label: 'Q8H — Every 8 hours' },
  { value: 'Q12H', label: 'Q12H — Every 12 hours' },
] as const;

/** Backend enum: POST /encounters/:id/prescriptions -> items[].duration_unit */
export const DURATION_UNIT_OPTIONS = [
  { value: 'day', label: 'Day(s)' },
  { value: 'week', label: 'Week(s)' },
  { value: 'month', label: 'Month(s)' },
  { value: 'year', label: 'Year(s)' },
] as const;

/** Backend enum: POST /encounters/:id/labs -> category */
export const LAB_CATEGORY_OPTIONS = [
  { value: 'laboratory', label: 'Laboratory' },
  { value: 'imaging', label: 'Imaging / Radiology' },
  { value: 'pathology', label: 'Pathology / Histology' },
  { value: 'other', label: 'Other Diagnostic' },
] as const;

export function formatDuration(value?: number | null, unit?: string | null): string {
  if (!value || value <= 0) return unit ? `— ${unit}` : '—';
  const base = unit || 'day';
  return `${value} ${base}${value === 1 ? '' : 's'}`;
}

/**
 * Parses a free-text duration ("30 days", "2 weeks", "1 month") into the
 * `{ value, unit }` pair the backend prescription endpoint requires. Defaults to
 * 7 days when nothing usable is found.
 */
export function parseDuration(text: string): { value: number; unit: string } {
  const lower = text.toLowerCase();
  const numMatch = lower.match(/\d+/);
  const value = numMatch ? parseInt(numMatch[0], 10) : 7;
  let unit = 'day';
  if (lower.includes('week')) unit = 'week';
  else if (lower.includes('month')) unit = 'month';
  else if (lower.includes('year')) unit = 'year';
  return { value: value > 0 ? value : 7, unit };
}

/**
 * Renders backend lab `measurements` (JSON object) into a readable one-liner for
 * list/summary views. Accepts the string form too (older payloads / free text).
 */
export function formatMeasurements(measurements: unknown): string {
  if (measurements == null) return '';
  if (typeof measurements === 'string') return measurements;
  if (typeof measurements === 'object') {
    const entries = Object.entries(measurements as Record<string, unknown>);
    if (entries.length === 0) return '';
    return entries.map(([k, v]) => `${k}: ${String(v)}`).join(', ');
  }
  return String(measurements);
}

/**
 * Parses the free-text "analyte: value, analyte: value" field the lab form uses
 * into the `{ [analyte]: value }` object the backend expects. Non key/value text
 * is preserved under a `summary` key so nothing is silently dropped.
 */
export function parseMeasurements(text: string): Record<string, unknown> {
  const trimmed = text.trim();
  if (!trimmed) return {};
  const out: Record<string, unknown> = {};
  let matchedAny = false;
  for (const chunk of trimmed.split(/[,;\n]+/)) {
    const idx = chunk.indexOf(':');
    if (idx === -1) continue;
    const key = chunk.slice(0, idx).trim();
    const rawValue = chunk.slice(idx + 1).trim();
    if (!key) continue;
    const num = Number(rawValue);
    out[key] = rawValue !== '' && !Number.isNaN(num) ? num : rawValue;
    matchedAny = true;
  }
  if (!matchedAny) return { summary: trimmed };
  return out;
}

// --- Raw backend payload shapes (GET /api/v1/encounters/:id) --------------------

interface RawEncounter {
  id: string;
  patient_id: string;
  doctor_id?: string | null;
  opened_by_doctor_id?: string | null;
  clinic_id?: string | null;
  type?: string | null;
  status?: string | null;
  notes?: string | null;
  started_at?: string | null;
  ended_at?: string | null;
  closed_at?: string | null;
  created_at?: string | null;
  updated_at?: string | null;
}

interface RawVital {
  id: string;
  encounter_id?: string | null;
  patient_id?: string | null;
  source?: string | null;
  systolic_bp?: number | null;
  diastolic_bp?: number | null;
  pulse?: number | null;
  respiratory_rate?: number | null;
  temperature?: number | null;
  spo2?: number | null;
  blood_sugar?: number | null;
  weight?: number | null;
  notes?: string | null;
  recorded_at?: string | null;
  created_at?: string | null;
}

interface RawLab {
  id: string;
  encounter_id: string;
  test_name: string;
  category: string;
  summary_notes?: string | null;
  measurements?: unknown;
  flag?: string | null;
  created_at?: string | null;
}

interface RawDiagnosis {
  id: string;
  encounter_id: string;
  diagnosis_text: string;
  icd_code?: string | null;
  diagnosis_type?: string | null;
  notes?: string | null;
  diagnosed_at?: string | null;
  created_at?: string | null;
}

interface RawPrescriptionItem {
  id: string;
  prescription_id?: string | null;
  medication_name: string;
  dose: string;
  route: string;
  frequency: string;
  duration_value?: number | null;
  duration_unit?: string | null;
  duration?: string | null;
  status?: string | null;
  instructions?: string | null;
  started_at?: string | null;
}

interface RawPrescription {
  id: string;
  encounter_id: string;
  notes?: string | null;
  prescribed_at?: string | null;
  items?: RawPrescriptionItem[] | null;
}

export interface RawAggregatedEncounter {
  encounter: RawEncounter;
  patient_name?: string | null;
  doctor_name?: string | null;
  clinic_name?: string | null;
  vitals?: RawVital[] | null;
  labs?: RawLab[] | null;
  diagnoses?: RawDiagnosis[] | null;
  prescriptions?: RawPrescription[] | null;
}

export interface MapEncounterOptions {
  /** Encounter classification (outpatient/…) — not persisted by the backend, so
   * the caller supplies it when known (e.g. carried from the "new encounter" form). */
  type?: EncounterType;
  patientName?: string;
  doctorName?: string;
  clinicName?: string;
}

function mapVital(v: RawVital): VitalSign {
  return {
    id: v.id,
    encounter_id: v.encounter_id ?? undefined,
    patient_id: v.patient_id ?? undefined,
    systolic_bp: v.systolic_bp ?? undefined,
    diastolic_bp: v.diastolic_bp ?? undefined,
    pulse: v.pulse ?? undefined,
    spo2: v.spo2 ?? undefined,
    temperature: v.temperature ?? undefined,
    blood_sugar: v.blood_sugar ?? undefined,
    respiratory_rate: v.respiratory_rate ?? undefined,
    weight: v.weight ?? undefined,
    source: v.source === 'patient' ? 'patient' : 'clinic',
    notes: v.notes ?? undefined,
    recorded_at: v.recorded_at ?? v.created_at ?? '',
    created_at: v.created_at ?? undefined,
  };
}

function mapLab(l: RawLab): LabResult {
  return {
    id: l.id,
    encounter_id: l.encounter_id,
    test_name: l.test_name,
    category: l.category,
    summary_notes: l.summary_notes ?? undefined,
    measurements: formatMeasurements(l.measurements),
    flag: (l.flag as LabFlag) ?? 'normal',
    created_at: l.created_at ?? '',
  };
}

function mapDiagnosis(d: RawDiagnosis): Diagnosis {
  return {
    id: d.id,
    encounter_id: d.encounter_id,
    diagnosis_text: d.diagnosis_text,
    icd_code: d.icd_code ?? undefined,
    diagnosis_type: (d.diagnosis_type === 'provisional' ? 'provisional' : 'final') as DiagnosisType,
    notes: d.notes ?? undefined,
    created_at: d.diagnosed_at ?? d.created_at ?? '',
  };
}

function mapPrescriptionItem(it: RawPrescriptionItem, prescriptionId: string): PrescriptionItem {
  return {
    id: it.id,
    prescription_id: it.prescription_id ?? prescriptionId,
    medication_name: it.medication_name,
    dose: it.dose,
    route: it.route,
    frequency: it.frequency,
    duration: it.duration ?? formatDuration(it.duration_value, it.duration_unit),
    instructions: it.instructions ?? undefined,
    status: (it.status as PrescriptionItem['status']) ?? 'active',
    started_at: it.started_at ?? '',
  };
}

function mapPrescription(p: RawPrescription): Prescription {
  return {
    id: p.id,
    encounter_id: p.encounter_id,
    notes: p.notes ?? undefined,
    prescribed_at: p.prescribed_at ?? '',
    items: (p.items ?? []).map((it) => mapPrescriptionItem(it, p.id)),
  };
}

/**
 * Normalises the aggregated `GET /api/v1/encounters/:id` response into the UI
 * `Encounter` shape used across the clinical workspace and patient chart.
 */
export function mapAggregatedEncounter(
  res: RawAggregatedEncounter,
  opts: MapEncounterOptions = {}
): Encounter {
  const enc = res.encounter;
  const status: 'open' | 'closed' = enc.status === 'closed' ? 'closed' : 'open';
  const endedAt = enc.ended_at ?? enc.closed_at ?? null;

  return {
    id: enc.id,
    patient_id: enc.patient_id,
    patient_name: res.patient_name ?? opts.patientName ?? PLACEHOLDER_PATIENT_NAME,
    doctor_id: enc.doctor_id ?? undefined,
    opened_by_doctor_id: enc.opened_by_doctor_id ?? enc.doctor_id ?? '',
    doctor_name: res.doctor_name ?? opts.doctorName ?? undefined,
    opened_by_doctor_name: res.doctor_name ?? opts.doctorName ?? PLACEHOLDER_DOCTOR_NAME,
    clinic_id: enc.clinic_id ?? '',
    clinic_name: res.clinic_name ?? opts.clinicName ?? PLACEHOLDER_CLINIC_NAME,
    type: opts.type ?? ((enc.type as EncounterType) || 'outpatient'),
    status,
    notes: enc.notes ?? undefined,
    started_at: enc.started_at ?? enc.created_at ?? '',
    ended_at: endedAt,
    closed_at: endedAt,
    created_at: enc.created_at ?? undefined,
    updated_at: enc.updated_at ?? undefined,
    vitals: (res.vitals ?? []).map(mapVital),
    labs: (res.labs ?? []).map(mapLab),
    diagnoses: (res.diagnoses ?? []).map(mapDiagnosis),
    prescriptions: (res.prescriptions ?? []).map(mapPrescription),
  };
}
