'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { Building2, Search, ArrowRight, RefreshCw, AlertCircle } from 'lucide-react';
import { clinicsApi } from '@/lib/api/clinics';
import { getApiErrorMessage } from '@/lib/api/client';
import { StatusBadge } from '@/modules/core/ui/StatusBadge';
import { Button } from '@/modules/core/ui/Button';
import { Clinic } from '@/types/database';

export function ClinicsTable() {
  const [liveClinics, setLiveClinics] = useState<Clinic[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const [filterStatus, setFilterStatus] = useState<'all' | 'active' | 'deactivated'>('all');

  const fetchClinics = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const res = await clinicsApi.list();
      setLiveClinics(res.clinics || []);
    } catch (err: unknown) {
      setError(getApiErrorMessage(err, 'Failed to fetch registered clinics from backend.'));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchClinics();
  }, []);

  const filteredClinics = liveClinics.filter((c) => {
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
          <p className="text-xs text-slate-500">MOH Accredited primary and secondary healthcare centers</p>
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

          <button
            type="button"
            onClick={fetchClinics}
            disabled={isLoading}
            className="p-2 rounded-xl text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition-colors cursor-pointer"
            title="Refresh clinics list"
          >
            <RefreshCw className={`w-4 h-4 ${isLoading ? 'animate-spin text-emerald-600' : ''}`} />
          </button>

          <Link href="/admin/clinics/new">
            <Button size="sm" leftIcon={<Building2 className="w-3.5 h-3.5" />}>
              + Onboard Clinic
            </Button>
          </Link>
        </div>
      </div>

      {error && (
        <div className="p-4 m-6 rounded-2xl bg-rose-50 border border-rose-200 text-xs text-rose-700 font-medium flex items-center justify-between gap-3">
          <div className="flex items-center gap-2">
            <AlertCircle className="w-4 h-4 text-rose-600 shrink-0" />
            <span>{error}</span>
          </div>
          <Button size="sm" variant="outline" onClick={fetchClinics}>
            Retry
          </Button>
        </div>
      )}

      {isLoading && liveClinics.length === 0 ? (
        <div className="p-12 text-center">
          <div className="w-8 h-8 border-3 border-emerald-600 border-t-transparent rounded-full animate-spin mx-auto mb-3" />
          <p className="text-xs text-slate-500">Loading accredited healthcare facilities...</p>
        </div>
      ) : filteredClinics.length === 0 ? (
        <div className="p-12 text-center space-y-3">
          <div className="w-12 h-12 rounded-2xl bg-slate-50 text-slate-400 flex items-center justify-center mx-auto">
            <Building2 className="w-6 h-6" />
          </div>
          <div className="space-y-1">
            <h3 className="text-sm font-bold text-slate-800">No Facilities Found</h3>
            <p className="text-xs text-slate-500 max-w-sm mx-auto">
              {search || filterStatus !== 'all'
                ? 'No clinics matched your filter criteria.'
                : 'No healthcare facilities have been onboarded to the network yet.'}
            </p>
          </div>
          {!search && filterStatus === 'all' && (
            <Link href="/admin/clinics/new">
              <Button size="sm" className="mt-2">
                + Onboard First Clinic
              </Button>
            </Link>
          )}
        </div>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs border-collapse">
            <thead>
              <tr className="border-b border-slate-100 bg-slate-50/75 text-slate-500 font-semibold uppercase tracking-wider text-[11px]">
                <th className="py-3 px-6">Clinic Facility</th>
                <th className="py-3 px-6">Location / Address</th>
                <th className="py-3 px-6">Facility Admin</th>
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
                  <td className="py-4 px-6 text-slate-600">{clinic.address || 'Address unrecorded'}</td>
                  <td className="py-4 px-6">
                    <p className="font-semibold text-slate-800">{clinic.admin_name || 'Designated Admin'}</p>
                    <p className="text-[11px] text-slate-400">{clinic.admin_email || clinic.email}</p>
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
      )}
    </div>
  );
}
