'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { Search, Users, ArrowRight, ShieldCheck, UserCheck, PlusCircle } from 'lucide-react';
import { useStore } from '@/lib/store';
import { Button } from '@/modules/core/ui/Button';
import { calculateAge } from '@/modules/core/lib/utils';

export default function DoctorPatientsPage() {
  const { patients, activeClinic } = useStore();
  const [search, setSearch] = useState('');

  const filteredPatients = patients.filter((p) => {
    const match =
      p.first_name.toLowerCase().includes(search.toLowerCase()) ||
      p.last_name.toLowerCase().includes(search.toLowerCase()) ||
      p.id.toLowerCase().includes(search.toLowerCase()) ||
      p.phone.includes(search);
    return match;
  });

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold text-slate-900">Patient Directory & Clinical Registry</h1>
          <p className="text-xs text-slate-500">
            Access longitudinal health histories, laboratory results, and previous encounter trajectories
          </p>
        </div>

        <div className="flex items-center gap-3">
          <div className="relative">
            <Search className="w-3.5 h-3.5 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input
              type="text"
              placeholder="Search patient name, ID, phone..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="pl-8 pr-3 py-1.5 text-xs bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-1 focus:ring-[#388E3C] w-64"
            />
          </div>

          <Link href="/clinic/lookup">
            <Button size="sm" variant="outline">
              Exact Citizen Lookup
            </Button>
          </Link>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {filteredPatients.map((patient) => {
          const hasActiveGrant = patient.active_grant_clinic_ids?.includes(activeClinic.id);

          return (
            <div
              key={patient.id}
              className="bg-white rounded-3xl border border-slate-200 p-6 space-y-4 hover:border-[#A5D6A7] hover:shadow-xs transition-all flex flex-col justify-between"
            >
              <div className="space-y-3">
                <div className="flex items-start justify-between gap-2">
                  <div className="flex items-center gap-3">
                    <div className="w-11 h-11 rounded-2xl bg-[#E8F5E9] text-[#2E7D32] border border-[#C8E6C9] flex items-center justify-center font-bold text-sm">
                      {patient.first_name[0]}
                      {patient.last_name[0]}
                    </div>
                    <div>
                      <h3 className="font-bold text-slate-900 text-sm">
                        {patient.first_name} {patient.last_name}
                      </h3>
                      <p className="text-[11px] font-mono text-slate-400">{patient.id}</p>
                    </div>
                  </div>

                  {hasActiveGrant ? (
                    <span className="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-[#E8F5E9] text-[#1B5E20] border border-[#C8E6C9]">
                      Grant Active
                    </span>
                  ) : (
                    <span className="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-slate-100 text-slate-600">
                      Standard
                    </span>
                  )}
                </div>

                <div className="space-y-1 text-xs text-slate-600">
                  <p>
                    Age: <strong>{calculateAge(patient.date_of_birth)}</strong> • Sex: <strong>{patient.sex}</strong>
                  </p>
                  <p>Blood Group: <strong>{patient.blood_group}</strong></p>
                  <p className="text-slate-400">{patient.phone}</p>
                </div>
              </div>

              <div className="pt-3 border-t border-slate-100 flex items-center justify-between">
                <Link
                  href={`/doctor/patients/${patient.id}`}
                  className="inline-flex items-center gap-1 font-semibold text-xs text-[#2E7D32] hover:text-[#1B5E20]"
                >
                  Open Chart <ArrowRight className="w-3.5 h-3.5" />
                </Link>

                <Link href={`/doctor/encounters/new?patientId=${patient.id}`}>
                  <Button size="sm" variant="ghost" className="text-xs">
                    + Start Encounter
                  </Button>
                </Link>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
