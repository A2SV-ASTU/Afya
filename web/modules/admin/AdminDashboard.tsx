'use client';

import React, { useState } from 'react';
import { useStore } from '@/lib/store';
import { StatCard } from '@/components/ui/StatCard';
import { StatusBadge } from '@/components/ui/Badge';
import {
  Building2,
  CheckCircle2,
  XCircle,
  Stethoscope,
  Plus,
  Search,
  ChevronRight,
  ShieldCheck,
  Building,
  Info,
} from 'lucide-react';

export function AdminDashboard() {
  const { clinics, doctors, navigateTo, clinicsLoading, clinicsError, activateClinic, deactivateClinic } = useStore();
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'active' | 'deactivated'>('all');

  // Compute Platform-Level Counts ONLY (Zero Patient / Clinical Data visibility)
  const totalClinics = clinics.length;
  const activeClinics = clinics.filter((c) => c.status === 'active').length;
  const deactivatedClinics = clinics.filter((c) => c.status === 'deactivated').length;
  const totalDoctors = doctors.length;

  const filteredClinics = clinics.filter((c) => {
    const matchesSearch =
      c.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      c.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
      c.phone.includes(searchTerm);
    const matchesStatus = statusFilter === 'all' || c.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  return (
    <div id="admin-dashboard-page" className="p-8 space-y-6 max-w-7xl mx-auto">
      {clinicsLoading && (
        <div className="text-center py-12 text-slate-400">Loading clinics…</div>
      )}
      {clinicsError && (
        <div className="p-4 bg-rose-50 border border-rose-200 rounded-xl text-rose-700 text-sm">
          {clinicsError}
        </div>
      )}
      {!clinicsLoading && !clinicsError && (
        <>
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 text-xs font-semibold text-[#2E7D32] uppercase tracking-wider mb-1">
            <ShieldCheck className="w-4 h-4 text-[#388E3C]" />
            <span>SuperAdmin Console</span>
          </div>
          <h2 className="text-xl font-bold tracking-tight text-slate-900">
            Registered Healthcare Facilities & Analytics
          </h2>
          <p className="text-sm text-slate-500 mt-0.5">
            Centralized platform oversight: onboard healthcare institutions, manage operational statuses, and review system capacities.
          </p>
        </div>

        <button
          id="admin-create-clinic-cta"
          type="button"
          onClick={() => navigateTo('admin-create-clinic')}
          className="inline-flex items-center justify-center gap-2 px-4 py-2.5 bg-[#388E3C] hover:bg-[#2E7D32] text-white rounded-xl text-xs font-semibold shadow-xs transition-colors cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          <span>Onboard New Clinic</span>
        </button>
      </div>

      {/* Zero Visibility Governance Banner */}
      <div className="p-5 bg-[#0F2617] text-slate-300 rounded-3xl border border-[#1C3E25] flex items-start gap-3.5 shadow-md">
        <Info className="w-5 h-5 text-[#A5D6A7] shrink-0 mt-0.5" />
        <div className="text-xs space-y-1">
          <p className="font-semibold text-white text-sm">
            Zero-Visibility Clinical Privacy Architecture
          </p>
          <p className="text-slate-400 leading-relaxed">
            Per the Afya Data Retention & RBAC Specification (Section 4), Super Admins hold platform-level institution governance only. Super Admins cannot view doctor rosters, patient records, access-request logs, or clinical history.
          </p>
        </div>
      </div>

      {/* Analytics Section (Top Cards) */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          id="stat-total-clinics"
          title="Total Registered Clinics"
          value={totalClinics}
          subtitle="Healthcare institutions in registry"
          progressPercent={100}
          progressColor="bg-[#388E3C]"
          icon={<Building2 className="w-5 h-5" />}
        />
        <StatCard
          id="stat-active-clinics"
          title="Active Facilities"
          value={activeClinics}
          subtitle="Operational with active credentials"
          badge="Operational"
          progressPercent={totalClinics > 0 ? (activeClinics / totalClinics) * 100 : 100}
          progressColor="bg-[#43A047]"
          icon={<CheckCircle2 className="w-5 h-5" />}
        />
        <StatCard
          id="stat-deactivated-clinics"
          title="Deactivated Facilities"
          value={deactivatedClinics}
          subtitle="Suspended institution accounts"
          badge={deactivatedClinics > 0 ? `${deactivatedClinics} Off` : '0'}
          progressPercent={totalClinics > 0 ? (deactivatedClinics / totalClinics) * 100 : 0}
          progressColor="bg-rose-500"
          icon={<XCircle className="w-5 h-5" />}
        />
        <StatCard
          id="stat-total-doctors"
          title="Total System Doctors"
          value={totalDoctors}
          subtitle="Physicians across all facilities"
          progressPercent={85}
          progressColor="bg-[#2E7D32]"
          icon={<Stethoscope className="w-5 h-5" />}
        />
      </div>

      {/* Clinics Table Section */}
      <div className="bg-white rounded-3xl border border-slate-200 shadow-sm overflow-hidden">
        <div className="p-6 border-b border-slate-100 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h3 className="text-base font-bold text-slate-900">Registered Clinics</h3>
            <p className="text-xs text-slate-500 mt-0.5">
              Click any clinic row to inspect administrative details or modify activation status.
            </p>
          </div>

          <div className="flex flex-wrap items-center gap-3">
            {/* Filter Pills */}
            <div className="inline-flex p-1 bg-slate-100 rounded-xl text-xs font-medium">
              <button
                type="button"
                onClick={() => setStatusFilter('all')}
                className={`px-3 py-1.5 rounded-lg transition-colors cursor-pointer ${
                  statusFilter === 'all' ? 'bg-white text-slate-900 shadow-xs font-semibold' : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                All ({clinics.length})
              </button>
              <button
                type="button"
                onClick={() => setStatusFilter('active')}
                className={`px-3 py-1.5 rounded-lg transition-colors cursor-pointer ${
                  statusFilter === 'active' ? 'bg-white text-slate-900 shadow-xs font-semibold' : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                Active ({activeClinics})
              </button>
              <button
                type="button"
                onClick={() => setStatusFilter('deactivated')}
                className={`px-3 py-1.5 rounded-lg transition-colors cursor-pointer ${
                  statusFilter === 'deactivated' ? 'bg-white text-slate-900 shadow-xs font-semibold' : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                Deactivated ({deactivatedClinics})
              </button>
            </div>

            {/* Search Bar */}
            <div className="relative min-w-[240px]">
              <Search className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
              <input
                id="search-clinics-input"
                type="text"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder="Search clinic name, admin, phone..."
                className="w-full pl-9 pr-3 py-2 bg-white border border-slate-200 rounded-xl text-xs text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C]"
              />
            </div>
          </div>
        </div>

        {/* Table Content */}
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-slate-600">
            <thead className="bg-slate-50 border-b border-slate-200 text-[11px] font-semibold text-slate-500 uppercase tracking-wider">
              <tr>
                <th className="py-4 px-6">Facility & Address</th>
                <th className="py-4 px-6">Contact Details</th>
                <th className="py-4 px-6">Status</th>
                <th className="py-4 px-6">Onboarded</th>
                <th className="py-4 px-6 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredClinics.length === 0 ? (
                <tr>
                    <td colSpan={5} className="text-center py-12 text-slate-400">
                    <Building className="w-8 h-8 mx-auto mb-2 text-slate-300" />
                    <p className="font-medium text-slate-600">No clinics found matching criteria</p>
                    <p className="text-xs text-slate-400 mt-0.5">Try clearing search filters or create a new facility.</p>
                  </td>
                </tr>
              ) : (
                filteredClinics.map((clinic) => (
                  <tr
                    key={clinic.id}
                    id={`clinic-row-${clinic.id}`}
                    onClick={() => navigateTo('admin-clinic-detail', { clinicId: clinic.id })}
                    className="hover:bg-slate-50/80 cursor-pointer transition-colors group"
                  >
                    <td className="py-4 px-6">
                      <div className="flex items-center gap-3">
                        <div className="w-9 h-9 rounded-xl bg-[#E8F5E9] border border-[#C8E6C9] flex items-center justify-center text-[#2E7D32] font-bold shrink-0">
                          {clinic.name[0]}
                        </div>
                        <div className="overflow-hidden">
                          <p className="font-semibold text-slate-900 group-hover:text-[#2E7D32] transition-colors">
                            {clinic.name}
                          </p>
                          <p className="text-[11px] text-slate-400 truncate max-w-xs">{clinic.address}</p>
                        </div>
                      </div>
                    </td>
                    <td className="py-4 px-6">
                      <p className="text-slate-800 font-medium">{clinic.phone}</p>
                      <p className="text-[11px] text-slate-400">{clinic.email}</p>
                    </td>
                    <td className="py-4 px-6">
                      <StatusBadge variant={clinic.status}>
                        {clinic.status}
                      </StatusBadge>
                    </td>
                    <td className="py-4 px-6 text-slate-500 font-mono text-[11px]">
                      {new Date(clinic.created_at).toLocaleDateString('en-GB', {
                        day: 'numeric',
                        month: 'short',
                        year: 'numeric',
                      })}
                    </td>
                    <td className="py-4 px-6 text-right">
                      <div className="flex items-center justify-end gap-3">
                        <button
                          type="button"
                          onClick={(e) => {
                            e.stopPropagation();
                            if (clinic.status === 'active') {
                              deactivateClinic(clinic.id);
                            } else {
                              activateClinic(clinic.id);
                            }
                          }}
                          className={`px-3 py-1.5 rounded-lg text-[11px] font-semibold transition-colors cursor-pointer ${
                            clinic.status === 'active'
                              ? 'bg-rose-50 text-rose-600 hover:bg-rose-100'
                              : 'bg-emerald-50 text-emerald-600 hover:bg-emerald-100'
                          }`}
                        >
                          {clinic.status === 'active' ? 'Deactivate' : 'Activate'}
                        </button>
                        <span className="inline-flex items-center gap-1 text-xs font-semibold text-[#2E7D32] group-hover:text-[#1B5E20] group-hover:translate-x-0.5 transition-all">
                          View Details
                          <ChevronRight className="w-4 h-4" />
                        </span>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
        </>
      )}
    </div>
  );
}
