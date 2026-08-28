import { Patient, Encounter, VitalSign, LabResult, Prescription, Diagnosis } from '@/types/database';

export interface TimelinePrescriptionItem {
  medication_name: string;
  dose: string;
  route: string;
  frequency: string;
  duration: string;
  instructions?: string;
}

export interface TimelineVitals {
  systolic_bp?: number | null;
  diastolic_bp?: number | null;
  pulse?: number | null;
  respiratory_rate?: number | null;
  temperature?: number | null;
  spo2?: number | null;
  blood_sugar?: number | null;
  weight?: number | null;
}

export interface TimelineEncounterCardData {
  encounter_id: string;
  date: string;
  chief_complaint: string;
  diagnosis: string | null;
  prescription: TimelinePrescriptionItem[];
  vitals: TimelineVitals | null;
  labs: LabResult[];
  diagnosesList: Diagnosis[];
  rawEncounter: Encounter;
}

export interface TimelineEvent {
  id: string;
  type: 'encounter' | 'vital' | 'lab' | 'prescription' | 'diagnosis';
  date: string;
  title: string;
  clinicName: string;
  doctorName: string;
  data: unknown;
}

export interface VitalsTrendPoint {
  date: string;
  systolic: number;
  diastolic: number;
  pulse: number;
  bloodSugar?: number;
}
