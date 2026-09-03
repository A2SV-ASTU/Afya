'use client';

import React, { useState, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Stethoscope, CheckCircle2, AlertCircle, Loader2 } from 'lucide-react';
import { useStore } from '@/lib/store';
import { Button } from '@/modules/core/ui/Button';
import { Input } from '@/modules/core/ui/Input';

function AcceptInviteContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const token = searchParams.get('token') || '';

  const { acceptInvite } = useStore();

  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [phone, setPhone] = useState('+254 7');
  const [licenseNumber, setLicenseNumber] = useState('');
  const [specialization, setSpecialization] = useState('General Practice');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [error, setError] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    if (!firstName || !lastName || !phone || !password || !licenseNumber || !specialization) {
      setError('Please fill in all required fields.');
      return;
    }

    if (password !== confirmPassword) {
      setError('Passwords do not match.');
      return;
    }

    if (!token) {
      setError('Invalid invitation link - no token found.');
      return;
    }

    setIsSubmitting(true);

    try {
      const result = await acceptInvite(token, {
        first_name: firstName,
        last_name: lastName,
        phone,
        password,
        license_number: licenseNumber,
        specialization,
      });

      if (!result.success) {
        // Check for specific error types
        const errorMsg = result.error || 'Failed to accept invitation';
        if (errorMsg.toLowerCase().includes('expired')) {
          setError('This invitation has expired. Please request a new invitation from your clinic administrator.');
        } else if (errorMsg.toLowerCase().includes('already') || errorMsg.toLowerCase().includes('used')) {
          setError('This invitation has already been used. If you already have an account, please log in.');
        } else {
          setError(errorMsg);
        }
        setIsSubmitting(false);
        return;
      }

      setIsSuccess(true);
      setTimeout(() => {
        router.push('/login');
      }, 2500);
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Failed to complete registration.');
      setIsSubmitting(false);
    }
  };

  if (!token) {
    return (
      <div className="min-h-screen flex items-center justify-center p-4 bg-slate-100/60">
        <div className="w-full max-w-md bg-white rounded-3xl border border-slate-200 shadow-xl p-8 text-center space-y-4">
          <div className="w-12 h-12 rounded-2xl bg-rose-50 text-rose-600 flex items-center justify-center mx-auto border border-rose-200">
            <AlertCircle className="w-6 h-6" />
          </div>
          <h2 className="text-lg font-bold text-slate-900">Invalid Invitation Link</h2>
          <p className="text-xs text-slate-500">
            This invitation link is invalid. Please check your email for the correct link or request a new invitation from your clinic administrator.
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
          <div className="w-14 h-14 rounded-2xl bg-emerald-50 text-emerald-600 border border-emerald-200 flex items-center justify-center mx-auto">
            <CheckCircle2 className="w-8 h-8" />
          </div>
          <h2 className="text-xl font-bold text-slate-900">Account Created Successfully!</h2>
          <p className="text-xs text-slate-500">
            Welcome Dr. {firstName} {lastName}. Your physician account has been activated.
          </p>
          <p className="text-xs text-slate-500">
            You can now log in with your credentials. Redirecting to login page...
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center p-4 bg-slate-100/60">
      <div className="w-full max-w-lg bg-white rounded-3xl border border-slate-200 shadow-xl p-8 space-y-6">
        <div className="text-center space-y-2">
          <div className="w-12 h-12 rounded-2xl bg-emerald-600 text-white flex items-center justify-center mx-auto">
            <Stethoscope className="w-6 h-6" />
          </div>
          <h1 className="text-xl font-bold text-slate-900">Accept Physician Invitation</h1>
          <p className="text-xs text-slate-500">Complete your profile to activate your doctor account</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          {error && (
            <div className="p-3 rounded-xl bg-rose-50 border border-rose-200 text-xs text-rose-700 flex items-start gap-2">
              <AlertCircle className="w-4 h-4 shrink-0 mt-0.5" />
              <span>{error}</span>
            </div>
          )}

          <div className="grid grid-cols-2 gap-3">
            <Input
              label="First Name"
              value={firstName}
              onChange={(e) => setFirstName(e.target.value)}
              required
              disabled={isSubmitting}
              placeholder="e.g. Jane"
            />
            <Input
              label="Last Name"
              value={lastName}
              onChange={(e) => setLastName(e.target.value)}
              required
              disabled={isSubmitting}
              placeholder="e.g. Doe"
            />
          </div>

          <Input
            label="Phone Number"
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
            required
            disabled={isSubmitting}
            placeholder="+254 7XX XXX XXX"
          />

          <div className="grid grid-cols-2 gap-3">
            <Input
              label="KMPDC License No."
              value={licenseNumber}
              onChange={(e) => setLicenseNumber(e.target.value)}
              required
              disabled={isSubmitting}
              placeholder="e.g. KMPDC-12345"
            />
            <Input
              label="Specialization"
              value={specialization}
              onChange={(e) => setSpecialization(e.target.value)}
              required
              disabled={isSubmitting}
              placeholder="e.g. Cardiology"
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <Input
              label="Create Password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              disabled={isSubmitting}
              placeholder="Min. 8 characters"
            />
            <Input
              label="Confirm Password"
              type="password"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              required
              disabled={isSubmitting}
              placeholder="Re-enter password"
            />
          </div>

          <Button 
            type="submit" 
            className="w-full" 
            leftIcon={isSubmitting ? <Loader2 className="w-4 h-4 animate-spin" /> : <CheckCircle2 className="w-4 h-4" />}
            disabled={isSubmitting}
          >
            {isSubmitting ? 'Creating Account...' : 'Activate Doctor Profile'}
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
            <Loader2 className="w-5 h-5 animate-spin text-emerald-600" />
            Loading invitation...
          </div>
        </div>
      }
    >
      <AcceptInviteContent />
    </Suspense>
  );
}
