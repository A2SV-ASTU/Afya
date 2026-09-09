'use client';

import React, { useState } from 'react';
import { FlaskConical, CheckCircle2, AlertCircle } from 'lucide-react';
import { Button } from '@/modules/core/ui/Button';
import { Input } from '@/modules/core/ui/Input';
import { Encounter, LabFlag } from '@/types/database';
import { getApiErrorMessage } from '@/lib/api/client';
import { saveLabResultAction } from '../actions/startEncounter';
import { LAB_CATEGORY_OPTIONS } from '../lib/encounterMappers';

interface LabResultsFormProps {
  encounter: Encounter;
  onSaved?: () => void;
}

export function LabResultsForm({ encounter, onSaved }: LabResultsFormProps) {
  const [testName, setTestName] = useState('Full Blood Count (FBC)');
  const [category, setCategory] = useState<string>('laboratory');
  const [flag, setFlag] = useState<LabFlag>('normal');
  const [summary, setSummary] = useState('Hb: 13.8 g/dL, WBC: 6.8 x10^9/L, Platelets: 240 x10^9/L');
  const [measurements, setMeasurements] = useState('Hemoglobin: 13.8, Platelets: 240');
  const [isSaved, setIsSaved] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setIsSubmitting(true);
    try {
      await saveLabResultAction(encounter.id, {
        test_name: testName,
        category,
        flag,
        summary_notes: summary,
        measurements,
      });
      setIsSaved(true);
      if (onSaved) onSaved();
      setTimeout(() => setIsSaved(false), 3000);
    } catch (err) {
      setError(getApiErrorMessage(err, 'Failed to attach lab result. Please try again.'));
    } finally {
      setIsSubmitting(false);
    }
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
        {error && (
          <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-xs text-rose-700 flex items-start gap-2">
            <AlertCircle className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
            <span>{error}</span>
          </div>
        )}

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
              onChange={(e: React.ChangeEvent<HTMLSelectElement>) => setCategory(e.target.value)}
              className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C] text-slate-800"
            >
              {LAB_CATEGORY_OPTIONS.map((opt) => (
                <option key={opt.value} value={opt.value}>
                  {opt.label}
                </option>
              ))}
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
          <label className="block text-xs font-semibold text-slate-700">Analyte Measurements</label>
          <textarea
            rows={2}
            placeholder="analyte: value pairs, e.g. hemoglobin: 13.8, platelets: 240, wbc: 6.8"
            value={measurements}
            onChange={(e) => setMeasurements(e.target.value)}
            className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C] text-slate-800"
          />
          <p className="text-[10px] text-slate-400">
            Enter one or more <span className="font-mono">name: value</span> pairs separated by commas.
          </p>
        </div>

        <div className="flex items-center justify-end">
          <Button type="submit" isLoading={isSubmitting} leftIcon={<CheckCircle2 className="w-4 h-4" />}>
            Attach Lab Result
          </Button>
        </div>
      </form>
    </div>
  );
}
