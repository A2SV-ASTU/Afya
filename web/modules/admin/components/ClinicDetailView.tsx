'use client';

import React, { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import {
  Building2,
  ArrowLeft,
  ShieldAlert,
  CheckCircle2,
  Users,
  MapPin,
  Mail,
  Phone,
  PowerOff,
  Power,
  Calendar,
  AlertCircle,
  Stethoscope,
  RefreshCw,
  UserCheck,
} from 'lucide-react';
import { useStore } from '@/lib/store';
import { clinicsApi } from '@/lib/api/clinics';
import { getApiErrorMessage } from '@/lib/api/client';
import { Button } from '@/modules/core/ui/Button';
import { StatusBadge } from '@/modules/core/ui/StatusBadge';
import { ConfirmDialog } from '@/modules/core/ui/ConfirmDialog';
import { Clinic, DoctorResponse } from '@/types/database';

interface ClinicDetailViewProps {
  clinicId: string;
}

export function ClinicDetailView({ clinicId }: ClinicDetailViewProps) {
  const router = useRouter();
  const { clinics } = useStore();

  const [clinic, setClinic] = useState<Clinic | null>(() => clinics.find((c) => c.id === clinicId) || null);
  const [doctorsList, setDoctorsList] = useState<DoctorResponse[]>([]);
  const [isLoading, setIsLoading] = useState(!clinic);
  const [isActionLoading, setIsActionLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');
  const [showDeactivateDialog, setShowDeactivateDialog] = useState(false);

  // Fetch live clinic and doctor roster from backend
  const fetchClinicData = async () => {
    if (!clinicId) return;
    setIsLoading(true);
    setErrorMessage('');

    try {
      // 1. Fetch clinic details: GET /api/v1/clinics/:id
      const res = await clinicsApi.getById(clinicId);
      if (res && res.clinic) {
        setClinic(res.clinic);
      }

      // 2. Fetch doctors roster: GET /api/v1/clinics/:id/doctors
      try {
        const docRes = await clinicsApi.listDoctors(clinicId);
        if (docRes && docRes.doctors) {
          setDoctorsList(docRes.doctors);
        }
      } catch {
        // Doctors endpoint may be empty if none invited yet
      }
    } catch (err: unknown) {
      setErrorMessage(getApiErrorMessage(err, 'Failed to fetch clinic facility record.'));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchClinicData();
  }, [clinicId]);

  // Handle clinic activate/deactivate toggle
  const handleToggleClinicStatus = async () => {
    if (!clinic) return;
    setIsActionLoading(true);
    setErrorMessage('');
    setShowDeactivateDialog(false);

    try {
      const isCurrentlyActive = clinic.status === 'active';
      if (isCurrentlyActive) {
        // PATCH /api/v1/clinics/:id/deactivate
        await clinicsApi.deactivate(clinic.id);
        setClinic((prev) => (prev ? { ...prev, status: 'deactivated' } : prev));
      } else {
        // PATCH /api/v1/clinics/:id/activate
        await clinicsApi.activate(clinic.id);
        setClinic((prev) => (prev ? { ...prev, status: 'active' } : prev));
      }
    } catch (err: unknown) {
      setErrorMessage(getApiErrorMessage(err, 'Failed to update clinic facility status.'));
    } finally {
      setIsActionLoading(false);
    }
  };


  // Handle doctor activate/deactivate toggle
  const handleToggleDoctorStatus = async (doctor: DoctorResponse) => {
    if (!clinic) return;
    const isDocActive = doctor.doctor_status === 'active';

    try {
      if (isDocActive) {
        // PATCH /api/v1/clinics/:id/doctors/:doctor_id/deactivate
        await clinicsApi.deactivateDoctor(clinic.id, doctor.id);
        setDoctorsList((prev) =>
          prev.map((d) => (d.id === doctor.id ? { ...d, doctor_status: 'deactivated' } : d))
        );
      } else {
        // PATCH /api/v1/clinics/:id/doctors/:doctor_id/activate
        await clinicsApi.activateDoctor(clinic.id, doctor.id);
        setDoctorsList((prev) =>
          prev.map((d) => (d.id === doctor.id ? { ...d, doctor_status: 'active' } : d))
        );
      }
    } catch (err: unknown) {
      setErrorMessage(getApiErrorMessage(err, `Failed to update status for Dr. ${doctor.first_name} ${doctor.last_name}`));
    }
  };

  if (isLoading) {
    return (
      <div className="text-center p-16 bg-white rounded-3xl border border-slate-200">
        <div className="w-10 h-10 border-3 border-emerald-600 border-t-transparent rounded-full animate-spin mx-auto mb-4" />
        <h3 className="text-sm font-bold text-slate-800">Retrieving Facility Master Record...</h3>
        <p className="text-xs text-slate-400 mt-1">Connecting to Afya national health registry backend</p>
      </div>
    );
  }

  if (!clinic) {
    return (
      <div className="text-center p-12 bg-white rounded-3xl border border-slate-200 space-y-4">
        <div className="w-12 h-12 rounded-2xl bg-rose-50 border border-rose-200 text-rose-600 flex items-center justify-center mx-auto">
          <AlertCircle className="w-6 h-6" />
        </div>
        <div>
          <h3 className="text-base font-bold text-slate-900">Clinic Facility Not Found</h3>
          <p className="text-xs text-slate-500 mt-1">
            {errorMessage || 'The requested facility UUID does not exist or has been removed from the registry.'}
          </p>
        </div>
        <Button className="mt-4" onClick={() => router.push('/admin')}>
          Return to Admin Directory
        </Button>
      </div>
    );
  }

  const isActive = clinic.status === 'active';

  return (
    <div className="space-y-6">
      {/* Action Bar & Notification Alert */}
      {errorMessage && (
        <div className="p-4 rounded-2xl bg-rose-50 border border-rose-200 text-xs text-rose-700 font-medium flex items-start gap-2.5 animate-in fade-in">
          <AlertCircle className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
          <div className="flex-1">
            <p className="font-bold">Facility Operation Notice</p>
            <p className="text-rose-600 mt-0.5">{errorMessage}</p>
          </div>
        </div>
      )}

      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={() => router.push('/admin')}
            className="p-2 rounded-xl text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition-colors cursor-pointer"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-xl font-bold text-slate-900">{clinic.name}</h1>
              <StatusBadge status={clinic.status} />
            </div>
            <p className="text-xs text-slate-500 font-mono">UUID: {clinic.id} • Registered Healthcare Facility</p>
          </div>
        </div>

        <div className="flex items-center gap-2.5">
          <Button
            variant="outline"
            size="sm"
            onClick={fetchClinicData}
            leftIcon={<RefreshCw className="w-3.5 h-3.5" />}
          >
            Refresh
          </Button>

          <Button
            variant={isActive ? 'danger' : 'success'}
            size="sm"
            isLoading={isActionLoading}
            leftIcon={isActive ? <PowerOff className="w-4 h-4" /> : <Power className="w-4 h-4" />}
            onClick={() => setShowDeactivateDialog(true)}
          >
            {isActive ? 'Deactivate Facility' : 'Reactivate Facility'}
          </Button>
        </div>
      </div>

      {/* Facility Information Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {/* Card 1: Facility Profile */}
        <div className="bg-white rounded-3xl border border-slate-200 p-6 space-y-4">
          <h3 className="text-xs font-bold uppercase tracking-wider text-slate-400 flex items-center gap-2">
            <Building2 className="w-4 h-4 text-emerald-600" />
            Facility Contact & Location
          </h3>
          <div className="space-y-3 text-xs">
            <div className="flex items-center gap-2 text-slate-700">
              <Mail className="w-4 h-4 text-slate-400 shrink-0" />
              <span className="truncate">{clinic.email}</span>
            </div>
            <div className="flex items-center gap-2 text-slate-700">
              <Phone className="w-4 h-4 text-slate-400 shrink-0" />
              <span>{clinic.phone}</span>
            </div>
            <div className="flex items-center gap-2 text-slate-700">
              <MapPin className="w-4 h-4 text-slate-400 shrink-0" />
              <span>{clinic.address || 'Address not specified'}</span>
            </div>
          </div>
        </div>

        {/* Card 2: Governance */}
        <div className="bg-white rounded-3xl border border-slate-200 p-6 space-y-4">
          <h3 className="text-xs font-bold uppercase tracking-wider text-slate-400 flex items-center gap-2">
            <UserCheck className="w-4 h-4 text-emerald-600" />
            Facility Governance
          </h3>
          <div className="space-y-2 text-xs">
            <div>
              <span className="text-[11px] text-slate-400 block">Facility Admin Email</span>
              <span className="font-semibold text-slate-800">{clinic.email}</span>
            </div>
            <div>
              <span className="text-[11px] text-slate-400 block">Registration Timestamp</span>
              <span className="text-slate-600 font-mono text-[11px]">
                {clinic.created_at ? new Date(clinic.created_at).toLocaleString() : 'N/A'}
              </span>
            </div>
          </div>
        </div>

        {/* Card 3: Metrics & Clinical Scope */}
        <div className="bg-white rounded-3xl border border-slate-200 p-6 space-y-4">
          <h3 className="text-xs font-bold uppercase tracking-wider text-slate-400 flex items-center gap-2">
            <Users className="w-4 h-4 text-emerald-600" />
            Staffing Metrics
          </h3>
          <div className="space-y-3 text-xs">
            <div className="flex items-center justify-between">
              <span className="text-slate-500">Registered Physicians:</span>
              <span className="font-bold text-slate-900 text-sm">{doctorsList.length}</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-slate-500">Active Doctors:</span>
              <span className="font-bold text-emerald-700 text-sm">
                {doctorsList.filter((d) => d.doctor_status === 'active').length}
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Credentialed Doctors Roster */}
      <div className="bg-white rounded-3xl border border-slate-200 shadow-xs overflow-hidden">
        <div className="p-6 border-b border-slate-100 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Stethoscope className="w-5 h-5 text-[#2E7D32]" />
            <h3 className="text-base font-bold text-slate-900">
              Credentialed Doctors Roster ({doctorsList.length})
            </h3>
          </div>
        </div>

        {doctorsList.length === 0 ? (
          <div className="p-8 text-center text-xs text-slate-400">
            No doctors have registered under this facility yet. The clinic administrator can invite doctors via the Clinic Workspace.
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead>
                <tr className="border-b border-slate-100 bg-slate-50 text-slate-500 uppercase text-[11px]">
                  <th className="py-3 px-6">Doctor</th>
                  <th className="py-3 px-6">Specialization</th>
                  <th className="py-3 px-6">License Number</th>
                  <th className="py-3 px-6">Contact Email</th>
                  <th className="py-3 px-6">Status</th>
                  <th className="py-3 px-6 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {doctorsList.map((doc) => (
                  <tr key={doc.id}>
                    <td className="py-3 px-6 font-bold text-slate-900">
                      Dr. {doc.first_name} {doc.last_name}
                    </td>
                    <td className="py-3 px-6 text-slate-600">{doc.specialization || 'General Practice'}</td>
                    <td className="py-3 px-6 font-mono text-slate-500">{doc.license_number || 'KMPDC-REG'}</td>
                    <td className="py-3 px-6 text-slate-500">{doc.email || '—'}</td>
                    <td className="py-3 px-6">
                      <StatusBadge status={doc.doctor_status || 'active'} />
                    </td>
                    <td className="py-3 px-6 text-right">
                      <button
                        type="button"
                        onClick={() => handleToggleDoctorStatus(doc)}
                        className={`px-2.5 py-1 rounded-lg text-[11px] font-semibold border transition-colors cursor-pointer ${
                          doc.doctor_status === 'active'
                            ? 'bg-rose-50 text-rose-700 border-rose-200 hover:bg-rose-100'
                            : 'bg-emerald-50 text-emerald-700 border-emerald-200 hover:bg-emerald-100'
                        }`}
                      >
                        {doc.doctor_status === 'active' ? 'Deactivate' : 'Activate'}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Confirmation Dialog */}
      <ConfirmDialog
        isOpen={showDeactivateDialog}
        onClose={() => setShowDeactivateDialog(false)}
        onConfirm={handleToggleClinicStatus}
        title={isActive ? `Deactivate ${clinic.name}?` : `Reactivate ${clinic.name}?`}
        description={
          isActive
            ? `Deactivating ${clinic.name} will suspend clinic administrator login and doctor clinical sessions until reactivated by SuperAdmin.`
            : `Reactivating ${clinic.name} will restore clinic administrator login and physician clinical operations.`
        }
        confirmText={isActive ? 'Yes, Deactivate Facility' : 'Reactivate Facility'}
        variant={isActive ? 'danger' : 'success'}
      />
    </div>
  );
}

