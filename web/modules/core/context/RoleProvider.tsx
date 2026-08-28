'use client';

import React, { createContext, useContext } from 'react';
import { useAuth } from './AuthContext';
import { UserRole, ROLE_CONFIGS, RoleConfig } from '@/types/roles';

interface RoleContextType {
  role: UserRole;
  config: RoleConfig;
  setRole: (role: UserRole) => void;
  canAccess: (requiredRole: UserRole) => boolean;
}

const RoleContext = createContext<RoleContextType | undefined>(undefined);

export function RoleProvider({ children }: { children: React.ReactNode }) {
  const { currentRole, setCurrentRole } = useAuth();
  const config = ROLE_CONFIGS[currentRole];

  const canAccess = (requiredRole: UserRole): boolean => {
    if (currentRole === 'super_admin') return true;
    return currentRole === requiredRole;
  };

  return (
    <RoleContext.Provider
      value={{
        role: currentRole,
        config,
        setRole: setCurrentRole,
        canAccess,
      }}
    >
      {children}
    </RoleContext.Provider>
  );
}

export function useRole() {
  const context = useContext(RoleContext);
  if (!context) {
    throw new Error('useRole must be used within a RoleProvider');
  }
  return context;
}
