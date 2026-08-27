'use client';

import React, { createContext, useContext, useState, useEffect } from 'react';
import { User } from '@/types/database';
import { UserRole } from '@/types/roles';

export interface AuthContextType {
  currentUser: User;
  currentRole: UserRole;
  setCurrentRole: (role: UserRole) => void;
  isAuthenticated: boolean;
  token: string | null;
  login: (email: string, role: UserRole) => void;
  logout: () => void;
  updateUser: (data: Partial<User>) => void;
}

const DEFAULT_SUPER_ADMIN: User = {
  id: 'usr-admin-01',
  email: 'superadmin@health.go.ke',
  first_name: 'MOH Governance',
  last_name: 'SuperAdmin',
  role: 'super_admin',
  phone: '+254 20 2717077',
  created_at: '2025-01-01T00:00:00Z',
};

export const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [currentRole, setCurrentRoleState] = useState<UserRole>('super_admin');
  const [currentUser, setCurrentUser] = useState<User>(DEFAULT_SUPER_ADMIN);
  const [token, setToken] = useState<string | null>('simulated_afyamind_jwt_token');

  // Sync role changes to cookie for Next.js Middleware route evaluation
  const setCurrentRole = (role: UserRole) => {
    setCurrentRoleState(role);
    if (typeof document !== 'undefined') {
      document.cookie = `afyamind_role=${role}; path=/; max-age=86400; SameSite=Lax`;
    }
  };

  useEffect(() => {
    // Check initial cookie or storage
    if (typeof document !== 'undefined') {
      const syncRoleFromCookie = () => {
        const match = document.cookie.match(new RegExp('(^| )afyamind_role=([^;]+)'));
        if (match && match[2]) {
          setCurrentRoleState(match[2] as UserRole);
        } else {
          document.cookie = `afyamind_role=super_admin; path=/; max-age=86400; SameSite=Lax`;
        }
      };
      syncRoleFromCookie();
    }
  }, []);

  const login = (email: string, role: UserRole) => {
    setCurrentRole(role);
    setCurrentUser((prev) => ({
      ...prev,
      email,
      role,
    }));
    setToken('simulated_afyamind_jwt_token');
  };

  const logout = () => {
    setToken(null);
  };

  const updateUser = (data: Partial<User>) => {
    setCurrentUser((prev) => ({ ...prev, ...data }));
  };

  return (
    <AuthContext.Provider
      value={{
        currentUser,
        currentRole,
        setCurrentRole,
        isAuthenticated: !!token,
        token,
        login,
        logout,
        updateUser,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
