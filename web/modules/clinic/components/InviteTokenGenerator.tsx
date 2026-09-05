'use client';

import React, { useState } from 'react';
import { Mail, CheckCircle2, Copy, Sparkles } from 'lucide-react';
import { useStore } from '@/lib/store';
import { Modal } from '@/modules/core/ui/Modal';
import { Button } from '@/modules/core/ui/Button';
import { Input } from '@/modules/core/ui/Input';

interface InviteTokenGeneratorProps {
  isOpen: boolean;
  onClose: () => void;
}

export function InviteTokenGenerator({ isOpen, onClose }: InviteTokenGeneratorProps) {
  const { inviteDoctor, activeClinic } = useStore();

  const [email, setEmail] = useState('');
  const [specialization, setSpecialization] = useState('General Medicine');
  const [createdToken, setCreatedToken] = useState<string | null>(null);
  const [copied, setCopied] = useState(false);
  const [error, setError] = useState('');

  const handleGenerate = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    if (!email) {
      setError('Please provide a valid doctor email.');
      return;
    }

    try {
      const result = await inviteDoctor(activeClinic.id, email);
      // Backend only returns { message }, not the token
      // We'll show a success message instead
      setCreatedToken('invitation_sent_successfully');
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Failed to issue invitation.');
    }
  };

  const handleCopyLink = () => {
    if (!createdToken) return;
    const url = `${window.location.origin}/accept-invite?token=${createdToken}`;
    navigator.clipboard.writeText(url);
    setCopied(true);
    setTimeout(() => setCopied(false), 3000);
  };

  const handleReset = () => {
    setEmail('');
    setCreatedToken(null);
    setCopied(false);
    onClose();
  };

  return (
    <Modal
      isOpen={isOpen}
      onClose={handleReset}
      title="Invite Licensed Doctor"
      subtitle={`Issue cryptographic credentialing token for ${activeClinic.name}`}
      maxWidth="md"
    >
      {!createdToken ? (
        <form onSubmit={handleGenerate} className="space-y-4">
          {error && (
            <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-xs text-rose-700">
              {error}
            </div>
          )}

          <Input
            label="Doctor Email Address"
            type="email"
            placeholder="doctor.name@kmpdc.ke"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            autoFocus
          />

          <div className="space-y-1.5">
            <label className="block text-xs font-semibold text-slate-700">
              Clinical Specialization
            </label>
            <select
              value={specialization}
              onChange={(e) => setSpecialization(e.target.value)}
              className="w-full px-3.5 py-2 text-xs bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#388E3C]/20 focus:border-[#388E3C] text-slate-800"
            >
              <option value="General Medicine">General Medicine & Family Practice</option>
              <option value="Internal Medicine">Internal Medicine / Consultant Physician</option>
              <option value="Pediatrics">Pediatrics & Child Health</option>
              <option value="Obstetrics & Gynecology">Obstetrics & Gynecology</option>
              <option value="Psychiatry & Behavioral Health">Psychiatry & Behavioral Health</option>
              <option value="Cardiology">Cardiology</option>
              <option value="Emergency Medicine">Emergency Medicine</option>
            </select>
          </div>

          <div className="p-3.5 rounded-2xl bg-[#E8F5E9]/50 border border-[#C8E6C9] text-xs text-[#1B5E20] space-y-1">
            <p className="font-bold flex items-center gap-1.5">
              <Sparkles className="w-3.5 h-3.5 text-[#2E7D32]" />
              Cryptographic 24-Hour Expiration
            </p>
            <p className="text-[11px] text-[#2E7D32]">
              The invite token authorizes the recipient to set their password and register their KMPDC license for clinical encounters.
            </p>
          </div>

          <div className="pt-3 flex items-center justify-end gap-2.5">
            <Button type="button" variant="outline" size="sm" onClick={handleReset}>
              Cancel
            </Button>
            <Button type="submit" size="sm" leftIcon={<Mail className="w-4 h-4" />}>
              Generate & Send Token
            </Button>
          </div>
        </form>
      ) : (
        <div className="space-y-4 text-center py-2">
          <div className="w-12 h-12 rounded-2xl bg-[#E8F5E9] text-[#2E7D32] flex items-center justify-center mx-auto border border-[#C8E6C9]">
            <CheckCircle2 className="w-6 h-6" />
          </div>

          <div>
            <h4 className="text-base font-bold text-slate-900">Doctor Invite Sent Successfully</h4>
            <p className="text-xs text-slate-500 mt-1">
              Invitation sent to <strong className="text-slate-800">{email}</strong>. The doctor will receive an email with their onboarding link.
            </p>
          </div>

          <div className="p-3 bg-emerald-50 border border-emerald-200 rounded-2xl text-xs text-emerald-800">
            <p className="font-semibold">✓ Invitation email sent</p>
            <p className="text-emerald-700 mt-1">The doctor will receive a 24-hour invitation link via email to complete their registration.</p>
          </div>

          <div className="pt-2 flex justify-center">
            <Button size="sm" onClick={handleReset}>
              Done & Return to Roster
            </Button>
          </div>
        </div>
      )}
    </Modal>
  );
}
