'use client';

import React, { useState, useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Activity, Mail, Phone, Lock, AlertCircle, ArrowRight, ShieldAlert } from 'lucide-react';
import Link from 'next/link';
import { useAuth } from '@/modules/core/context/AuthContext';
import { ApiError, getApiErrorMessage } from '@/lib/api/client';
import { dashboardPathForRole } from '@/lib/auth-routing';

interface ErrorNotice {
  title: string;
  message: string;
  isDeactivated?: boolean;
  contact?: string;
}

export function LoginForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const { login } = useAuth();
  const [identifier, setIdentifier] = useState('');
  const [password, setPassword] = useState('');
  const [errorNotice, setErrorNotice] = useState<ErrorNotice | null>(null);
  const [loading, setLoading] = useState(false);

  // Check for deactivated redirect query params
  useEffect(() => {
    const errorParam = searchParams.get('error');
    if (errorParam === 'doctor_deactivated') {
      setErrorNotice({
        title: 'Physician Account Deactivated',
        message: 'Your physician account has been deactivated by the clinic administrator. Access to the clinical workspace has been revoked.',
        contact: 'Please contact your healthcare facility administrator to request reactivation.',
        isDeactivated: true,
      });
    } else if (errorParam === 'clinic_deactivated') {
      setErrorNotice({
        title: 'Healthcare Facility Deactivated',
        message: 'This healthcare facility has been deactivated by the national system administrator. Access to clinic operations and patient registry is suspended.',
        contact: 'Please contact Afya National Administration for support.',
        isDeactivated: true,
      });
    } else if (errorParam === 'facility_deactivated') {
      setErrorNotice({
        title: 'Affiliated Facility Deactivated',
        message: 'Your affiliated healthcare facility is currently deactivated. Access to the clinical workspace has been suspended.',
        contact: 'Please contact facility management or system administration.',
        isDeactivated: true,
      });
    }
  }, [searchParams]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrorNotice(null);

    if (!identifier || !password) {
      setErrorNotice({
        title: 'Missing Required Fields',
        message: 'Please provide an email/phone number and password.',
        isDeactivated: false,
      });
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
      if (err instanceof ApiError) {
        if (err.code === 'doctor_deactivated') {
          setErrorNotice({
            title: 'Physician Account Deactivated',
            message: err.message,
            isDeactivated: true,
            contact: 'Please contact your clinic administrator for credential reinstatement.',
          });
          return;
        }
        if (err.code === 'clinic_deactivated') {
          setErrorNotice({
            title: 'Healthcare Facility Deactivated',
            message: err.message,
            isDeactivated: true,
            contact: 'Please contact Afya National Administration for assistance.',
          });
          return;
        }
        if (err.code === 'facility_deactivated') {
          setErrorNotice({
            title: 'Affiliated Facility Deactivated',
            message: err.message,
            isDeactivated: true,
            contact: 'Please contact facility management or system administration.',
          });
          return;
        }
      }
      setErrorNotice({
        title: 'Sign In Failed',
        message: getApiErrorMessage(err, 'Login failed. Please check your credentials.'),
        isDeactivated: false,
      });
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
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Afya</h1>
          <p className="text-xs text-slate-500">Secure National Clinical Governance & Encounter Gateway</p>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="space-y-4">
          {errorNotice && (
            <div
              className={`p-4 rounded-2xl border text-xs animate-in fade-in zoom-in-95 duration-200 ${errorNotice.isDeactivated
                  ? 'bg-rose-50 border-rose-200 text-rose-800'
                  : 'bg-rose-50 border-rose-200 text-rose-700'
                }`}
            >
              <div className="flex items-start gap-3">
                <AlertCircle className="w-4 h-4 text-rose-600 shrink-0 mt-0.5" />
                <div className="space-y-1">
                  <p className="font-bold text-rose-900">{errorNotice.title}</p>
                  <p className="leading-relaxed">{errorNotice.message}</p>
                  {errorNotice.contact && (
                    <p className="text-[11px] text-rose-600/90 font-medium pt-1 border-t border-rose-200/60 mt-1">
                      {errorNotice.contact}
                    </p>
                  )}
                </div>
              </div>
            </div>
          )}

          <div>
            <label className="block text-xs font-semibold text-slate-600 mb-1.5">
              Email or Phone Number
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
                placeholder="+251911223344 or user@afya.org"
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