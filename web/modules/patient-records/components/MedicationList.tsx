'use client';

import React, { useCallback, useEffect, useState } from 'react';
import { Pill, RefreshCw } from 'lucide-react';
import { StatusBadge } from '@/modules/core/ui/StatusBadge';
import { prescriptionsApi } from '@/lib/api/prescriptions';
import { getApiErrorMessage } from '@/lib/api/client';
import { formatDateTime } from '@/modules/core/lib/utils';
import { Prescription } from '@/types/database';
import { Button } from '@/modules/core/ui/Button';

interface MedicationListProps {
  patientId: string;
}

export function MedicationList({ patientId }: MedicationListProps) {
  const [prescriptions, setPrescriptions] = useState<Prescription[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchMedications = useCallback(async () => {
    if (!patientId) {
      setIsLoading(false);
      return;
    }
    setIsLoading(true);
    setError(null);
    try {
      const res = await prescriptionsApi.listForPatient(patientId, 1, 100);
      setPrescriptions(res.prescriptions || []);
    } catch (err) {
      setError(getApiErrorMessage(err, 'Failed to load medication history.'));
    } finally {
      setIsLoading(false);
    }
  }, [patientId]);

  useEffect(() => {
    fetchMedications();
  }, [fetchMedications]);

  const allItems = prescriptions.flatMap((rx) =>
    (rx.items || []).map((item, idx) => {
      const raw = item as unknown as Record<string, unknown>;
      const id = String(raw.id || raw.ID || `${rx.id}-item-${idx}`);
      const medicationName = String(raw.medication_name || raw.MedicationName || 'Medication');
      const dose = String(raw.dose || raw.Dose || '—');
      const frequency = String(raw.frequency || raw.Frequency || '—');
      const route = String(raw.route || raw.Route || 'oral');
      const durationVal = raw.duration_value ?? raw.DurationValue;
      const durationUnit = raw.duration_unit ?? raw.DurationUnit;
      const duration = raw.duration
        ? String(raw.duration)
        : durationVal != null && durationUnit != null
        ? `${durationVal} ${durationUnit}`
        : '—';
      const instructions = (raw.instructions || raw.Instructions) ? String(raw.instructions || raw.Instructions) : undefined;
      const status = String(raw.status || raw.Status || 'active').toLowerCase();
      const deactivatedAt = (raw.deactivated_at || raw.DeactivatedAt) ? String(raw.deactivated_at || raw.DeactivatedAt) : null;

      return {
        id,
        medication_name: medicationName,
        dose,
        frequency,
        route,
        duration,
        instructions,
        status,
        deactivated_at: deactivatedAt,
        prescribedAt: rx.prescribed_at,
        encounterId: rx.encounter_id,
      };
    })
  );

  if (isLoading) {
    return (
      <div className="p-8 text-center bg-white rounded-3xl border border-slate-200 text-xs text-slate-500">
        Loading medication history…
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-8 text-center bg-white rounded-3xl border border-rose-200 text-xs text-rose-600">
        <p>{error}</p>
        <Button variant="outline" size="sm" onClick={fetchMedications} className="mt-3">
          Retry
        </Button>
      </div>
    );
  }

  if (allItems.length === 0) {
    return (
      <div className="p-8 text-center bg-white rounded-3xl border border-slate-200 text-xs text-slate-500">
        No active or historical medications recorded for this patient.
      </div>
    );
  }

  return (
    <div className="bg-white rounded-3xl border border-slate-200 shadow-xs overflow-hidden">
      <div className="p-6 border-b border-slate-100 flex items-center justify-between">
        <h3 className="text-base font-bold text-slate-900 flex items-center gap-2">
          <Pill className="w-5 h-5 text-[#2E7D32]" />
          Longitudinal E-Prescriptions &amp; Active Medication History ({allItems.length})
        </h3>
        <Button variant="outline" size="sm" onClick={fetchMedications} disabled={isLoading}>
          <RefreshCw className={`w-3.5 h-3.5 mr-1.5 ${isLoading ? 'animate-spin' : ''}`} />
          Refresh
        </Button>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full text-left text-xs border-collapse">
          <thead>
            <tr className="border-b border-slate-100 bg-slate-50/75 text-slate-500 font-semibold uppercase tracking-wider text-[11px]">
              <th className="py-3 px-6">Medication &amp; Strength</th>
              <th className="py-3 px-6">Regimen &amp; Route</th>
              <th className="py-3 px-6">Duration &amp; Instructions</th>
              <th className="py-3 px-6">Prescribed Date</th>
              <th className="py-3 px-6">Status</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 font-medium text-slate-700">
            {allItems.map((item) => (
              <tr key={item.id} className="hover:bg-slate-50/60 transition-colors">
                <td className="py-4 px-6">
                  <p className="font-bold text-slate-900">{item.medication_name}</p>
                  <span className="text-[11px] font-mono px-2 py-0.5 bg-slate-100 text-slate-700 rounded-md font-semibold">
                    {item.dose}
                  </span>
                </td>
                <td className="py-4 px-6">
                  <p className="font-semibold text-slate-800">{item.frequency}</p>
                  <p className="text-[11px] text-slate-400">Route: {item.route}</p>
                </td>
                <td className="py-4 px-6">
                  <p className="text-slate-700">{item.duration}</p>
                  {item.instructions && (
                    <p className="text-[11px] text-slate-400">{item.instructions}</p>
                  )}
                </td>
                <td className="py-4 px-6">
                  <p className="font-mono text-slate-700">{formatDateTime(item.prescribedAt)}</p>
                  {item.deactivated_at && (
                    <p className="text-[10px] text-rose-500">Deactivated {formatDateTime(item.deactivated_at)}</p>
                  )}
                </td>
                <td className="py-4 px-6">
                  <StatusBadge status={item.status || 'active'} />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
