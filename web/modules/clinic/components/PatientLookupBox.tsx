'use client';

import React from 'react';
import Link from 'next/link';
import { Search, UserCheck, ShieldAlert, ArrowRight, Smartphone, AlertCircle } from 'lucide-react';
import { Button } from '@/modules/core/ui/Button';
import { usePatientLookup } from '../hooks/usePatientLookup';
import { calculateAge } from '@/modules/core/lib/utils';
import { useStore } from '@/lib/store';

export function PatientLookupBox() {
  const { query, setQuery, foundPatient, hasSearched, error, executeLookup } = usePatientLookup();
  const { activeClinic } = useStore();

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    executeLookup();
  };

  const hasActiveAccess = foundPatient?.active_grant_clinic_ids?.includes(activeClinic.id);

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <div>
        <h1 className="text-xl font-bold text-slate-900">Exact Patient Identifier Lookup</h1>
        <p className="text-xs text-slate-500">
          Strict privacy architecture: Zero wildcard browsing. Exact match by National ID, Patient ID, Phone, or Email.
        </p>
      </div>

      <div className="bg-white rounded-3xl border border-slate-200 shadow-xs p-6 space-y-4">
        <form onSubmit={handleSearch} className="flex gap-3">
          <div className="relative flex-1">
            <Search className="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
            <input
              id="patient-lookup-input"
              type="text"
              placeholder="Enter exact ID (e.g. PAT-001, +254711223344, sarah.njeri@citizen.ke)..."
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-2.5 text-xs bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C] text-slate-900 placeholder:text-slate-400"
              autoFocus
            />
          </div>
          <Button type="submit" size="md">
            Verify Patient
          </Button>
        </form>

        {error && (
          <p className="text-xs text-rose-600 font-medium flex items-center gap-1.5">
            <AlertCircle className="w-3.5 h-3.5" />
            {error}
          </p>
        )}

        <div className="flex flex-wrap items-center gap-2 pt-2 text-[11px] text-slate-500">
          <span className="font-semibold text-slate-700">Quick Test Records:</span>
          <button
            type="button"
            onClick={() => {
              setQuery('PAT-001');
              executeLookup('PAT-001');
            }}
            className="px-2 py-0.5 rounded-lg bg-slate-100 hover:bg-[#E8F5E9] hover:text-[#1B5E20] font-mono text-[10px] cursor-pointer"
          >
            PAT-001 (Sarah Njeri)
          </button>
          <button
            type="button"
            onClick={() => {
              setQuery('PAT-002');
              executeLookup('PAT-002');
            }}
            className="px-2 py-0.5 rounded-lg bg-slate-100 hover:bg-[#E8F5E9] hover:text-[#1B5E20] font-mono text-[10px] cursor-pointer"
          >
            PAT-002 (David Kiprop)
          </button>
          <button
            type="button"
            onClick={() => {
              setQuery('PAT-003');
              executeLookup('PAT-003');
            }}
            className="px-2 py-0.5 rounded-lg bg-slate-100 hover:bg-[#E8F5E9] hover:text-[#1B5E20] font-mono text-[10px] cursor-pointer"
          >
            PAT-003 (Amina Hassan)
          </button>
        </div>
      </div>

      {/* Result Display */}
      {hasSearched && foundPatient && (
        <div className="bg-white rounded-3xl border border-slate-200 shadow-xs p-6 space-y-6 animate-in fade-in">
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
                    {foundPatient.id}
                  </span>
                </div>
                <p className="text-xs text-slate-500">
                  {calculateAge(foundPatient.date_of_birth)} • {foundPatient.sex} • Blood Group: {foundPatient.blood_group}
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

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 p-4 rounded-2xl bg-slate-50 border border-slate-100 text-xs">
            <div>
              <p className="text-slate-400 text-[10px] uppercase font-semibold">Phone Number</p>
              <p className="font-semibold text-slate-800 mt-0.5">{foundPatient.phone}</p>
            </div>
            <div>
              <p className="text-slate-400 text-[10px] uppercase font-semibold">Email</p>
              <p className="font-semibold text-slate-800 mt-0.5">{foundPatient.email}</p>
            </div>
            <div>
              <p className="text-slate-400 text-[10px] uppercase font-semibold">Known Allergies</p>
              <p className="font-semibold text-rose-600 mt-0.5">
                {foundPatient.allergies?.length ? foundPatient.allergies.join(', ') : 'None Reported'}
              </p>
            </div>
          </div>

          <div className="flex items-center justify-end gap-3 pt-2">
            {hasActiveAccess ? (
              <Link href={`/doctor/patients/${foundPatient.id}`}>
                <Button leftIcon={<ArrowRight className="w-4 h-4" />}>
                  Open Clinical Longitudinal Chart
                </Button>
              </Link>
            ) : (
              <Link href={`/clinic/requests/new?patientId=${foundPatient.id}`}>
                <Button leftIcon={<Smartphone className="w-4 h-4" />}>
                  Request Patient 5-min Access Grant
                </Button>
              </Link>
            )}
          </div>
        </div>
      )}

      {hasSearched && !foundPatient && (
        <div className="bg-white rounded-3xl border border-slate-200 p-8 text-center space-y-2">
          <p className="text-sm font-bold text-slate-800">No Citizen Found with &ldquo;{query}&rdquo;</p>
          <p className="text-xs text-slate-500">
            Confirm the exact National ID, phone (+254...), or citizen email address.
          </p>
        </div>
      )}
    </div>
  );
}
