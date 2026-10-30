import { FormEvent, useEffect, useState } from "react";
import EmployeeDrawer from "../components/EmployeeDrawer";
import { api } from "../lib/api";
import { formatDate, formatMoney, initials, localDateInputValue } from "../lib/format";
import type { Employee, PaginatedEmployees } from "../types";

const emptyForm = { employee_code: "", first_name: "", last_name: "", email: "", country_code: "IN", department: "Engineering", job_title: "Software Engineer", status: "active", hire_date: localDateInputValue() };

export default function Employees() {
  const [result, setResult] = useState<PaginatedEmployees | null>(null);
  const [selected, setSelected] = useState<Employee | null>(null);
  const [query, setQuery] = useState("");
  const [country, setCountry] = useState("");
  const [department, setDepartment] = useState("");
  const [status, setStatus] = useState("");
  const [currency, setCurrency] = useState("");
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [showCreate, setShowCreate] = useState(false);
  const [form, setForm] = useState(emptyForm);
  const [opening, setOpening] = useState({ annual_salary: "", currency: "INR", effective_from: localDateInputValue() });
  const [saving, setSaving] = useState(false);

  async function load(pageOverride = page) {
    setLoading(true); setError("");
    try {
      const params = new URLSearchParams({ page: String(pageOverride), per_page: "25" });
      if (query.trim()) params.set("q", query.trim());
      if (country) params.set("country_code", country);
      if (department) params.set("department", department);
      if (status) params.set("status", status);
      if (currency) params.set("currency", currency);
      setResult(await api.employees(params));
    } catch (err) { setError(err instanceof Error ? err.message : "Could not load employees"); }
    finally { setLoading(false); }
  }

  useEffect(() => { const timer = window.setTimeout(() => { void load(); }, 250); return () => window.clearTimeout(timer); }, [query, country, department, status, currency, page]);

  async function createEmployee(event: FormEvent) {
    event.preventDefault(); setSaving(true); setError("");
    try {
      const created = await api.createEmployee({ employee: form, salary: { ...opening, annual_salary: Number(opening.annual_salary) } });
      setShowCreate(false); setForm(emptyForm); setOpening({ ...opening, annual_salary: "" }); setPage(1); await load(1); setSelected(created);
    } catch (err) { setError(err instanceof Error ? err.message : "Could not create employee"); }
    finally { setSaving(false); }
  }

  function clearFilters() { setQuery(""); setCountry(""); setDepartment(""); setStatus(""); setCurrency(""); setPage(1); }

  return <div className="page-content">
    <div className="page-intro"><div><p className="eyebrow">PEOPLE DIRECTORY</p><h1>Employees</h1><p className="muted">Manage employee details and annual compensation.</p></div><button className="primary-button" onClick={() => { setError(""); setShowCreate(true); }}>＋ Add employee</button></div>
    <section className="panel directory-panel">
      <div className="filter-toolbar"><label className="search-box"><span>⌕</span><input aria-label="Search employees" placeholder="Search name, email or employee ID" value={query} onChange={e => { setQuery(e.target.value); setPage(1); }} /></label>
        <input aria-label="Filter by country" placeholder="Country code" maxLength={2} value={country} onChange={e => { setCountry(e.target.value.toUpperCase()); setPage(1); }} />
        <select aria-label="Filter by department" value={department} onChange={e => { setDepartment(e.target.value); setPage(1); }}><option value="">All departments</option>{["Engineering", "Product", "People", "Finance", "Sales", "Marketing", "Operations", "Customer Success"].map(name => <option key={name}>{name}</option>)}</select>
        <select aria-label="Filter by status" value={status} onChange={e => { setStatus(e.target.value); setPage(1); }}><option value="">All statuses</option><option value="active">Active</option><option value="on_leave">On leave</option><option value="terminated">Terminated</option></select>
        <select aria-label="Filter by currency" value={currency} onChange={e => { setCurrency(e.target.value); setPage(1); }}><option value="">All currencies</option>{["USD", "INR", "GBP", "EUR", "CAD", "SGD", "AUD", "AED"].map(code => <option key={code}>{code}</option>)}</select>
        {(query || country || department || status || currency) && <button className="text-button" onClick={clearFilters}>Clear</button>}
      </div>
      {error && <p className="form-error page-error" role="alert">{error}</p>}
      <div className="table-wrap"><table><thead><tr><th>Employee</th><th>Department</th><th>Country</th><th>Annual salary</th><th>Status</th><th>Hire date</th><th></th></tr></thead>
        <tbody>{loading ? <tr><td colSpan={7} className="table-state">Loading employees…</td></tr> : result?.data.length ? result.data.map(employee => <tr key={employee.id} onClick={() => setSelected(employee)} className="clickable-row"><td><div className="person-cell"><div className="avatar">{initials(employee.first_name, employee.last_name)}</div><div><strong>{employee.full_name}</strong><span>{employee.employee_code} · {employee.email}</span></div></div></td><td>{employee.department}<span className="sub-cell">{employee.job_title}</span></td><td><span className="country-code">{employee.country_code}</span></td><td>{employee.current_salary ? <><strong>{formatMoney(employee.current_salary.annual_salary, employee.current_salary.currency)}</strong><span className="sub-cell">{employee.current_salary.currency} · Annual</span></> : "—"}</td><td><span className={`status-pill ${employee.status}`}>{employee.status.replace("_", " ")}</span></td><td>{formatDate(employee.hire_date)}</td><td><button className="row-action" aria-label={`View ${employee.full_name}`} onClick={e => { e.stopPropagation(); setSelected(employee); }}>›</button></td></tr>) : <tr><td colSpan={7} className="table-state">No employees match these filters.</td></tr>}</tbody>
      </table></div>
      <div className="table-footer"><span>{result ? `Showing ${result.data.length ? (result.pagination.page - 1) * result.pagination.per_page + 1 : 0}–${(result.pagination.page - 1) * result.pagination.per_page + result.data.length} of ${result.pagination.total.toLocaleString("en")} employees` : ""}</span><div className="pagination"><button disabled={!result || page <= 1 || loading} onClick={() => setPage(p => p - 1)}>← Previous</button><span>Page {result?.pagination.page || page} of {result?.pagination.total_pages || 1}</span><button disabled={!result || page >= result.pagination.total_pages || loading} onClick={() => setPage(p => p + 1)}>Next →</button></div></div>
    </section>
    {selected && <EmployeeDrawer employee={selected} onClose={() => setSelected(null)} onChanged={() => void load()} />}
    {showCreate && <div className="drawer-backdrop" onMouseDown={e => { if (e.target === e.currentTarget) setShowCreate(false); }}><aside className="employee-drawer create-drawer"><div className="drawer-top"><span className="eyebrow">NEW RECORD</span><button className="icon-button" aria-label="Close form" onClick={() => setShowCreate(false)}>×</button></div><h2>Add employee</h2><p className="muted">Create the employee profile and opening salary record.</p>
      <form className="stack-form" onSubmit={createEmployee}>
        <label>Employee ID<input placeholder="EMP10001" value={form.employee_code} onChange={e => setForm({ ...form, employee_code: e.target.value.toUpperCase() })} pattern="EMP[0-9]{5}" required /></label>
        <div className="form-grid"><label>First name<input value={form.first_name} onChange={e => setForm({ ...form, first_name: e.target.value })} required /></label><label>Last name<input value={form.last_name} onChange={e => setForm({ ...form, last_name: e.target.value })} required /></label></div>
        <label>Work email<input type="email" value={form.email} onChange={e => setForm({ ...form, email: e.target.value })} required /></label>
        <div className="form-grid"><label>Country code<input value={form.country_code} maxLength={2} pattern="[A-Za-z]{2}" onChange={e => setForm({ ...form, country_code: e.target.value.toUpperCase() })} required /></label><label>Department<select value={form.department} onChange={e => setForm({ ...form, department: e.target.value })}>{["Engineering", "Product", "People", "Finance", "Sales", "Marketing", "Operations", "Customer Success"].map(name => <option key={name}>{name}</option>)}</select></label></div>
        <label>Job title<input value={form.job_title} onChange={e => setForm({ ...form, job_title: e.target.value })} required /></label>
        <label>Hire date<input type="date" value={form.hire_date} onChange={e => setForm({ ...form, hire_date: e.target.value })} required /></label>
        <div className="form-divider" /><p className="eyebrow">OPENING COMPENSATION</p>
        <label>Annual salary<input type="number" min="1" step="0.01" value={opening.annual_salary} onChange={e => setOpening({ ...opening, annual_salary: e.target.value })} required /></label>
        <div className="form-grid"><label>Currency<select value={opening.currency} onChange={e => setOpening({ ...opening, currency: e.target.value })}>{["USD", "INR", "GBP", "EUR", "CAD", "SGD", "AUD", "AED"].map(code => <option key={code}>{code}</option>)}</select></label><label>Effective from<input type="date" value={opening.effective_from} onChange={e => setOpening({ ...opening, effective_from: e.target.value })} required /></label></div>
        <label>Status<select value={form.status} onChange={e => setForm({ ...form, status: e.target.value })}><option value="active">Active</option><option value="on_leave">On leave</option></select></label>
        {error && <p className="form-error" role="alert">{error}</p>}
        <button className="primary-button" disabled={saving}>{saving ? "Creating…" : "Create employee"}</button>
      </form>
    </aside></div>}
  </div>;
}
