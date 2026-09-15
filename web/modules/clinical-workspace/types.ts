import { LabFlag, DiagnosisType } from '@/types/database';

export type WorkspaceTab = 'evaluation' | 'vitals' | 'labs' | 'diagnoses' | 'prescriptions' | 'appointment' | 'history' | 'summary';

export interface VitalsInput {
  systolic_bp?: number;
  diastolic_bp?: number;
  pulse?: number;
  spo2?: number;
  temperature?: number;
  blood_sugar?: number;
  respiratory_rate?: number;
  weight?: number;
}

export interface LabResultInput {
  test_name: string;
  /** Backend enum: laboratory | imaging | pathology | other */
  category: string;
  summary_notes: string;
  /** Free-text "analyte: value, analyte: value" — mapped to an object before send. */
  measurements: string;
  flag: LabFlag;
}

export interface DiagnosisInput {
  diagnosis_text: string;
  icd_code?: string;
  diagnosis_type: DiagnosisType;
  notes?: string;
}

export interface PrescriptionItemInput {
  medication_name: string;
  /** Backend enum: oral | iv | im | subcutaneous | topical | other */
  route: string;
  dose: string;
  /** Backend enum: OD | BD | TDS | QID | QHS | PRN | STAT | Q4H | Q6H | Q8H | Q12H */
  frequency: string;
  duration_value: number;
  /** Backend enum: day | week | month | year */
  duration_unit: string;
  instructions?: string;
}

export interface ScheduleAppointmentInput {
  scheduled_at: string;
  notes?: string;
}
