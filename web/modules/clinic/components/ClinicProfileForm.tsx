'use client';

import React, { useState } from 'react';
import { Building2, CheckCircle2, ShieldCheck, Mail, Phone, MapPin } from 'lucide-react';
import { useStore } from '@/lib/store';
import { Button } from '@/modules/core/ui/Button';
import { Input } from '@/modules/core/ui/Input';

export function ClinicProfileForm() {
  const { activeClinic, updateClinicProfile } = useStore();

  const [name, setName] = useState(activeClinic.name);
  const [phone, setPhone] = useState(activeClinic.phone);
  const [address, setAddress] = useState(activeClinic.address);
  const [isSaved, setIsSaved] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    updateClinicProfile(activeClinic.id, { name, phone, address });
    setIsSubmitting(false);
    setIsSaved(true);
    setTimeout(() => setIsSaved(false), 3000);
  };

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <div>
        <h1 className="text-xl font-bold text-slate-900">Facility Operations & Profile</h1>
        <p className="text-xs text-slate-500">Configure clinic metadata and public contact details</p>
      </div>

      <div className="bg-white rounded-3xl border border-slate-200 shadow-xs p-8 space-y-6">
        {isSaved && (
          <div className="p-3.5 rounded-2xl bg-[#E8F5E9] border border-[#C8E6C9] text-xs text-[#1B5E20] flex items-center gap-2 font-semibold">
            <CheckCircle2 className="w-4 h-4 text-[#2E7D32]" />
            Clinic operational profile updated successfully!
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-5">
          <div className="space-y-4">
            <Input
              label="Clinic Facility Name"
              value={name}
              onChange={(e) => setName(e.target.value)}
              required
            />

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <Input
                label="Emergency Contact Phone"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                required
              />

              <Input
                label="Physical Address / Plaza"
                value={address}
                onChange={(e) => setAddress(e.target.value)}
                required
              />
            </div>
          </div>

          <div className="p-4 rounded-2xl bg-slate-50 border border-slate-200 text-xs text-slate-600 space-y-2">
            <div className="flex items-center gap-2 font-bold text-slate-800">
              <ShieldCheck className="w-4 h-4 text-[#2E7D32]" />
              <span>Accredited Facility Identity</span>
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-[11px]">
              <div>
                <span className="text-slate-400">Facility Master ID:</span>
                <p className="font-mono font-semibold text-slate-800">{activeClinic.id}</p>
              </div>
              <div>
                <span className="text-slate-400">Primary Admin Email:</span>
                <p className="font-semibold text-slate-800">{activeClinic.admin_email}</p>
              </div>
            </div>
          </div>

          <div className="pt-4 flex items-center justify-end">
            <Button
              type="submit"
              isLoading={isSubmitting}
              leftIcon={<CheckCircle2 className="w-4 h-4" />}
            >
              Save Profile Changes
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
