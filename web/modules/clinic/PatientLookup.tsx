'use client';

import React, { useState } from 'react';
import { useStore } from '@/lib/store';
import {
  Search,
  User,
  ShieldCheck,
  ArrowRight,
  AlertCircle,
  CheckCircle,
  HelpCircle,
  Send,
  Building2,
} from 'lucide-react';
import { Patient } from '@/types/database';

export function PatientLookup() {
  const { lookupPatientExact, navigateTo } = useStore();
  const [query, setQuery] = useState('');
  const [hasSearched, setHasSearched] = useState(false);
  const [matchedPatient, setMatchedPatient] = useState<Patient | null>(null);

  const handleSearch = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!query.trim()) return;

    setHasSearched(true);
    const result = await lookupPatientExact(query);
    setMatchedPatient(result);
  };

  const setSampleQuery = async (sample: string) => {
    setQuery(sample);
    setHasSearched(true);
    const result = await lookupPatientExact(sample);
    setMatchedPatient(result);
  };


  return (
    <div id="patient-lookup-page" className="p-6 md:p-8 max-w-4xl mx-auto space-y-6">
      {/* Header */}
      <div>
        <div className="flex items-center gap-2 text-xs font-semibold text-emerald-700 uppercase tracking-wider mb-1">
          <ShieldCheck className="w-4 h-4" />
          <span>Patient Consent Verification Flow</span>
        </div>
        <h1 className="text-2xl font-bold tracking-tight text-slate-900">
          Exact Patient Lookup
        </h1>
        <p className="text-xs text-slate-500 mt-1">
          Privacy-guaranteed lookup requiring exact match by Patient Email or Phone provided in person.
        </p>
      </div>

      {/* Lookup Card */}
      <div className="bg-white rounded-2xl border border-slate-200/80 shadow-xs overflow-hidden">
        <div className="p-6 border-b border-slate-100 bg-slate-50/50">
          <div className="flex items-center gap-2 text-xs font-bold text-slate-900">
            <Search className="w-4 h-4 text-emerald-600" />
            <span>Search Single Patient Identifier</span>
          </div>
          <p className="text-xs text-slate-500 mt-0.5">
            To prevent directory harvesting, Afya disables autocomplete and partial search.
          </p>
        </div>

        <div className="p-6 md:p-8 space-y-6">
          <form onSubmit={handleSearch} className="space-y-4">
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">
                Patient Email or Phone Number (Exact Match)
              </label>
              <div className="flex gap-2">
                <div className="relative flex-1">
                  <User className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    id="input-patient-lookup-query"
                    type="text"
                    required
                    value={query}
                    onChange={(e) => setQuery(e.target.value)}
                    placeholder="e.g. sarah.kamau@gmail.com or +254 712 345 678"
                    className="w-full pl-10 pr-4 py-2.5 text-xs bg-white border border-slate-200 rounded-xl text-slate-900 focus:outline-none focus:ring-2 focus:ring-emerald-500/20 focus:border-emerald-500 shadow-2xs"
                  />
                </div>
                <button
                  id="search-patient-exact-btn"
                  type="submit"
                  className="px-5 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs rounded-xl shadow-xs transition-colors cursor-pointer shrink-0"
                >
                  Verify Patient
                </button>
              </div>
            </div>

            {/* Exact Identifier Quick Chips for effortless testing */}
            <div className="flex flex-wrap items-center gap-2 pt-1 text-xs">
              <span className="text-slate-400 text-[11px]">Quick test demo patients:</span>
              <button
                type="button"
                onClick={() => setSampleQuery('sarah.kamau@gmail.com')}
                className="px-2.5 py-1 rounded-lg bg-slate-100 hover:bg-emerald-50 text-slate-700 hover:text-emerald-800 text-[11px] font-mono border border-slate-200 cursor-pointer"
              >
                sarah.kamau@gmail.com
              </button>
              <button
                type="button"
                onClick={() => setSampleQuery('achieng.otieno@gmail.com')}
                className="px-2.5 py-1 rounded-lg bg-slate-100 hover:bg-emerald-50 text-slate-700 hover:text-emerald-800 text-[11px] font-mono border border-slate-200 cursor-pointer"
              >
                achieng.otieno@gmail.com
              </button>
              <button
                type="button"
                onClick={() => setSampleQuery('michael.mburu@gmail.com')}
                className="px-2.5 py-1 rounded-lg bg-slate-100 hover:bg-emerald-50 text-slate-700 hover:text-emerald-800 text-[11px] font-mono border border-slate-200 cursor-pointer"
              >
                michael.mburu@gmail.com
              </button>
            </div>
          </form>

          {/* Results State */}
          {hasSearched && (
            <div className="pt-4 border-t border-slate-100">
              {matchedPatient ? (
                /* Patient Found Single Card */
                <div
                  id="patient-match-card"
                  className="p-5 rounded-2xl bg-emerald-50/50 border border-emerald-200/80 space-y-4 animate-in fade-in duration-200"
                >
                  <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                    <div className="flex items-center gap-3.5">
                      <div className="w-12 h-12 rounded-2xl bg-emerald-600 text-white font-bold text-lg flex items-center justify-center shadow-xs">
                        {matchedPatient.first_name[0]}
                        {matchedPatient.last_name[0]}
                      </div>
                      <div>
                        <div className="flex items-center gap-2">
                          <h3 className="text-base font-bold text-slate-900">
                            {matchedPatient.first_name} {matchedPatient.last_name}
                          </h3>
                          <span className="px-2 py-0.5 rounded-full text-[10px] font-bold bg-emerald-100 text-emerald-800 border border-emerald-200">
                            Verified Patient
                          </span>
                        </div>
                        <p className="text-xs text-slate-600 mt-0.5">
                          {matchedPatient.email} • {matchedPatient.phone}
                        </p>
                      </div>
                    </div>

                    <button
                      id="proceed-to-request-btn"
                      type="button"
                      onClick={() =>
                        navigateTo('clinic-new-request', { patientId: matchedPatient.id })
                      }
                      className="inline-flex items-center justify-center gap-2 px-5 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold rounded-xl shadow-xs transition-all cursor-pointer"
                    >
                      <Send className="w-4 h-4" />
                      <span>Proceed to Request Access →</span>
                    </button>
                  </div>

                  <div className="p-3 bg-white/80 rounded-xl border border-emerald-100 text-xs text-slate-600 flex items-start gap-2">
                    <CheckCircle className="w-4 h-4 text-emerald-600 shrink-0 mt-0.5" />
                    <span>
                      Identity verified. Proceeding will open the formal request form to specify the clinical reason and submitting physician before triggering the 5-minute patient consent countdown.
                    </span>
                  </div>
                </div>
              ) : (
                /* No Patient Found State */
                <div
                  id="no-patient-found-card"
                  className="p-6 text-center rounded-2xl bg-slate-50 border border-slate-200/80 space-y-2 animate-in fade-in duration-200"
                >
                  <AlertCircle className="w-8 h-8 text-slate-400 mx-auto" />
                  <h4 className="text-sm font-bold text-slate-800">No Patient Found</h4>
                  <p className="text-xs text-slate-500 max-w-md mx-auto">
                    No registered patient record matched the exact query <strong>&ldquo;{query}&rdquo;</strong>. Please verify the exact phone number or email address provided by the patient.
                  </p>
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
