'use client';

import React, { useState } from 'react';
import { Activity, Heart, Thermometer, Droplets, CheckCircle2, Wind, Scale } from 'lucide-react';
import { useStore } from '@/lib/store';
import { Button } from '@/modules/core/ui/Button';
import { Input } from '@/modules/core/ui/Input';
import { Encounter } from '@/types/database';

interface VitalsRecorderProps {
  encounter: Encounter;
  onSaved?: () => void;
}

export function VitalsRecorder({ encounter, onSaved }: VitalsRecorderProps) {
  const { addVitals } = useStore();

  const [systolic, setSystolic] = useState('120');
  const [diastolic, setDiastolic] = useState('80');
  const [pulse, setPulse] = useState('72');
  const [spo2, setSpo2] = useState('98');
  const [temperature, setTemperature] = useState('36.6');
  const [bloodSugar, setBloodSugar] = useState('5.4');
  const [respiratoryRate, setRespiratoryRate] = useState('16');
  const [weight, setWeight] = useState('70');
  const [notes, setNotes] = useState('');
  const [isSaved, setIsSaved] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    addVitals(encounter.id, {
      systolic_bp: systolic ? parseInt(systolic, 10) : undefined,
      diastolic_bp: diastolic ? parseInt(diastolic, 10) : undefined,
      pulse: pulse ? parseInt(pulse, 10) : undefined,
      spo2: spo2 ? parseInt(spo2, 10) : undefined,
      temperature: temperature ? parseFloat(temperature) : undefined,
      blood_sugar: bloodSugar ? parseFloat(bloodSugar) : undefined,
      respiratory_rate: respiratoryRate ? parseInt(respiratoryRate, 10) : undefined,
      weight: weight ? parseFloat(weight) : undefined,
      notes: notes || undefined,
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
            <Activity className="w-5 h-5 text-[#2E7D32]" />
            Record Point-of-Care Vitals
          </h3>
          <p className="text-xs text-slate-500">
            Standard physiological measurements calibrated to clinical grade standards
          </p>
        </div>

        {isSaved && (
          <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-[#E8F5E9] text-[#1B5E20] border border-[#C8E6C9]">
            <CheckCircle2 className="w-4 h-4 text-[#2E7D32]" /> Vitals Saved to Encounter
          </span>
        )}
      </div>

      <form onSubmit={handleSubmit} className="space-y-5">
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-4">
          <Input
            label="Blood Pressure (Systolic)"
            type="number"
            placeholder="120"
            suffix="mmHg"
            value={systolic}
            onChange={(e) => setSystolic(e.target.value)}
            required
          />

          <Input
            label="Blood Pressure (Diastolic)"
            type="number"
            placeholder="80"
            suffix="mmHg"
            value={diastolic}
            onChange={(e) => setDiastolic(e.target.value)}
            required
          />

          <Input
            label="Heart Rate / Pulse"
            type="number"
            placeholder="72"
            suffix="bpm"
            value={pulse}
            onChange={(e) => setPulse(e.target.value)}
            required
          />

          <Input
            label="SpO2 Oxygen Saturation"
            type="number"
            placeholder="98"
            suffix="%"
            value={spo2}
            onChange={(e) => setSpo2(e.target.value)}
            required
          />

          <Input
            label="Body Temperature"
            type="number"
            step="0.1"
            placeholder="36.6"
            suffix="°C"
            value={temperature}
            onChange={(e) => setTemperature(e.target.value)}
          />

          <Input
            label="Random Blood Sugar"
            type="number"
            step="0.1"
            placeholder="5.4"
            suffix="mmol/L"
            value={bloodSugar}
            onChange={(e) => setBloodSugar(e.target.value)}
          />

          <Input
            label="Respiratory Rate"
            type="number"
            placeholder="16"
            suffix="breaths/min"
            value={respiratoryRate}
            onChange={(e) => setRespiratoryRate(e.target.value)}
          />

          <Input
            label="Body Weight"
            type="number"
            step="0.5"
            placeholder="70.0"
            suffix="kg"
            value={weight}
            onChange={(e) => setWeight(e.target.value)}
          />
        </div>

        <div className="space-y-1.5">
          <label className="block text-xs font-semibold text-slate-700">Clinical Observations & Vitals Notes</label>
          <input
            type="text"
            placeholder="e.g. Patient rested 5 mins prior to blood pressure reading. Regular pulse rhythm."
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C] text-slate-800"
          />
        </div>

        <div className="flex items-center justify-end">
          <Button type="submit" leftIcon={<CheckCircle2 className="w-4 h-4" />}>
            Record & Sign Vitals
          </Button>
        </div>
      </form>
    </div>
  );
}
