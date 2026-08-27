'use client';

import React, { useState } from 'react';
import { Stethoscope, CheckCircle2, Search } from 'lucide-react';
import { useStore } from '@/lib/store';
import { Button } from '@/modules/core/ui/Button';
import { Input } from '@/modules/core/ui/Input';
import { Encounter, DiagnosisType } from '@/types/database';

interface DiagnosisPickerProps {
  encounter: Encounter;
  onSaved?: () => void;
}

const COMMON_ICD_CODES = [
  { code: 'I10', text: 'Essential (primary) hypertension' },
  { code: 'E11.9', text: 'Type 2 diabetes mellitus without complications' },
  { code: 'J06.9', text: 'Acute upper respiratory infection, unspecified' },
  { code: 'K29.7', text: 'Gastritis, unspecified' },
  { code: 'B54', text: 'Unspecified malaria' },
  { code: 'M54.5', text: 'Low back pain' },
  { code: 'F41.1', text: 'Generalized anxiety disorder' },
  { code: 'F32.9', text: 'Major depressive disorder, single episode' },
];

export function DiagnosisPicker({ encounter, onSaved }: DiagnosisPickerProps) {
  const { addDiagnosis } = useStore();

  const [diagnosisText, setDiagnosisText] = useState('Essential (primary) hypertension');
  const [icdCode, setIcdCode] = useState('I10');
  const [type, setType] = useState<DiagnosisType>('final');
  const [notes, setNotes] = useState('Controlled under current outpatient medical protocol');
  const [isSaved, setIsSaved] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    addDiagnosis(encounter.id, {
      diagnosis_text: diagnosisText,
      icd_code: icdCode,
      diagnosis_type: type,
      notes: notes || undefined,
    });

    setIsSaved(true);
    if (onSaved) onSaved();
    setTimeout(() => setIsSaved(false), 3000);
  };

  const handleSelectPredefined = (item: { code: string; text: string }) => {
    setDiagnosisText(item.text);
    setIcdCode(item.code);
  };

  return (
    <div className="bg-white rounded-3xl border border-slate-200 p-6 space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h3 className="text-base font-bold text-slate-900 flex items-center gap-2">
            <Stethoscope className="w-5 h-5 text-[#2E7D32]" />
            Clinical Diagnoses (ICD-10 Standard)
          </h3>
          <p className="text-xs text-slate-500">Record definitive or provisional clinical diagnoses</p>
        </div>

        {isSaved && (
          <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-[#E8F5E9] text-[#1B5E20] border border-[#C8E6C9]">
            <CheckCircle2 className="w-4 h-4 text-[#2E7D32]" /> Diagnosis Recorded
          </span>
        )}
      </div>

      <div className="space-y-2">
        <label className="text-xs font-semibold text-slate-500">Common ICD-10 Presets</label>
        <div className="flex flex-wrap gap-1.5">
          {COMMON_ICD_CODES.map((item) => (
            <button
              key={item.code}
              type="button"
              onClick={() => handleSelectPredefined(item)}
              className="px-2.5 py-1 rounded-xl text-[11px] font-medium bg-slate-50 hover:bg-[#E8F5E9] hover:text-[#1B5E20] border border-slate-200 transition-colors cursor-pointer"
            >
              <strong className="font-mono text-[#2E7D32] mr-1">{item.code}</strong> {item.text}
            </button>
          ))}
        </div>
      </div>

      <form onSubmit={handleSubmit} className="space-y-4">
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div className="sm:col-span-2">
            <Input
              label="Diagnosis Description"
              value={diagnosisText}
              onChange={(e) => setDiagnosisText(e.target.value)}
              required
            />
          </div>

          <Input
            label="ICD-10 Code"
            placeholder="e.g. I10"
            value={icdCode}
            onChange={(e) => setIcdCode(e.target.value)}
          />
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div className="space-y-1.5">
            <label className="block text-xs font-semibold text-slate-700">Diagnosis Classification</label>
            <select
              value={type}
              onChange={(e: any) => setType(e.target.value)}
              className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C] text-slate-800"
            >
              <option value="final">Final / Confirmed Diagnosis</option>
              <option value="provisional">Provisional / Working Diagnosis</option>
            </select>
          </div>

          <div className="sm:col-span-2">
            <Input
              label="Clinical Notes & Management Strategy"
              placeholder="e.g. Follow up in 4 weeks. Monitored for side-effects."
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
            />
          </div>
        </div>

        <div className="flex items-center justify-end">
          <Button type="submit" leftIcon={<CheckCircle2 className="w-4 h-4" />}>
            Attach Diagnosis
          </Button>
        </div>
      </form>
    </div>
  );
}
