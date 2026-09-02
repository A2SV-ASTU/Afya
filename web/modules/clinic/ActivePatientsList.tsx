'use client';

import React, { useState } from 'react';
import { useStore } from '@/lib/store';
import { StatusBadge } from '@/components/ui/Badge';
import { Modal } from '@/components/ui/Modal';
import {
  UserCheck,
  Search,
  Lock,
  ShieldCheck,
  Info,
  Stethoscope,
  Building2,
  Calendar,
  AlertTriangle,
} from 'lucide-react';
import { Patient } from '@/types/database';

export function ActivePatientsList() {
  const { currentUser, patients, accessRequests, navigateTo } = useStore();
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedPatientInfo, setSelectedPatientInfo] = useState<Patient | null>(null);

  // Filter patients with active grants for this clinic
  const activeGrantedPatients = patients.filter((p) =>
    p.active_grant_clinic_ids.includes(currentUser?.clinic_id || '')
  );

  const filteredPatients = activeGrantedPatients.filter((p) =>
    `${p.first_name} ${p.last_name}`.toLowerCase().includes(searchTerm.toLowerCase()) ||
    p.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
    p.phone.includes(searchTerm)
  );

  return (
    <div id="active-patients-page" className="p-6 md:p-8 space-y-8 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 text-xs font-semibold text-emerald-700 uppercase tracking-wider mb-1">
            <UserCheck className="w-4 h-4" />
            <span>Facility Consents</span>
          </div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">
            Patients (Active Access)
          </h1>
          <p className="text-xs text-slate-500 mt-1">
            Patients who have approved institutional data-sharing requests.
          </p>
        </div>

        <button
          id="active-patients-lookup-btn"
          type="button"
          onClick={() => navigateTo('clinic-lookup')}
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-semibold shadow-xs transition-colors cursor-pointer"
        >
          <span>Lookup New Patient</span>
        </button>
      </div>

      {/* Institutional Privacy Guard Banner */}
      <div className="p-4 bg-slate-900 text-slate-300 rounded-2xl border border-slate-800 flex items-start gap-3">
        <Lock className="w-5 h-5 text-emerald-400 shrink-0 mt-0.5" />
        <div className="text-xs space-y-1">
          <p className="font-semibold text-white">Institutional Access Restriction (Doctor-Only Charts)</p>
          <p className="text-slate-400 leading-relaxed">
            {/*
              CLINICAL GUARD / CODE COMMENT:
              Clinic's Patients (Active Access) list intentionally DOES NOT link into patient charts.
              Only the Doctor role holds authorization to open longitudinal history and clinical encounters.
            */}
            As mandated by the AfyaMind Security Model, Facility Administrators do not hold clinical record view permissions. Only licensed Attending Physicians logged under the Doctor role can open longitudinal timelines and encounter records.
          </p>
        </div>
      </div>

      {/* Table Card */}
      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
        <div className="p-5 border-b border-slate-100 flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-slate-50/40">
          <div>
            <h3 className="text-sm font-bold text-slate-900">Authorized Patient Consents</h3>
            <p className="text-xs text-slate-500">
              Approved grants allowing facility doctors to start clinical visits.
            </p>
          </div>

          <div className="relative min-w-[240px]">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              id="search-active-patients-input"
              type="text"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              placeholder="Filter authorized patients..."
              className="w-full pl-9 pr-3 py-1.5 bg-white border border-slate-200 rounded-xl text-xs text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500"
            />
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-slate-600">
            <thead className="bg-slate-50 border-b border-slate-200/80 text-[11px] font-semibold text-slate-500 uppercase tracking-wider">
              <tr>
                <th className="py-3.5 px-5">Patient Name</th>
                <th className="py-3.5 px-5">Identifier / Contact</th>
                <th className="py-3.5 px-5">Consent Status</th>
                <th className="py-3.5 px-5">Original Requesting Physician</th>
                <th className="py-3.5 px-5 text-right">Access Permission</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredPatients.length === 0 ? (
                <tr>
                  <td colSpan={5} className="text-center py-10 text-slate-400">
                    <UserCheck className="w-8 h-8 mx-auto mb-2 text-slate-300" />
                    <p className="font-medium text-slate-600">No active patient grants found</p>
                    <p className="text-xs text-slate-400 mt-0.5">
                      Send a patient lookup request to obtain electronic consent.
                    </p>
                  </td>
                </tr>
              ) : (
                filteredPatients.map((patient) => {
                  const matchingReq = accessRequests.find(
                    (r) => r.patient_id === patient.id && r.status === 'approved'
                  );

                  return (
                    <tr
                      key={patient.id}
                      id={`active-patient-row-${patient.id}`}
                      onClick={() => setSelectedPatientInfo(patient)}
                      className="hover:bg-slate-50/80 cursor-pointer transition-colors"
                    >
                      <td className="py-4 px-5">
                        <div className="flex items-center gap-3">
                          <div className="w-8 h-8 rounded-full bg-emerald-100 text-emerald-800 font-bold flex items-center justify-center shrink-0">
                            {patient.first_name[0]}
                          </div>
                          <div>
                            <p className="font-bold text-slate-900">
                              {patient.first_name} {patient.last_name}
                            </p>
                            <p className="text-[11px] text-slate-400">
                              DOB: {patient.date_of_birth} ({patient.sex})
                            </p>
                          </div>
                        </div>
                      </td>
                      <td className="py-4 px-5">
                        <p className="text-slate-800 font-medium">{patient.phone}</p>
                        <p className="text-[11px] text-slate-400">{patient.email}</p>
                      </td>
                      <td className="py-4 px-5">
                        <StatusBadge variant="approved">AUTHENTICATED</StatusBadge>
                      </td>
                      <td className="py-4 px-5">
                        <p className="font-medium text-slate-800">
                          {matchingReq?.submitted_by_doctor_name || 'Dr. Angela Mwangi'}
                        </p>
                        <p className="text-[11px] text-slate-400">
                          Granted: {matchingReq ? new Date(matchingReq.created_at).toLocaleDateString() : 'Active'}
                        </p>
                      </td>
                      <td className="py-4 px-5 text-right">
                        <button
                          type="button"
                          onClick={(e) => {
                            e.stopPropagation();
                            setSelectedPatientInfo(patient);
                          }}
                          className="inline-flex items-center gap-1.5 px-3 py-1 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-lg text-xs font-semibold transition-colors cursor-pointer"
                        >
                          <Info className="w-3.5 h-3.5 text-slate-500" />
                          <span>Consent Info</span>
                        </button>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Informational Modal Explaining Clinic Role Chart Barrier */}
      {selectedPatientInfo && (
        <Modal
          isOpen={Boolean(selectedPatientInfo)}
          onClose={() => setSelectedPatientInfo(null)}
          title={`Patient Consent Profile: ${selectedPatientInfo.first_name} ${selectedPatientInfo.last_name}`}
          subtitle="Institutional grant record under Kenya Data Protection Act compliance"
          maxWidth="md"
        >
          <div className="space-y-4">
            <div className="p-4 rounded-xl bg-slate-50 border border-slate-200 text-xs space-y-2">
              <div className="flex justify-between border-b border-slate-200 pb-2">
                <span className="text-slate-500">Patient Identifier:</span>
                <span className="font-bold text-slate-900">{selectedPatientInfo.email}</span>
              </div>
              <div className="flex justify-between border-b border-slate-200 pb-2">
                <span className="text-slate-500">Telephone:</span>
                <span className="font-bold text-slate-900">{selectedPatientInfo.phone}</span>
              </div>
              <div className="flex justify-between border-b border-slate-200 pb-2">
                <span className="text-slate-500">Consent Status:</span>
                <span className="font-bold text-emerald-700">APPROVED & ACTIVE</span>
              </div>
              <div className="flex justify-between">
                <span className="text-slate-500">Permitted Clinical Actors:</span>
                <span className="font-bold text-slate-900">All Licensed Clinic Doctors</span>
              </div>
            </div>

            <div className="p-3.5 bg-amber-50 border border-amber-200 rounded-xl text-xs text-amber-900 flex items-start gap-2.5">
              <Lock className="w-4 h-4 text-amber-700 shrink-0 mt-0.5" />
              <div>
                <p className="font-bold">Clinical Chart Access Restriction</p>
                <p className="text-[11px] text-amber-800 mt-0.5">
                  Notice: As a Clinic Administrator, you have institutional consent verification but cannot directly view or write medical evaluations, vitals, lab results, diagnoses, or prescriptions. Switch to the <strong>Doctor</strong> role to access this patient&apos;s longitudinal clinical chart.
                </p>
              </div>
            </div>

            <div className="flex items-center justify-end gap-2 pt-2">
              <button
                type="button"
                onClick={() => setSelectedPatientInfo(null)}
                className="px-4 py-2 bg-slate-900 text-white rounded-xl text-xs font-semibold cursor-pointer"
              >
                Close
              </button>
            </div>
          </div>
        </Modal>
      )}
    </div>
  );
}
