export class ApiError extends Error {
  code: string;
  status: number;
  details?: unknown;

  constructor(message: string, code: string, status: number, details?: unknown) {
    super(message);
    this.name = 'ApiError';
    this.code = code;
    this.status = status;
    this.details = details;
  }
}

export interface RequestOptions extends RequestInit {
  params?: Record<string, string | number | boolean | undefined | null>;
}

export function getBaseUrl(): string {
  const envUrl = process.env.NEXT_PUBLIC_API_BASE_URL || process.env.NEXT_PUBLIC_API_URL;
  if (envUrl) {
    return envUrl.replace(/\/+$/, '');
  }
  return 'http://localhost:8080/api/v1';
}

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
      const baseUrl = getBaseUrl();
      const refreshRes = await fetch(`${baseUrl}/auth/refresh`, {
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
  const { params, headers, body, ...rest } = options;
  const baseUrl = getBaseUrl();

  const formattedEndpoint = endpoint.startsWith('/') ? endpoint : `/${endpoint}`;
  let url = endpoint.startsWith('http') ? endpoint : `${baseUrl}${formattedEndpoint}`;


  if (params) {
    const searchParams = new URLSearchParams();
    Object.entries(params).forEach(([key, val]) => {
      if (val !== undefined && val !== null) {
        searchParams.append(key, String(val));
      }
    });
    const queryString = searchParams.toString();
    if (queryString) {
      url += (url.includes('?') ? '&' : '?') + queryString;
    }
  }

  const defaultHeaders: Record<string, string> = {};

  if (!(body instanceof FormData)) {
    defaultHeaders['Content-Type'] = 'application/json';
  }

  // Inject token from storage if available
  if (typeof window !== 'undefined') {
    const token = localStorage.getItem('afyamind_token');
    if (token) {
      defaultHeaders['Authorization'] = `Bearer ${token}`;
    }
  }


  const response = await fetch(url, {
    credentials: 'include',
    headers: {
      ...defaultHeaders,
      ...headers,
    },
    body,
    ...rest,
  });

  if (shouldAttemptRefresh(formattedEndpoint, isRetry, response.status)) {
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
      (typeof errorBody.error === 'string'
        ? errorBody.error
        : errorBody.error?.message) ||
      errorBody.message ||
      `API request failed with status ${response.status}`;
    throw new ApiError(
      errorMsg,
      (typeof errorBody.error === 'object' && errorBody.error?.code) || errorBody.code || 'internal_error',
      response.status,
      errorBody.error || errorBody
    );
  }

  if (response.status === 204) {
    return undefined as T;
  }

  return response.json();
}

apiClient.get = <T = unknown>(path: string) => apiClient<T>(path, { method: 'GET' });
apiClient.post = <T = unknown>(path: string, body?: unknown) => apiClient<T>(path, { method: 'POST', body: body ? JSON.stringify(body) : undefined });
apiClient.patch = <T = unknown>(path: string, body?: unknown) => apiClient<T>(path, { method: 'PATCH', body: body ? JSON.stringify(body) : undefined });

export const api = {
  get: <T>(endpoint: string, options?: RequestOptions) =>
    apiClient<T>(endpoint, { ...options, method: 'GET' }),
  post: <T>(endpoint: string, data?: unknown, options?: RequestOptions) =>
    apiClient<T>(endpoint, {
      ...options,
      method: 'POST',
      body: data ? (data instanceof FormData ? data : JSON.stringify(data)) : undefined,
    }),
  put: <T>(endpoint: string, data?: unknown, options?: RequestOptions) =>
    apiClient<T>(endpoint, {
      ...options,
      method: 'PUT',
      body: data ? (data instanceof FormData ? data : JSON.stringify(data)) : undefined,
    }),
  patch: <T>(endpoint: string, data?: unknown, options?: RequestOptions) =>
    apiClient<T>(endpoint, {
      ...options,
      method: 'PATCH',
      body: data ? (data instanceof FormData ? data : JSON.stringify(data)) : undefined,
    }),
  delete: <T>(endpoint: string, options?: RequestOptions) =>
    apiClient<T>(endpoint, { ...options, method: 'DELETE' }),
};

export function getApiErrorMessage(err: unknown, fallback: string) {
  if (err instanceof ApiError) return err.message;
  if (err instanceof Error) return err.message;
  return fallback;
}

