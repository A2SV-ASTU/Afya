'use client';

import React, { useState } from 'react';
import { FlaskConical, CheckCircle2, AlertTriangle } from 'lucide-react';
import { useStore } from '@/lib/store';
import { Button } from '@/modules/core/ui/Button';
import { Input } from '@/modules/core/ui/Input';
import { Encounter, LabCategory, LabFlag } from '@/types/database';

interface LabResultsFormProps {
  encounter: Encounter;
  onSaved?: () => void;
}

export function LabResultsForm({ encounter, onSaved }: LabResultsFormProps) {
  const { addLabResult } = useStore();

  const [testName, setTestName] = useState('Full Blood Count (FBC)');
  const [category, setCategory] = useState<LabCategory>('Hematology');
  const [flag, setFlag] = useState<LabFlag>('normal');
  const [summary, setSummary] = useState('Hb: 13.8 g/dL, WBC: 6.8 x10^9/L, Platelets: 240 x10^9/L');
  const [measurements, setMeasurements] = useState('Hemoglobin: 13.8 (Ref 12.0-16.0), Platelets: 240 (Ref 150-450)');
  const [isSaved, setIsSaved] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    await addLabResult(encounter.id, {
      test_name: testName,
      category,
      flag,
      summary_notes: summary,
      measurements,
    });

    setIsSaved(true);
    if (onSaved) onSaved();
    setTimeout(() => setIsSaved(false), 3000);
  };


  return (
    <div className="bg-white rounded-3xl border border-slate-200 p-6 space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h3 className="text-base font-bold text-slate-900 flex items-center gap-2">
            <FlaskConical className="w-5 h-5 text-[#2E7D32]" />
            Order & Enter Diagnostic Laboratory Results
          </h3>
          <p className="text-xs text-slate-500">Hematology, Biochemistry, Microbiology & Urinalysis panels</p>
        </div>

        {isSaved && (
          <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-[#E8F5E9] text-[#1B5E20] border border-[#C8E6C9]">
            <CheckCircle2 className="w-4 h-4 text-[#2E7D32]" /> Lab Result Logged
          </span>
        )}
      </div>

      <form onSubmit={handleSubmit} className="space-y-4">
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <Input
            label="Diagnostic Investigation Name"
            placeholder="e.g. Lipid Profile / Fasting Glucose"
            value={testName}
            onChange={(e) => setTestName(e.target.value)}
            required
          />

          <div className="space-y-1.5">
            <label className="block text-xs font-semibold text-slate-700">Lab Discipline</label>
            <select
              value={category}
              onChange={(e: React.ChangeEvent<HTMLSelectElement>) => setCategory(e.target.value as LabCategory)}
              className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C] text-slate-800"
            >
              <option value="Hematology">Hematology</option>
              <option value="Biochemistry">Clinical Biochemistry</option>
              <option value="Microbiology">Microbiology & Cultures</option>
              <option value="Imaging/Radiology">Imaging & Radiology</option>
              <option value="Pathology">Pathology & Histology</option>
              <option value="Other">Other Diagnostic</option>
            </select>
          </div>

          <div className="space-y-1.5">
            <label className="block text-xs font-semibold text-slate-700">Diagnostic Severity Flag</label>
            <select
              value={flag}
              onChange={(e: React.ChangeEvent<HTMLSelectElement>) => setFlag(e.target.value as LabFlag)}
              className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C] text-slate-800"
            >
              <option value="normal">Normal (Within Reference)</option>
              <option value="abnormal">Abnormal (Attention Required)</option>
              <option value="critical">Critical (Immediate Alert)</option>
            </select>
          </div>
        </div>

        <div className="space-y-1.5">
          <label className="block text-xs font-semibold text-slate-700">Clinical Interpretation Summary</label>
          <input
            type="text"
            placeholder="e.g. Normal white cell count, healthy glycemic control."
            value={summary}
            onChange={(e) => setSummary(e.target.value)}
            className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C] text-slate-800"
            required
          />
        </div>

        <div className="space-y-1.5">
          <label className="block text-xs font-semibold text-slate-700">Raw Analyte Measurements & Ranges</label>
          <textarea
            rows={2}
            placeholder="e.g. Total Cholesterol: 4.8 mmol/L (Ref < 5.2), HDL: 1.4 mmol/L..."
            value={measurements}
            onChange={(e) => setMeasurements(e.target.value)}
            className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C] text-slate-800"
          />
        </div>

        <div className="flex items-center justify-end">
          <Button type="submit" leftIcon={<CheckCircle2 className="w-4 h-4" />}>
            Attach Lab Result
          </Button>
        </div>
      </form>
    </div>
  );
}
