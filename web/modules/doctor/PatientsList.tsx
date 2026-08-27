'use client';

import React, { useState } from 'react';
import { useStore } from '@/lib/store';
import { StatusBadge } from '@/components/ui/Badge';
import {
  FolderOpen,
  Search,
  PlusCircle,
  ChevronRight,
  ShieldCheck,
  User,
  HeartPulse,
  Calendar,
  AlertTriangle,
} from 'lucide-react';

export function PatientsList() {
  const { currentUser, clinics, patients, navigateTo } = useStore();
  const [searchTerm, setSearchTerm] = useState('');

  const activeClinic = clinics.find((c) => c.id === currentUser.clinic_id) || clinics[0];

  // Scoped strictly to patients whose clinic has active approved access
  const authorizedPatients = patients.filter((p) =>
    p.active_grant_clinic_ids.includes(activeClinic.id)
  );

  const filtered = authorizedPatients.filter((p) =>
    `${p.first_name} ${p.last_name}`.toLowerCase().includes(searchTerm.toLowerCase()) ||
    p.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
    p.phone.includes(searchTerm) ||
    p.blood_group.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div id="doctor-patients-list-page" className="p-6 md:p-8 space-y-8 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 text-xs font-semibold text-emerald-700 uppercase tracking-wider mb-1">
            <FolderOpen className="w-4 h-4" />
            <span>Clinical Medical Records</span>
          </div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">
            Active Patient Chart Directory
          </h1>
          <p className="text-xs text-slate-500 mt-1">
            Verified patient medical charts with active cryptographic consent grants.
          </p>
        </div>

        <button
          id="patients-list-start-encounter-btn"
          type="button"
          onClick={() => navigateTo('doctor-start-encounter')}
          className="inline-flex items-center gap-2 px-5 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold shadow-xs transition-all cursor-pointer"
        >
          <PlusCircle className="w-4 h-4" />
          <span>+ Start Encounter</span>
        </button>
      </div>

      {/* Directory Table Card */}
      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
        <div className="p-5 border-b border-slate-100 flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-slate-50/40">
          <div>
            <h3 className="text-sm font-bold text-slate-900">Patient Directory ({authorizedPatients.length})</h3>
            <p className="text-xs text-slate-500">
              Select any patient record to review their longitudinal clinical history and past encounters.
            </p>
          </div>

          <div className="relative min-w-[260px]">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              id="search-doctor-patients-input"
              type="text"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              placeholder="Search by name, phone, blood group..."
              className="w-full pl-9 pr-3 py-1.5 bg-white border border-slate-200 rounded-xl text-xs text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500"
            />
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-slate-600">
            <thead className="bg-slate-50 border-b border-slate-200/80 text-[11px] font-semibold text-slate-500 uppercase tracking-wider">
              <tr>
                <th className="py-3.5 px-5">Patient Name & Demographics</th>
                <th className="py-3.5 px-5">Contact Details</th>
                <th className="py-3.5 px-5">Blood & Allergies</th>
                <th className="py-3.5 px-5">Last Encounter</th>
                <th className="py-3.5 px-5 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={5} className="text-center py-10 text-slate-400">
                    <User className="w-8 h-8 mx-auto mb-2 text-slate-300" />
                    <p className="font-medium text-slate-600">No matching patient charts</p>
                  </td>
                </tr>
              ) : (
                filtered.map((pat) => (
                  <tr
                    key={pat.id}
                    id={`doctor-patient-row-${pat.id}`}
                    onClick={() => navigateTo('doctor-patient-history', { patientId: pat.id })}
                    className="hover:bg-slate-50/80 cursor-pointer transition-colors group"
                  >
                    <td className="py-4 px-5">
                      <div className="flex items-center gap-3">
                        <div className="w-9 h-9 rounded-full bg-emerald-100 text-emerald-800 font-bold flex items-center justify-center shrink-0">
                          {pat.first_name[0]}
                          {pat.last_name[0]}
                        </div>
                        <div>
                          <p className="font-bold text-slate-900 group-hover:text-emerald-700 transition-colors">
                            {pat.first_name} {pat.last_name}
                          </p>
                          <p className="text-[11px] text-slate-400">
                            Age: 32 yrs • DOB: {pat.date_of_birth} ({pat.sex})
                          </p>
                        </div>
                      </div>
                    </td>
                    <td className="py-4 px-5">
                      <p className="font-medium text-slate-800">{pat.phone}</p>
                      <p className="text-[11px] text-slate-400">{pat.email}</p>
                    </td>
                    <td className="py-4 px-5">
                      <div className="space-y-1">
                        <span className="font-bold text-slate-800 text-xs block">Blood: {pat.blood_group}</span>
                        {pat.allergies && pat.allergies.length > 0 && (
                          <div className="flex flex-wrap gap-1">
                            {pat.allergies.map((alg, i) => (
                              <span
                                key={i}
                                className="text-[10px] px-1.5 py-0.2 rounded bg-rose-50 text-rose-700 border border-rose-200"
                              >
                                {alg}
                              </span>
                            ))}
                          </div>
                        )}
                      </div>
                    </td>
                    <td className="py-4 px-5 font-mono text-[11px] text-slate-500">
                      {pat.last_encounter_date ? (
                        new Date(pat.last_encounter_date).toLocaleDateString('en-GB', {
                          day: 'numeric',
                          month: 'short',
                          year: 'numeric',
                        })
                      ) : (
                        <span className="text-slate-400 italic">No previous visits</span>
                      )}
                    </td>
                    <td className="py-4 px-5 text-right">
                      <div className="flex items-center justify-end gap-2">
                        <span className="inline-flex items-center gap-1 text-xs font-semibold text-emerald-700 group-hover:text-emerald-800 transition-colors">
                          View Chart
                          <ChevronRight className="w-4 h-4" />
                        </span>
                        <button
                          type="button"
                          onClick={(e) => {
                            e.stopPropagation();
                            navigateTo('doctor-start-encounter', { preselectedPatientId: pat.id });
                          }}
                          className="px-2.5 py-1 bg-emerald-600 text-white rounded-lg text-xs font-semibold hover:bg-emerald-700 transition-colors shadow-2xs"
                        >
                          + Encounter
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
