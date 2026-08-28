'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { Building2, Search, ArrowRight, ShieldCheck } from 'lucide-react';
import { useStore } from '@/lib/store';
import { StatusBadge } from '@/modules/core/ui/StatusBadge';
import { Button } from '@/modules/core/ui/Button';

export function ClinicsTable() {
  const { clinics } = useStore();
  const [search, setSearch] = useState('');
  const [filterStatus, setFilterStatus] = useState<'all' | 'active' | 'deactivated'>('all');

  const filteredClinics = clinics.filter((c) => {
    const matchesSearch =
      c.name.toLowerCase().includes(search.toLowerCase()) ||
      c.email.toLowerCase().includes(search.toLowerCase()) ||
      c.address.toLowerCase().includes(search.toLowerCase());
    const matchesStatus = filterStatus === 'all' || c.status === filterStatus;
    return matchesSearch && matchesStatus;
  });

  return (
    <div className="bg-white rounded-3xl border border-slate-200 shadow-xs overflow-hidden">
      <div className="p-6 border-b border-slate-100 flex flex-wrap items-center justify-between gap-4">
        <div>
          <h2 className="text-base font-bold text-slate-900">National Healthcare Facility Directory</h2>
          <p className="text-xs text-slate-500">MOH Accredited Tier 2-4 primary healthcare centers</p>
        </div>

        <div className="flex items-center gap-3">
          <div className="relative">
            <Search className="w-3.5 h-3.5 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input
              id="admin-search-clinics"
              type="text"
              placeholder="Search clinic name, email..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="pl-8 pr-3 py-1.5 text-xs bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-1 focus:ring-[#388E3C] w-56"
            />
          </div>

          <select
            id="admin-filter-status"
            value={filterStatus}
            onChange={(e: React.ChangeEvent<HTMLSelectElement>) => setFilterStatus(e.target.value as 'all' | 'active' | 'deactivated')}
            className="px-3 py-1.5 text-xs bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-1 focus:ring-[#388E3C] text-slate-700"
          >
            <option value="all">All Status</option>
            <option value="active">Active Only</option>
            <option value="deactivated">Deactivated</option>
          </select>

          <Link href="/admin/clinics/new">
            <Button size="sm" leftIcon={<Building2 className="w-3.5 h-3.5" />}>
              + Onboard Clinic
            </Button>
          </Link>
        </div>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full text-left text-xs border-collapse">
          <thead>
            <tr className="border-b border-slate-100 bg-slate-50/75 text-slate-500 font-semibold uppercase tracking-wider text-[11px]">
              <th className="py-3 px-6">Clinic Facility</th>
              <th className="py-3 px-6">Location / Address</th>
              <th className="py-3 px-6">Facility Admin</th>
              <th className="py-3 px-6">Doctors</th>
              <th className="py-3 px-6">Status</th>
              <th className="py-3 px-6 text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 font-medium text-slate-700">
            {filteredClinics.map((clinic) => (
              <tr key={clinic.id} className="hover:bg-slate-50/60 transition-colors">
                <td className="py-4 px-6">
                  <div className="flex items-center gap-3">
                    <div className="w-9 h-9 rounded-xl bg-[#E8F5E9] text-[#2E7D32] flex items-center justify-center font-bold text-xs shrink-0 border border-[#C8E6C9]">
                      <Building2 className="w-4 h-4" />
                    </div>
                    <div>
                      <p className="font-bold text-slate-900">{clinic.name}</p>
                      <p className="text-[11px] text-slate-400">{clinic.email}</p>
                    </div>
                  </div>
                </td>
                <td className="py-4 px-6 text-slate-600">{clinic.address}</td>
                <td className="py-4 px-6">
                  <p className="font-semibold text-slate-800">{clinic.admin_name}</p>
                  <p className="text-[11px] text-slate-400">{clinic.admin_email}</p>
                </td>
                <td className="py-4 px-6">
                  <span className="font-semibold text-slate-900">{clinic.total_doctors}</span> doctors
                </td>
                <td className="py-4 px-6">
                  <StatusBadge status={clinic.status} />
                </td>
                <td className="py-4 px-6 text-right">
                  <Link
                    href={`/admin/clinics/${clinic.id}`}
                    className="inline-flex items-center gap-1 font-semibold text-[#2E7D32] hover:text-[#1B5E20] text-xs"
                  >
                    Manage Facility <ArrowRight className="w-3.5 h-3.5" />
                  </Link>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
