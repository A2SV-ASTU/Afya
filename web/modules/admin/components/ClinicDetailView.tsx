'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Building2, ArrowLeft, ShieldAlert, CheckCircle2, Users, MapPin, Mail, Phone } from 'lucide-react';
import { useStore } from '@/lib/store';
import { Button } from '@/modules/core/ui/Button';
import { StatusBadge } from '@/modules/core/ui/StatusBadge';
import { ConfirmDialog } from '@/modules/core/ui/ConfirmDialog';

interface ClinicDetailViewProps {
  clinicId: string;
}

export function ClinicDetailView({ clinicId }: ClinicDetailViewProps) {
  const router = useRouter();
  const { clinics, doctors, deactivateClinic } = useStore();
  const [showDeactivateDialog, setShowDeactivateDialog] = useState(false);

  const clinic = clinics.find((c) => c.id === clinicId);
  const clinicDoctors = doctors.filter((d) => d.clinic_id === clinicId);

  if (!clinic) {
    return (
      <div className="text-center p-12 bg-white rounded-3xl border border-slate-200">
        <h3 className="text-base font-bold text-slate-900">Clinic Facility Not Found</h3>
        <p className="text-xs text-slate-500 mt-1">The requested facility does not exist or was purged.</p>
        <Button className="mt-4" onClick={() => router.push('/admin')}>
          Back to Directory
        </Button>
      </div>
    );
  }

  const handleToggleDeactivate = () => {
    deactivateClinic(clinic.id);
    setShowDeactivateDialog(false);
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={() => router.push('/admin')}
            className="p-2 rounded-xl text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-xl font-bold text-slate-900">{clinic.name}</h1>
              <StatusBadge status={clinic.status} />
            </div>
            <p className="text-xs text-slate-500">ID: {clinic.id} • Facility Master Record</p>
          </div>
        </div>

        <div>
          <Button
            variant={clinic.status === 'active' ? 'danger' : 'success'}
            size="sm"
            onClick={() => setShowDeactivateDialog(true)}
          >
            {clinic.status === 'active' ? 'Deactivate Facility' : 'Reactivate Facility'}
          </Button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white rounded-3xl border border-slate-200 p-6 space-y-4">
          <h3 className="text-xs font-bold uppercase tracking-wider text-slate-400">Facility Information</h3>
          <div className="space-y-3 text-xs">
            <div className="flex items-center gap-2 text-slate-700">
              <Mail className="w-4 h-4 text-slate-400" />
              <span>{clinic.email}</span>
            </div>
            <div className="flex items-center gap-2 text-slate-700">
              <Phone className="w-4 h-4 text-slate-400" />
              <span>{clinic.phone}</span>
            </div>
            <div className="flex items-center gap-2 text-slate-700">
              <MapPin className="w-4 h-4 text-slate-400" />
              <span>{clinic.address}</span>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-3xl border border-slate-200 p-6 space-y-4">
          <h3 className="text-xs font-bold uppercase tracking-wider text-slate-400">Facility Administrator</h3>
          <div className="space-y-1">
            <p className="text-sm font-bold text-slate-900">{clinic.admin_name}</p>
            <p className="text-xs text-slate-500">{clinic.admin_email}</p>
            <p className="text-[11px] text-slate-400 pt-2">Authorized to manage roster & doctor credentialing</p>
          </div>
        </div>

        <div className="bg-white rounded-3xl border border-slate-200 p-6 space-y-4">
          <h3 className="text-xs font-bold uppercase tracking-wider text-slate-400">Staffing & Encounters</h3>
          <div className="flex items-center justify-between">
            <span className="text-xs text-slate-500">Credentialed Physicians</span>
            <span className="text-sm font-bold text-slate-900">{clinicDoctors.length}</span>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-xs text-slate-500">Active Patient Grants</span>
            <span className="text-sm font-bold text-slate-900">{clinic.active_grants_count}</span>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-3xl border border-slate-200 shadow-xs overflow-hidden">
        <div className="p-6 border-b border-slate-100">
          <h3 className="text-base font-bold text-slate-900">Credentialed Doctors Roster ({clinicDoctors.length})</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead>
              <tr className="border-b border-slate-100 bg-slate-50 text-slate-500 uppercase text-[11px]">
                <th className="py-3 px-6">Doctor</th>
                <th className="py-3 px-6">Specialization</th>
                <th className="py-3 px-6">License Number</th>
                <th className="py-3 px-6">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {clinicDoctors.map((doc) => (
                <tr key={doc.id}>
                  <td className="py-3 px-6 font-bold text-slate-900">
                    Dr. {doc.first_name} {doc.last_name}
                  </td>
                  <td className="py-3 px-6 text-slate-600">{doc.specialization || 'General Practice'}</td>
                  <td className="py-3 px-6 font-mono text-slate-500">{doc.license_number || 'KMPDC-REG'}</td>
                  <td className="py-3 px-6">
                    <StatusBadge status={doc.doctor_status || 'active'} />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      <ConfirmDialog
        isOpen={showDeactivateDialog}
        onClose={() => setShowDeactivateDialog(false)}
        onConfirm={handleToggleDeactivate}
        title={clinic.status === 'active' ? 'Deactivate Clinic Facility?' : 'Reactivate Clinic Facility?'}
        description={
          clinic.status === 'active'
            ? 'Deactivating this facility will suspend all affiliated doctor access until re-enabled by SuperAdmin.'
            : 'Reactivating this facility will restore all credentialed physician clinical operations.'
        }
        confirmText={clinic.status === 'active' ? 'Deactivate' : 'Reactivate'}
        variant={clinic.status === 'active' ? 'danger' : 'success'}
      />
    </div>
  );
}
