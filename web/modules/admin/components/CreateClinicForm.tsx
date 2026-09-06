'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Building2, ArrowLeft, CheckCircle2, Shield, AlertCircle, Mail, Phone, MapPin, User, Check } from 'lucide-react';
import { useStore } from '@/lib/store';
import { createClinic } from '@/lib/api/clinics';
import { getApiErrorMessage } from '@/lib/api/client';
import { getErrorMessage } from '@/lib/api/errors';
import { Button } from '@/modules/core/ui/Button';
import { Input } from '@/modules/core/ui/Input';
import { Clinic } from '@/types/database';

export function CreateClinicForm() {
  const router = useRouter();
  const { createClinic: syncStoreClinic } = useStore();

  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [address, setAddress] = useState('');
  const [adminFirstName, setAdminFirstName] = useState('');
  const [adminLastName, setAdminLastName] = useState('');
  const [error, setError] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [createdClinic, setCreatedClinic] = useState<Clinic | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    const cleanName = name.trim();
    const cleanEmail = email.trim();
    const cleanPhone = phone.trim();
    const cleanAddress = address.trim();
    const cleanFirstName = adminFirstName.trim();
    const cleanLastName = adminLastName.trim();

    if (!cleanName || !cleanEmail || !cleanPhone || !cleanAddress || !cleanFirstName || !cleanLastName) {
      setError('Please fill in all mandatory fields.');
      return;
    }

    setIsSubmitting(true);
    try {
      const newClinic = await createClinic({
        name: cleanName,
        email: cleanEmail,
        phone: cleanPhone || '+254 20 000000',
        address: cleanAddress,
        admin_first_name: cleanFirstName,
        admin_last_name: cleanLastName,
      });

      // Sync with local store
      if (syncStoreClinic) {
        await syncStoreClinic({
          name: cleanName,
          email: cleanEmail,
          phone: cleanPhone || '+254 20 000000',
          address: cleanAddress,
          admin_name: `${cleanFirstName} ${cleanLastName}`,
        });
      }

      setCreatedClinic(newClinic);
    } catch (err: unknown) {
      let errorMessage = 'Failed to onboard facility.';
      if (err && typeof err === 'object' && 'code' in err) {
        const errorCode = (err as { code: string }).code;
        if (errorCode === 'conflict') {
          errorMessage = 'A clinic with this email already exists';
        } else if (errorCode === 'validation_error') {
          errorMessage = 'Please check the form for errors';
        } else {
          errorMessage = getErrorMessage(errorCode);
        }
      } else {
        errorMessage = getApiErrorMessage(err, 'Failed to onboard facility.');
      }
      setError(errorMessage);
    } finally {
      setIsSubmitting(false);
    }
  };

  if (createdClinic) {
    return (
      <div className="max-w-2xl mx-auto space-y-6 animate-in fade-in zoom-in-95 duration-200">
        <div className="bg-white rounded-3xl border border-emerald-200 shadow-sm p-8 text-center space-y-6">
          <div className="w-16 h-16 rounded-2xl bg-emerald-100 text-emerald-700 border border-emerald-300 flex items-center justify-center mx-auto">
            <CheckCircle2 className="w-8 h-8" />
          </div>

          <div className="space-y-2">
            <span className="px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider bg-emerald-50 text-emerald-800 border border-emerald-200">
              Facility Successfully Provisioned
            </span>
            <h1 className="text-2xl font-bold text-slate-900">{createdClinic.name}</h1>
            <p className="text-xs text-slate-500 max-w-md mx-auto">
              The clinic record has been created and an automated welcome email containing the generated administrative credentials was dispatched to <strong className="text-slate-800">{createdClinic.email}</strong>.
            </p>
          </div>

          <div className="p-4 bg-slate-50 rounded-2xl border border-slate-200 text-left text-xs space-y-2">
            <div className="flex justify-between py-1 border-b border-slate-200/60">
              <span className="text-slate-500">Facility ID:</span>
              <span className="font-mono text-slate-800 font-semibold">{createdClinic.id}</span>
            </div>
            <div className="flex justify-between py-1 border-b border-slate-200/60">
              <span className="text-slate-500">Contact Phone:</span>
              <span className="text-slate-800 font-semibold">{createdClinic.phone}</span>
            </div>
            <div className="flex justify-between py-1 border-b border-slate-200/60">
              <span className="text-slate-500">Physical Address:</span>
              <span className="text-slate-800 font-semibold">{createdClinic.address}</span>
            </div>
            <div className="flex justify-between py-1">
              <span className="text-slate-500">Operational Status:</span>
              <span className="inline-flex items-center gap-1 font-semibold text-emerald-700">
                <Check className="w-3.5 h-3.5" />
                Active
              </span>
            </div>
          </div>

          <div className="flex flex-col sm:flex-row gap-3 pt-2">
            <Button
              variant="outline"
              className="flex-1"
              onClick={() => {
                setCreatedClinic(null);
                setName('');
                setEmail('');
                setPhone('');
                setAddress('');
                setAdminFirstName('');
                setAdminLastName('');
              }}
            >
              Register Another Facility
            </Button>
            <Button
              variant="primary"
              className="flex-1"
              onClick={() => router.push('/admin')}
            >
              Return to Admin Dashboard
            </Button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      {/* Header with back navigation */}
      <div className="flex items-center gap-3">
        <button
          type="button"
          onClick={() => router.back()}
          className="p-2 rounded-xl text-slate-500 hover:text-slate-900 hover:bg-slate-100 transition-colors cursor-pointer"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-900">
            Onboard New Clinic
          </h1>
          <p className="text-xs text-slate-500 mt-0.5">
            Register a licensed healthcare facility and initialize administrative credentials.
          </p>
        </div>
      </div>

      {error && (
        <div className="p-4 bg-rose-50 border border-rose-200 rounded-2xl flex items-center gap-3 text-rose-800 text-xs font-semibold">
          <AlertCircle className="w-5 h-5 text-rose-600 shrink-0" />
          <span>{error}</span>
        </div>
      )}

      {/* Main Provisioning Form */}
      <div className="bg-white rounded-3xl border border-slate-200/80 shadow-xs overflow-hidden">
        <div className="p-6 border-b border-slate-100 bg-slate-50/50 flex items-center justify-between">
          <div className="flex items-center gap-2 text-xs font-semibold text-emerald-800 uppercase tracking-wider">
            <Building2 className="w-4 h-4 text-emerald-600" />
            <span>Facility Metadata & Governance</span>
          </div>
          <span className="text-[11px] text-slate-400 font-medium">All fields mandatory</span>
        </div>

        <form onSubmit={handleSubmit} className="p-6 sm:p-8 space-y-6">
          {/* Section 1: Facility Info */}
          <div className="space-y-4">
            <h3 className="text-xs font-bold uppercase tracking-wider text-[#2E7D32]">
              1. Institutional Details
            </h3>

            <Input
              label="Clinic / Hospital Legal Name"
              placeholder="e.g. Afya Horizon Health Center"
              value={name}
              onChange={(e) => setName(e.target.value)}
              required
            />

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <Input
                label="Official Clinic Email"
                type="email"
                placeholder="contact@horizonhealth.org"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />

              <Input
                label="Facility Phone Number"
                type="tel"
                placeholder="+254 20 1234567"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                required
              />
            </div>

            <div>
              <Input
                label="Physical Address & Location"
                placeholder="Upper Hill Medical Plaza, Nairobi"
                value={address}
                onChange={(e) => setAddress(e.target.value)}
                required
              />
            </div>
          </div>

          {/* Section 2: Administrator Details */}
          <div className="pt-4 border-t border-slate-100 space-y-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-[#2E7D32]">
                <User className="w-4 h-4" />
                <span>2. Designated Clinic Administrator</span>
              </div>
              <span className="text-[11px] text-slate-400">
                Password auto-generated & emailed
              </span>
            </div>
            <p className="text-xs text-slate-600">
              The clinic administrator will receive their login credentials by email.
            </p>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <Input
                label="Administrator First Name"
                placeholder="e.g. Alice"
                value={adminFirstName}
                onChange={(e) => setAdminFirstName(e.target.value)}
                required
              />

              <Input
                label="Administrator Last Name"
                placeholder="e.g. Smith"
                value={adminLastName}
                onChange={(e) => setAdminLastName(e.target.value)}
                required
              />
            </div>

            <div className="p-3.5 bg-emerald-50/70 border border-emerald-200/80 rounded-2xl text-[11px] text-emerald-900 flex items-start gap-2.5">
              <Shield className="w-4 h-4 text-emerald-700 shrink-0 mt-0.5" />
              <div>
                <strong className="font-semibold block text-emerald-950 mb-0.5">Automated Credentials Provisioning:</strong>
                Submitting this form immediately provisions an administrator account. A secure temporary login password will be generated and dispatched directly to the official clinic email address.
              </div>
            </div>
          </div>

          <div className="pt-4 border-t border-slate-100 flex items-center justify-end gap-3">
            <Button
              type="button"
              variant="outline"
              onClick={() => router.back()}
              disabled={isSubmitting}
            >
              Cancel
            </Button>
            <Button
              type="submit"
              variant="primary"
              isLoading={isSubmitting}
            >
              Provision Healthcare Facility
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
