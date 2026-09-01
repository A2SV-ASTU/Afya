import { apiClient } from './client';
import { User } from '@/types/database';

export interface RegisterPayload {
  first_name: string;
  last_name: string;
  phone: string;
  email: string;
  password: string;
  date_of_birth: string;
  sex: string;
}

export interface LoginPayload {
  phone?: string;
  email?: string;
  password: string;
}

export interface UpdateProfilePayload {
  first_name?: string;
  last_name?: string;
  email?: string;
  phone?: string;
  date_of_birth?: string;
  sex?: string;
  blood_type?: string;
  emergency_contact_name?: string;
  emergency_contact_phone?: string;
}

export interface AuthResponse {
  data: {
    user: User;
  };
}

export interface RegisterResponse {
  data: User;
}

export interface MessageResponse {
  data: {
    message: string;
  };
}

export const authApi = {
  register: (payload: RegisterPayload) =>
    apiClient<RegisterResponse>('/auth/register', {
      method: 'POST',
      body: JSON.stringify(payload),
    }),

  login: (payload: LoginPayload) =>
    apiClient<AuthResponse>('/auth/login', {
      method: 'POST',
      body: JSON.stringify(payload),
    }),

  refreshToken: () =>
    apiClient<MessageResponse>('/auth/refresh', {
      method: 'POST',
      body: JSON.stringify({}),
    }),

  logout: () =>
    apiClient<MessageResponse>('/auth/logout', {
      method: 'POST',
    }),

  forgotPassword: (payload: { email: string }) =>
    apiClient<MessageResponse>('/auth/forgot-password', {
      method: 'POST',
      body: JSON.stringify(payload),
    }),

  resetPassword: (payload: { token?: string; password: string }) =>
    apiClient<MessageResponse>('/auth/reset-password', {
      method: 'POST',
      body: JSON.stringify(payload),
    }),

  getCurrentUser: () =>
    apiClient<{ data: User }>('/users/me', {
      method: 'GET',
    }),

  updateProfile: (payload: UpdateProfilePayload) =>
    apiClient<{ data: User }>('/users/me', {
      method: 'PATCH',
      body: JSON.stringify(payload),
    }),

  changePassword: (payload: { current_password: string; new_password: string }) =>
    apiClient<MessageResponse>('/users/me/password', {
      method: 'PUT',
      body: JSON.stringify(payload),
    }),

  deleteAccount: () =>
    apiClient<MessageResponse>('/users/me', {
      method: 'DELETE',
    }),
};

export function extractUser(payload: { user?: User } | User): User {
  if ('user' in payload && payload.user) return payload.user;
  return payload as User;
}

export const registerApi = authApi.register;
export const updateProfileApi = authApi.updateProfile;
export const changePasswordApi = authApi.changePassword;
export const deleteAccountApi = authApi.deleteAccount;
export const forgotPasswordApi = authApi.forgotPassword;
export const resetPasswordApi = authApi.resetPassword;
export const refreshTokenApi = authApi.refreshToken;
export const loginApi = authApi.login;
export const logoutApi = authApi.logout;
export const fetchCurrentUserApi = authApi.getCurrentUser;
