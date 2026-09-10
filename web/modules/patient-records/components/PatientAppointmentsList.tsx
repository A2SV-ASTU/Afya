'use client';

import React, { useCallback, useEffect, useState } from 'react';
import { Calendar, Clock, RefreshCw, AlertCircle } from 'lucide-react';
import { appointmentsApi } from '@/lib/api/appointments';
import { getApiErrorMessage } from '@/lib/api/client';
import { StatusBadge } from '@/modules/core/ui/StatusBadge';
import { Button } from '@/modules/core/ui/Button';
import { formatDateTime } from '@/modules/core/lib/utils';
import { Appointment } from '@/types/database';
import { UpdatableAppointmentStatus } from '@/lib/api/appointments';

interface PatientAppointmentsListProps {
  patientId: string;
}

export function PatientAppointmentsList({ patientId }: PatientAppointmentsListProps) {
  const [appointments, setAppointments] = useState<Appointment[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [updatingId, setUpdatingId] = useState<string | null>(null);

  const fetchAppointments = useCallback(async () => {
    if (!patientId) {
      setIsLoading(false);
      return;
    }
    setIsLoading(true);
    setError(null);
    try {
      const res = await appointmentsApi.listForPatient(patientId);
      const list = res.appointments || [];
      // Sort newest first
      list.sort((a, b) => new Date(b.scheduled_at).getTime() - new Date(a.scheduled_at).getTime());
      setAppointments(list);
    } catch (err) {
      setError(getApiErrorMessage(err, 'Failed to load follow-up consultations.'));
    } finally {
      setIsLoading(false);
    }
  }, [patientId]);

  useEffect(() => {
    fetchAppointments();
  }, [fetchAppointments]);

  const handleUpdateStatus = async (appointmentId: string, status: UpdatableAppointmentStatus) => {
    setUpdatingId(appointmentId);
    try {
      await appointmentsApi.updateStatus(appointmentId, status);
      setAppointments((prev) =>
        prev.map((a) => (a.id === appointmentId ? { ...a, status } : a))
      );
    } catch (err) {
      setError(getApiErrorMessage(err, `Failed to update appointment to ${status}.`));
    } finally {
      setUpdatingId(null);
    }
  };

  if (isLoading) {
    return (
      <div className="p-8 text-center bg-white rounded-3xl border border-slate-200 text-xs text-slate-500">
        <RefreshCw className="w-4 h-4 animate-spin mx-auto mb-2 text-[#2E7D32]" />
        Loading scheduled reviews &amp; follow-ups…
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-8 text-center bg-white rounded-3xl border border-rose-200 text-xs text-rose-600 space-y-3">
        <p>{error}</p>
        <Button variant="outline" size="sm" onClick={fetchAppointments}>
          Retry
        </Button>
      </div>
    );
  }

  if (appointments.length === 0) {
    return (
      <div className="p-8 text-center bg-white rounded-3xl border border-slate-200 text-xs text-slate-500">
        No follow-up consultations or reviews scheduled for this patient.
      </div>
    );
  }

  return (
    <div className="bg-white rounded-3xl border border-slate-200 shadow-xs overflow-hidden">
      <div className="p-6 border-b border-slate-100 flex items-center justify-between">
        <h3 className="text-base font-bold text-slate-900 flex items-center gap-2">
          <Calendar className="w-5 h-5 text-[#2E7D32]" />
          Scheduled Reviews &amp; Consultations ({appointments.length})
        </h3>
        <Button variant="outline" size="sm" onClick={fetchAppointments} disabled={isLoading}>
          <RefreshCw className={`w-3.5 h-3.5 mr-1.5 ${isLoading ? 'animate-spin' : ''}`} />
          Refresh
        </Button>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full text-left text-xs border-collapse">
          <thead>
            <tr className="border-b border-slate-100 bg-slate-50/75 text-slate-500 font-semibold uppercase tracking-wider text-[11px]">
              <th className="py-3 px-6">Scheduled Date &amp; Time</th>
              <th className="py-3 px-6">Clinical Review Purpose</th>
              <th className="py-3 px-6">Attending Physician</th>
              <th className="py-3 px-6">Status</th>
              <th className="py-3 px-6 text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 font-medium text-slate-700">
            {appointments.map((appt, idx) => {
              const isUpdating = updatingId === appt.id;
              return (
                <tr key={appt.id || `appt-${idx}`} className="hover:bg-slate-50/60 transition-colors">
                  <td className="py-4 px-6 font-mono text-slate-800">
                    {formatDateTime(appt.scheduled_at)}
                  </td>
                  <td className="py-4 px-6 text-slate-600 max-w-sm">
                    {appt.notes || 'Routine Follow-up'}
                  </td>
                  <td className="py-4 px-6 text-slate-800">
                    {appt.doctor_name || 'Attending Physician'}
                  </td>
                  <td className="py-4 px-6">
                    <StatusBadge status={appt.status} />
                  </td>
                  <td className="py-4 px-6 text-right">
                    {appt.status === 'scheduled' ? (
                      <div className="flex items-center justify-end gap-1.5">
                        <button
                          type="button"
                          onClick={() => handleUpdateStatus(appt.id, 'attended')}
                          disabled={isUpdating}
                          className="px-2.5 py-1 text-xs font-semibold text-[#1B5E20] bg-[#E8F5E9] hover:bg-[#C8E6C9] rounded-lg transition-colors border border-[#C8E6C9] cursor-pointer disabled:opacity-50"
                        >
                          {isUpdating ? 'Updating…' : 'Mark Attended'}
                        </button>
                        <button
                          type="button"
                          onClick={() => handleUpdateStatus(appt.id, 'missed')}
                          disabled={isUpdating}
                          className="px-2.5 py-1 text-xs font-semibold text-slate-600 hover:bg-slate-100 rounded-lg transition-colors cursor-pointer disabled:opacity-50"
                        >
                          Missed
                        </button>
                        <button
                          type="button"
                          onClick={() => handleUpdateStatus(appt.id, 'cancelled')}
                          disabled={isUpdating}
                          className="px-2 py-1 text-xs text-rose-600 hover:bg-rose-50 rounded-lg transition-colors cursor-pointer disabled:opacity-50"
                        >
                          Cancel
                        </button>
                      </div>
                    ) : (
                      <span className="text-slate-400 text-[11px] italic">Completed</span>
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}
