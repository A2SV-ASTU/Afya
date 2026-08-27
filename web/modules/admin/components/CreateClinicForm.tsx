'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Building2, ArrowLeft, CheckCircle2, Shield } from 'lucide-react';
import { useStore } from '@/lib/store';
import { Button } from '@/modules/core/ui/Button';
import { Input } from '@/modules/core/ui/Input';

export function CreateClinicForm() {
  const router = useRouter();
  const { createClinic } = useStore();

  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [address, setAddress] = useState('');
  const [adminName, setAdminName] = useState('');
  const [adminPassword, setAdminPassword] = useState('');
  const [error, setError] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    if (!name || !email || !address || !adminName) {
      setError('Please fill in all mandatory fields.');
      return;
    }

    setIsSubmitting(true);
    try {
      const newClinic = createClinic({
        name,
        email,
        phone: phone || '+254 20 000000',
        address,
        admin_name: adminName,
        admin_password: adminPassword || 'Secret@123',
      });
      router.push(`/admin/clinics/${newClinic.id}`);
    } catch (err: any) {
      setError(err.message || 'Failed to onboard facility.');
      setIsSubmitting(false);
    }
  };

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <div className="flex items-center gap-3">
        <button
          type="button"
          onClick={() => router.push('/admin')}
          className="p-2 rounded-xl text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition-colors"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <div>
          <h1 className="text-xl font-bold text-slate-900">Onboard Healthcare Facility</h1>
          <p className="text-xs text-slate-500">Register and credential a new clinical facility</p>
        </div>
      </div>

      <div className="bg-white rounded-3xl border border-slate-200 shadow-xs p-8">
        <form onSubmit={handleSubmit} className="space-y-6">
          {error && (
            <div className="p-3.5 rounded-2xl bg-rose-50 border border-rose-200 text-xs text-rose-700 font-medium">
              {error}
            </div>
          )}

          <div className="space-y-4">
            <h3 className="text-xs font-bold uppercase tracking-wider text-[#2E7D32]">
              1. Facility Profile & Accreditation
            </h3>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <Input
                label="Facility Name"
                placeholder="e.g. St. Jude Healthcare Centre"
                value={name}
                onChange={(e) => setName(e.target.value)}
                required
              />

              <Input
                label="Official Contact Email"
                type="email"
                placeholder="facility@stjude.org"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />

              <Input
                label="Emergency / Switchboard Phone"
                placeholder="+254 700 123456"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
              />

              <Input
                label="Physical Address & Ward / County"
                placeholder="Upper Hill Medical Plaza, Nairobi"
                value={address}
                onChange={(e) => setAddress(e.target.value)}
                required
              />
            </div>
          </div>

          <div className="pt-4 border-t border-slate-100 space-y-4">
            <h3 className="text-xs font-bold uppercase tracking-wider text-[#2E7D32]">
              2. Facility Administrator Credentials
            </h3>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <Input
                label="Administrator Full Name"
                placeholder="Dr. Samuel Ombati"
                value={adminName}
                onChange={(e) => setAdminName(e.target.value)}
                required
              />

              <Input
                label="Initial Temporary Password"
                type="password"
                placeholder="••••••••••••"
                value={adminPassword}
                onChange={(e) => setAdminPassword(e.target.value)}
                helperText="Must be changed on first login"
              />
            </div>
          </div>

          <div className="pt-6 border-t border-slate-100 flex items-center justify-end gap-3">
            <Button
              type="button"
              variant="outline"
              onClick={() => router.push('/admin')}
            >
              Cancel
            </Button>
            <Button
              type="submit"
              isLoading={isSubmitting}
              leftIcon={<CheckCircle2 className="w-4 h-4" />}
            >
              Confirm & Onboard Clinic
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
