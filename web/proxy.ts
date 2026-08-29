import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { dashboardPathForRole, isAuthPath, isUserRole } from '@/lib/auth-routing';

export default function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const roleCookie = request.cookies.get('afyamind_role')?.value;
  const userRole = isUserRole(roleCookie) ? roleCookie : 'guest';

  if (isAuthPath(pathname)) {
    if (userRole !== 'guest') {
      const dest = request.nextUrl.clone();
      dest.pathname = dashboardPathForRole(userRole);
      dest.search = '';
      return NextResponse.redirect(dest);
    }
    return NextResponse.next();
  }

  if (userRole === 'guest') {
    const loginUrl = request.nextUrl.clone();
    loginUrl.pathname = '/login';
    loginUrl.searchParams.set('from', pathname);
    return NextResponse.redirect(loginUrl);
  }

  if (pathname.startsWith('/admin') && userRole !== 'super_admin') {
    return buildForbiddenRewrite(request, 'super_admin', userRole);
  }

  if (
    pathname.startsWith('/clinic') &&
    userRole !== 'clinic_admin' &&
    userRole !== 'super_admin'
  ) {
    return buildForbiddenRewrite(request, 'clinic_admin', userRole);
  }

  if (
    pathname.startsWith('/doctor') &&
    userRole !== 'doctor' &&
    userRole !== 'super_admin'
  ) {
    return buildForbiddenRewrite(request, 'doctor', userRole);
  }

  return NextResponse.next();
}

function buildForbiddenRewrite(
  request: NextRequest,
  requiredRole: string,
  currentRole: string
) {
  const url = request.nextUrl.clone();
  url.pathname = '/403';
  url.searchParams.set('required_role', requiredRole);
  url.searchParams.set('current_role', currentRole);
  return NextResponse.rewrite(url);
}

export const config = {
  matcher: [
    '/admin/:path*',
    '/clinic/:path*',
    '/doctor/:path*',
    '/login',
    '/register',
    '/accept-invite',
    '/forgot-password',
    '/reset-password',
  ],
};
