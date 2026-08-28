'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Activity, Shield, Building2, Stethoscope, ArrowRight, Lock } from 'lucide-react';
import { useAuth } from '@/modules/core/context/AuthContext';
import { Button } from '@/modules/core/ui/Button';
import { Input } from '@/modules/core/ui/Input';
import { UserRole } from '@/types/roles';

export default function LoginPage() {
  const router = useRouter();
  const { login } = useAuth();

  const [email, setEmail] = useState('superadmin@health.go.ke');
  const [password, setPassword] = useState('••••••••••••');
  const [role, setRole] = useState<UserRole>('super_admin');
  const [isLoading, setIsLoading] = useState(false);

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);

    setTimeout(() => {
      login(email, role);
      if (role === 'super_admin') router.push('/admin');
      else if (role === 'clinic_admin') router.push('/clinic');
      else router.push('/doctor');
    }, 400);
  };

  const handleRolePreset = (presetRole: UserRole, presetEmail: string) => {
    setRole(presetRole);
    setEmail(presetEmail);
  };

  return (
    <div className="min-h-screen flex items-center justify-center p-4 bg-slate-100/60">
      <div className="w-full max-w-md bg-white rounded-3xl border border-slate-200 shadow-xl p-8 space-y-6">
        <div className="text-center space-y-2">
          <div className="w-12 h-12 rounded-2xl bg-[#388E3C] text-white flex items-center justify-center mx-auto shadow-sm">
            <Activity className="w-6 h-6" />
          </div>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">AfyaMind Network</h1>
          <p className="text-xs text-slate-500">Secure National Clinical Governance & Encounter Gateway</p>
        </div>

        <div className="space-y-2">
          <label className="text-xs font-semibold text-slate-600 block">Select Role Demo Profile:</label>
          <div className="grid grid-cols-3 gap-2">
            <button
              type="button"
              onClick={() => handleRolePreset('super_admin', 'superadmin@health.go.ke')}
              className={`p-2 rounded-xl text-xs font-semibold border flex flex-col items-center gap-1 transition-all cursor-pointer ${
                role === 'super_admin'
                  ? 'bg-[#E8F5E9] text-[#1B5E20] border-[#388E3C] shadow-2xs'
                  : 'bg-slate-50 text-slate-600 border-slate-200 hover:bg-slate-100'
              }`}
            >
              <Shield className="w-4 h-4 text-[#2E7D32]" />
              <span>SuperAdmin</span>
            </button>

            <button
              type="button"
              onClick={() => handleRolePreset('clinic_admin', 'admin@stjude.org')}
              className={`p-2 rounded-xl text-xs font-semibold border flex flex-col items-center gap-1 transition-all cursor-pointer ${
                role === 'clinic_admin'
                  ? 'bg-[#E8F5E9] text-[#1B5E20] border-[#388E3C] shadow-2xs'
                  : 'bg-slate-50 text-slate-600 border-slate-200 hover:bg-slate-100'
              }`}
            >
              <Building2 className="w-4 h-4 text-[#2E7D32]" />
              <span>Clinic Admin</span>
            </button>

            <button
              type="button"
              onClick={() => handleRolePreset('doctor', 'dr.jane.muthoni@stjude.org')}
              className={`p-2 rounded-xl text-xs font-semibold border flex flex-col items-center gap-1 transition-all cursor-pointer ${
                role === 'doctor'
                  ? 'bg-[#E8F5E9] text-[#1B5E20] border-[#388E3C] shadow-2xs'
                  : 'bg-slate-50 text-slate-600 border-slate-200 hover:bg-slate-100'
              }`}
            >
              <Stethoscope className="w-4 h-4 text-[#2E7D32]" />
              <span>Doctor</span>
            </button>
          </div>
        </div>

        <form onSubmit={handleLogin} className="space-y-4">
          <Input
            label="Email or License Identifier"
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />

          <Input
            label="Password"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />

          <Button
            type="submit"
            className="w-full"
            isLoading={isLoading}
            leftIcon={<Lock className="w-4 h-4" />}
          >
            Authenticate & Open Workspace
          </Button>
        </form>

        <div className="pt-2 text-center">
          <p className="text-[11px] text-slate-400">
            KMPDC accredited • Zero-Visibility SuperAdmin Architecture
          </p>
        </div>
      </div>
    </div>
  );
}
