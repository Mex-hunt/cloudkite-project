const config = window.__CLOUDKITE_CONFIG__ ?? {};
const API_BASE_URL = config.apiBaseUrl ?? import.meta.env.VITE_API_BASE_URL ?? "http://localhost:8000";

export interface User {
  id: string;
  email: string;
  name: string;
}

export interface AuthResponse {
  access_token: string;
  token_type: string;
  expires_in: number;
  user: User;
}

export interface TokenStatus {
  active: boolean;
  subject?: string;
  expires_at?: number;
  reason?: string;
}

async function request<T>(path: string, init: RequestInit = {}): Promise<T> {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    ...init,
    headers: {
      Accept: "application/json",
      ...init.headers
    }
  });

  if (!response.ok) {
    const payload = await response.json().catch(() => null);
    throw new Error(payload?.detail ?? `Request failed with status ${response.status}`);
  }

  if (response.status === 204) {
    return undefined as T;
  }

  return response.json() as Promise<T>;
}

export function login(email: string, password: string): Promise<AuthResponse> {
  return request<AuthResponse>("/auth/login", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password })
  });
}

export function register(email: string, name: string, password: string): Promise<AuthResponse> {
  return request<AuthResponse>("/auth/register", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, name, password })
  });
}

export function me(token: string): Promise<User> {
  return request<User>("/auth/me", {
    headers: { Authorization: `Bearer ${token}` }
  });
}

export function verify(token: string): Promise<TokenStatus> {
  return request<TokenStatus>("/auth/verify", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ token })
  });
}

export function logout(token: string): Promise<void> {
  return request<void>("/auth/logout", {
    method: "POST",
    headers: { Authorization: `Bearer ${token}` }
  });
}

export const runtimeConfig = {
  apiBaseUrl: API_BASE_URL,
  appVersion: config.appVersion ?? import.meta.env.VITE_APP_VERSION ?? "0.1.0",
  environment: config.environment ?? import.meta.env.VITE_ENVIRONMENT ?? "local"
};
