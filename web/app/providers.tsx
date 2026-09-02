'use client';

import React from 'react';
import { StoreProvider } from '@/lib/store';
import { AuthProvider } from '@/modules/core/context/AuthContext';
import { RoleProvider } from '@/modules/core/context/RoleProvider';

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <AuthProvider>
      <StoreProvider>
        <RoleProvider>{children}</RoleProvider>
      </StoreProvider>
    </AuthProvider>
  );
}