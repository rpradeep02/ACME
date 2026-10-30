import type { Dashboard, Employee, PaginatedEmployees, SalaryRecord } from "../types";

const API_BASE = (import.meta.env.VITE_API_BASE_URL || "http://localhost:3000").replace(/\/$/, "");
let token: string | null = sessionStorage.getItem("acme_payroll_token");

export function setToken(value: string | null) {
  token = value;
  if (value) sessionStorage.setItem("acme_payroll_token", value);
  else sessionStorage.removeItem("acme_payroll_token");
}

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  const headers = new Headers(options.headers);
  headers.set("Accept", "application/json");
  if (options.body) headers.set("Content-Type", "application/json");
  if (token) headers.set("Authorization", `Bearer ${token}`);
  const response = await fetch(`${API_BASE}${path}`, { ...options, headers });
  const body = response.status === 204 ? null : await response.json().catch(() => ({}));
  if (!response.ok) {
    if (response.status === 401) setToken(null);
    const message = body?.errors?.join(", ") || body?.error || `Request failed (${response.status})`;
    throw new Error(message);
  }
  return body as T;
}

export const api = {
  login: (email: string, password: string) => request<{ token: string; user: { id: number; email: string; role: string } }>("/api/v1/session", { method: "POST", body: JSON.stringify({ email, password }) }),
  me: () => request<{ id: number; email: string; role: string }>("/api/v1/me"),
  dashboard: () => request<Dashboard>("/api/v1/dashboard"),
  employees: (params: URLSearchParams) => request<PaginatedEmployees>(`/api/v1/employees?${params.toString()}`),
  employee: (id: number) => request<Employee>(`/api/v1/employees/${id}`),
  createEmployee: (payload: { employee: Record<string, unknown>; salary: Record<string, unknown> }) => request<Employee>("/api/v1/employees", { method: "POST", body: JSON.stringify(payload) }),
  updateEmployee: (id: number, employee: Record<string, unknown>) => request<Employee>(`/api/v1/employees/${id}`, { method: "PATCH", body: JSON.stringify({ employee }) }),
  addSalary: (id: number, salary: Record<string, unknown>) => request<SalaryRecord>(`/api/v1/employees/${id}/salary_records`, { method: "POST", body: JSON.stringify({ salary }) }),
};
