'use client';

import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { usePathname, useRouter } from 'next/navigation';
import { User, UserRole } from '@/types/database';
import { authApi, extractUser, LoginPayload, RegisterPayload } from '@/lib/api/auth';
import { ApiError } from '@/lib/api/client';
import { clinicsApi } from '@/lib/api/clinics';
import { isAuthPath, isPublicPath } from '@/lib/auth-routing';

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

export function getDeactivationStatus(user: User): { code: string; message: string } | null {
  if (user.role === 'doctor') {
    if (user.doctor_status === 'deactivated') {
      return {
        code: 'doctor_deactivated',
        message: 'Your physician account has been deactivated by the clinic administrator. Access to the clinical workspace has been revoked. Please contact your facility administrator.',
      };
    }
    if (user.clinic_status === 'deactivated') {
      return {
        code: 'facility_deactivated',
        message: 'Your affiliated healthcare facility has been deactivated by system administration. Access to the clinical workspace is suspended. Please contact facility management.',
      };
    }
  } else if (user.role === 'clinic_admin') {
    if (user.clinic_status === 'deactivated') {
      return {
        code: 'clinic_deactivated',
        message: 'This healthcare facility has been deactivated by the national system administrator. Access to clinic operations and patient registry is suspended. Please contact Afya Administration.',
      };
    }
  }
  return null;
}

async function verifyClinicStatusIfNeeded(user: User): Promise<{ code: string; message: string } | null> {
  const directCheck = getDeactivationStatus(user);
  if (directCheck) return directCheck;

  // If clinic_status wasn't included on user, verify via clinic lookup if applicable
  if ((user.role === 'clinic_admin' || user.role === 'doctor') && user.clinic_id && user.clinic_status === undefined) {
    try {
      const res = await clinicsApi.getById(user.clinic_id);
      if (res?.clinic?.status === 'deactivated') {
        user.clinic_status = 'deactivated';
        return getDeactivationStatus(user);
      }
    } catch {
      // ignore
    }
  }
  return null;
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
      .then(async (res) => {
        if (cancelled) return;
        const user = res.data;
        const deactivation = await verifyClinicStatusIfNeeded(user);
        if (deactivation) {
          clearSession();
          authApi.logout().catch(() => {});
          if (!isAuthPath(pathname)) {
            router.push(`/login?error=${encodeURIComponent(deactivation.code)}`);
          }
          return;
        }
        applyUser(user);
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
  }, [applyUser, clearSession, pathname, router]);

  useEffect(() => {
    const onExpired = () => {
      clearSession();
      if (!isAuthPath(pathname) && !isPublicPath(pathname)) {
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

    // Verify account and facility active status
    const deactivation = await verifyClinicStatusIfNeeded(user);
    if (deactivation) {
      clearSession();
      try {
        await authApi.logout();
      } catch {
        // ignore
      }
      throw new ApiError(
        deactivation.message,
        deactivation.code,
        403,
        { role: user.role, status: 'deactivated' }
      );
    }

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
