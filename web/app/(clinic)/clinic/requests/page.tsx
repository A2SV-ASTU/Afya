'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { KeyRound, PlusCircle, RefreshCw, AlertCircle, Ban, ArrowRight, Clock, ShieldCheck } from 'lucide-react';
import { useStore } from '@/lib/store';
import { accessRequestsApi } from '@/lib/api/access-requests';
import { getApiErrorMessage } from '@/lib/api/client';
import { Button } from '@/modules/core/ui/Button';
import { StatusBadge } from '@/modules/core/ui/StatusBadge';
import { CountdownBadge } from '@/modules/core/ui/CountdownBadge';
import { formatDateTime } from '@/modules/core/lib/utils';
import { useAuth } from '@/modules/core/context/AuthContext';
import {
  AccessRequest,
  getAccessRequestPatientName,
  getAccessRequestPatientEmail,
} from '@/types/database';

export default function ClinicRequestsPage() {
  const { currentUser, isReady } = useAuth();
  const clinicId = currentUser?.clinic_id;

  const [liveRequests, setLiveRequests] = useState<AccessRequest[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState('');
  const [revokingId, setRevokingId] = useState<string | null>(null);

  const fetchRequests = async () => {
    if (!clinicId) {
      setIsLoading(false);
      return;
    }
    setIsLoading(true);
    setErrorMessage('');

    try {
      // GET /api/v1/clinics/:clinicId/access-requests
      const res = await accessRequestsApi.listRequests(clinicId);
      if (res && res.access_requests) {
        setLiveRequests(res.access_requests);
      } else {
        setLiveRequests([]);
      }
    } catch (err: unknown) {
      setErrorMessage(getApiErrorMessage(err, 'Failed to fetch access requests from registry.'));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    if (clinicId) {
      fetchRequests();
    } else if (isReady) {
      setIsLoading(false);
    }
  }, [clinicId, isReady]);

  const handleRevoke = async (requestId: string) => {
    if (!clinicId) return;
    setRevokingId(requestId);
    setErrorMessage('');

    try {
      // POST /api/v1/clinics/:clinicId/access-requests/:id/revoke
      await accessRequestsApi.revokeRequest(clinicId, requestId);
      setLiveRequests((prev) =>
        prev.map((r) =>
          r.id === requestId
            ? { ...r, status: 'revoked' as const, revoked_at: new Date().toISOString() }
            : r
        )
      );
    } catch (err: unknown) {
      setErrorMessage(getApiErrorMessage(err, 'Failed to revoke access grant.'));
    } finally {
      setRevokingId(null);
    }
  };

  const displayedRequests = liveRequests;

  return (
    <div className="space-y-6">
      {errorMessage && (
        <div className="p-4 rounded-2xl bg-rose-50 border border-rose-200 text-xs text-rose-700 font-medium flex items-start gap-2.5 animate-in fade-in">
          <AlertCircle className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
          <div className="flex-1">
            <p className="font-bold">Access Request Notice</p>
            <p className="text-rose-600 mt-0.5">{errorMessage}</p>
          </div>
        </div>
      )}

      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold text-slate-900">Patient Access Consent Requests</h1>
          <p className="text-xs text-slate-500">
            Time-bounded authorization requests sent to citizens for explicit chart access
          </p>
        </div>

        <div className="flex items-center gap-2.5">
          <Button
            variant="outline"
            size="sm"
            onClick={fetchRequests}
            isLoading={isLoading}
            leftIcon={<RefreshCw className="w-3.5 h-3.5" />}
          >
            Refresh
          </Button>

          {/* <Link href="/clinic/requests/new">
            <Button size="sm" leftIcon={<PlusCircle className="w-4 h-4" />}>
              + Request Patient Access
            </Button>
          </Link> */}
        </div>
      </div>

      <div className="bg-white rounded-3xl border border-slate-200 shadow-xs overflow-hidden">
        <div className="p-6 border-b border-slate-100 flex items-center justify-between">
          <div>
            <h2 className="text-base font-bold text-slate-900">All Consent Requests ({displayedRequests.length})</h2>
            <p className="text-xs text-slate-500 mt-0.5">Strict 15-minute privacy-bounded authorization grants</p>
          </div>
          <span className="text-xs text-slate-400 font-mono">Registry Gateway</span>
        </div>

        {displayedRequests.length === 0 && !isLoading ? (
          <div className="p-12 text-center space-y-3">
            <div className="w-12 h-12 rounded-2xl bg-slate-100 text-slate-400 flex items-center justify-center mx-auto">
              <KeyRound className="w-6 h-6" />
            </div>
            <p className="text-sm font-bold text-slate-800">No Consent Requests Dispatched</p>
            <p className="text-xs text-slate-500 max-w-sm mx-auto">
              Look up a citizen on the <Link href="/clinic/lookup" className="text-emerald-600 underline font-semibold">Lookup Page</Link> to initiate a consent authorization request.
            </p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs border-collapse">
              <thead>
                <tr className="border-b border-slate-100 bg-slate-50/75 text-slate-500 font-semibold uppercase tracking-wider text-[11px]">
                  <th className="py-3 px-6">Target Citizen</th>
                  <th className="py-3 px-6">Clinical Reason</th>
                  <th className="py-3 px-6">Time Window</th>
                  <th className="py-3 px-6">Status</th>
                  <th className="py-3 px-6 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 font-medium text-slate-700">
                {displayedRequests.map((req) => {
                  const isRevoked = Boolean(req.revoked_at || req.status === 'revoked');
                  const isApproved = req.status === 'approved' && !isRevoked;
                  const isPending = req.status === 'pending' && !isRevoked;
                  const effectiveStatus = isRevoked ? ('revoked' as const) : req.status;
                  const patientName = getAccessRequestPatientName(req);
                  const patientEmail = getAccessRequestPatientEmail(req);

                  return (
                    <tr key={req.id} className="hover:bg-slate-50/60 transition-colors">
                      <td className="py-4 px-6">
                        <p className="font-bold text-slate-900">{patientName}</p>
                        <p className="text-[10px] text-slate-400 font-mono">
                          {patientEmail ? `${patientEmail} • ` : ''}UUID: {req.patient_id}
                        </p>
                      </td>
                      <td className="py-4 px-6 text-slate-600 max-w-xs">{req.reason || 'Clinical consultation'}</td>
                      <td className="py-4 px-6">
                        {!isRevoked && (isPending || (isApproved && req.expires_at)) ? (
                          <CountdownBadge expiresAt={req.expires_at} />
                        ) : (
                          <span suppressHydrationWarning className="text-[11px] text-slate-400 font-mono">
                            {formatDateTime(req.revoked_at || req.created_at)}
                          </span>
                        )}

                      </td>
                      <td className="py-4 px-6">
                        <StatusBadge status={effectiveStatus} />
                      </td>
                      <td className="py-4 px-6 text-right">
                        <div className="flex items-center justify-end gap-2">
                          {isApproved && (
                            <button
                              type="button"
                              onClick={() => handleRevoke(req.id)}
                              disabled={revokingId === req.id}
                              className="px-2.5 py-1 text-xs font-semibold text-rose-700 bg-rose-50 hover:bg-rose-100 rounded-lg transition-colors border border-rose-200 inline-flex items-center gap-1 cursor-pointer disabled:opacity-50"
                              title="Revoke active consent grant"
                            >
                              <Ban className="w-3 h-3" />
                              <span>{revokingId === req.id ? 'Revoking...' : 'Revoke'}</span>
                            </button>
                          )}
                        </div>
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

