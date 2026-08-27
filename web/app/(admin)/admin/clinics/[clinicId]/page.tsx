'use client';

import React from 'react';
import { useParams } from 'next/navigation';
import { ClinicDetailView } from '@/modules/admin/components/ClinicDetailView';

export default function ClinicDetailPage() {
  const params = useParams();
  const clinicId = (params?.clinicId as string) || '';

  return <ClinicDetailView clinicId={clinicId} />;
}
