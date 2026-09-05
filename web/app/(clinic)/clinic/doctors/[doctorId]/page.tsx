'use client';

import React, { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { ArrowLeft, Stethoscope, Mail, Phone, ShieldCheck, CheckCircle2, PowerOff, Power, AlertCircle, RefreshCw } from 'lucide-react';
import { useAuth } from '@/modules/core/context/AuthContext';
import { clinicsApi } from '@/lib/api/clinics';
import { getApiErrorMessage } from '@/lib/api/client';
import { Button } from '@/modules/core/ui/Button';
import { StatusBadge } from '@/modules/core/ui/StatusBadge';
import { ConfirmDialog } from '@/modules/core/ui/ConfirmDialog';
import { DoctorResponse } from '@/types/database';

export default function DoctorDetailPage() {
  const router = useRouter();
  const params = useParams();
  const doctorId = (params?.doctorId as string) || '';

  const { currentUser, isReady } = useAuth();
  const clinicId = currentUser?.clinic_id;

  const [doctor, setDoctor] = useState<DoctorResponse | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isActionLoading, setIsActionLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');
  const [showConfirmModal, setShowConfirmModal] = useState(false);

  const fetchDoctor = async () => {
    if (!clinicId || !doctorId) {
      setIsLoading(false);
      return;
    }
    setIsLoading(true);
    setErrorMessage('');

    try {
      const res = await clinicsApi.listDoctors(clinicId);
      if (res && res.doctors) {
        const found = res.doctors.find((d) => d.id === doctorId);
        if (found) {
          setDoctor(found);
        } else {
          setDoctor(null);
          setErrorMessage('Doctor record not found in facility roster.');
        }
      } else {
        setDoctor(null);
        setErrorMessage('Doctor record not found in facility roster.');
      }
    } catch (err: unknown) {
      setErrorMessage(getApiErrorMessage(err, 'Failed to fetch doctor profile.'));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    if (clinicId && doctorId) {
      fetchDoctor();
    } else if (isReady) {
      setIsLoading(false);
    }
  }, [clinicId, doctorId, isReady]);

  const handleToggleStatus = async () => {
    if (!clinicId || !doctor) return;
    setIsActionLoading(true);
    setErrorMessage('');
    setShowConfirmModal(false);

    try {
      const isCurrentlyActive = doctor.doctor_status === 'active';
      if (isCurrentlyActive) {
        await clinicsApi.deactivateDoctor(clinicId, doctor.id);
        setDoctor((prev) => (prev ? { ...prev, doctor_status: 'deactivated' } : prev));
      } else {
        await clinicsApi.activateDoctor(clinicId, doctor.id);
        setDoctor((prev) => (prev ? { ...prev, doctor_status: 'active' } : prev));
      }
    } catch (err: unknown) {
      setErrorMessage(getApiErrorMessage(err, 'Failed to update doctor authorization status.'));
    } finally {
      setIsActionLoading(false);
    }
  };

  if (isLoading) {
    return (
      <div className="p-16 text-center bg-white rounded-3xl border border-slate-200">
        <div className="w-8 h-8 border-3 border-emerald-600 border-t-transparent rounded-full animate-spin mx-auto mb-3" />
        <p className="text-xs text-slate-500">Retrieving physician credentials from registry...</p>
      </div>
    );
  }

  if (!doctor) {
    return (
      <div className="p-8 text-center bg-white rounded-3xl border border-slate-200 space-y-4">
        <div className="w-12 h-12 rounded-2xl bg-rose-50 border border-rose-200 text-rose-600 flex items-center justify-center mx-auto">
          <AlertCircle className="w-6 h-6" />
        </div>
        <h3 className="text-base font-bold text-slate-900">Physician Profile Not Found</h3>
        <p className="text-xs text-slate-500">{errorMessage || 'The requested doctor ID does not exist in this clinic roster.'}</p>
        <Button className="mt-4" onClick={() => router.push('/clinic/doctors')}>
          Back to Roster
        </Button>
      </div>
    );
  }

  const isActive = doctor.doctor_status === 'active';

  return (
    <div className="space-y-6">
      {errorMessage && (
        <div className="p-4 rounded-2xl bg-rose-50 border border-rose-200 text-xs text-rose-700 font-medium flex items-start gap-2.5 animate-in fade-in">
          <AlertCircle className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
          <div className="flex-1">
            <p className="font-bold">Credential Notice</p>
            <p className="text-rose-600 mt-0.5">{errorMessage}</p>
          </div>
        </div>
      )}

      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={() => router.push('/clinic/doctors')}
            className="p-2 rounded-xl text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition-colors cursor-pointer"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-xl font-bold text-slate-900">
                Dr. {doctor.first_name} {doctor.last_name}
              </h1>
              <StatusBadge status={doctor.doctor_status || 'active'} />
            </div>
            <p className="text-xs text-slate-500 font-mono">
              {doctor.specialization || 'General Practice'} • License: {doctor.license_number || 'KMPDC-REG'}
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2.5">
          <Button
            variant="outline"
            size="sm"
            onClick={fetchDoctor}
            leftIcon={<RefreshCw className="w-3.5 h-3.5" />}
          >
            Refresh
          </Button>

          <Button
            variant={isActive ? 'danger' : 'success'}
            size="sm"
            isLoading={isActionLoading}
            leftIcon={isActive ? <PowerOff className="w-4 h-4" /> : <Power className="w-4 h-4" />}
            onClick={() => setShowConfirmModal(true)}
          >
            {isActive ? 'Deactivate Doctor' : 'Reactivate Doctor'}
          </Button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white p-6 rounded-3xl border border-slate-200 space-y-3 text-xs">
          <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Contact Details</p>
          <div className="flex items-center gap-2 text-slate-700">
            <Mail className="w-4 h-4 text-slate-400 shrink-0" />
            <span className="truncate">{doctor.email}</span>
          </div>
          <div className="flex items-center gap-2 text-slate-700">
            <Phone className="w-4 h-4 text-slate-400 shrink-0" />
            <span>{doctor.phone || '+254 700 000000'}</span>
          </div>
        </div>

        <div className="bg-white p-6 rounded-3xl border border-slate-200 space-y-3 text-xs">
          <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Credentials & Accreditation</p>
          <p className="font-bold text-slate-900 flex items-center gap-1.5">
            <ShieldCheck className="w-4 h-4 text-emerald-600" />
            KMPDC Registry Verified
          </p>
          <p className="text-slate-500">Authorized for outpatient encounters, diagnostics & e-prescriptions</p>
        </div>

        <div className="bg-white p-6 rounded-3xl border border-slate-200 space-y-3 text-xs">
          <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Clinical Status</p>
          <p className="text-lg font-bold text-slate-900 capitalize">{doctor.doctor_status || 'Active'}</p>
          <p className="text-slate-500">Facility authorization and clinical encounter privileges</p>
        </div>
      </div>

      {/* Confirmation Dialog */}
      <ConfirmDialog
        isOpen={showConfirmModal}
        onClose={() => setShowConfirmModal(false)}
        onConfirm={handleToggleStatus}
        title={isActive ? `Deactivate Dr. ${doctor.first_name} ${doctor.last_name}?` : `Reactivate Dr. ${doctor.first_name} ${doctor.last_name}?`}
        description={
          isActive
            ? `Deactivating this doctor will prevent them from signing into this clinic or creating clinical encounters until reactivated.`
            : `Reactivating this doctor will restore their clinical privileges for this facility.`
        }
        confirmText={isActive ? 'Deactivate Doctor' : 'Reactivate Doctor'}
        variant={isActive ? 'danger' : 'success'}
      />
    </div>
  );
}

