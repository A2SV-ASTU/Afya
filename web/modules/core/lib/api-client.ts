/**
 * Centralized API Client Wrapper for Afya
 * Re-exports the unified client from @/lib/api/client
 */

export {
  apiClient,
  ApiError,
  api,
  getBaseUrl,
  getApiErrorMessage,
} from '@/lib/api/client';
export type { RequestOptions } from '@/lib/api/client';

export interface ApiErrorResponse {
  error: string;
  message?: string;
  code?: string;
  status?: number;
  details?: unknown;
}

