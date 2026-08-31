'use client';

import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { usePathname, useRouter } from 'next/navigation';
import { User, UserRole } from '@/types/database';
import { authApi, extractUser, LoginPayload, RegisterPayload } from '@/lib/api/auth';
import { isAuthPath } from '@/lib/auth-routing';

export interface AuthContextType {
  currentUser: User | null;
  currentRole: UserRole;
  setCurrentRole: (role: UserRole) => void;
  isAuthenticated: boolean;
  isReady: boolean;
  token: string | null;
  login: (credentials: LoginPayload) => Promise<User>;
  register: (payload: RegisterPayload) => Promise<User>;
  logout: (options?: { skipRemote?: boolean }) => Promise<void>;
  updateUser: (data: Parameters<typeof authApi.updateProfile>[0]) => Promise<void>;
}

function setCookie(name: string, value: string, maxAgeSeconds = 86400) {
  if (typeof document === 'undefined') return;
  document.cookie = `${name}=${encodeURIComponent(value)}; path=/; max-age=${maxAgeSeconds}; SameSite=Lax`;
}

function deleteCookie(name: string) {
  if (typeof document === 'undefined') return;
  document.cookie = `${name}=; path=/; max-age=0; SameSite=Lax`;
}

export const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const router = useRouter();
  const pathname = usePathname();
  const [token, setToken] = useState<string | null>(null);
  const [currentRole, setCurrentRoleState] = useState<UserRole>('patient');
  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [isReady, setIsReady] = useState(false);

  const applyUser = useCallback((user: User) => {
    setCurrentUser(user);
    setCurrentRoleState(user.role);
    setCookie('afyamind_role', user.role);
    setToken('session');
    setIsAuthenticated(true);
  }, []);

  const clearSession = useCallback(() => {
    setToken(null);
    setCurrentUser(null);
    setIsAuthenticated(false);
    deleteCookie('afyamind_role');
  }, []);

  const logout = useCallback(
    async (options?: { skipRemote?: boolean }) => {
      if (!options?.skipRemote) {
        try {
          await authApi.logout();
        } catch {
          // Local session is cleared even if the API call fails (expired session).
        }
      }
      clearSession();
      if (!isAuthPath(pathname)) {
        router.push('/login');
      }
    },
    [clearSession, pathname, router]
  );

  useEffect(() => {
    let cancelled = false;

    authApi
      .getCurrentUser()
      .then((res) => {
        if (cancelled) return;
        applyUser(res.data);
      })
      .catch(() => {
        if (cancelled) return;
        clearSession();
      })
      .finally(() => {
        if (!cancelled) setIsReady(true);
      });

    return () => {
      cancelled = true;
    };
  }, [applyUser, clearSession]);

  useEffect(() => {
    const onExpired = () => {
      clearSession();
      if (!isAuthPath(pathname)) {
        router.push('/login');
      }
    };
    window.addEventListener('afyamind:session-expired', onExpired);
    return () => window.removeEventListener('afyamind:session-expired', onExpired);
  }, [clearSession, pathname, router]);

  const setCurrentRole = (role: UserRole) => {
    setCurrentRoleState(role);
    setCookie('afyamind_role', role);
  };

  const login = async (credentials: LoginPayload): Promise<User> => {
    const res = await authApi.login(credentials);
    const user = extractUser(res.data);
    applyUser(user);
    return user;
  };

  const register = async (payload: RegisterPayload): Promise<User> => {
    const res = await authApi.register(payload);
    const user = extractUser(res.data);
    applyUser(user);
    return user;
  };

  const updateUser = async (data: Parameters<typeof authApi.updateProfile>[0]) => {
    const res = await authApi.updateProfile(data);
    applyUser(res.data);
  };

  return (
    <AuthContext.Provider
      value={{
        currentUser,
        currentRole,
        setCurrentRole,
        isAuthenticated,
        isReady,
        token,
        login,
        register,
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
