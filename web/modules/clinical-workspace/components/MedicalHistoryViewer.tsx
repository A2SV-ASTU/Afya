'use client';

import React, { useCallback, useEffect, useState } from 'react';
import { History, Activity, Pill, Stethoscope, FileText, AlertCircle, Loader2 } from 'lucide-react';
import { MedicalHistoryResponse } from '@/types/database';
import { encountersApi } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api/client';
import { formatDateTime } from '@/modules/core/lib/utils';

interface MedicalHistoryViewerProps {
  encounterId: string;
  patientName: string;
}

export function MedicalHistoryViewer({ encounterId, patientName }: MedicalHistoryViewerProps) {
  const [history, setHistory] = useState<MedicalHistoryResponse | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadHistory = useCallback(async () => {
    setIsLoading(true);
    setError(null);
    try {
      const res = await encountersApi.getMedicalHistory(encounterId);
      setHistory(res);
    } catch (err) {
      setError(getApiErrorMessage(err, 'Failed to retrieve encounter medical history vantage point.'));
    } finally {
      setIsLoading(false);
    }
  }, [encounterId]);

  useEffect(() => {
    loadHistory();
  }, [loadHistory]);

  if (isLoading) {
    return (
      <div className="bg-white rounded-3xl border border-slate-200 p-12 flex items-center justify-center gap-2 text-xs text-slate-500 shadow-2xs">
        <Loader2 className="w-4 h-4 animate-spin text-[#2E7D32]" />
        Retrieving patient clinical history vantage point…
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-4 rounded-2xl bg-rose-50 border border-rose-200 text-xs text-rose-700 flex items-start gap-2.5">
        <AlertCircle className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
        <div>
          <p className="font-bold">Medical History Unavailable</p>
          <p className="mt-0.5">{error}</p>
        </div>
      </div>
    );
  }

  if (!history) {
    return (
      <div className="bg-white rounded-3xl border border-slate-200 p-8 text-center text-xs text-slate-400">
        No past clinical history recorded for this encounter.
      </div>
    );
  }

  return (
    <div className="bg-white rounded-3xl border border-slate-200 p-6 space-y-6 shadow-2xs">
      <div className="flex items-center justify-between border-b border-slate-100 pb-4">
        <div>
          <h3 className="text-base font-bold text-slate-900 flex items-center gap-2">
            <History className="w-5 h-5 text-[#2E7D32]" />
            Patient Medical History Vantage Point
          </h3>
          <p className="text-xs text-slate-500">
            Longitudinal clinical profile and recorded timeline for {patientName}
          </p>
        </div>
        <span className="text-xs font-mono text-slate-500 bg-slate-50 px-2.5 py-1 rounded-lg border border-slate-200">
          Recorded: {formatDateTime(history.date)}
        </span>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 text-xs">
        {/* Chief Complaint & Diagnosis */}
        <div className="space-y-4">
          <div className="p-4 rounded-2xl bg-slate-50 border border-slate-100 space-y-2">
            <div className="flex items-center gap-2 font-bold text-slate-900">
              <FileText className="w-4 h-4 text-[#2E7D32]" />
              <span>Presenting Chief Complaint</span>
            </div>
            <p className="text-slate-700 leading-relaxed">
              {history.chief_complaint || 'No presenting complaint documented for this session.'}
            </p>
          </div>

          <div className="p-4 rounded-2xl bg-emerald-50/50 border border-emerald-100 space-y-2">
            <div className="flex items-center gap-2 font-bold text-emerald-950">
              <Stethoscope className="w-4 h-4 text-emerald-600" />
              <span>Primary Diagnosis</span>
            </div>
            <p className="text-emerald-900 font-semibold">
              {history.diagnosis || 'Provisional evaluation in progress / none finalized'}
            </p>
          </div>
        </div>

        {/* Vitals Summary */}
        <div className="p-4 rounded-2xl bg-slate-50 border border-slate-100 space-y-3">
          <div className="flex items-center gap-2 font-bold text-slate-900">
            <Activity className="w-4 h-4 text-[#2E7D32]" />
            <span>Physiological Vitals Baseline</span>
          </div>

          {history.vitals ? (
            <div className="grid grid-cols-2 gap-2.5 pt-1">
              {history.vitals.systolic !== undefined && history.vitals.diastolic !== undefined && (
                <div className="p-2.5 bg-white rounded-xl border border-slate-100">
                  <p className="text-[10px] text-slate-400">Blood Pressure</p>
                  <p className="font-bold text-slate-800">
                    {history.vitals.systolic}/{history.vitals.diastolic} <span className="text-[10px] font-normal text-slate-500">mmHg</span>
                  </p>
                </div>
              )}
              {history.vitals.pulse !== undefined && (
                <div className="p-2.5 bg-white rounded-xl border border-slate-100">
                  <p className="text-[10px] text-slate-400">Heart Rate / Pulse</p>
                  <p className="font-bold text-slate-800">
                    {history.vitals.pulse} <span className="text-[10px] font-normal text-slate-500">bpm</span>
                  </p>
                </div>
              )}
              {history.vitals.temperature !== undefined && (
                <div className="p-2.5 bg-white rounded-xl border border-slate-100">
                  <p className="text-[10px] text-slate-400">Body Temperature</p>
                  <p className="font-bold text-slate-800">{history.vitals.temperature}°C</p>
                </div>
              )}
              {history.vitals.blood_sugar !== undefined && (
                <div className="p-2.5 bg-white rounded-xl border border-slate-100">
                  <p className="text-[10px] text-slate-400">Blood Glucose</p>
                  <p className="font-bold text-slate-800">{history.vitals.blood_sugar} mmol/L</p>
                </div>
              )}
              {history.vitals.weight !== undefined && (
                <div className="p-2.5 bg-white rounded-xl border border-slate-100">
                  <p className="text-[10px] text-slate-400">Weight</p>
                  <p className="font-bold text-slate-800">{history.vitals.weight} kg</p>
                </div>
              )}
              {history.vitals.spo2 !== undefined && (
                <div className="p-2.5 bg-white rounded-xl border border-slate-100">
                  <p className="text-[10px] text-slate-400">SpO2 Oxygen</p>
                  <p className="font-bold text-slate-800">{history.vitals.spo2}%</p>
                </div>
              )}
            </div>
          ) : (
            <p className="text-slate-400 italic">No baseline vitals registered for this session.</p>
          )}
        </div>
      </div>

      {/* Prescriptions */}
      <div className="space-y-3 pt-2">
        <h4 className="text-xs font-bold text-slate-800 flex items-center gap-1.5 uppercase tracking-wider">
          <Pill className="w-3.5 h-3.5 text-[#2E7D32]" />
          Historical Prescriptions &amp; Therapies ({history.prescription?.length || 0})
        </h4>

        {history.prescription && history.prescription.length > 0 ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            {history.prescription.map((rx, idx) => (
              <div
                key={idx}
                className="p-3.5 rounded-2xl bg-white border border-slate-200 text-xs space-y-1"
              >
                <div className="flex items-center justify-between">
                  <span className="font-bold text-slate-900">{rx.medication_name}</span>
                  <span className="px-2 py-0.5 rounded-md text-[10px] font-mono bg-slate-100 text-slate-700">
                    {rx.dose}
                  </span>
                </div>
                <p className="text-slate-500 text-[11px]">
                  {rx.frequency} • Route: {rx.route || 'Oral'} • Duration: {rx.duration_value} {rx.duration_unit}
                </p>
              </div>
            ))}
          </div>
        ) : (
          <p className="text-slate-400 italic text-xs">No active or past pharmacotherapy registered.</p>
        )}
      </div>
    </div>
  );
}
