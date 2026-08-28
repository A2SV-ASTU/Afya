'use client';

import React, { useState } from 'react';
import { useStore } from '@/lib/store';
import { StatusBadge } from '@/components/ui/Badge';
import {
  Calendar,
  Search,
  Clock,
  User,
  CheckCircle2,
  XCircle,
  AlertCircle,
  ExternalLink,
  ChevronRight,
  PlusCircle,
} from 'lucide-react';
import { AppointmentStatus } from '@/types/database';

export function AppointmentsList() {
  const { appointments, updateAppointmentStatus, navigateTo } = useStore();
  const [statusFilter, setStatusFilter] = useState<'all' | AppointmentStatus>('all');
  const [searchTerm, setSearchTerm] = useState('');

  const filtered = appointments.filter((apt) => {
    const matchesSearch =
      apt.patient_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (apt.notes && apt.notes.toLowerCase().includes(searchTerm.toLowerCase()));
    const matchesStatus = statusFilter === 'all' || apt.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  return (
    <div id="doctor-appointments-page" className="p-6 md:p-8 space-y-8 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 text-xs font-semibold text-emerald-700 uppercase tracking-wider mb-1">
            <Calendar className="w-4 h-4" />
            <span>Clinical Follow-Up Registry</span>
          </div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">
            Appointments & Follow-Up Schedule
          </h1>
          <p className="text-xs text-slate-500 mt-1">
            Track patient consultations, reviews, and clinical follow-up attendance.
          </p>
        </div>

        <button
          id="appointments-new-encounter-btn"
          type="button"
          onClick={() => navigateTo('doctor-start-encounter')}
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-semibold shadow-xs transition-colors cursor-pointer"
        >
          <PlusCircle className="w-4 h-4" />
          <span>+ Start New Encounter</span>
        </button>
      </div>

      {/* Appointments Card */}
      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
        <div className="p-5 border-b border-slate-100 flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-slate-50/40">
          {/* Status Filter Pills */}
          <div className="flex flex-wrap items-center gap-1.5 p-1 bg-slate-100 rounded-xl text-xs font-medium">
            {(['all', 'scheduled', 'attended', 'missed', 'cancelled'] as const).map((st) => (
              <button
                key={st}
                type="button"
                onClick={() => setStatusFilter(st)}
                className={`px-3 py-1 rounded-lg capitalize transition-colors cursor-pointer ${
                  statusFilter === st
                    ? 'bg-white text-slate-900 shadow-2xs font-bold'
                    : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                {st}
              </button>
            ))}
          </div>

          {/* Search */}
          <div className="relative min-w-[240px]">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              id="search-appointments-input"
              type="text"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              placeholder="Search by patient name or clinical purpose..."
              className="w-full pl-9 pr-3 py-1.5 bg-white border border-slate-200 rounded-xl text-xs text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500"
            />
          </div>
        </div>

        {/* Table */}
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-slate-600">
            <thead className="bg-slate-50 border-b border-slate-200/80 text-[11px] font-semibold text-slate-500 uppercase tracking-wider">
              <tr>
                <th className="py-3.5 px-5">Patient Name</th>
                <th className="py-3.5 px-5">Scheduled Date & Time</th>
                <th className="py-3.5 px-5">Clinical Purpose / Notes</th>
                <th className="py-3.5 px-5">Status</th>
                <th className="py-3.5 px-5 text-right">Update Status & Chart</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={5} className="text-center py-10 text-slate-400">
                    <Calendar className="w-8 h-8 mx-auto mb-2 text-slate-300" />
                    <p className="font-medium text-slate-600">No appointments match query</p>
                  </td>
                </tr>
              ) : (
                filtered.map((apt) => (
                  <tr key={apt.id} id={`apt-row-${apt.id}`} className="hover:bg-slate-50/80 transition-colors">
                    <td className="py-4 px-5 font-bold text-slate-900">
                      <div className="flex items-center gap-2.5">
                        <div className="w-7 h-7 rounded-full bg-emerald-100 text-emerald-800 font-bold flex items-center justify-center text-xs">
                          {apt.patient_name[0]}
                        </div>
                        <span>{apt.patient_name}</span>
                      </div>
                    </td>
                    <td className="py-4 px-5">
                      <p className="font-bold text-slate-900">
                        {new Date(apt.scheduled_at).toLocaleDateString('en-GB', {
                          weekday: 'short',
                          day: 'numeric',
                          month: 'short',
                          year: 'numeric',
                        })}
                      </p>
                      <span className="font-mono text-[11px] text-slate-400">
                        {new Date(apt.scheduled_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                      </span>
                    </td>
                    <td className="py-4 px-5 max-w-xs">
                      <p className="text-slate-700 line-clamp-2">{apt.notes || 'Routine follow-up review'}</p>
                      {apt.source_encounter_id && (
                        <button
                          type="button"
                          onClick={() => navigateTo('doctor-encounter-workspace', { encounterId: apt.source_encounter_id })}
                          className="text-[11px] text-emerald-700 hover:underline flex items-center gap-1 mt-0.5"
                        >
                          <span>Linked Encounter #{apt.source_encounter_id.slice(0, 6)}</span>
                          <ExternalLink className="w-3 h-3" />
                        </button>
                      )}
                    </td>
                    <td className="py-4 px-5">
                      <StatusBadge variant={apt.status}>{apt.status}</StatusBadge>
                    </td>
                    <td className="py-4 px-5 text-right">
                      <div className="flex items-center justify-end gap-1.5">
                        {apt.status === 'scheduled' && (
                          <>
                            <button
                              id={`apt-attend-${apt.id}`}
                              type="button"
                              onClick={() => updateAppointmentStatus(apt.id, 'attended')}
                              className="px-2.5 py-1 text-[11px] font-semibold text-emerald-800 bg-emerald-50 hover:bg-emerald-100 rounded-lg border border-emerald-200 transition-colors cursor-pointer"
                              title="Mark as Attended"
                            >
                              Mark Attended
                            </button>
                            <button
                              id={`apt-cancel-${apt.id}`}
                              type="button"
                              onClick={() => updateAppointmentStatus(apt.id, 'cancelled')}
                              className="px-2.5 py-1 text-[11px] font-medium text-rose-700 bg-rose-50 hover:bg-rose-100 rounded-lg border border-rose-200 transition-colors cursor-pointer"
                              title="Cancel"
                            >
                              Cancel
                            </button>
                          </>
                        )}

                        {apt.status !== 'scheduled' && (
                          <button
                            type="button"
                            onClick={() => updateAppointmentStatus(apt.id, 'scheduled')}
                            className="px-2 py-1 text-[11px] text-slate-500 hover:text-slate-900 bg-slate-100 hover:bg-slate-200 rounded-lg transition-colors cursor-pointer"
                          >
                            Reset
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
