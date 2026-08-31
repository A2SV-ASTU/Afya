'use client';

import React, { useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Activity, Mail, Phone, Lock, AlertCircle, ArrowRight } from 'lucide-react';
import Link from 'next/link';
import { useAuth } from '@/modules/core/context/AuthContext';
import { getApiErrorMessage } from '@/lib/api/client';
import { dashboardPathForRole } from '@/lib/auth-routing';

export function LoginForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const { login } = useAuth();
  const [identifier, setIdentifier] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    if (!identifier || !password) {
      setError('Please provide an email/phone number and password.');
      return;
    }

    setLoading(true);

    const isEmail = identifier.includes('@');
    const payload = isEmail
      ? { email: identifier.trim(), password }
      : { phone: identifier.trim(), password };

    try {
      const user = await login(payload);
      const from = searchParams.get('from');
      const safeFrom =
        from && from.startsWith('/') && !from.startsWith('//') && from !== '/login'
          ? from
          : dashboardPathForRole(user.role);
      router.push(safeFrom);
      router.refresh();
    } catch (err: unknown) {
      setError(getApiErrorMessage(err, 'Login failed. Please check your credentials.'));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center p-4 bg-slate-100/60">
      <div className="w-full max-w-md bg-white rounded-3xl border border-slate-200 shadow-xl p-8 space-y-6">
        {/* Header */}
        <div className="text-center space-y-2">
          <div className="w-12 h-12 rounded-2xl bg-[#388E3C] text-white flex items-center justify-center mx-auto shadow-sm">
            <Activity className="w-6 h-6" />
          </div>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">AfyaMind Network</h1>
          <p className="text-xs text-slate-500">Secure National Clinical Governance & Encounter Gateway</p>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="space-y-4">
          {error && (
            <div className="p-3 rounded-xl bg-rose-500/10 border border-rose-500/20 text-rose-600 text-xs flex items-center gap-2">
              <AlertCircle className="w-4 h-4 shrink-0" />
              <span>{error}</span>
            </div>
          )}

          <div>
            <label className="block text-xs font-semibold text-slate-600 mb-1.5">
              Phone Number or Email
            </label>
            <div className="relative">
              {identifier.includes('@') ? (
                <Mail className="w-4 h-4 text-slate-400 absolute left-3 top-2.5" />
              ) : (
                <Phone className="w-4 h-4 text-slate-400 absolute left-3 top-2.5" />
              )}
              <input
                type="text"
                value={identifier}
                onChange={(e) => setIdentifier(e.target.value)}
                placeholder="+251911223344 or user@afyamind.org"
                className="w-full bg-slate-50 border border-slate-200 rounded-xl pl-9 pr-3 py-2 text-xs text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-[#388E3C] focus:border-transparent transition-all"
                required
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-600 mb-1.5">
              Password
            </label>
            <div className="relative">
              <Lock className="w-4 h-4 text-slate-400 absolute left-3 top-2.5" />
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                className="w-full bg-slate-50 border border-slate-200 rounded-xl pl-9 pr-3 py-2 text-xs text-slate-900 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-[#388E3C] focus:border-transparent transition-all"
                required
              />
            </div>
            <div className="flex justify-end mt-1.5">
              <Link href="/forgot-password" className="text-[11px] text-[#388E3C] font-medium hover:underline">
                Forgot Password?
              </Link>
            </div>
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full mt-2 bg-[#388E3C] hover:bg-[#2E7D32] text-white font-semibold py-2.5 px-4 rounded-xl text-xs transition-colors flex items-center justify-center gap-2 disabled:opacity-50 cursor-pointer shadow-xs"
          >
            <span>{loading ? 'Authenticating...' : 'Sign In'}</span>
            <ArrowRight className="w-4 h-4" />
          </button>


        </form>

        
      </div>
    </div>
  );
}