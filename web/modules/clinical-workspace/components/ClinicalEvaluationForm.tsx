'use client';

import React, { useState } from 'react';
import { Button } from '@/modules/core/ui/Button';
import { Save } from 'lucide-react';
import { clinicalEvaluationsApi } from '@/lib/api';

interface ClinicalEvaluationFormProps {
  encounterId: string;
  isClosed: boolean;
  onSaved: () => void;
  // you might pass the existing evaluation if you have it in encounter
}

export function ClinicalEvaluationForm({ encounterId, isClosed, onSaved }: ClinicalEvaluationFormProps) {
  const [isSaving, setIsSaving] = useState(false);

  const [formData, setFormData] = useState({
    chief_complaint: '',
    history_of_present_illness: '',
    past_medical_history: '',
    family_history: '',
    allergies: '',
    physical_examination: '',
  });

  const handleChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    setFormData(prev => ({ ...prev, [e.target.name]: e.target.value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (isClosed) return;
    setIsSaving(true);
    try {
      await clinicalEvaluationsApi.create(encounterId, formData);
      onSaved();
    } catch (err) {
      console.error(err);
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="bg-white rounded-3xl border border-slate-200 shadow-2xs overflow-hidden">
      <div className="p-5 border-b border-slate-100 bg-slate-50/60 flex items-center justify-between">
        <div>
          <h3 className="text-sm font-bold text-slate-900">Clinical Evaluation & Notes</h3>
          <p className="text-xs text-slate-500">Record subjective and objective findings.</p>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="p-6 space-y-5">
        <div className="space-y-1.5">
          <label className="text-xs font-semibold text-slate-800">Chief Complaint</label>
          <textarea
            name="chief_complaint"
            value={formData.chief_complaint}
            onChange={handleChange}
            disabled={isClosed}
            className="w-full px-3.5 py-2.5 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C]"
            rows={2}
          />
        </div>

        <div className="space-y-1.5">
          <label className="text-xs font-semibold text-slate-800">History of Present Illness</label>
          <textarea
            name="history_of_present_illness"
            value={formData.history_of_present_illness}
            onChange={handleChange}
            disabled={isClosed}
            className="w-full px-3.5 py-2.5 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C]"
            rows={3}
          />
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-slate-800">Past Admissions / Surgeries</label>
            <textarea
              name="past_medical_history"
              value={formData.past_medical_history}
              onChange={handleChange}
              disabled={isClosed}
              className="w-full px-3.5 py-2.5 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C]"
              rows={2}
            />
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-slate-800">Family History</label>
            <textarea
              name="family_history"
              value={formData.family_history}
              onChange={handleChange}
              disabled={isClosed}
              className="w-full px-3.5 py-2.5 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C]"
              rows={2}
            />
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-slate-800">Allergies Notes</label>
            <textarea
              name="allergies"
              value={formData.allergies}
              onChange={handleChange}
              disabled={isClosed}
              className="w-full px-3.5 py-2.5 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C]"
              rows={2}
            />
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-slate-800">General Physical Appearance</label>
            <textarea
              name="physical_examination"
              value={formData.physical_examination}
              onChange={handleChange}
              disabled={isClosed}
              className="w-full px-3.5 py-2.5 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C]"
              rows={2}
            />
          </div>
        </div>

        {!isClosed && (
          <div className="pt-4 flex justify-end border-t border-slate-100">
            <Button
              type="submit"
              isLoading={isSaving}
              leftIcon={<Save className="w-4 h-4" />}
            >
              Save Notes
            </Button>
          </div>
        )}
      </form>
    </div>
  );
}
