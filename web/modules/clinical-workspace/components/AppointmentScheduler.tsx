'use client';

import React, { useState } from 'react';
import { Calendar, CheckCircle2, AlertCircle } from 'lucide-react';
import { Button } from '@/modules/core/ui/Button';
import { Input } from '@/modules/core/ui/Input';
import { Encounter } from '@/types/database';
import { getApiErrorMessage } from '@/lib/api/client';
import { scheduleAppointmentAction } from '../actions/startEncounter';

interface AppointmentSchedulerProps {
  encounter: Encounter;
  onSaved?: () => void;
}

export function AppointmentScheduler({ encounter, onSaved }: AppointmentSchedulerProps) {
  const [date, setDate] = useState('');
  const [time, setTime] = useState('10:00');
  const [notes, setNotes] = useState('4-week routine clinical review');
  const [isSaved, setIsSaved] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    if (!date) {
      setError('Select an appointment date.');
      return;
    }

    setIsSubmitting(true);
    try {
      const scheduledAt = new Date(`${date}T${time}:00`).toISOString();
      await scheduleAppointmentAction(encounter.patient_id, {
        scheduled_at: scheduledAt,
        notes,
      });
      setIsSaved(true);
      if (onSaved) onSaved();
      setTimeout(() => setIsSaved(false), 3000);
    } catch (err) {
      setError(getApiErrorMessage(err, 'Failed to book the follow-up appointment. Please try again.'));
    } finally {
      setIsSubmitting(false);
    }
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
        {error && (
          <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-xs text-rose-700 flex items-start gap-2">
            <AlertCircle className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
            <span>{error}</span>
          </div>
        )}

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
          <Button type="submit" isLoading={isSubmitting} leftIcon={<CheckCircle2 className="w-4 h-4" />}>
            Book Follow-up Date
          </Button>
        </div>
      </form>
    </div>
  );
}
