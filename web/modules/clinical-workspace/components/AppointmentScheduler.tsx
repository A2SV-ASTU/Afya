'use client';

import React, { useCallback, useEffect, useState } from 'react';
import { Calendar, CheckCircle2, AlertCircle, Clock, Loader2 } from 'lucide-react';
import { Button } from '@/modules/core/ui/Button';
import { Input } from '@/modules/core/ui/Input';
import { Appointment, Encounter } from '@/types/database';
import { appointmentsApi } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api/client';
import { formatDateTime } from '@/modules/core/lib/utils';
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

  const [existingAppointments, setExistingAppointments] = useState<Appointment[]>([]);
  const [isLoadingAppointments, setIsLoadingAppointments] = useState(false);

  const loadExistingAppointments = useCallback(async () => {
    setIsLoadingAppointments(true);
    try {
      const res = await appointmentsApi.listForPatient(encounter.patient_id, 'scheduled');
      setExistingAppointments(res.appointments || []);
    } catch {
      // Non-critical, ignore
    } finally {
      setIsLoadingAppointments(false);
    }
  }, [encounter.patient_id]);

  useEffect(() => {
    loadExistingAppointments();
  }, [loadExistingAppointments]);

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
      await loadExistingAppointments();
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

      {/* Existing Upcoming Appointments for this Patient */}
      <div className="pt-4 border-t border-slate-100 space-y-3">
        <div className="flex items-center justify-between">
          <h4 className="text-xs font-bold text-slate-800 flex items-center gap-1.5 uppercase tracking-wider">
            <Clock className="w-3.5 h-3.5 text-[#2E7D32]" />
            Upcoming Scheduled Appointments for Patient ({existingAppointments.length})
          </h4>
          {isLoadingAppointments && <Loader2 className="w-3.5 h-3.5 animate-spin text-slate-400" />}
        </div>

        {existingAppointments.length === 0 ? (
          <p className="text-xs text-slate-400 italic">No other future appointments booked for this patient.</p>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            {existingAppointments.map((apt) => (
              <div
                key={apt.id}
                className="p-3.5 rounded-2xl bg-slate-50 border border-slate-200/80 text-xs space-y-1"
              >
                <div className="flex items-center justify-between">
                  <span className="font-bold text-slate-900">
                    {formatDateTime(apt.scheduled_at)}
                  </span>
                  <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-[#E8F5E9] text-[#1B5E20] border border-[#C8E6C9] uppercase">
                    {apt.status}
                  </span>
                </div>
                {apt.clinic_name && (
                  <p className="text-[11px] text-slate-500">Facility: {apt.clinic_name}</p>
                )}
                {apt.doctor_name && (
                  <p className="text-[11px] text-slate-500">Doctor: Dr. {apt.doctor_name}</p>
                )}
                {apt.notes && (
                  <p className="text-[11px] text-slate-700 italic mt-1 bg-white p-2 rounded-xl border border-slate-100">
                    &ldquo;{apt.notes}&rdquo;
                  </p>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
