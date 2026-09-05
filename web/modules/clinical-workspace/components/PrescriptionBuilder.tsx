'use client';

import React, { useState } from 'react';
import { Pill, CheckCircle2, Calculator, AlertCircle } from 'lucide-react';
import { useStore } from '@/lib/store';
import { Button } from '@/modules/core/ui/Button';
import { Input } from '@/modules/core/ui/Input';
import { Encounter } from '@/types/database';
import { useMedicationCalculator } from '../hooks/useMedicationCalculator';

interface PrescriptionBuilderProps {
  encounter: Encounter;
  onSaved?: () => void;
}

export function PrescriptionBuilder({ encounter, onSaved }: PrescriptionBuilderProps) {
  const { addPrescription } = useStore();

  const [medName, setMedName] = useState('Amlodipine Besylate');
  const [dose, setDose] = useState('5mg');
  const [route, setRoute] = useState('Oral');
  const [frequency, setFrequency] = useState('Once daily (OD) in the morning');
  const [duration, setDuration] = useState('30 days');
  const [instructions, setInstructions] = useState('Take with or after breakfast. Do not miss doses.');
  const [isSaved, setIsSaved] = useState(false);

  const calc = useMedicationCalculator(dose, frequency, duration);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    await addPrescription(encounter.id, {
      medication_name: medName,
      dose,
      route,
      frequency,
      duration,
      instructions,
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

        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div className="space-y-1.5">
            <label className="block text-xs font-semibold text-slate-700">Route of Administration</label>
            <select
              value={route}
              onChange={(e) => setRoute(e.target.value)}
              className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C] text-slate-800"
            >
              <option value="Oral">Oral (PO)</option>
              <option value="Intravenous">Intravenous (IV)</option>
              <option value="Intramuscular">Intramuscular (IM)</option>
              <option value="Subcutaneous">Subcutaneous (SC)</option>
              <option value="Inhalation">Inhalation</option>
              <option value="Topical">Topical</option>
              <option value="Ophthalmic">Ophthalmic (Eye Drops)</option>
            </select>
          </div>

          <Input
            label="Dosing Frequency"
            placeholder="e.g. Twice daily (BD) after meals"
            value={frequency}
            onChange={(e) => setFrequency(e.target.value)}
            required
          />

          <Input
            label="Treatment Duration"
            placeholder="e.g. 7 days, 30 days"
            value={duration}
            onChange={(e) => setDuration(e.target.value)}
            required
          />
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
          <Button type="submit" leftIcon={<CheckCircle2 className="w-4 h-4" />}>
            Sign & Add to E-Prescriptions
          </Button>
        </div>
      </form>
    </div>
  );
}
