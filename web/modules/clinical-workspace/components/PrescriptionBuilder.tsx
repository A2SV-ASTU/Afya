'use client';

import React, { useState } from 'react';
import { Pill, CheckCircle2, Calculator, AlertCircle } from 'lucide-react';
import { Button } from '@/modules/core/ui/Button';
import { Input } from '@/modules/core/ui/Input';
import { Encounter } from '@/types/database';
import { useMedicationCalculator } from '../hooks/useMedicationCalculator';
import { getApiErrorMessage } from '@/lib/api/client';
import { savePrescriptionAction } from '../actions/startEncounter';
import {
  PRESCRIPTION_ROUTE_OPTIONS,
  PRESCRIPTION_FREQUENCY_OPTIONS,
  DURATION_UNIT_OPTIONS,
} from '../lib/encounterMappers';

interface PrescriptionBuilderProps {
  encounter: Encounter;
  onSaved?: () => void;
}

export function PrescriptionBuilder({ encounter, onSaved }: PrescriptionBuilderProps) {
  const [medName, setMedName] = useState('Amlodipine Besylate');
  const [dose, setDose] = useState('5mg');
  const [route, setRoute] = useState('oral');
  const [frequency, setFrequency] = useState('OD');
  const [durationValue, setDurationValue] = useState('30');
  const [durationUnit, setDurationUnit] = useState('day');
  const [instructions, setInstructions] = useState('Take with or after breakfast. Do not miss doses.');
  const [isSaved, setIsSaved] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const calc = useMedicationCalculator(dose, frequency, `${durationValue} ${durationUnit}`);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    const parsedDuration = parseInt(durationValue, 10);
    if (!parsedDuration || parsedDuration <= 0) {
      setError('Treatment duration must be a positive number.');
      return;
    }

    setIsSubmitting(true);
    try {
      await savePrescriptionAction(encounter.id, {
        medication_name: medName,
        dose,
        route,
        frequency,
        duration_value: parsedDuration,
        duration_unit: durationUnit,
        instructions: instructions || undefined,
      });
      setIsSaved(true);
      if (onSaved) onSaved();
      setTimeout(() => setIsSaved(false), 3000);
    } catch (err) {
      setError(getApiErrorMessage(err, 'Failed to sign prescription. Please try again.'));
    } finally {
      setIsSubmitting(false);
    }
  };


  return (
    <div className="bg-white rounded-3xl border border-slate-200 p-6 space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h3 className="text-base font-bold text-slate-900 flex items-center gap-2">
            <Pill className="w-5 h-5 text-[#2E7D32]" />
            Prescribe Medication (E-Prescription)
          </h3>
          <p className="text-xs text-slate-500">Formulary prescription builder with automatic dispense calculation</p>
        </div>

        {isSaved && (
          <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-[#E8F5E9] text-[#1B5E20] border border-[#C8E6C9]">
            <CheckCircle2 className="w-4 h-4 text-[#2E7D32]" /> E-Prescription Signed
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
          <div className="sm:col-span-2">
            <Input
              label="Medication Generic / Brand Name"
              placeholder="e.g. Metformin HCl / Amoxicillin"
              value={medName}
              onChange={(e) => setMedName(e.target.value)}
              required
            />
          </div>

          <Input
            label="Single Unit Strength / Dose"
            placeholder="e.g. 500mg, 10ml, 1 puff"
            value={dose}
            onChange={(e) => setDose(e.target.value)}
            required
          />
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <div className="space-y-1.5">
            <label className="block text-xs font-semibold text-slate-700">Route of Administration</label>
            <select
              value={route}
              onChange={(e) => setRoute(e.target.value)}
              className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C] text-slate-800"
            >
              {PRESCRIPTION_ROUTE_OPTIONS.map((opt) => (
                <option key={opt.value} value={opt.value}>
                  {opt.label}
                </option>
              ))}
            </select>
          </div>

          <div className="space-y-1.5">
            <label className="block text-xs font-semibold text-slate-700">Dosing Frequency</label>
            <select
              value={frequency}
              onChange={(e) => setFrequency(e.target.value)}
              className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C] text-slate-800"
            >
              {PRESCRIPTION_FREQUENCY_OPTIONS.map((opt) => (
                <option key={opt.value} value={opt.value}>
                  {opt.label}
                </option>
              ))}
            </select>
          </div>

          <Input
            label="Duration"
            type="number"
            min={1}
            placeholder="e.g. 30"
            value={durationValue}
            onChange={(e) => setDurationValue(e.target.value)}
            required
          />

          <div className="space-y-1.5">
            <label className="block text-xs font-semibold text-slate-700">Duration Unit</label>
            <select
              value={durationUnit}
              onChange={(e) => setDurationUnit(e.target.value)}
              className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C] text-slate-800"
            >
              {DURATION_UNIT_OPTIONS.map((opt) => (
                <option key={opt.value} value={opt.value}>
                  {opt.label}
                </option>
              ))}
            </select>
          </div>
        </div>

        <Input
          label="Dispense & Patient Instructions"
          placeholder="e.g. Complete the full course even if feeling better."
          value={instructions}
          onChange={(e) => setInstructions(e.target.value)}
        />

        {/* Real-time Pharmacy Dispense Calculation */}
        <div className="p-3.5 rounded-2xl bg-slate-50 border border-slate-200 flex items-center justify-between text-xs">
          <div className="flex items-center gap-2 text-slate-600">
            <Calculator className="w-4 h-4 text-[#2E7D32]" />
            <span>Calculated Total Pharmacy Dispense:</span>
          </div>
          <div className="flex items-center gap-3">
            <span className="font-bold text-slate-900 bg-white px-2.5 py-1 rounded-lg border border-slate-200">
              {calc.totalQuantityPills} units / pills total
            </span>
          </div>
        </div>

        <div className="flex items-center justify-end">
          <Button type="submit" isLoading={isSubmitting} leftIcon={<CheckCircle2 className="w-4 h-4" />}>
            Sign & Add to E-Prescriptions
          </Button>
        </div>
      </form>
    </div>
  );
}
