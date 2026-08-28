'use client';

import React from 'react';
import { ShieldCheck, AlertTriangle, CheckCircle2, Lock } from 'lucide-react';
import { Modal } from '@/modules/core/ui/Modal';
import { Button } from '@/modules/core/ui/Button';
import { Encounter } from '@/types/database';

interface CloseEncounterModalProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: () => void;
  encounter: Encounter;
}

export function CloseEncounterModal({
  isOpen,
  onClose,
  onConfirm,
  encounter,
}: CloseEncounterModalProps) {
  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      title="Close & Cryptographically Sign Encounter"
      subtitle={`Encounter ID: ${encounter.id} • ${encounter.clinic_name}`}
      maxWidth="md"
      footer={
        <div className="flex items-center justify-end gap-2.5 w-full">
          <Button variant="outline" size="sm" onClick={onClose}>
            Back to Editing
          </Button>
          <Button
            variant="brand"
            size="sm"
            onClick={onConfirm}
            leftIcon={<Lock className="w-3.5 h-3.5" />}
          >
            Sign & Close Encounter
          </Button>
        </div>
      }
    >
      <div className="space-y-4 text-xs text-slate-600">
        <div className="p-4 rounded-2xl bg-amber-50 border border-amber-200 space-y-2">
          <div className="flex items-center gap-2 font-bold text-amber-900">
            <AlertTriangle className="w-4 h-4 text-amber-600" />
            <span>Immutable Clinical Record Policy</span>
          </div>
          <p className="text-amber-800 leading-relaxed">
            Closing this encounter marks it as <strong>closed and finalized</strong>. It will be sealed into the patient&apos;s longitudinal health record with your cryptographic physician signature. No further edits can be made.
          </p>
        </div>

        <div className="space-y-2 p-3 bg-slate-50 rounded-2xl border border-slate-100">
          <p className="font-bold text-slate-800">Recorded Data Payload Summary:</p>
          <ul className="list-disc pl-4 space-y-1 text-slate-600">
            <li>Vitals Sign sets recorded: <strong>{encounter.vitals?.length || 0}</strong></li>
            <li>Laboratory findings attached: <strong>{encounter.labs?.length || 0}</strong></li>
            <li>ICD Diagnoses registered: <strong>{encounter.diagnoses?.length || 0}</strong></li>
            <li>E-Prescriptions authorized: <strong>{encounter.prescriptions?.length || 0}</strong></li>
          </ul>
        </div>
      </div>
    </Modal>
  );
}
