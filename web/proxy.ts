import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

/**
 * Next.js Edge Middleware for Role-Based Route Protection (RBAC)
 * Handles route boundaries for (admin), (clinic), (doctor), (auth)
 */
export function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl;

  // Read current active role from cookie or header (default to simulated super_admin / active session)
  const roleCookie = request.cookies.get('afyamind_role')?.value;
  const userRole = roleCookie || 'super_admin';

  // Public & Asset Routes
  if (
    pathname.startsWith('/_next') ||
    pathname.startsWith('/api') ||
    pathname.startsWith('/favicon.ico') ||
    pathname === '/403' ||
    pathname === '/login' ||
    pathname === '/accept-invite' ||
    pathname === '/'
  ) {
    return NextResponse.next();
  }

  // Admin Route Protection
  if (pathname.startsWith('/admin')) {
    if (userRole !== 'super_admin') {
      const url = request.nextUrl.clone();
      url.pathname = '/403';
      url.searchParams.set('required_role', 'super_admin');
      url.searchParams.set('current_role', userRole);
      return NextResponse.rewrite(url);
    }
  }

  // Clinic Route Protection
  if (pathname.startsWith('/clinic')) {
    if (userRole !== 'clinic_admin' && userRole !== 'super_admin') {
      const url = request.nextUrl.clone();
      url.pathname = '/403';
      url.searchParams.set('required_role', 'clinic_admin');
      url.searchParams.set('current_role', userRole);
      return NextResponse.rewrite(url);
    }
  }

  // Doctor Route Protection
  if (pathname.startsWith('/doctor')) {
    if (userRole !== 'doctor' && userRole !== 'super_admin') {
      const url = request.nextUrl.clone();
      url.pathname = '/403';
      url.searchParams.set('required_role', 'doctor');
      url.searchParams.set('current_role', userRole);
      return NextResponse.rewrite(url);
    }
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    '/admin/:path*',
    '/clinic/:path*',
    '/doctor/:path*',
    '/login',
    '/accept-invite',
  ],
};
