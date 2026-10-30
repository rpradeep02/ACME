import { FormEvent, useEffect, useState } from "react";
import { api } from "../lib/api";
import { formatDate, formatMoney, initials, localDateInputValue } from "../lib/format";
import type { Employee } from "../types";

type Props = { employee: Employee; onClose: () => void; onChanged: () => void };

export default function EmployeeDrawer({ employee: initial, onClose, onChanged }: Props) {
  const [employee, setEmployee] = useState(initial);
  const [editing, setEditing] = useState(false);
  const [salaryOpen, setSalaryOpen] = useState(false);
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  const [profile, setProfile] = useState({ first_name: initial.first_name, last_name: initial.last_name, email: initial.email, department: initial.department, job_title: initial.job_title, status: initial.status });
  const [salary, setSalary] = useState({ annual_salary: "", currency: initial.current_salary?.currency || "USD", effective_from: localDateInputValue() });

  useEffect(() => {
    api.employee(initial.id).then(data => setEmployee(data)).catch(err => setError(err.message));
  }, [initial.id]);

  async function saveProfile(event: FormEvent) {
    event.preventDefault(); setBusy(true); setError("");
    try { await api.updateEmployee(employee.id, profile); const fresh = await api.employee(employee.id); setEmployee(fresh); setEditing(false); onChanged(); }
    catch (err) { setError(err instanceof Error ? err.message : "Could not save changes"); }
    finally { setBusy(false); }
  }

  async function saveSalary(event: FormEvent) {
    event.preventDefault(); setBusy(true); setError("");
    try { await api.addSalary(employee.id, { ...salary, annual_salary: Number(salary.annual_salary) }); const fresh = await api.employee(employee.id); setEmployee(fresh); setSalaryOpen(false); setSalary({ ...salary, annual_salary: "" }); onChanged(); }
    catch (err) { setError(err instanceof Error ? err.message : "Could not save salary"); }
    finally { setBusy(false); }
  }

  return <div className="drawer-backdrop" onMouseDown={e => { if (e.target === e.currentTarget) onClose(); }}>
    <aside className="employee-drawer" aria-label={`Employee profile: ${employee.full_name}`}>
      <div className="drawer-top"><span className="eyebrow">EMPLOYEE PROFILE</span><button className="icon-button" aria-label="Close profile" onClick={onClose}>×</button></div>
      <div className="profile-heading"><div className="avatar large">{initials(employee.first_name, employee.last_name)}</div><div><h2>{employee.full_name}</h2><p className="muted">{employee.employee_code} · {employee.job_title}</p></div></div>
      <div className="profile-tags"><span className={`status-pill ${employee.status}`}>{employee.status.replace("_", " ")}</span><span className="tag">{employee.country_code}</span><span className="tag">{employee.department}</span></div>
      {error && <p className="form-error" role="alert">{error}</p>}
      <section className="drawer-section">
        <div className="section-heading"><h3>Personal & work details</h3><button className="text-button" onClick={() => setEditing(!editing)}>{editing ? "Cancel" : "Edit details"}</button></div>
        {editing ? <form className="stack-form" onSubmit={saveProfile}>
          <div className="form-grid"><label>First name<input value={profile.first_name} onChange={e => setProfile({ ...profile, first_name: e.target.value })} required /></label><label>Last name<input value={profile.last_name} onChange={e => setProfile({ ...profile, last_name: e.target.value })} required /></label></div>
          <label>Work email<input type="email" value={profile.email} onChange={e => setProfile({ ...profile, email: e.target.value })} required /></label>
          <div className="form-grid"><label>Department<input value={profile.department} onChange={e => setProfile({ ...profile, department: e.target.value })} required /></label><label>Job title<input value={profile.job_title} onChange={e => setProfile({ ...profile, job_title: e.target.value })} required /></label></div>
          <label>Status<select value={profile.status} onChange={e => setProfile({ ...profile, status: e.target.value as typeof profile.status })}><option value="active">Active</option><option value="on_leave">On leave</option><option value="terminated">Terminated</option></select></label>
          <button className="primary-button" disabled={busy}>{busy ? "Saving…" : "Save details"}</button>
        </form> : <div className="detail-grid"><div><span>Email</span><strong>{employee.email}</strong></div><div><span>Hire date</span><strong>{formatDate(employee.hire_date)}</strong></div><div><span>Department</span><strong>{employee.department}</strong></div><div><span>Country</span><strong>{employee.country_code}</strong></div></div>}
      </section>
      <section className="drawer-section">
        <div className="section-heading"><div><h3>Compensation</h3><p className="muted small">Annual gross base salary</p></div><button className="primary-button small-button" onClick={() => setSalaryOpen(!salaryOpen)}>{salaryOpen ? "Cancel" : "+ Add change"}</button></div>
        {salaryOpen && <form className="salary-form" onSubmit={saveSalary}>
          <label>Annual salary<input type="number" min="1" step="0.01" placeholder="e.g. 125000" value={salary.annual_salary} onChange={e => setSalary({ ...salary, annual_salary: e.target.value })} required /></label>
          <div className="form-grid"><label>Currency<select value={salary.currency} onChange={e => setSalary({ ...salary, currency: e.target.value })}>{["USD", "INR", "GBP", "EUR", "CAD", "SGD", "AUD", "AED"].map(code => <option key={code}>{code}</option>)}</select></label><label>Effective from<input type="date" value={salary.effective_from} onChange={e => setSalary({ ...salary, effective_from: e.target.value })} required /></label></div>
          <p className="muted small">The previous open salary period will end the day before this date.</p>
          <button className="primary-button" disabled={busy || !salary.annual_salary}>{busy ? "Saving…" : "Save salary change"}</button>
        </form>}
        <div className="salary-history">{(employee.salary_history || []).length === 0 ? <p className="muted">No salary history available.</p> : (employee.salary_history || []).map(record => <div className="salary-row" key={record.id}><div><strong>{formatMoney(record.annual_salary, record.currency)}</strong><span>{formatDate(record.effective_from)} – {record.effective_to ? formatDate(record.effective_to) : "Present"}</span></div><span className="tag">{record.currency}</span></div>)}</div>
      </section>
      <div className="drawer-note">Salary changes are retained in history. Employee records cannot be hard-deleted.</div>
    </aside>
  </div>;
}
