'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import {
  Building2,
  Users,
  Search,
  KeyRound,
  ShieldCheck,
  PlusCircle,
  Clock,
  ArrowRight,
  Stethoscope,
  Activity,
  RefreshCw,
  MailCheck,
  AlertCircle,
} from 'lucide-react';
import { useAuth } from '@/modules/core/context/AuthContext';
import { clinicsApi } from '@/lib/api/clinics';
import { accessRequestsApi } from '@/lib/api/access-requests';
import { getApiErrorMessage } from '@/lib/api/client';
import { StatCard } from '@/modules/core/ui/StatCard';
import { StatusBadge } from '@/modules/core/ui/StatusBadge';
import { Button } from '@/modules/core/ui/Button';
import { Clinic, DoctorResponse, DoctorInvitation, AccessRequest } from '@/types/database';

export default function ClinicDashboardPage() {
  const { currentUser, isReady } = useAuth();
  const clinicId = currentUser?.clinic_id;

  const [clinic, setClinic] = useState<Clinic | null>(null);
  const [doctorsList, setDoctorsList] = useState<DoctorResponse[]>([]);
  const [invitationsList, setInvitationsList] = useState<DoctorInvitation[]>([]);
  const [requestsList, setRequestsList] = useState<AccessRequest[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState('');

  const fetchDashboardData = async () => {
    if (!clinicId) {
      setIsLoading(false);
      return;
    }
    setIsLoading(true);
    setErrorMessage('');

    try {
      // Parallel fetch: clinic details, doctors roster, invitations, and access requests
      const [clinicRes, doctorsRes, invitesRes, requestsRes] = await Promise.allSettled([
        clinicsApi.getById(clinicId),
        clinicsApi.listDoctors(clinicId),
        clinicsApi.listInvitations(clinicId),
        accessRequestsApi.listRequests(clinicId),
      ]);

      if (clinicRes.status === 'fulfilled' && clinicRes.value?.clinic) {
        setClinic(clinicRes.value.clinic);
      }

      if (doctorsRes.status === 'fulfilled' && doctorsRes.value?.doctors) {
        setDoctorsList(doctorsRes.value.doctors);
      }

      if (invitesRes.status === 'fulfilled' && invitesRes.value?.invitations) {
        setInvitationsList(invitesRes.value.invitations);
      }

      if (requestsRes.status === 'fulfilled' && requestsRes.value?.access_requests) {
        setRequestsList(requestsRes.value.access_requests);
      }
    } catch (err: unknown) {
      setErrorMessage(getApiErrorMessage(err, 'Failed to sync live clinic dashboard metrics.'));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    if (clinicId) {
      fetchDashboardData();
    } else if (isReady) {
      setIsLoading(false);
    }
  }, [clinicId, isReady]);

  if (!isReady || (isLoading && !clinic && clinicId)) {
    return (
      <div className="p-12 text-center bg-white rounded-3xl border border-slate-200">
        <div className="w-8 h-8 border-3 border-emerald-600 border-t-transparent rounded-full animate-spin mx-auto mb-3" />
        <p className="text-xs text-slate-500">Loading clinic facility operations...</p>
      </div>
    );
  }

  if (isReady && !clinicId) {
    return (
      <div className="p-8 text-center bg-white rounded-3xl border border-slate-200 space-y-3">
        <div className="w-12 h-12 rounded-2xl bg-amber-50 text-amber-600 flex items-center justify-center mx-auto border border-amber-200">
          <AlertCircle className="w-6 h-6" />
        </div>
        <h2 className="text-base font-bold text-slate-900">No Facility Assigned</h2>
        <p className="text-xs text-slate-500 max-w-sm mx-auto">
          Your administrator account is not currently assigned to an accredited clinic facility. Please contact support.
        </p>
      </div>
    );
  }

  const displayedClinicName = clinic?.name || 'Clinic Facility';
  const displayedStatus = clinic?.status || 'active';
  const displayedAddress = clinic?.address || 'Healthcare Facility';
  const displayedPhone = clinic?.phone;

  const pendingRequests = requestsList.filter((r) => r.status === 'pending' && !r.revoked_at);
  const nonRevokedApprovedGrants = requestsList.filter(
    (r) => r.status === 'approved' && !r.revoked_at
  );
  const activeGrants = Array.from(
    new Set(nonRevokedApprovedGrants.map((r) => r.patient_id))
  );
  const activeDoctors = doctorsList.filter((d) => d.doctor_status !== 'deactivated');
  const pendingInvitations = invitationsList.filter((i) => i.status === 'pending');


  return (
    <div className="space-y-6">
      {errorMessage && (
        <div className="p-4 rounded-2xl bg-rose-50 border border-rose-200 text-xs text-rose-700 font-medium flex items-start gap-2.5 animate-in fade-in">
          <AlertCircle className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
          <div className="flex-1">
            <p className="font-bold">Sync Notice</p>
            <p className="text-rose-600 mt-0.5">{errorMessage}</p>
          </div>
        </div>
      )}

      {/* Clinic Welcome & Status Banner */}
      <div className="bg-white rounded-3xl border border-slate-200 shadow-xs p-6 flex flex-wrap items-center justify-between gap-4">
        <div className="flex items-center gap-4">
          <div className="w-14 h-14 rounded-2xl bg-[#E8F5E9] text-[#2E7D32] border border-[#C8E6C9] flex items-center justify-center font-bold shrink-0">
            <Building2 className="w-7 h-7" />
          </div>
          <div>
            <div className="flex items-center gap-2.5 flex-wrap">
              <h1 className="text-xl font-bold text-slate-900">{displayedClinicName}</h1>
              <StatusBadge status={displayedStatus} />
            </div>
            <p className="text-xs text-slate-500 mt-1">
              {displayedAddress} {displayedPhone && `• Tel: ${displayedPhone}`}
              {currentUser && ` • Administrator: ${currentUser.first_name} ${currentUser.last_name} (${currentUser.email})`}
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2.5">
          <Button
            variant="outline"
            size="sm"
            onClick={fetchDashboardData}
            isLoading={isLoading}
            leftIcon={<RefreshCw className="w-3.5 h-3.5" />}
          >
            Refresh
          </Button>

          {/* <Link href="/clinic/lookup">
            <Button size="sm" variant="outline" leftIcon={<Search className="w-3.5 h-3.5" />}>
              Patient Lookup
            </Button>
          </Link> */}
          <Link href="/clinic/lookup">
            <Button size="sm" leftIcon={<KeyRound className="w-3.5 h-3.5" />}>
              + Request Consent
            </Button>
          </Link>
        </div>
      </div>

      {/* KPI Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard
          title="Active Doctors Roster"
          value={activeDoctors.length}
          subtitle={`${doctorsList.length} total registered`}
          badge={activeDoctors.length > 0 ? 'Verified' : 'No Doctors'}
          icon={<Users className="w-5 h-5" />}
        />

        <StatCard
          title="Active Consent Grants"
          value={activeGrants.length}
          subtitle="Citizen approved charts"
          badge={activeGrants.length > 0 ? 'Live' : 'None'}
          progressPercent={activeGrants.length > 0 ? Math.min(activeGrants.length * 25, 100) : 0}
          icon={<ShieldCheck className="w-5 h-5" />}
        />

        <StatCard
          title="Pending Consent Requests"
          value={pendingRequests.length}
          subtitle="Awaiting mobile confirmation"
          badge={pendingRequests.length > 0 ? 'Action Needed' : 'None'}
          icon={<KeyRound className="w-5 h-5" />}
        />

        <StatCard
          title="Doctor Invitations"
          value={invitationsList.length}
          subtitle={`${pendingInvitations.length} pending onboarding`}
          badge={pendingInvitations.length > 0 ? 'Sent' : 'Settled'}
          icon={<MailCheck className="w-5 h-5" />}
        />
      </div>

      {/* Quick Access Tiles */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Link
          href="/clinic/doctors"
          className="group p-6 bg-white rounded-3xl border border-slate-200 hover:border-[#A5D6A7] hover:shadow-xs transition-all space-y-3"
        >
          <div className="w-10 h-10 rounded-2xl bg-[#E8F5E9] text-[#2E7D32] flex items-center justify-center group-hover:scale-105 transition-transform">
            <Stethoscope className="w-5 h-5" />
          </div>
          <div>
            <h3 className="text-sm font-bold text-slate-900">Doctors Roster & Invitations</h3>
            <p className="text-xs text-slate-500 mt-1">
              Invite licensed physicians via email magic links and manage clinical access credentials.
            </p>
          </div>
        </Link>

        <Link
          href="/clinic/lookup"
          className="group p-6 bg-white rounded-3xl border border-slate-200 hover:border-[#A5D6A7] hover:shadow-xs transition-all space-y-3"
        >
          <div className="w-10 h-10 rounded-2xl bg-[#E8F5E9] text-[#2E7D32] flex items-center justify-center group-hover:scale-105 transition-transform">
            <Search className="w-5 h-5" />
          </div>
          <div>
            <h3 className="text-sm font-bold text-slate-900">Citizen Lookup & Consent</h3>
            <p className="text-xs text-slate-500 mt-1">
              Verify registered citizen email and dispatch instant 15-minute access authorization requests.
            </p>
          </div>
        </Link>

        <Link
          href="/clinic/active-access"
          className="group p-6 bg-white rounded-3xl border border-slate-200 hover:border-[#A5D6A7] hover:shadow-xs transition-all space-y-3"
        >
          <div className="w-10 h-10 rounded-2xl bg-[#E8F5E9] text-[#2E7D32] flex items-center justify-center group-hover:scale-105 transition-transform">
            <ShieldCheck className="w-5 h-5" />
          </div>
          <div>
            <h3 className="text-sm font-bold text-slate-900">Active Patient Grants</h3>
            <p className="text-xs text-slate-500 mt-1">
              View authorized patient charts, review medical history, or revoke access early.
            </p>
          </div>
        </Link>
      </div>
    </div>
  );
}

