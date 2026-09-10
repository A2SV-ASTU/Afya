'use client';

import React, { useState, useEffect, useCallback } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import {
  KeyRound,
  ArrowLeft,
  Clock,
  AlertCircle,
  Search,
  UserCheck,
  CheckCircle2,
  Loader2,
} from 'lucide-react';
import { useAuth } from '@/modules/core/context/AuthContext';
import { accessRequestsApi } from '@/lib/api/access-requests';
import { clinicsApi } from '@/lib/api/clinics';
import { getApiErrorMessage } from '@/lib/api/client';
import { Button } from '@/modules/core/ui/Button';
import { DoctorResponse, PatientLookupResponse } from '@/types/database';

export function AccessRequestForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const initialPatientId = searchParams.get('patientId') || '';
  const initialPatientEmail = searchParams.get('email') || '';

  const { currentUser, isReady } = useAuth();
  const clinicId = currentUser?.clinic_id;

  // Patient lookup state
  const [patientId, setPatientId] = useState(initialPatientId);
  const [searchQuery, setSearchQuery] = useState(initialPatientEmail);
  const [resolvedPatient, setResolvedPatient] = useState<PatientLookupResponse | null>(null);
  const [isSearching, setIsSearching] = useState(false);
  const [searchError, setSearchError] = useState('');

  // Doctor roster state
  const [doctors, setDoctors] = useState<DoctorResponse[]>([]);
  const [doctorId, setDoctorId] = useState('');
  const [isLoadingDoctors, setIsLoadingDoctors] = useState(true);

  // Form submission state
  const [reason, setReason] = useState('Outpatient Consultation & Longitudinal Vitals Review');
  const [error, setError] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);

  // 1. Fetch live doctor roster for this clinic facility
  const fetchDoctors = useCallback(async () => {
    if (!clinicId) {
      setIsLoadingDoctors(false);
      return;
    }

    try {
      const res = await clinicsApi.listDoctors(clinicId);
      if (res && res.doctors) {
        const activeDocs = res.doctors.filter((d) => d.doctor_status !== 'deactivated');
        setDoctors(activeDocs);
        if (activeDocs.length > 0) {
          setDoctorId((prev) => prev || activeDocs[0].id);
        }
      }
    } catch {
      setDoctors([]);
    } finally {
      setIsLoadingDoctors(false);
    }
  }, [clinicId]);

  useEffect(() => {
    if (clinicId) {
      fetchDoctors();
    } else if (isReady) {
      setIsLoadingDoctors(false);
    }
  }, [clinicId, isReady, fetchDoctors]);

  // 2. Resolve initial patient email if provided in query params
  const lookupPatientByEmail = useCallback(async (email: string) => {
    const term = email.trim();
    if (!term) return;

    setIsSearching(true);
    setSearchError('');

    try {
      const res = await accessRequestsApi.lookupPatient(term);
      if (res && res.id) {
        setResolvedPatient(res);
        setPatientId(res.id);
        setSearchError('');
      } else {
        setSearchError(`No registered citizen found with email "${term}".`);
      }
    } catch (err: unknown) {
      setSearchError(getApiErrorMessage(err, `No registered citizen found with email "${term}".`));
    } finally {
      setIsSearching(false);
    }
  }, []);

  useEffect(() => {
    if (initialPatientEmail) {
      lookupPatientByEmail(initialPatientEmail);
    }
  }, [initialPatientEmail, lookupPatientByEmail]);

  const handleManualLookup = (e: React.FormEvent) => {
    e.preventDefault();
    if (!searchQuery.trim()) {
      setSearchError('Please enter a citizen email address to search.');
      return;
    }
    lookupPatientByEmail(searchQuery);
  };

  const handleClearPatient = () => {
    setPatientId('');
    setResolvedPatient(null);
    setSearchQuery('');
    setSearchError('');
  };

  // 3. Dispatch access request to Go backend
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    if (!clinicId) {
      setError('Active clinic facility context not found. Please log in again.');
      return;
    }

    if (!patientId) {
      setError('Please search and select a verified target citizen.');
      return;
    }

    if (!reason.trim()) {
      setError('Please provide a clinical rationale for accessing patient records.');
      return;
    }

    setIsSubmitting(true);

    try {
      // POST /api/v1/clinics/:clinicId/access-requests
      await accessRequestsApi.createRequest(clinicId, {
        patient_id: patientId,
        reason: reason.trim(),
      });

      setIsSuccess(true);
      setIsSubmitting(false);

      setTimeout(() => {
        router.push('/clinic/requests');
      }, 1200);
    } catch (err: unknown) {
      setError(getApiErrorMessage(err, 'Failed to dispatch patient consent request.'));
      setIsSubmitting(false);
    }
  };

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <div className="flex items-center gap-3">
        <button
          type="button"
          onClick={() => router.push('/clinic/requests')}
          className="p-2 rounded-xl text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition-colors"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <div>
          <h1 className="text-xl font-bold text-slate-900">Initiate Patient Consent Request</h1>
          <p className="text-xs text-slate-500">
            Dispatches an instant authorization prompt to the citizen&apos;s Afya mobile app
          </p>
        </div>
      </div>

      <div className="bg-white rounded-3xl border border-slate-200 shadow-xs p-6 sm:p-8">
        {isSuccess ? (
          <div className="py-8 text-center space-y-4 animate-in fade-in zoom-in-95">
            <div className="w-14 h-14 rounded-2xl bg-[#E8F5E9] text-[#2E7D32] border border-[#C8E6C9] flex items-center justify-center mx-auto">
              <CheckCircle2 className="w-8 h-8" />
            </div>
            <div className="space-y-1">
              <h3 className="text-lg font-bold text-slate-900">Consent Request Dispatched!</h3>
              <p className="text-xs text-slate-500 max-w-md mx-auto">
                An authorization prompt has been pushed to the patient&apos;s mobile device. Redirecting to the requests queue...
              </p>
            </div>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="space-y-5">
            {error && (
              <div className="p-3.5 rounded-2xl bg-rose-50 border border-rose-200 text-xs text-rose-700 flex items-center gap-2 font-medium">
                <AlertCircle className="w-4 h-4 shrink-0" />
                {error}
              </div>
            )}

            {/* Target Citizen Section */}
            <div className="space-y-2">
              <label className="block text-xs font-semibold text-slate-700">
                Target Citizen <span className="text-rose-500">*</span>
              </label>

              {resolvedPatient ? (
                <div className="p-4 rounded-2xl bg-[#E8F5E9]/50 border border-[#C8E6C9] flex items-center justify-between gap-4">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-white text-[#2E7D32] border border-[#C8E6C9] flex items-center justify-center font-bold text-sm shrink-0">
                      <UserCheck className="w-5 h-5" />
                    </div>
                    <div>
                      <p className="font-bold text-slate-900 text-xs">
                        {resolvedPatient.first_name} {resolvedPatient.last_name}
                      </p>
                      <p className="text-[11px] text-slate-500">{resolvedPatient.email}</p>
                      <p className="text-[10px] font-mono text-slate-400">ID: {resolvedPatient.id}</p>
                    </div>
                  </div>
                  <button
                    type="button"
                    onClick={handleClearPatient}
                    className="text-xs text-slate-500 hover:text-rose-600 font-semibold transition-colors px-2 py-1 cursor-pointer"
                  >
                    Change
                  </button>
                </div>
              ) : (
                <div className="space-y-2">
                  <div className="flex gap-2">
                    <div className="relative flex-1">
                      <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
                      <input
                        id="citizen-lookup-input"
                        type="email"
                        placeholder="Enter citizen registered email address..."
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className="w-full pl-9 pr-3.5 py-2.5 text-xs bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C] text-slate-800"
                      />
                    </div>
                    <Button
                      type="button"
                      variant="outline"
                      size="sm"
                      isLoading={isSearching}
                      onClick={handleManualLookup}
                    >
                      Lookup
                    </Button>
                  </div>

                  {searchError && (
                    <p className="text-xs text-rose-600 font-medium">{searchError}</p>
                  )}

                  {initialPatientId && !resolvedPatient && (
                    <div className="p-3 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-600 flex items-center justify-between">
                      <span className="font-mono text-[11px]">Selected UUID: {initialPatientId}</span>
                      <span className="text-[10px] bg-slate-200 px-2 py-0.5 rounded-md font-semibold">Direct ID</span>
                    </div>
                  )}
                </div>
              )}
            </div>

            {/* Attending Physician Selection */}
            <div className="space-y-1.5">
              <label className="block text-xs font-semibold text-slate-700">
                Designated Attending Physician
              </label>
              {isLoadingDoctors ? (
                <div className="flex items-center gap-2 p-3 text-xs text-slate-400 bg-slate-50 rounded-xl">
                  <Loader2 className="w-3.5 h-3.5 animate-spin" />
                  Loading clinic medical roster...
                </div>
              ) : doctors.length > 0 ? (
                <select
                  id="request-select-doctor"
                  value={doctorId}
                  onChange={(e) => setDoctorId(e.target.value)}
                  className="w-full px-3.5 py-2.5 text-xs bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C] text-slate-800"
                >
                  {doctors.map((doc) => (
                    <option key={doc.id} value={doc.id}>
                      Dr. {doc.first_name} {doc.last_name} ({doc.specialization || 'Attending Physician'})
                    </option>
                  ))}
                </select>
              ) : (
                <div className="p-3 bg-slate-50 border border-slate-200 rounded-xl text-xs text-slate-600">
                  <span>Facility Clinical Staff / On-Duty Physician</span>
                </div>
              )}
            </div>

            {/* Clinical Purpose / Reason */}
            <div className="space-y-1.5">
              <label className="block text-xs font-semibold text-slate-700">
                Clinical Purpose / Rationale <span className="text-rose-500">*</span>
              </label>
              <textarea
                id="request-reason-text"
                rows={3}
                value={reason}
                onChange={(e) => setReason(e.target.value)}
                placeholder="e.g. Outpatient hypertension consultation and historical lab biochemistry review..."
                className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C] text-slate-800"
                required
              />
            </div>

            {/* 15-Minute Bounded Window Notice */}
            <div className="p-4 rounded-2xl bg-[#E8F5E9]/60 border border-[#C8E6C9] text-xs text-[#1B5E20] space-y-1">
              <div className="flex items-center gap-1.5 font-bold">
                <Clock className="w-4 h-4 text-[#2E7D32]" />
                <span>Time-Bounded Cryptographic Consent Window</span>
              </div>
              <p className="text-[11px] text-[#2E7D32] leading-relaxed">
                Upon patient approval in their Afya mobile application, the grant unlocks longitudinal health records for your clinic for 15 minutes. All access events are cryptographically recorded in the national ledger.
              </p>
            </div>

            <div className="pt-4 flex items-center justify-end gap-3">
              <Button
                type="button"
                variant="outline"
                onClick={() => router.push('/clinic/requests')}
              >
                Cancel
              </Button>
              <Button
                type="submit"
                isLoading={isSubmitting}
                leftIcon={<KeyRound className="w-4 h-4" />}
                disabled={!patientId || !reason.trim()}
              >
                Dispatch Consent Request
              </Button>
            </div>
          </form>
        )}
      </div>
    </div>
  );
}
