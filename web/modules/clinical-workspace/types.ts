import {
  Encounter,
  VitalSign,
  LabResult,
  Diagnosis,
  Prescription,
  PrescriptionItem,
  Appointment,
  EncounterType,
  LabCategory,
  LabFlag,
  DiagnosisType,
} from '@/types/database';

export type WorkspaceTab = 'vitals' | 'labs' | 'diagnoses' | 'prescriptions' | 'appointment' | 'summary';

export interface VitalsInput {
  systolic_bp?: number;
  diastolic_bp?: number;
  pulse?: number;
  spo2?: number;
  temperature?: number;
  blood_sugar?: number;
  respiratory_rate?: number;
  weight?: number;
  notes?: string;
}

export interface LabResultInput {
  test_name: string;
  category: LabCategory;
  summary_notes: string;
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
  dose: string;
  route: string;
  frequency: string;
  duration: string;
  instructions?: string;
}

export interface ScheduleAppointmentInput {
  scheduled_at: string;
  notes?: string;
}
