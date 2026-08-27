'use client';

import { useState } from 'react';
import { VitalsInput, LabResultInput, DiagnosisInput, PrescriptionItemInput } from '../types';

export function useEncounterDraft(encounterId: string) {
  const [draftVitals, setDraftVitals] = useState<VitalsInput>({
    systolic_bp: 120,
    diastolic_bp: 80,
    pulse: 72,
    spo2: 98,
    temperature: 36.6,
    blood_sugar: 5.4,
    respiratory_rate: 16,
    weight: 70,
  });

  const [draftLab, setDraftLab] = useState<LabResultInput>({
    test_name: 'Full Blood Count (FBC)',
    category: 'Hematology',
    summary_notes: 'Normal WBC count, mild microcytic anemia',
    measurements: 'Hb: 11.2 g/dL, WBC: 6.4 x10^9/L, Platelets: 240 x10^9/L',
    flag: 'normal',
  });

  const [draftDiagnosis, setDraftDiagnosis] = useState<DiagnosisInput>({
    diagnosis_text: 'Essential Hypertension - Stage 1',
    icd_code: 'I10',
    diagnosis_type: 'final',
    notes: 'Well controlled with diet and medication',
  });

  const [draftRx, setDraftRx] = useState<PrescriptionItemInput>({
    medication_name: 'Amlodipine Besylate',
    dose: '5mg',
    route: 'oral',
    frequency: 'Once daily (OD) in the morning',
    duration: '30 days',
    instructions: 'Take after breakfast with water',
  });

  return {
    draftVitals,
    setDraftVitals,
    draftLab,
    setDraftLab,
    draftDiagnosis,
    setDraftDiagnosis,
    draftRx,
    setDraftRx,
  };
}
