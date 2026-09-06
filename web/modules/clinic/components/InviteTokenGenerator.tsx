'use client';

import React, { useState } from 'react';
import { Mail, CheckCircle2, AlertCircle, Send, ShieldCheck, UserPlus } from 'lucide-react';
import { useAuth } from '@/modules/core/context/AuthContext';
import { invitationsApi } from '@/lib/api/invitations';
import { getApiErrorMessage } from '@/lib/api/client';
import { Modal } from '@/modules/core/ui/Modal';
import { Button } from '@/modules/core/ui/Button';
import { Input } from '@/modules/core/ui/Input';

interface InviteDoctorModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export function InviteTokenGenerator({ isOpen, onClose }: InviteDoctorModalProps) {
  const { currentUser } = useAuth();
  const clinicId = currentUser?.clinic_id;

  const [email, setEmail] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);
  const [error, setError] = useState('');

  const handleSendInvite = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    const cleanEmail = email.trim();
    if (!cleanEmail) {
      setError('Please provide a valid doctor email address.');
      return;
    }

    if (!clinicId) {
      setError('Active clinic identifier not found. Please re-login.');
      return;
    }

    setIsSubmitting(true);
    try {
      // Direct call to Go backend: POST /api/v1/clinics/:clinicId/invitations
      await invitationsApi.inviteDoctor(clinicId, { email: cleanEmail });
      setIsSuccess(true);
      setIsSubmitting(false);
    } catch (err: unknown) {
      setError(getApiErrorMessage(err, 'Failed to dispatch doctor invitation email.'));
      setIsSubmitting(false);
    }
  };

  const handleReset = () => {
    setEmail('');
    setIsSuccess(false);
    setError('');
    onClose();
  };

  return (
    <Modal
      isOpen={isOpen}
      onClose={handleReset}
      title="Invite Physician to Clinic"
      subtitle="Send an official credentialing invite for your healthcare facility"
      maxWidth="md"
    >
      {!isSuccess ? (
        <form onSubmit={handleSendInvite} className="space-y-4">
          {error && (
            <div className="p-3.5 rounded-2xl bg-rose-50 border border-rose-200 text-xs text-rose-700 font-medium flex items-start gap-2 animate-in fade-in">
              <AlertCircle className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
              <span>{error}</span>
            </div>
          )}

          <Input
            label="Doctor Email Address"
            type="email"
            placeholder="doctor.name@hospital.org"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            helperText="The backend will email a secure magic link for the doctor to register their credentials"
            required
            autoFocus
          />

          <div className="p-3.5 rounded-2xl bg-[#E8F5E9]/60 border border-[#C8E6C9] text-xs text-[#1B5E20] space-y-1.5">
            <p className="font-bold flex items-center gap-1.5">
              <ShieldCheck className="w-4 h-4 text-[#2E7D32]" />
              Automated Email Dispatch
            </p>
            <p className="text-[11px] text-[#2E7D32] leading-relaxed">
              When submitted, the Go backend generates a 24-hour cryptographic invitation token and automatically emails an onboarding magic link directly to the physician.
            </p>
          </div>

          <div className="pt-3 flex items-center justify-end gap-2.5">
            <Button type="button" variant="outline" size="sm" onClick={handleReset}>
              Cancel
            </Button>
            <Button
              type="submit"
              size="sm"
              isLoading={isSubmitting}
              leftIcon={<Send className="w-3.5 h-3.5" />}
            >
              Send Doctor Invitation
            </Button>
          </div>
        </form>
      ) : (
        <div className="space-y-4 text-center py-3 animate-in fade-in zoom-in-95">
          <div className="w-14 h-14 rounded-2xl bg-[#E8F5E9] text-[#2E7D32] flex items-center justify-center mx-auto border border-[#C8E6C9]">
            <CheckCircle2 className="w-7 h-7" />
          </div>

          <div className="space-y-1">
            <h4 className="text-base font-bold text-slate-900">Doctor Invitation Dispatched</h4>
            <p className="text-xs text-slate-500 max-w-sm mx-auto">
              An onboarding email containing a secure magic link was sent to <strong className="text-slate-800">{email}</strong>.
            </p>
          </div>

          <div className="p-3.5 bg-slate-50 border border-slate-200 rounded-2xl text-xs text-slate-600 text-left space-y-1">
            <p className="font-semibold text-slate-800">Next Steps for Doctor:</p>
            <ul className="list-disc list-inside text-[11px] text-slate-500 space-y-0.5">
              <li>Open the invitation email</li>
              <li>Click the magic registration link</li>
              <li>Enter full name, KMPDC license, and set password</li>
            </ul>
          </div>

          <div className="pt-2 flex items-center justify-center gap-2">
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={() => {
                setEmail('');
                setIsSuccess(false);
              }}
            >
              + Invite Another Doctor
            </Button>
            <Button size="sm" onClick={handleReset}>
              Return to Roster
            </Button>
          </div>
        </div>
      )}
    </Modal>
  );
}

