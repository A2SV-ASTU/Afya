'use client';

import React, { useCallback, useEffect, useState } from 'react';
import { Button } from '@/modules/core/ui/Button';
import { Save, AlertCircle, Lock, Loader2 } from 'lucide-react';
import { clinicalEvaluationsApi } from '@/lib/api';
import { ApiError, getApiErrorMessage } from '@/lib/api/client';

interface ClinicalEvaluationFormProps {
  encounterId: string;
  isClosed: boolean;
  onSaved: () => void;
}

interface EvaluationFields {
  chief_complaint: string;
  history_of_present_illness: string;
  past_admissions: string;
  family_history: string;
  allergies_notes: string;
  general_appearance: string;
}

const EMPTY_FIELDS: EvaluationFields = {
  chief_complaint: '',
  history_of_present_illness: '',
  past_admissions: '',
  family_history: '',
  allergies_notes: '',
  general_appearance: '',
};

export function ClinicalEvaluationForm({ encounterId, isClosed, onSaved }: ClinicalEvaluationFormProps) {
  const [formData, setFormData] = useState<EvaluationFields>(EMPTY_FIELDS);
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [alreadyRecorded, setAlreadyRecorded] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadExisting = useCallback(async () => {
    setIsLoading(true);
    try {
      const res = await clinicalEvaluationsApi.getByEncounterId(encounterId);
      const evaluation = res.clinical_evaluation;
      if (evaluation) {
        setFormData({
          chief_complaint: evaluation.chief_complaint || '',
          history_of_present_illness: evaluation.history_of_present_illness || '',
          past_admissions: evaluation.past_admissions || '',
          family_history: evaluation.family_history || '',
          allergies_notes: evaluation.allergies_notes || '',
          general_appearance: evaluation.general_appearance || '',
        });
        setAlreadyRecorded(true);
      }
    } catch (err) {
      // A 404 simply means no evaluation has been recorded yet — that is expected.
      if (!(err instanceof ApiError && err.status === 404)) {
        setError(getApiErrorMessage(err, 'Failed to load clinical evaluation.'));
      }
    } finally {
      setIsLoading(false);
    }
  }, [encounterId]);

  useEffect(() => {
    loadExisting();
  }, [loadExisting]);

  const handleChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    setFormData((prev) => ({ ...prev, [e.target.name]: e.target.value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (isClosed || alreadyRecorded) return;
    setError(null);

    if (!formData.chief_complaint.trim() || !formData.history_of_present_illness.trim()) {
      setError('Chief complaint and history of present illness are required.');
      return;
    }

    setIsSaving(true);
    try {
      await clinicalEvaluationsApi.create(encounterId, {
        chief_complaint: formData.chief_complaint.trim(),
        history_of_present_illness: formData.history_of_present_illness.trim(),
        past_admissions: formData.past_admissions.trim() || undefined,
        family_history: formData.family_history.trim() || undefined,
        allergies_notes: formData.allergies_notes.trim() || undefined,
        general_appearance: formData.general_appearance.trim() || undefined,
      });
      setAlreadyRecorded(true);
      onSaved();
    } catch (err) {
      if (err instanceof ApiError && err.status === 409) {
        // Another writer (or the "new encounter" step) already created it — reload it.
        setAlreadyRecorded(true);
        await loadExisting();
      } else {
        setError(getApiErrorMessage(err, 'Failed to save clinical evaluation.'));
      }
    } finally {
      setIsSaving(false);
    }
  };

  const readOnly = isClosed || alreadyRecorded;
  const fieldClass =
    'w-full px-3.5 py-2.5 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C] disabled:bg-slate-50 disabled:text-slate-500';

  if (isLoading) {
    return (
      <div className="bg-white rounded-3xl border border-slate-200 shadow-2xs p-10 flex items-center justify-center gap-2 text-xs text-slate-500">
        <Loader2 className="w-4 h-4 animate-spin" />
        Loading clinical evaluation…
      </div>
    );
  }

  return (
    <div className="bg-white rounded-3xl border border-slate-200 shadow-2xs overflow-hidden">
      <div className="p-5 border-b border-slate-100 bg-slate-50/60 flex items-center justify-between">
        <div>
          <h3 className="text-sm font-bold text-slate-900">Clinical Evaluation &amp; Notes</h3>
          <p className="text-xs text-slate-500">Record subjective and objective findings.</p>
        </div>
        {readOnly && (
          <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[11px] font-semibold bg-slate-100 text-slate-600 border border-slate-200">
            <Lock className="w-3.5 h-3.5" />
            {isClosed ? 'Encounter sealed' : 'Recorded'}
          </span>
        )}
      </div>

      <form onSubmit={handleSubmit} className="p-6 space-y-5">
        {error && (
          <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-xs text-rose-700 flex items-start gap-2">
            <AlertCircle className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
            <span>{error}</span>
          </div>
        )}

        {alreadyRecorded && !isClosed && (
          <p className="text-[11px] text-slate-400">
            The initial clinical evaluation has been recorded and cannot be edited from here yet.
          </p>
        )}

        <div className="space-y-1.5">
          <label className="text-xs font-semibold text-slate-800">
            Chief Complaint <span className="text-rose-500">*</span>
          </label>
          <textarea
            name="chief_complaint"
            value={formData.chief_complaint}
            onChange={handleChange}
            disabled={readOnly}
            className={fieldClass}
            rows={2}
          />
        </div>

        <div className="space-y-1.5">
          <label className="text-xs font-semibold text-slate-800">
            History of Present Illness <span className="text-rose-500">*</span>
          </label>
          <textarea
            name="history_of_present_illness"
            value={formData.history_of_present_illness}
            onChange={handleChange}
            disabled={readOnly}
            className={fieldClass}
            rows={3}
          />
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-slate-800">Past Admissions / Surgeries</label>
            <textarea
              name="past_admissions"
              value={formData.past_admissions}
              onChange={handleChange}
              disabled={readOnly}
              className={fieldClass}
              rows={2}
            />
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-slate-800">Family History</label>
            <textarea
              name="family_history"
              value={formData.family_history}
              onChange={handleChange}
              disabled={readOnly}
              className={fieldClass}
              rows={2}
            />
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-slate-800">Allergies Notes</label>
            <textarea
              name="allergies_notes"
              value={formData.allergies_notes}
              onChange={handleChange}
              disabled={readOnly}
              className={fieldClass}
              rows={2}
            />
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-slate-800">General Physical Appearance</label>
            <textarea
              name="general_appearance"
              value={formData.general_appearance}
              onChange={handleChange}
              disabled={readOnly}
              className={fieldClass}
              rows={2}
            />
          </div>
        </div>

        {!readOnly && (
          <div className="pt-4 flex justify-end border-t border-slate-100">
            <Button type="submit" isLoading={isSaving} leftIcon={<Save className="w-4 h-4" />}>
              Save Notes
            </Button>
          </div>
        )}
      </form>
    </div>
  );
}
