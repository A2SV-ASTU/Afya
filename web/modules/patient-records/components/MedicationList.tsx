'use client';

import React, { useCallback, useEffect, useState } from 'react';
import { Pill, RefreshCw, Ban, CheckCircle2, AlertCircle } from 'lucide-react';
import { StatusBadge } from '@/modules/core/ui/StatusBadge';
import { prescriptionsApi } from '@/lib/api/prescriptions';
import { getApiErrorMessage } from '@/lib/api/client';
import { formatDateTime } from '@/modules/core/lib/utils';
import { Button } from '@/modules/core/ui/Button';
import { Prescription, PrescriptionItem } from '@/types/database';
import { ConfirmDialog } from '@/modules/core/ui/ConfirmDialog';

interface MedicationListProps {
  patientId: string;
}

export function MedicationList({ patientId }: MedicationListProps) {
  const [prescriptions, setPrescriptions] = useState<Prescription[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Deactivation modal and action state
  const [selectedPrescription, setSelectedPrescription] = useState<{ id: string; name: string } | null>(null);
  const [isDeactivating, setIsDeactivating] = useState(false);
  const [actionError, setActionError] = useState<string | null>(null);
  const [actionSuccess, setActionSuccess] = useState<string | null>(null);

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

  const handleConfirmDeactivate = async () => {
    if (!selectedPrescription || !selectedPrescription.id || selectedPrescription.id === 'undefined') {
      setActionError('Invalid prescription ID. Unable to discontinue.');
      return;
    }
    setIsDeactivating(true);
    setActionError(null);
    try {
      await prescriptionsApi.deactivate(selectedPrescription.id);
      setPrescriptions((prev) =>
        prev.map((rx) => {
          const rxRaw = rx as unknown as Record<string, unknown>;
          const currId = String(rx.id || rxRaw.ID || rxRaw.id || '');
          if (currId === selectedPrescription.id) {
            const itemsList = (rx.items || rxRaw.Items || rxRaw.items || []) as unknown as Record<string, unknown>[];
            const updated = itemsList.map((it) => ({
              ...it,
              status: 'deactivated',
              Status: 'deactivated',
              deactivated_at: new Date().toISOString(),
              DeactivatedAt: new Date().toISOString(),
            }));
            return {
              ...rx,
              items: updated as unknown as PrescriptionItem[],
              Items: updated,
            } as Prescription;
          }
          return rx;
        })
      );
      setActionSuccess(`Successfully discontinued ${selectedPrescription.name}.`);
      setTimeout(() => setActionSuccess(null), 4000);
      setSelectedPrescription(null);
    } catch (err) {
      setActionError(getApiErrorMessage(err, 'Failed to discontinue medication.'));
    } finally {
      setIsDeactivating(false);
    }
  };

  const allItems = prescriptions.flatMap((rx) => {
    const rxRaw = rx as unknown as Record<string, unknown>;
    const rxId = String(rx.id || rxRaw.ID || rxRaw.id || '');
    const prescribedAt = String(rx.prescribed_at || rxRaw.PrescribedAt || rxRaw.prescribed_at || '');
    const encounterId = String(rx.encounter_id || rxRaw.EncounterID || rxRaw.encounter_id || '');
    const rawItems = (rx.items || rxRaw.Items || rxRaw.items || []) as unknown[];

    return rawItems.map((item, idx) => {
      const raw = item as Record<string, unknown>;
      const prescriptionId = String(
        raw.prescription_id || raw.PrescriptionID || raw.prescriptionId || rxId || ''
      );
      const id = String(raw.id || raw.ID || `${prescriptionId}-item-${idx}`);
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
        prescriptionId,
        medication_name: medicationName,
        dose,
        frequency,
        route,
        duration,
        instructions,
        status,
        deactivated_at: deactivatedAt,
        prescribedAt,
        encounterId,
      };
    });
  });

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
    <div className="bg-white rounded-3xl border border-slate-200 shadow-xs overflow-hidden space-y-0">
      {actionSuccess && (
        <div className="p-4 bg-[#E8F5E9] border-b border-[#C8E6C9] text-xs text-[#1B5E20] flex items-center gap-2 font-semibold animate-in fade-in">
          <CheckCircle2 className="w-4 h-4 text-[#2E7D32]" />
          {actionSuccess}
        </div>
      )}

      {actionError && (
        <div className="p-4 bg-rose-50 border-b border-rose-200 text-xs text-rose-700 flex items-center gap-2 font-semibold animate-in fade-in">
          <AlertCircle className="w-4 h-4 text-rose-600" />
          {actionError}
        </div>
      )}

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
              <th className="py-3 px-6 text-right">Actions</th>
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
                <td className="py-4 px-6 text-right">
                  {item.status === 'active' ? (
                    <Button
                      size="sm"
                      variant="outline"
                      disabled={!item.prescriptionId || item.prescriptionId === 'undefined'}
                      onClick={() => {
                        if (item.prescriptionId && item.prescriptionId !== 'undefined') {
                          setSelectedPrescription({ id: item.prescriptionId, name: item.medication_name });
                        }
                      }}
                      className="text-rose-600 hover:text-rose-700 hover:bg-rose-50 border-rose-200 text-[11px] h-7 px-2.5 cursor-pointer disabled:opacity-50"
                    >
                      <Ban className="w-3 h-3 mr-1" />
                      Discontinue
                    </Button>
                  ) : (
                    <span className="text-slate-400 text-[11px] italic">Discontinued</span>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <ConfirmDialog
        isOpen={Boolean(selectedPrescription)}
        onClose={() => setSelectedPrescription(null)}
        onConfirm={handleConfirmDeactivate}
        title="Discontinue Medication Order"
        description={`Are you sure you want to discontinue ${selectedPrescription?.name || 'this medication'}? This will mark the prescription as deactivated across the patient's national health record.`}
        confirmText="Discontinue Medication"
        cancelText="Keep Active"
        variant="danger"
        isLoading={isDeactivating}
      />
    </div>
  );
}
