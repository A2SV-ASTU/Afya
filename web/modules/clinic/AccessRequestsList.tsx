'use client';

import React, { useState } from 'react';
import { useStore } from '@/lib/store';
import { StatusBadge } from '@/components/ui/Badge';
import { CountdownBadge } from '@/components/ui/CountdownBadge';
import {
  Send,
  Search,
  Plus,
  Clock,
  ShieldCheck,
  CheckCircle2,
  XCircle,
  AlertCircle,
  RotateCcw,
} from 'lucide-react';
import {
  AccessRequestStatus,
  getAccessRequestPatientName,
  getAccessRequestPatientEmail,
} from '@/types/database';

export function AccessRequestsList() {
  const {
    currentUser,
    accessRequests,
    approveAccessRequest,
    denyAccessRequest,
    revokeAccessRequest,
    navigateTo,
  } = useStore();

  const [statusFilter, setStatusFilter] = useState<'all' | AccessRequestStatus>('all');
  const [searchTerm, setSearchTerm] = useState('');

  const clinicRequests = accessRequests.filter(
    (r) => (r.clinic_id || r.requesting_clinic_id) === currentUser?.clinic_id
  );

  const filteredRequests = clinicRequests.filter((req) => {
    const patientName = getAccessRequestPatientName(req);
    const patientEmail = getAccessRequestPatientEmail(req);
    const reason = req.reason || '';
    const doctorName = req.submitted_by_doctor_name || '';

    const isRevoked = Boolean(req.revoked_at || req.status === 'revoked');
    const effectiveStatus = isRevoked ? ('revoked' as const) : req.status;

    const matchesSearch =
      patientName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      patientEmail.toLowerCase().includes(searchTerm.toLowerCase()) ||
      reason.toLowerCase().includes(searchTerm.toLowerCase()) ||
      doctorName.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = statusFilter === 'all' || effectiveStatus === statusFilter;
    return matchesSearch && matchesStatus;
  });


  return (
    <div id="access-requests-page" className="p-6 md:p-8 space-y-8 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 text-xs font-semibold text-emerald-700 uppercase tracking-wider mb-1">
            <ShieldCheck className="w-4 h-4" />
            <span>Patient Consent Auditing</span>
          </div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">
            Access Requests (Sent)
          </h1>
          <p className="text-xs text-slate-500 mt-1">
            Track status and 5-minute countdowns for all institutional patient consent requests.
          </p>
        </div>

        <button
          id="new-access-request-cta"
          type="button"
          onClick={() => navigateTo('clinic-lookup')}
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-semibold shadow-xs transition-colors cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          <span>+ New Access Request</span>
        </button>
      </div>

      {/* Table Card */}
      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
        <div className="p-5 border-b border-slate-100 flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-slate-50/40">
          {/* Status Filter Pills */}
          <div className="flex flex-wrap items-center gap-1.5 p-1 bg-slate-100 rounded-xl text-xs font-medium">
            {(['all', 'pending', 'approved', 'denied', 'expired'] as const).map((st) => (
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

          {/* Search Bar */}
          <div className="relative min-w-[240px]">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              id="search-requests-input"
              type="text"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              placeholder="Search by patient, physician, reason..."
              className="w-full pl-9 pr-3 py-1.5 bg-white border border-slate-200 rounded-xl text-xs text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500"
            />
          </div>
        </div>

        {/* Requests Table */}
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-slate-600">
            <thead className="bg-slate-50 border-b border-slate-200/80 text-[11px] font-semibold text-slate-500 uppercase tracking-wider">
              <tr>
                <th className="py-3.5 px-5">Patient & Email</th>
                <th className="py-3.5 px-5">Clinical Purpose / Reason</th>
                <th className="py-3.5 px-5">Submitting Physician</th>
                <th className="py-3.5 px-5">Status / Timer</th>
                <th className="py-3.5 px-5 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredRequests.length === 0 ? (
                <tr>
                  <td colSpan={5} className="text-center py-10 text-slate-400">
                    <Send className="w-8 h-8 mx-auto mb-2 text-slate-300" />
                    <p className="font-medium text-slate-600">No access requests found</p>
                    <p className="text-xs text-slate-400 mt-0.5">
                      Use &quot;+ New Access Request&quot; to look up a patient and request consent.
                    </p>
                  </td>
                </tr>
              ) : (
                filteredRequests.map((req) => {
                  const patientName = getAccessRequestPatientName(req);
                  const patientEmail = getAccessRequestPatientEmail(req);
                  const isRevoked = Boolean(req.revoked_at || req.status === 'revoked');
                  const effectiveStatus = isRevoked ? ('revoked' as const) : req.status;

                  return (
                    <tr key={req.id} id={`req-row-${req.id}`} className="hover:bg-slate-50/80 transition-colors">
                      <td className="py-4 px-5">
                        <div className="flex items-center gap-3">
                          <div className="w-8 h-8 rounded-full bg-slate-100 text-slate-700 font-bold flex items-center justify-center shrink-0">
                            {patientName ? patientName[0].toUpperCase() : 'P'}
                          </div>
                          <div>
                            <p className="font-bold text-slate-900">{patientName}</p>
                            <p className="text-[11px] text-slate-400 font-mono">
                              {patientEmail ? `${patientEmail} • ` : ''}UUID: {req.patient_id}
                            </p>
                          </div>

                        </div>
                      </td>
                      <td className="py-4 px-5 max-w-xs">
                        <p className="text-slate-700 line-clamp-2 leading-relaxed">{req.reason}</p>
                        <span className="text-[10px] text-slate-400 font-mono">
                          Sent {new Date(req.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                        </span>
                      </td>
                      <td className="py-4 px-5">
                        <p className="font-medium text-slate-800">{req.submitted_by_doctor_name}</p>
                      </td>
                      <td className="py-4 px-5">
                        <div className="space-y-1">
                          <StatusBadge variant={effectiveStatus}>{effectiveStatus}</StatusBadge>
                          {effectiveStatus === 'pending' && (
                            <div className="pt-0.5">
                              <CountdownBadge expiresAt={req.expires_at} type="access_request" />
                            </div>
                          )}
                        </div>
                      </td>
                      <td className="py-4 px-5 text-right">
                        {effectiveStatus === 'pending' && (
                          <div className="flex items-center justify-end gap-1.5">
                            <button
                              id={`quick-approve-${req.id}`}
                              type="button"
                              onClick={() => approveAccessRequest(req.id)}
                              className="p-1.5 text-emerald-700 bg-emerald-50 hover:bg-emerald-100 rounded-lg text-[11px] font-semibold border border-emerald-200 transition-colors cursor-pointer"
                              title="Simulate Patient App Approving"
                            >
                              <CheckCircle2 className="w-3.5 h-3.5" />
                            </button>
                            <button
                              id={`quick-deny-${req.id}`}
                              type="button"
                              onClick={() => denyAccessRequest(req.id)}
                              className="p-1.5 text-rose-700 bg-rose-50 hover:bg-rose-100 rounded-lg text-[11px] font-semibold border border-rose-200 transition-colors cursor-pointer"
                              title="Simulate Patient App Denying"
                            >
                              <XCircle className="w-3.5 h-3.5" />
                            </button>
                          </div>
                        )}

                        {effectiveStatus === 'approved' && (
                          <button
                            id={`revoke-grant-${req.id}`}
                            type="button"
                            onClick={() => {
                              if (window.confirm(`Revoke active consent grant for ${patientName}?`)) {
                                revokeAccessRequest(req.id);
                              }
                            }}
                            className="px-2.5 py-1 text-[11px] font-medium text-slate-500 hover:text-rose-700 hover:bg-rose-50 rounded-lg border border-slate-200 hover:border-rose-200 transition-colors cursor-pointer"
                          >
                            Revoke Grant
                          </button>
                        )}

                      {req.status === 'denied' || req.status === 'expired' ? (
                        <button
                          type="button"
                          onClick={() => navigateTo('clinic-lookup')}
                          className="px-2.5 py-1 text-[11px] font-medium text-emerald-700 bg-emerald-50 hover:bg-emerald-100 rounded-lg border border-emerald-200 transition-colors cursor-pointer"
                        >
                          Retry Request
                        </button>
                      ) : null}
                    </td>
                  </tr>
                );
              })
            )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
