'use client';

import React, { useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Mail, Phone, Lock, AlertCircle, ArrowRight } from 'lucide-react';
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
    <form onSubmit={handleSubmit} className="space-y-4">
      {error && (
        <div className="p-3 rounded-lg bg-rose-500/10 border border-rose-500/20 text-rose-400 text-xs flex items-center gap-2">
          <AlertCircle className="w-4 h-4 shrink-0" />
          <span>{error}</span>
        </div>
      )}

      <div>
        <label className="block text-xs font-medium text-slate-300 mb-1.5">Phone Number or Email</label>
        <div className="relative">
          {identifier.includes('@') ? (
            <Mail className="w-4 h-4 text-slate-500 absolute left-3 top-2.5" />
          ) : (
            <Phone className="w-4 h-4 text-slate-500 absolute left-3 top-2.5" />
          )}
          <input
            type="text"
            value={identifier}
            onChange={(e) => setIdentifier(e.target.value)}
            placeholder="+251911223344 or user@afyamind.org"
            className="w-full bg-slate-800 border border-slate-700 rounded-lg pl-9 pr-3 py-2 text-xs text-slate-200 placeholder-slate-500 focus:outline-none focus:ring-1 focus:ring-teal-500"
            required
          />
        </div>
      </div>

      <div>
        <label className="block text-xs font-medium text-slate-300 mb-1.5">Password</label>
        <div className="relative">
          <Lock className="w-4 h-4 text-slate-500 absolute left-3 top-2.5" />
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="••••••••"
            className="w-full bg-slate-800 border border-slate-700 rounded-lg pl-9 pr-3 py-2 text-xs text-slate-200 placeholder-slate-500 focus:outline-none focus:ring-1 focus:ring-teal-500"
            required
          />
        </div>
        <div className="flex justify-end mt-1.5">
          <Link href="/forgot-password" title="Forgot Password" className="text-[10px] text-teal-400 hover:underline">
            Forgot Password?
          </Link>
        </div>
      </div>

      <button
        type="submit"
        disabled={loading}
        className="w-full mt-2 bg-teal-500 hover:bg-teal-400 text-slate-950 font-semibold py-2.5 px-4 rounded-lg text-xs transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
      >
        <span>{loading ? 'Authenticating...' : 'Sign In'}</span>
        <ArrowRight className="w-4 h-4" />
      </button>

      <div className="text-center pt-2">
        <p className="text-xs text-slate-400">
          New patient?{' '}
          <Link href="/register" className="text-teal-400 font-medium hover:underline">
            Create Patient Account
          </Link>
        </p>
      </div>
    </form>
  );
}
