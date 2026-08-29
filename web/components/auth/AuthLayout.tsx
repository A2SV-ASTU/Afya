'use client';

import React from 'react';

interface AuthLayoutProps {
  children: React.ReactNode;
  title: string;
  subtitle: string;
}

export function AuthLayout({ children, title, subtitle }: AuthLayoutProps) {
  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 flex flex-col justify-center items-center p-4">
      <div className="w-full max-w-md">
        {/* Brand Header */}
        <div className="flex flex-col items-center mb-8 text-center">
          <div className="h-12 w-12 rounded-2xl bg-teal-500 flex items-center justify-center font-bold text-slate-950 text-2xl shadow-xl shadow-teal-500/20 mb-3">
            A
          </div>
          <h1 className="text-2xl font-bold tracking-tight text-slate-100">AfyaMind</h1>
          <p className="text-xs text-slate-400 mt-1">Unified EMR & Clinic Network</p>
        </div>

        {/* Card Container */}
        <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 sm:p-8 shadow-2xl">
          <div className="mb-6">
            <h2 className="text-xl font-semibold text-slate-100">{title}</h2>
            <p className="text-xs text-slate-400 mt-1">{subtitle}</p>
          </div>
          {children}
        </div>

        <p className="text-center text-xs text-slate-500 mt-8">
          &copy; {new Date().getFullYear()} AfyaMind EMR. Secure end-to-end medical records.
        </p>
      </div>
    </div>
  );
}