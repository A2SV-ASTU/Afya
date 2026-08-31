import { UserRole } from '@/types/database';

const AUTH_PATHS = new Set([
  '/login',
  '/forgot-password',
  '/accept-invite',
]);

export function dashboardPathForRole(role: string | undefined): string {
  switch (role) {
    case 'super_admin':
      return '/admin';
    case 'clinic_admin':
      return '/clinic';
    case 'doctor':
      return '/doctor';
    default:
      return '/';
  }
}

export function isAuthPath(pathname: string): boolean {
  return AUTH_PATHS.has(pathname);
}

export function isUserRole(value: string | undefined): value is UserRole {
  return (
    value === 'super_admin' ||
    value === 'clinic_admin' ||
    value === 'doctor' ||
    value === 'patient'
  );
}
