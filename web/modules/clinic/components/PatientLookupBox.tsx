'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import {
  Search,
  UserCheck,
  ShieldAlert,
  ArrowRight,
  Smartphone,
  AlertCircle,
  Mail,
  ShieldCheck,
  Send,
  CheckCircle2,
  Clock,
} from 'lucide-react';
import { Button } from '@/modules/core/ui/Button';
import { Modal } from '@/modules/core/ui/Modal';
import { usePatientLookup } from '../hooks/usePatientLookup';
import { useAuth } from '@/modules/core/context/AuthContext';
import { accessRequestsApi } from '@/lib/api/access-requests';
import { getApiErrorMessage } from '@/lib/api/client';
import { AccessRequest } from '@/types/database';

export function PatientLookupBox() {
  const router = useRouter();
  const { query, setQuery, foundPatient, isLoading, hasSearched, error, executeLookup, resetLookup } = usePatientLookup();
  const { currentUser } = useAuth();
  const clinicId = currentUser?.clinic_id;

  const [activeGrants, setActiveGrants] = useState<AccessRequest[]>([]);

  // Inline Request Modal state
  const [showRequestModal, setShowRequestModal] = useState(false);
  const [requestReason, setRequestReason] = useState('Outpatient Consultation & Longitudinal Record Review');
  const [isDispatching, setIsDispatching] = useState(false);
  const [dispatchError, setDispatchError] = useState('');
  const [dispatchSuccess, setDispatchSuccess] = useState(false);

  useEffect(() => {
    if (!clinicId) return;
    accessRequestsApi
      .listRequests(clinicId)
      .then((res) => {
        if (res?.access_requests) {
          setActiveGrants(res.access_requests);
        }
      })
      .catch(() => {});
  }, [clinicId]);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    executeLookup();
  };

  // Check if clinic currently holds active/approved non-revoked access for this patient
  const hasActiveAccess = Boolean(
    foundPatient &&
      activeGrants.some(
        (r) =>
          r.patient_id === foundPatient.id &&
          r.status === 'approved' &&
          !r.revoked_at
      )
  );

  // Check if a consent request is already pending for this citizen
  const hasPendingRequest = Boolean(
    foundPatient &&
      !hasActiveAccess &&
      activeGrants.some(
        (r) =>
          r.patient_id === foundPatient.id &&
          r.status === 'pending' &&
          !r.revoked_at &&
          new Date(r.expires_at).getTime() > Date.now()
      )
  );

  const handleDirectAccessRequest = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!clinicId || !foundPatient) return;

    if (hasActiveAccess) {
      setDispatchError(
        'An active patient consent grant already exists for this citizen. Sending a duplicate request is not allowed.'
      );
      return;
    }

    setDispatchError('');
    setIsDispatching(true);

    try {
      // POST /api/v1/clinics/:clinicId/access-requests
      await accessRequestsApi.createRequest(clinicId, {
        patient_id: foundPatient.id,
        reason: requestReason.trim(),
      });
      setDispatchSuccess(true);
      setIsDispatching(false);
    } catch (err: unknown) {
      setDispatchError(getApiErrorMessage(err, 'Failed to dispatch consent request.'));
      setIsDispatching(false);
    }
  };

  const handleCloseModal = () => {
    setShowRequestModal(false);
    setDispatchSuccess(false);
    setDispatchError('');
  };

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <div>
        <h1 className="text-xl font-bold text-slate-900">Exact Citizen Identifier Lookup</h1>
        <p className="text-xs text-slate-500">
          Strict confidentiality architecture: Search by registered citizen email to verify identity and initiate instant consent requests.
        </p>
      </div>

      <div className="bg-white rounded-3xl border border-slate-200 shadow-xs p-6 space-y-4">
        <form onSubmit={handleSearch} className="flex flex-col sm:flex-row gap-3">
          <div className="relative flex-1">
            <Mail className="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
            <input
              id="patient-lookup-input"
              type="email"
              placeholder="Enter citizen registered email (e.g. patient@afya.org)..."
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-2.5 text-xs bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C] text-slate-900 placeholder:text-slate-400"
              required
              autoFocus
            />
          </div>
          <Button type="submit" size="md" isLoading={isLoading} leftIcon={<Search className="w-4 h-4" />}>
            Verify Citizen
          </Button>
        </form>

        {error && (
          <div className="p-3.5 rounded-2xl bg-rose-50 border border-rose-200 text-xs text-rose-700 font-medium flex items-start gap-2 animate-in fade-in">
            <AlertCircle className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
            <span>{error}</span>
          </div>
        )}

        <div className="p-3 bg-slate-50 rounded-2xl border border-slate-200/80 text-[11px] text-slate-500 flex items-start gap-2">
          <ShieldCheck className="w-4 h-4 text-emerald-700 shrink-0 mt-0.5" />
          <p className="leading-relaxed">
            Per the national health data protocol, search queries hit the live Go backend <code>GET /api/v1/patients/lookup</code>. Once verified, you can dispatch an instant 15-minute access authorization prompt directly to the citizen.
          </p>
        </div>
      </div>

      {/* Result Display */}
      {hasSearched && foundPatient && (
        <div className="bg-white rounded-3xl border border-slate-200 shadow-xs p-6 space-y-6 animate-in fade-in zoom-in-95 duration-200">
          <div className="flex flex-wrap items-center justify-between gap-4">
            <div className="flex items-center gap-3.5">
              <div className="w-12 h-12 rounded-2xl bg-[#E8F5E9] text-[#2E7D32] border border-[#C8E6C9] flex items-center justify-center font-bold text-sm">
                {foundPatient.first_name[0]}
                {foundPatient.last_name[0]}
              </div>
              <div>
                <div className="flex items-center gap-2">
                  <h2 className="text-base font-bold text-slate-900">
                    {foundPatient.first_name} {foundPatient.last_name}
                  </h2>
                  <span className="px-2 py-0.5 rounded-full text-[10px] font-mono bg-slate-100 text-slate-600 font-semibold">
                    Citizen Verified
                  </span>
                </div>
                <p className="text-xs text-slate-500 font-mono mt-0.5">
                  Registry UUID: {foundPatient.id}
                </p>
              </div>
            </div>

            <div>
              {hasActiveAccess ? (
                <span className="inline-flex items-center gap-1.5 px-3 py-1 bg-[#E8F5E9] text-[#1B5E20] border border-[#C8E6C9] text-xs font-semibold rounded-full">
                  <UserCheck className="w-3.5 h-3.5" />
                  Access Granted (Active)
                </span>
              ) : (
                <span className="inline-flex items-center gap-1.5 px-3 py-1 bg-amber-50 text-amber-800 border border-amber-200 text-xs font-semibold rounded-full">
                  <ShieldAlert className="w-3.5 h-3.5" />
                  Consent Required
                </span>
              )}
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 p-4 rounded-2xl bg-slate-50 border border-slate-100 text-xs">
            <div>
              <p className="text-slate-400 text-[10px] uppercase font-semibold">Citizen Full Name</p>
              <p className="font-semibold text-slate-800 mt-0.5">{foundPatient.first_name} {foundPatient.last_name}</p>
            </div>
            <div>
              <p className="text-slate-400 text-[10px] uppercase font-semibold">Registered Email Address</p>
              <p className="font-semibold text-slate-800 mt-0.5">{foundPatient.email}</p>
            </div>
          </div>

          {hasActiveAccess && (
            <div className="p-4 rounded-2xl bg-[#E8F5E9] border border-[#A5D6A7] text-xs text-[#1B5E20] flex items-start gap-3 animate-in fade-in">
              <div className="w-8 h-8 rounded-xl bg-white text-[#2E7D32] flex items-center justify-center shrink-0 border border-[#C8E6C9] mt-0.5 shadow-2xs">
                <UserCheck className="w-4 h-4" />
              </div>
              <div className="space-y-1">
                <p className="font-bold text-[#1B5E20]">Active Patient Access Grant Already Exists</p>
                <p className="leading-relaxed text-[#2E7D32]">
                  Your healthcare facility already holds an active, authorized consent grant for <strong>{foundPatient.first_name} {foundPatient.last_name}</strong>. 
                  Sending a new request is not permitted because their longitudinal medical chart is already unlocked.
                </p>
              </div>
            </div>
          )}

          {hasPendingRequest && (
            <div className="p-4 rounded-2xl bg-amber-50 border border-amber-200 text-xs text-amber-900 flex items-start gap-3 animate-in fade-in">
              <div className="w-8 h-8 rounded-xl bg-amber-100 text-amber-700 flex items-center justify-center shrink-0 border border-amber-200 mt-0.5">
                <Clock className="w-4 h-4" />
              </div>
              <div className="space-y-1">
                <p className="font-bold text-amber-950">Consent Request Already Pending</p>
                <p className="leading-relaxed text-amber-800">
                  A consent request for this citizen has already been dispatched and is currently awaiting their authorization in the mobile app.
                </p>
              </div>
            </div>
          )}

          <div className="flex flex-wrap items-center justify-between gap-3 pt-2">
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={resetLookup}
            >
              Search Another Citizen
            </Button>

            {!hasActiveAccess && (
              <Button
                leftIcon={<Smartphone className="w-4 h-4" />}
                onClick={() => setShowRequestModal(true)}
              >
                Send Consent Request to Patient App
              </Button>
            )}
          </div>
        </div>
      )}

      {hasSearched && !foundPatient && !isLoading && (
        <div className="bg-white rounded-3xl border border-slate-200 p-8 text-center space-y-3">
          <div className="w-12 h-12 rounded-2xl bg-slate-100 text-slate-500 flex items-center justify-center mx-auto">
            <Search className="w-6 h-6" />
          </div>
          <div>
            <p className="text-sm font-bold text-slate-800">No Citizen Found with &ldquo;{query}&rdquo;</p>
            <p className="text-xs text-slate-500 mt-0.5">
              Confirm the exact registered citizen email address in the Afya mobile app.
            </p>
          </div>
          <Button type="button" variant="outline" size="sm" onClick={resetLookup}>
            Clear Search
          </Button>
        </div>
      )}

      {/* Quick Access Request Modal */}
      {foundPatient && (
        <Modal
          isOpen={showRequestModal}
          onClose={handleCloseModal}
          title="Send Consent Request to Citizen App"
          subtitle={`Dispatches an authorization push notification to ${foundPatient.first_name} ${foundPatient.last_name}`}
          maxWidth="md"
        >
          {!dispatchSuccess ? (
            <form onSubmit={handleDirectAccessRequest} className="space-y-4">
              {dispatchError && (
                <div className="p-3.5 rounded-2xl bg-rose-50 border border-rose-200 text-xs text-rose-700 flex items-center gap-2 font-medium animate-in fade-in">
                  <AlertCircle className="w-4 h-4 shrink-0" />
                  <span>{dispatchError}</span>
                </div>
              )}

              <div className="p-3.5 rounded-2xl bg-slate-50 border border-slate-100 text-xs space-y-1">
                <p className="font-bold text-slate-900">{foundPatient.first_name} {foundPatient.last_name}</p>
                <p className="text-slate-500">{foundPatient.email}</p>
                <p className="text-[10px] font-mono text-slate-400">UUID: {foundPatient.id}</p>
              </div>

              <div className="space-y-1.5">
                <label className="block text-xs font-semibold text-slate-700">
                  Clinical Reason / Consultation Purpose <span className="text-rose-500">*</span>
                </label>
                <textarea
                  rows={3}
                  value={requestReason}
                  onChange={(e) => setRequestReason(e.target.value)}
                  placeholder="e.g. Outpatient clinical consultation and historical vitals review..."
                  className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C] text-slate-800"
                  required
                />
              </div>

              <div className="p-3.5 rounded-2xl bg-[#E8F5E9]/60 border border-[#C8E6C9] text-xs text-[#1B5E20] space-y-1">
                <div className="flex items-center gap-1.5 font-bold">
                  <Clock className="w-3.5 h-3.5 text-[#2E7D32]" />
                  <span>15-Minute Bounded Window</span>
                </div>
                <p className="text-[11px] text-[#2E7D32]">
                  When approved by the patient on their phone, health records will unlock for 15 minutes.
                </p>
              </div>

              <div className="pt-2 flex items-center justify-end gap-2.5">
                <Button type="button" variant="outline" size="sm" onClick={handleCloseModal}>
                  Cancel
                </Button>
                <Button
                  type="submit"
                  size="sm"
                  isLoading={isDispatching}
                  leftIcon={<Send className="w-3.5 h-3.5" />}
                >
                  Send Request Now
                </Button>
              </div>
            </form>
          ) : (
            <div className="py-4 text-center space-y-4 animate-in fade-in zoom-in-95">
              <div className="w-12 h-12 rounded-2xl bg-[#E8F5E9] text-[#2E7D32] border border-[#C8E6C9] flex items-center justify-center mx-auto">
                <CheckCircle2 className="w-6 h-6" />
              </div>
              <div className="space-y-1">
                <h4 className="text-base font-bold text-slate-900">Consent Request Dispatched!</h4>
                <p className="text-xs text-slate-500">
                  An authorization prompt has been sent to <strong>{foundPatient.first_name}</strong>&apos;s Afya app.
                </p>
              </div>
              <div className="pt-2 flex items-center justify-center gap-2">
                <Button
                  size="sm"
                  onClick={() => {
                    handleCloseModal();
                    router.push('/clinic/requests');
                  }}
                >
                  View Consent Queue
                </Button>
              </div>
            </div>
          )}
        </Modal>
      )}
    </div>
  );
}

