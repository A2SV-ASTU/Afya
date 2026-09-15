'use client';

import React, { useCallback, useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import {
  Calendar,
  Clock,
  CheckCircle2,
  AlertCircle,
  RefreshCw,
  Search,
  Users,
  ExternalLink,
  Check,
  XCircle,
} from 'lucide-react';
import { useAuth } from '@/modules/core/context/AuthContext';
import { accessRequestsApi, appointmentsApi } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api/client';
import { StatusBadge } from '@/modules/core/ui/StatusBadge';
import { Button } from '@/modules/core/ui/Button';
import { EmptyState } from '@/modules/core/ui/EmptyState';
import { formatDateTime } from '@/modules/core/lib/utils';
import {
  AccessRequest,
  Appointment,
  AppointmentStatus,
  getAccessRequestPatientName,
  getAccessRequestPatientEmail,
} from '@/types/database';
import { UpdatableAppointmentStatus } from '@/lib/api/appointments';

interface EnrichedAppointment extends Appointment {
  patient_email?: string;
}

export default function DoctorAppointmentsPage() {
  const { currentUser, isReady } = useAuth();
  const clinicId = currentUser?.clinic_id ?? null;

  const [appointments, setAppointments] = useState<EnrichedAppointment[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [updatingId, setUpdatingId] = useState<string | null>(null);
  const [statusFilter, setStatusFilter] = useState<'all' | AppointmentStatus>('all');
  const [searchTerm, setSearchTerm] = useState('');

  const fetchAppointments = useCallback(async () => {
    if (!clinicId) {
      setIsLoading(false);
      setError('Your account is not attached to an active clinic.');
      return;
    }

    setIsLoading(true);
    setError(null);

    try {
      // 1. Fetch authorized patients for this clinic
      const res = await accessRequestsApi.listRequests(clinicId, 'approved');
      const liveGrants = (res.access_requests || []).filter(
        (g) => g.status === 'approved' && !g.revoked_at
      );

      // Deduplicate by patient_id
      const uniqueGrants = new Map<string, AccessRequest>();
      for (const g of liveGrants) {
        if (!uniqueGrants.has(g.patient_id) || new Date(g.created_at) > new Date(uniqueGrants.get(g.patient_id)!.created_at)) {
          uniqueGrants.set(g.patient_id, g);
        }
      }

      const grantsList = Array.from(uniqueGrants.values());
      if (grantsList.length === 0) {
        setAppointments([]);
        setIsLoading(false);
        return;
      }

      // 2. Fetch appointments for all authorized patients in parallel
      const results = await Promise.allSettled(
        grantsList.map(async (grant) => {
          const apptRes = await appointmentsApi.listForPatient(grant.patient_id);
          const patientName = getAccessRequestPatientName(grant);
          const patientEmail = getAccessRequestPatientEmail(grant);

          return (apptRes.appointments || []).map((appt) => ({
            ...appt,
            patient_name: appt.patient_name || patientName,
            patient_email: patientEmail,
            doctor_name: appt.doctor_name || (currentUser ? `Dr. ${currentUser.first_name} ${currentUser.last_name}` : 'Attending Physician'),
          }));
        })
      );

      const allAppts: EnrichedAppointment[] = [];
      for (const r of results) {
        if (r.status === 'fulfilled') {
          allAppts.push(...r.value);
        }
      }

      // Sort: scheduled ones first by date ascending, then others descending
      allAppts.sort((a, b) => {
        if (a.status === 'scheduled' && b.status !== 'scheduled') return -1;
        if (a.status !== 'scheduled' && b.status === 'scheduled') return 1;
        return new Date(a.scheduled_at).getTime() - new Date(b.scheduled_at).getTime();
      });

      setAppointments(allAppts);
    } catch (err) {
      setError(getApiErrorMessage(err, 'Failed to retrieve follow-up appointments.'));
    } finally {
      setIsLoading(false);
    }
  }, [clinicId, currentUser]);

  useEffect(() => {
    if (isReady) fetchAppointments();
  }, [isReady, fetchAppointments]);

  const handleUpdateStatus = async (appointmentId: string, status: UpdatableAppointmentStatus) => {
    setUpdatingId(appointmentId);
    try {
      await appointmentsApi.updateStatus(appointmentId, status);
      // Optimistic update
      setAppointments((prev) =>
        prev.map((a) => (a.id === appointmentId ? { ...a, status } : a))
      );
    } catch (err) {
      setError(getApiErrorMessage(err, `Failed to update appointment to ${status}.`));
    } finally {
      setUpdatingId(null);
    }
  };

  const filteredAppointments = useMemo(() => {
    return appointments.filter((appt) => {
      if (statusFilter !== 'all' && appt.status !== statusFilter) {
        return false;
      }
      if (searchTerm.trim()) {
        const q = searchTerm.toLowerCase().trim();
        const name = (appt.patient_name || '').toLowerCase();
        const email = (appt.patient_email || '').toLowerCase();
        const notes = (appt.notes || '').toLowerCase();
        const doc = (appt.doctor_name || '').toLowerCase();
        return name.includes(q) || email.includes(q) || notes.includes(q) || doc.includes(q);
      }
      return true;
    });
  }, [appointments, statusFilter, searchTerm]);

  const upcomingCount = appointments.filter((a) => a.status === 'scheduled').length;

  return (
    <div className="space-y-6">
      {/* Header Banner */}
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 text-xs font-semibold text-[#2E7D32] uppercase tracking-wider mb-1">
            <Calendar className="w-4 h-4" />
            <span>Clinical Follow-ups &amp; Reviews</span>
          </div>
          <h1 className="text-xl font-bold text-slate-900">Consultation Schedule</h1>
          <p className="text-xs text-slate-500 mt-0.5">
            Chronological schedule for patient reviews, vitals rechecks, and medication evaluations
          </p>
        </div>

        <div className="flex items-center gap-2">
          <Button
            size="sm"
            variant="outline"
            onClick={fetchAppointments}
            disabled={isLoading}
            leftIcon={<RefreshCw className={`w-3.5 h-3.5 ${isLoading ? 'animate-spin' : ''}`} />}
          >
            Refresh Schedule
          </Button>
        </div>
      </div>

      {error && (
        <div className="p-4 rounded-2xl bg-rose-50 border border-rose-200 text-xs text-rose-700 flex items-start gap-2.5">
          <AlertCircle className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
          <span>{error}</span>
        </div>
      )}

      {/* Filter and Search Bar */}
      <div className="bg-white rounded-3xl border border-slate-200 p-4 shadow-xs flex flex-wrap items-center justify-between gap-3">
        <div className="flex flex-wrap items-center gap-1.5">
          {(['all', 'scheduled', 'attended', 'missed', 'cancelled'] as const).map((st) => (
            <button
              key={st}
              type="button"
              onClick={() => setStatusFilter(st)}
              className={`px-3 py-1.5 rounded-xl text-xs font-semibold capitalize transition-colors cursor-pointer ${
                statusFilter === st
                  ? 'bg-[#E8F5E9] text-[#1B5E20] border border-[#C8E6C9]'
                  : 'text-slate-600 hover:bg-slate-100'
              }`}
            >
              {st === 'all' ? `All (${appointments.length})` : `${st} (${appointments.filter((a) => a.status === st).length})`}
            </button>
          ))}
        </div>

        <div className="relative w-full sm:w-64">
          <Search className="w-3.5 h-3.5 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <input
            type="text"
            placeholder="Search patient, notes..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-8 pr-3 py-1.5 text-xs bg-slate-50 border border-slate-200 rounded-xl focus:bg-white focus:outline-none focus:ring-1 focus:ring-[#388E3C]"
          />
        </div>
      </div>

      {/* Appointments Table */}
      <div className="bg-white rounded-3xl border border-slate-200 shadow-xs overflow-hidden">
        <div className="p-6 border-b border-slate-100 flex items-center justify-between">
          <h2 className="text-base font-bold text-slate-900">
            Appointments ({filteredAppointments.length})
          </h2>
          <span className="text-xs text-[#2E7D32] font-semibold bg-[#E8F5E9] px-2.5 py-0.5 rounded-full border border-[#C8E6C9]">
            {upcomingCount} Upcoming Scheduled
          </span>
        </div>

        {isLoading ? (
          <div className="p-12 text-center text-xs text-slate-400">
            <RefreshCw className="w-5 h-5 animate-spin mx-auto mb-2 text-[#2E7D32]" />
            Loading appointments from authorized patient records…
          </div>
        ) : filteredAppointments.length === 0 ? (
          <div className="p-12">
            <EmptyState
              icon={<Calendar className="w-8 h-8 text-slate-300" />}
              title="No appointments match your filter"
              description="Scheduled follow-up consultations booked during clinical encounters will appear here."
            />
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs border-collapse">
              <thead>
                <tr className="border-b border-slate-100 bg-slate-50/75 text-slate-500 font-semibold uppercase tracking-wider text-[11px]">
                  <th className="py-3 px-6">Patient</th>
                  <th className="py-3 px-6">Scheduled Date &amp; Time</th>
                  <th className="py-3 px-6">Clinical Review Purpose</th>
                  <th className="py-3 px-6">Attending Doctor</th>
                  <th className="py-3 px-6">Status</th>
                  <th className="py-3 px-6 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 font-medium text-slate-700">
                {filteredAppointments.map((appt) => {
                  const isUpdating = updatingId === appt.id;
                  return (
                    <tr key={appt.id} className="hover:bg-slate-50/60 transition-colors">
                      <td className="py-4 px-6">
                        <Link
                          href={`/doctor/patients/${appt.patient_id}`}
                          className="font-bold text-slate-900 hover:text-[#2E7D32] inline-flex items-center gap-1 group"
                        >
                          {appt.patient_name}
                          <ExternalLink className="w-3 h-3 text-slate-300 group-hover:text-[#2E7D32]" />
                        </Link>
                        {appt.patient_email && (
                          <p className="text-[11px] text-slate-400">{appt.patient_email}</p>
                        )}
                        <p className="text-[10px] font-mono text-slate-400 mt-0.5">{appt.patient_id}</p>
                      </td>
                      <td className="py-4 px-6 font-mono text-slate-800">
                        {formatDateTime(appt.scheduled_at)}
                      </td>
                      <td className="py-4 px-6 text-slate-600 max-w-xs">
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
                              title="Mark Attended"
                              className="px-2.5 py-1 text-xs font-semibold text-[#1B5E20] bg-[#E8F5E9] hover:bg-[#C8E6C9] rounded-lg transition-colors border border-[#C8E6C9] cursor-pointer disabled:opacity-50"
                            >
                              {isUpdating ? 'Updating…' : 'Mark Attended'}
                            </button>
                            <button
                              type="button"
                              onClick={() => handleUpdateStatus(appt.id, 'missed')}
                              disabled={isUpdating}
                              title="Mark Missed"
                              className="px-2.5 py-1 text-xs font-semibold text-slate-600 hover:bg-slate-100 rounded-lg transition-colors cursor-pointer disabled:opacity-50"
                            >
                              Missed
                            </button>
                            <button
                              type="button"
                              onClick={() => handleUpdateStatus(appt.id, 'cancelled')}
                              disabled={isUpdating}
                              title="Cancel Consultation"
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
        )}
      </div>
    </div>
  );
}
