'use client';

import React, { Suspense } from 'react';
import { useSearchParams, useRouter } from 'next/navigation';
import { ShieldAlert, ArrowLeft, Lock } from 'lucide-react';
import { Button } from '@/modules/core/ui/Button';

function ForbiddenContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const requiredRole = searchParams.get('required_role') || 'authorized role';
  const currentRole = searchParams.get('current_role') || 'current';

  return (
    <div className="min-h-screen flex items-center justify-center p-4 bg-slate-100/60">
      <div className="w-full max-w-md bg-white rounded-3xl border border-rose-200 shadow-xl p-8 text-center space-y-4">
        <div className="w-14 h-14 rounded-2xl bg-rose-50 border border-rose-200 text-rose-600 flex items-center justify-center mx-auto">
          <ShieldAlert className="w-7 h-7" />
        </div>

        <div>
          <h1 className="text-xl font-bold text-slate-900">403 Access Prohibited</h1>
          <p className="text-xs text-slate-500 mt-1">
            This sector is restricted by AfyaMind RBAC governance protocols.
          </p>
        </div>

        <div className="p-3.5 bg-slate-50 rounded-2xl border border-slate-100 text-xs text-slate-600 space-y-1 font-mono">
          <p>Required: <strong className="text-slate-900">{requiredRole}</strong></p>
          <p>Active Session: <strong className="text-slate-900">{currentRole}</strong></p>
        </div>

        <div className="pt-2 flex flex-col gap-2">
          <Button onClick={() => router.push('/')} leftIcon={<ArrowLeft className="w-4 h-4" />}>
            Return to Dashboard
          </Button>
        </div>
      </div>
    </div>
  );
}

export default function ForbiddenPage() {
  return (
    <Suspense fallback={<div className="p-8 text-center text-xs text-slate-400">Loading...</div>}>
      <ForbiddenContent />
    </Suspense>
  );
}
