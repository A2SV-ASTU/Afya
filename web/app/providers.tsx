'use client';

import React from 'react';
import { StoreProvider } from '@/lib/store';
import { AuthProvider } from '@/modules/core/context/AuthContext';
import { RoleProvider } from '@/modules/core/context/RoleProvider';

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <StoreProvider>
      <AuthProvider>
        <RoleProvider>{children}</RoleProvider>
      </AuthProvider>
    </StoreProvider>
  );
}
