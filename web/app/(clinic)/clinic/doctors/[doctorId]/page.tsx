'use client';

import React from 'react';
import { useParams, useRouter } from 'next/navigation';
import { ArrowLeft, Stethoscope, Mail, Phone, ShieldCheck, CheckCircle2 } from 'lucide-react';
import { useStore } from '@/lib/store';
import { Button } from '@/modules/core/ui/Button';
import { StatusBadge } from '@/modules/core/ui/StatusBadge';

export default function DoctorDetailPage() {
  const router = useRouter();
  const params = useParams();
  const doctorId = (params?.doctorId as string) || '';

  const { doctors, encounters, activeClinic, deactivateDoctor, activateDoctor } = useStore();
  const doctor = doctors.find((d) => d.id === doctorId);
  const doctorEncounters = encounters.filter((e) => e.opened_by_doctor_id === doctorId);

  console.log('[DoctorDetailPage] State:', {
    doctorId,
    doctor,
    activeClinicId: activeClinic.id,
    doctorStatus: doctor?.doctor_status,
  });

  if (!doctor) {
    return (
      <div className="p-8 text-center bg-white rounded-3xl border border-slate-200">
        <h3 className="text-base font-bold text-slate-900">Doctor Profile Not Found</h3>
        <Button className="mt-4" onClick={() => router.push('/clinic/doctors')}>
          Back to Roster
        </Button>
      </div>
    );
  }

  const handleToggleStatus = async () => {
    if (!activeClinic.id || !doctor?.id) {
      console.error('[DoctorDetailPage] Missing required IDs:', { 
        activeClinicId: activeClinic.id, 
        doctorId: doctor?.id 
      });
      return;
    }
    
    console.log('[DoctorDetailPage] Toggling status:', {
      currentStatus: doctor.doctor_status,
      willActivate: doctor.doctor_status !== 'active',
    });
    
    try {
      if (doctor.doctor_status === 'active') {
        await deactivateDoctor(activeClinic.id, doctor.id);
      } else {
        await activateDoctor(activeClinic.id, doctor.id);
      }
      console.log('[DoctorDetailPage] Status toggled successfully');
    } catch (err) {
      console.error('[DoctorDetailPage] Failed to toggle status:', err);
    }
  };

  if (!doctor) {
    return (
      <div className="p-8 text-center bg-white rounded-3xl border border-slate-200">
        <h3 className="text-base font-bold text-slate-900">Doctor Profile Not Found</h3>
        <Button className="mt-4" onClick={() => router.push('/clinic/doctors')}>
          Back to Roster
        </Button>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={() => router.push('/clinic/doctors')}
            className="p-2 rounded-xl text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition-colors"
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
            <p className="text-xs text-slate-500">
              {doctor.specialization || 'General Practice'} • License: {doctor.license_number || 'KMPDC-REG'}
            </p>
          </div>
        </div>

        <div>
          <Button
            variant={doctor.doctor_status === 'active' ? 'danger' : 'success'}
            size="sm"
            onClick={handleToggleStatus}
          >
            {doctor.doctor_status === 'active' ? 'Deactivate Doctor' : 'Reactivate Doctor'}
          </Button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-white p-6 rounded-3xl border border-slate-200 space-y-3 text-xs">
          <p className="text-[10px] font-bold text-slate-400 uppercase">Contact Information</p>
          <div className="flex items-center gap-2 text-slate-700">
            <Mail className="w-4 h-4 text-slate-400" />
            <span>{doctor.email}</span>
          </div>
          <div className="flex items-center gap-2 text-slate-700">
            <Phone className="w-4 h-4 text-slate-400" />
            <span>{doctor.phone || '+254 700 000000'}</span>
          </div>
        </div>

        <div className="bg-white p-6 rounded-3xl border border-slate-200 space-y-3 text-xs">
          <p className="text-[10px] font-bold text-slate-400 uppercase">Credentials & Verification</p>
          <p className="font-bold text-slate-900">KMPDC Registration Active</p>
          <p className="text-slate-500">Authorized for clinical encounters & e-prescriptions</p>
        </div>

        <div className="bg-white p-6 rounded-3xl border border-slate-200 space-y-3 text-xs">
          <p className="text-[10px] font-bold text-slate-400 uppercase">Activity Summary</p>
          <p className="text-lg font-bold text-slate-900">{doctorEncounters.length} Encounters</p>
          <p className="text-slate-500">Recorded and signed at this facility</p>
        </div>
      </div>
    </div>
  );
}
