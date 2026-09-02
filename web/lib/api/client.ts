export class ApiError extends Error {
  code: string;
  status: number;

  constructor(message: string, code: string, status: number) {
    super(message);
    this.name = 'ApiError';
    this.code = code;
    this.status = status;
  }
}

interface RequestOptions extends RequestInit {
  params?: Record<string, string>;
}

const BASE_URL = process.env.NEXT_PUBLIC_API_URL || '/api/v1';

const SKIP_REFRESH_ENDPOINTS = new Set([
  '/auth/login',
  '/auth/register',
  '/auth/signup',
  '/auth/forgot-password',
  '/auth/reset-password',
  '/auth/refresh',
  '/auth/logout',
]);

function getCookie(name: string): string | null {
  if (typeof document === 'undefined') return null;
  const match = document.cookie.match(new RegExp(`(?:^|; )${name}=([^;]+)`));
  return match ? decodeURIComponent(match[1]) : null;
}

let refreshPromise: Promise<void> | null = null;

function shouldAttemptRefresh(endpoint: string, isRetry: boolean, status: number) {
  return status === 401 && !isRetry && !SKIP_REFRESH_ENDPOINTS.has(endpoint);
}

async function refreshSession(): Promise<void> {
  if (!refreshPromise) {
    refreshPromise = (async () => {
      const refreshRes = await fetch(`${BASE_URL}/auth/refresh`, {
        method: 'POST',
        credentials: 'include',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({}),
      });
      if (!refreshRes.ok) {
        throw new Error('Refresh token has expired or is invalid');
      }
    })().finally(() => {
      refreshPromise = null;
    });
  }
  return refreshPromise;
}

function clearRoleCookie() {
  if (typeof document === 'undefined') return;
  document.cookie = 'afyamind_role=; path=/; max-age=0; SameSite=Lax';
}

export async function apiClient<T>(
  endpoint: string,
  options: RequestOptions = {},
  isRetry = false
): Promise<T> {
  const { params, headers, ...rest } = options;

  let url = `${BASE_URL}${endpoint}`;
  if (params) {
    const searchParams = new URLSearchParams(params);
    url += `?${searchParams.toString()}`;
  }

  const activeRole = getCookie('afyamind_role');

  const defaultHeaders: Record<string, string> = {
    'Content-Type': 'application/json',
  };

  if (activeRole) {
    defaultHeaders['X-User-Role'] = activeRole;
  }

  const response = await fetch(url, {
    credentials: 'include',
    headers: {
      ...defaultHeaders,
      ...headers,
    },
    ...rest,
  });

  if (shouldAttemptRefresh(endpoint, isRetry, response.status)) {
    try {
      await refreshSession();
      return apiClient<T>(endpoint, options, true);
    } catch {
      clearRoleCookie();
      if (typeof window !== 'undefined') {
        window.dispatchEvent(new Event('afyamind:session-expired'));
      }
      throw new ApiError('Session expired. Please log in again.', 'unauthenticated', 401);
    }
  }

  if (!response.ok) {
    const errorBody = await response.json().catch(() => ({}));
    const errorMsg =
      errorBody.error?.message ||
      errorBody.message ||
      `API request failed with status ${response.status}`;
    throw new ApiError(
      errorMsg,
      errorBody.error?.code || 'internal_error',
      response.status
    );
  }

  if (response.status === 204) {
    return undefined as T;
  }

  return response.json();
}

apiClient.get = <T = any>(path: string) => apiClient<T>(path, { method: 'GET' });
apiClient.post = <T = any>(path: string, body?: unknown) => apiClient<T>(path, { method: 'POST', body: body ? JSON.stringify(body) : undefined });
apiClient.patch = <T = any>(path: string, body?: unknown) => apiClient<T>(path, { method: 'PATCH', body: body ? JSON.stringify(body) : undefined });

export function getApiErrorMessage(err: unknown, fallback: string) {
  if (err instanceof ApiError) return err.message;
  if (err instanceof Error) return err.message;
  return fallback;
}
