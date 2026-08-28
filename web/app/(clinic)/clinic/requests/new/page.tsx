'use client';

import React, { Suspense } from 'react';
import { AccessRequestForm } from '@/modules/clinic/components/AccessRequestForm';

export default function NewAccessRequestPage() {
  return (
    <Suspense fallback={<div className="p-8 text-center text-xs text-slate-400">Loading request form...</div>}>
      <AccessRequestForm />
    </Suspense>
  );
}
