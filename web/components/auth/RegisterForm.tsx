'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { User, Phone, Mail, Lock, AlertCircle } from 'lucide-react';
import { useAuth } from '@/modules/core/context/AuthContext';
import { getApiErrorMessage } from '@/lib/api/client';
import { dashboardPathForRole } from '@/lib/auth-routing';

export function RegisterForm() {
  const router = useRouter();
  const { register } = useAuth();

  const [formData, setFormData] = useState({
    first_name: '',
    last_name: '',
    phone: '',
    email: '',
    password: '',
    date_of_birth: '',
    sex: '',
  });

  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    if (formData.password.length < 8) {
      setError('Password must be at least 8 characters long.');
      return;
    }

    setLoading(true);

    try {
      const user = await register(formData);
      router.push(dashboardPathForRole(user.role));
      router.refresh();
    } catch (err: unknown) {
      setError(getApiErrorMessage(err, 'Failed to process patient registration.'));
    } finally {
      setLoading(false);
    }
  };

  const inputClass =
    'w-full bg-slate-800 border border-slate-700 rounded-lg pl-9 pr-3 py-2 text-xs text-slate-200 focus:outline-none focus:ring-1 focus:ring-teal-500';

  return (
    <form onSubmit={handleSubmit} className="space-y-3.5">
      {error && (
        <div className="p-3 rounded-lg bg-rose-500/10 border border-rose-500/20 text-rose-400 text-xs flex items-center gap-2">
          <AlertCircle className="w-4 h-4 shrink-0" />
          <span>{error}</span>
        </div>
      )}

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        <div>
          <label className="block text-xs font-medium text-slate-300 mb-1">First Name *</label>
          <div className="relative">
            <User className="w-4 h-4 text-slate-500 absolute left-3 top-2.5" />
            <input
              name="first_name"
              type="text"
              value={formData.first_name}
              onChange={handleChange}
              placeholder="John"
              className={inputClass}
              required
            />
          </div>
        </div>

        <div>
          <label className="block text-xs font-medium text-slate-300 mb-1">Last Name *</label>
          <div className="relative">
            <User className="w-4 h-4 text-slate-500 absolute left-3 top-2.5" />
            <input
              name="last_name"
              type="text"
              value={formData.last_name}
              onChange={handleChange}
              placeholder="Doe"
              className={inputClass}
              required
            />
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        <div>
          <label className="block text-xs font-medium text-slate-300 mb-1">Phone Number *</label>
          <div className="relative">
            <Phone className="w-4 h-4 text-slate-500 absolute left-3 top-2.5" />
            <input
              name="phone"
              type="tel"
              value={formData.phone}
              onChange={handleChange}
              placeholder="+251911223344"
              className={inputClass}
              required
            />
          </div>
        </div>

        <div>
          <label className="block text-xs font-medium text-slate-300 mb-1">Email *</label>
          <div className="relative">
            <Mail className="w-4 h-4 text-slate-500 absolute left-3 top-2.5" />
            <input
              name="email"
              type="email"
              value={formData.email}
              onChange={handleChange}
              placeholder="john.doe@example.com"
              className={inputClass}
              required
            />
          </div>
        </div>
      </div>

      <div>
        <label className="block text-xs font-medium text-slate-300 mb-1">Password *</label>
        <div className="relative">
          <Lock className="w-4 h-4 text-slate-500 absolute left-3 top-2.5" />
          <input
            name="password"
            type="password"
            value={formData.password}
            onChange={handleChange}
            placeholder="At least 8 characters"
            className={inputClass}
            required
            minLength={8}
          />
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        <div>
          <label className="block text-xs font-medium text-slate-300 mb-1">Date of Birth *</label>
          <input
            name="date_of_birth"
            type="date"
            value={formData.date_of_birth}
            onChange={handleChange}
            className="w-full bg-slate-800 border border-slate-700 rounded-lg px-2.5 py-2 text-xs text-slate-200 focus:outline-none focus:ring-1 focus:ring-teal-500"
            required
          />
        </div>

        <div>
          <label className="block text-xs font-medium text-slate-300 mb-1">Sex *</label>
          <select
            name="sex"
            value={formData.sex}
            onChange={handleChange}
            className="w-full bg-slate-800 border border-slate-700 rounded-lg px-2.5 py-2 text-xs text-slate-200 focus:outline-none focus:ring-1 focus:ring-teal-500"
            required
          >
            <option value="">Select...</option>
            <option value="male">Male</option>
            <option value="female">Female</option>
            <option value="other">Other</option>
          </select>
        </div>
      </div>

      <button
        type="submit"
        disabled={loading}
        className="w-full mt-2 bg-teal-500 hover:bg-teal-400 text-slate-950 font-semibold py-2.5 px-4 rounded-lg text-xs transition-colors flex items-center justify-center gap-2 disabled:opacity-50"
      >
        <span>{loading ? 'Creating Patient Record...' : 'Register Patient Account'}</span>
      </button>

      <p className="text-center text-xs text-slate-400 pt-1">
        Already have an account?{' '}
        <Link href="/login" className="text-teal-400 font-medium hover:underline">
          Sign in
        </Link>
      </p>
    </form>
  );
}
