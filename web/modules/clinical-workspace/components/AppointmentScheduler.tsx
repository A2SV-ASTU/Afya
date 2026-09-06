'use client';

import React, { useState } from 'react';
import { Calendar, CheckCircle2, Clock } from 'lucide-react';
import { useStore } from '@/lib/store';
import { Button } from '@/modules/core/ui/Button';
import { Input } from '@/modules/core/ui/Input';
import { Encounter } from '@/types/database';

interface AppointmentSchedulerProps {
  encounter: Encounter;
  onSaved?: () => void;
}

export function AppointmentScheduler({ encounter, onSaved }: AppointmentSchedulerProps) {
  const { addEncounterAppointment } = useStore();

  const [date, setDate] = useState('2025-04-15');
  const [time, setTime] = useState('10:00');
  const [notes, setNotes] = useState('4-week routine clinical review of BP response to Amlodipine');
  const [isSaved, setIsSaved] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    const scheduledAt = `${date}T${time}:00Z`;
    await addEncounterAppointment(encounter.id, {
      scheduled_at: scheduledAt,
      notes,
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
            <Calendar className="w-5 h-5 text-[#2E7D32]" />
            Schedule Clinical Follow-up Appointment
          </h3>
          <p className="text-xs text-slate-500">Book next outpatient review date for patient continuity of care</p>
        </div>

        {isSaved && (
          <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-[#E8F5E9] text-[#1B5E20] border border-[#C8E6C9]">
            <CheckCircle2 className="w-4 h-4 text-[#2E7D32]" /> Follow-up Booked
          </span>
        )}
      </div>

      <form onSubmit={handleSubmit} className="space-y-4">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <Input
            label="Appointment Date"
            type="date"
            value={date}
            onChange={(e) => setDate(e.target.value)}
            required
          />

          <Input
            label="Target Time Window"
            type="time"
            value={time}
            onChange={(e) => setTime(e.target.value)}
            required
          />
        </div>

        <Input
          label="Clinical Follow-up Objectives & Instructions"
          placeholder="e.g. Fasting blood sugar recheck and review of daily BP logs."
          value={notes}
          onChange={(e) => setNotes(e.target.value)}
          required
        />

        <div className="flex items-center justify-end">
          <Button type="submit" leftIcon={<CheckCircle2 className="w-4 h-4" />}>
            Book Follow-up Date
          </Button>
        </div>
      </form>
    </div>
  );
}
