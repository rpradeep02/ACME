export type SalaryRecord = {
  id: number;
  annual_salary: number;
  currency: string;
  effective_from: string;
  effective_to: string | null;
};

export type Employee = {
  id: number;
  employee_code: string;
  first_name: string;
  last_name: string;
  full_name: string;
  email: string;
  country_code: string;
  department: string;
  job_title: string;
  status: "active" | "on_leave" | "terminated";
  hire_date: string;
  current_salary: SalaryRecord | null;
  salary_history?: SalaryRecord[];
};

export type Dashboard = {
  employee_count: number;
  active_employee_count: number;
  countries_count: number;
  headcount_by_country: { country_code: string; count: number }[];
  payroll_by_currency: { currency: string; annual_total: number; employee_count: number }[];
  departments: { department: string; count: number }[];
};

export type PaginatedEmployees = {
  data: Employee[];
  pagination: { page: number; per_page: number; total: number; total_pages: number };
};
