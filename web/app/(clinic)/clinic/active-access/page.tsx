'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { ShieldCheck, ArrowRight, UserCheck, Stethoscope, RefreshCw, AlertCircle, Ban, Clock, KeyRound } from 'lucide-react';
import { useAuth } from '@/modules/core/context/AuthContext';
import { accessRequestsApi } from '@/lib/api/access-requests';
import { getApiErrorMessage } from '@/lib/api/client';
import { CountdownBadge } from '@/modules/core/ui/CountdownBadge';
import { Button } from '@/modules/core/ui/Button';
import {
  AccessRequest,
  getAccessRequestPatientName,
  getAccessRequestPatientEmail,
} from '@/types/database';

export default function ClinicActiveAccessPage() {
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
      setErrorMessage(getApiErrorMessage(err, 'Failed to retrieve access requests.'));
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

  const handleRevoke = async (grantId: string, patientId?: string) => {
    if (!clinicId) return;
    setRevokingId(grantId);
    setErrorMessage('');

    try {
      // POST /api/v1/clinics/:clinicId/access-requests/:id/revoke
      await accessRequestsApi.revokeRequest(clinicId, grantId);

      // Also revoke any duplicate approved grants for this patient in the background
      if (patientId) {
        const otherGrants = liveRequests.filter(
          (r) => r.patient_id === patientId && r.id !== grantId && r.status === 'approved' && !r.revoked_at
        );
        for (const other of otherGrants) {
          accessRequestsApi.revokeRequest(clinicId, other.id).catch(() => {});
        }
      }

      setLiveRequests((prev) =>
        prev.map((g) =>
          g.id === grantId || (patientId && g.patient_id === patientId)
            ? { ...g, status: 'revoked' as const, revoked_at: new Date().toISOString() }
            : g
        )
      );
    } catch (err: unknown) {
      setErrorMessage(getApiErrorMessage(err, 'Failed to revoke access grant.'));
    } finally {
      setRevokingId(null);
    }
  };

  // Filter ONLY approved and non-revoked grants (revoked grants must NOT be shown)
  const nonRevokedApprovedGrants = liveRequests.filter(
    (r) => r.status === 'approved' && !r.revoked_at
  );

  // Deduplicate by patient_id so each patient only has 1 active grant card displayed (keeps the newest)
  const activeGrants = Array.from(
    nonRevokedApprovedGrants.reduce((map, grant) => {
      if (!map.has(grant.patient_id) || new Date(grant.created_at) > new Date(map.get(grant.patient_id)!.created_at)) {
        map.set(grant.patient_id, grant);
      }
      return map;
    }, new Map<string, AccessRequest>()).values()
  );

  // Count pending requests to give user helpful feedback
  const pendingRequests = liveRequests.filter((r) => r.status === 'pending' && !r.revoked_at);

  return (
    <div className="space-y-6">
      {errorMessage && (
        <div className="p-4 rounded-2xl bg-rose-50 border border-rose-200 text-xs text-rose-700 font-medium flex items-start gap-2.5 animate-in fade-in">
          <AlertCircle className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
          <div className="flex-1">
            <p className="font-bold">Active Access Notice</p>
            <p className="text-rose-600 mt-0.5">{errorMessage}</p>
          </div>
        </div>
      )}

      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 text-xs font-semibold text-emerald-700 uppercase tracking-wider mb-1">
            <ShieldCheck className="w-4 h-4" />
            <span>Authorized Clinical Window</span>
          </div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">
            Active Patient Consent Grants
          </h1>
          <p className="text-xs text-slate-500 mt-0.5">
            Citizens who have approved 15-minute access to their longitudinal health records from their mobile app.
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
            Refresh Grants
          </Button>

          <Link href="/clinic/lookup">
            <Button size="sm">
              + Look Up & Request Access
            </Button>
          </Link>
        </div>
      </div>

      {activeGrants.length === 0 && !isLoading ? (
        <div className="bg-white rounded-3xl border border-slate-200 p-10 text-center space-y-4 shadow-xs">
          <div className="w-14 h-14 rounded-2xl bg-[#E8F5E9] border border-[#C8E6C9] flex items-center justify-center text-[#2E7D32] mx-auto">
            <ShieldCheck className="w-7 h-7" />
          </div>
          <div className="space-y-1.5 max-w-md mx-auto">
            <h3 className="text-base font-bold text-slate-900">No Active Patient Consent Grants</h3>
            <p className="text-xs text-slate-500 leading-relaxed">
              When an access request is dispatched, it remains in <strong>Pending</strong> status until the patient authorizes it in the Afya mobile app. Upon approval, their unlocked chart will immediately appear here for 15 minutes.
            </p>
          </div>

          {pendingRequests.length > 0 && (
            <div className="p-3.5 max-w-md mx-auto rounded-2xl bg-amber-50 border border-amber-200 text-xs text-amber-800 flex items-center justify-between gap-3">
              <div className="flex items-center gap-2 text-left">
                <Clock className="w-4 h-4 text-amber-600 shrink-0" />
                <span><strong>{pendingRequests.length}</strong> request(s) currently awaiting citizen authorization</span>
              </div>
              <Link href="/clinic/requests">
                <button
                  type="button"
                  className="px-2.5 py-1 text-[11px] font-bold bg-amber-600 hover:bg-amber-700 text-white rounded-lg transition-colors shrink-0 cursor-pointer"
                >
                  View Queue →
                </button>
              </Link>
            </div>
          )}

          <div className="pt-2 flex flex-wrap items-center justify-center gap-2.5">
            <Link href="/clinic/lookup">
              <Button size="sm">
                Look Up Citizen & Request Access
              </Button>
            </Link>
            <Link href="/clinic/requests">
              <Button size="sm" variant="outline" leftIcon={<KeyRound className="w-3.5 h-3.5" />}>
                View All Requests Queue
              </Button>
            </Link>
          </div>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {activeGrants.map((grant) => {
            const patientName = getAccessRequestPatientName(grant);
            const patientEmail = getAccessRequestPatientEmail(grant);

            return (
              <div
                key={grant.id}
                className="bg-white rounded-3xl border border-[#A5D6A7] shadow-xs p-6 space-y-4 hover:shadow-sm transition-all"
              >
                <div className="flex items-start justify-between gap-3">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-[#E8F5E9] text-[#2E7D32] border border-[#C8E6C9] flex items-center justify-center font-bold shrink-0">
                      <UserCheck className="w-5 h-5" />
                    </div>
                    <div>
                      <h3 className="text-sm font-bold text-slate-900">
                        {patientName}
                      </h3>
                      <p className="text-[11px] font-mono text-slate-400">
                        {patientEmail ? `${patientEmail} • ` : ''}UUID: {grant.patient_id}
                      </p>
                    </div>
                  </div>

                {grant.expires_at ? (
                  <CountdownBadge expiresAt={grant.expires_at} />
                ) : (
                  <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200">
                    <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
                    Approved
                  </span>
                )}
              </div>

              <div className="p-3.5 bg-slate-50 rounded-2xl border border-slate-100 text-xs space-y-1">

                <p className="text-[10px] font-semibold text-slate-400 uppercase tracking-wider">Clinical Scope / Reason</p>
                <p className="text-slate-700 font-medium">{grant.reason || 'Outpatient Consultation & Longitudinal Record Review'}</p>
              </div>

              <div className="flex items-center justify-between pt-2 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => handleRevoke(grant.id, grant.patient_id)}
                  disabled={revokingId === grant.id}
                  className="text-xs font-semibold text-rose-600 hover:text-rose-800 cursor-pointer inline-flex items-center gap-1 disabled:opacity-50"
                >
                  <Ban className="w-3.5 h-3.5" />
                  <span>{revokingId === grant.id ? 'Revoking...' : 'Revoke Early'}</span>
                </button>
              </div>
            </div>
          );
        })}
        </div>
      )}
    </div>
  );
}


