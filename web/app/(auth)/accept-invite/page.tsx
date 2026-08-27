'use client';

import React, { useState, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Stethoscope, CheckCircle2, ShieldCheck, ArrowRight, Building2, Loader2 } from 'lucide-react';
import { useStore } from '@/lib/store';
import { Button } from '@/modules/core/ui/Button';
import { Input } from '@/modules/core/ui/Input';

function AcceptInviteContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const token = searchParams.get('token') || '';

  const { invitations, clinics, acceptInvite } = useStore();

  const invitation = invitations.find((i) => i.token === token);
  const clinic = invitation ? clinics.find((c) => c.id === invitation.clinic_id) : null;

  const defaultNames = React.useMemo(() => {
    if (!invitation) return { first: '', last: '' };
    const emailParts = invitation.email.split('@')[0].split('.');
    if (emailParts.length >= 2) {
      return {
        first: emailParts[0].charAt(0).toUpperCase() + emailParts[0].slice(1),
        last: emailParts[1].charAt(0).toUpperCase() + emailParts[1].slice(1),
      };
    }
    return { first: '', last: '' };
  }, [invitation]);

  const [firstName, setFirstName] = useState(() => defaultNames.first);
  const [lastName, setLastName] = useState(() => defaultNames.last);
  const [phone, setPhone] = useState('+254 7');
  const [licenseNumber, setLicenseNumber] = useState('KMPDC-A');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [error, setError] = useState('');
  const [isSuccess, setIsSuccess] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    if (!firstName || !lastName || !password || !licenseNumber) {
      setError('Please fill in all mandatory onboarding details.');
      return;
    }

    if (password !== confirmPassword) {
      setError('Passwords do not match.');
      return;
    }

    try {
      acceptInvite(token, {
        first_name: firstName,
        last_name: lastName,
        license_number: licenseNumber,
        specialization: invitation?.specialization || 'General Practice',
        password,
      });

      setIsSuccess(true);
      setTimeout(() => {
        router.push('/doctor');
      }, 1200);
    } catch (err: any) {
      setError(err.message || 'Failed to complete registration.');
    }
  };

  if (!invitation) {
    return (
      <div className="min-h-screen flex items-center justify-center p-4 bg-slate-100/60">
        <div className="w-full max-w-md bg-white rounded-3xl border border-slate-200 shadow-xl p-8 text-center space-y-4">
          <div className="w-12 h-12 rounded-2xl bg-rose-50 text-rose-600 flex items-center justify-center mx-auto border border-rose-200">
            <ShieldCheck className="w-6 h-6" />
          </div>
          <h2 className="text-lg font-bold text-slate-900">Invalid or Expired Invitation</h2>
          <p className="text-xs text-slate-500">
            This invitation link is invalid or has expired. Please request a new invite token from your facility administrator.
          </p>
          <Button onClick={() => router.push('/login')}>Go to Login</Button>
        </div>
      </div>
    );
  }

  if (isSuccess) {
    return (
      <div className="min-h-screen flex items-center justify-center p-4 bg-slate-100/60">
        <div className="w-full max-w-md bg-white rounded-3xl border border-slate-200 shadow-xl p-8 text-center space-y-4">
          <div className="w-14 h-14 rounded-2xl bg-[#E8F5E9] text-[#2E7D32] border border-[#C8E6C9] flex items-center justify-center mx-auto">
            <CheckCircle2 className="w-8 h-8" />
          </div>
          <h2 className="text-xl font-bold text-slate-900">Physician Credentials Activated!</h2>
          <p className="text-xs text-slate-500">
            Welcome Dr. {firstName} {lastName}. Redirecting to your clinical workspace...
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center p-4 bg-slate-100/60">
      <div className="w-full max-w-lg bg-white rounded-3xl border border-slate-200 shadow-xl p-8 space-y-6">
        <div className="text-center space-y-2">
          <div className="w-12 h-12 rounded-2xl bg-[#388E3C] text-white flex items-center justify-center mx-auto">
            <Stethoscope className="w-6 h-6" />
          </div>
          <h1 className="text-xl font-bold text-slate-900">Accept Physician Invitation</h1>
          <div className="flex items-center justify-center gap-1.5 text-xs text-slate-500">
            <Building2 className="w-3.5 h-3.5 text-[#2E7D32]" />
            <span>{clinic?.name || invitation.clinic_name}</span>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          {error && (
            <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-xs text-rose-700">
              {error}
            </div>
          )}

          <div className="grid grid-cols-2 gap-3">
            <Input
              label="First Name"
              value={firstName}
              onChange={(e) => setFirstName(e.target.value)}
              required
            />
            <Input
              label="Last Name"
              value={lastName}
              onChange={(e) => setLastName(e.target.value)}
              required
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <Input
              label="KMPDC License No."
              value={licenseNumber}
              onChange={(e) => setLicenseNumber(e.target.value)}
              required
            />
            <Input
              label="Phone Number"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              required
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <Input
              label="Create Password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
            <Input
              label="Confirm Password"
              type="password"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              required
            />
          </div>

          <Button type="submit" className="w-full" leftIcon={<CheckCircle2 className="w-4 h-4" />}>
            Activate Doctor Profile & Join Facility
          </Button>
        </form>
      </div>
    </div>
  );
}

export default function AcceptInvitePage() {
  return (
    <Suspense
      fallback={
        <div className="min-h-screen flex items-center justify-center bg-slate-50 p-4">
          <div className="flex items-center gap-2 text-slate-500 text-sm">
            <Loader2 className="w-5 h-5 animate-spin text-[#2E7D32]" />
            Loading invitation...
          </div>
        </div>
      }
    >
      <AcceptInviteContent />
    </Suspense>
  );
}
