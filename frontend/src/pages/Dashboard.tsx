import { useEffect, useState } from "react";
import { api } from "../lib/api";
import { formatMoney } from "../lib/format";
import type { Dashboard as DashboardData } from "../types";

export default function Dashboard() {
  const [data, setData] = useState<DashboardData | null>(null);
  const [error, setError] = useState("");
  useEffect(() => { api.dashboard().then(setData).catch(err => setError(err.message)); }, []);
  if (error) return <div className="error-panel">{error}</div>;
  if (!data) return <div className="loading-panel">Loading workforce overview…</div>;

  const maxCountry = Math.max(1, ...data.headcount_by_country.map(row => row.count));
  return <div className="page-content">
    <div className="page-intro"><div><p className="eyebrow">OVERVIEW</p><h1>Good morning</h1><p className="muted">Here's what's happening across ACME today.</p></div><span className="updated-label">Live workforce data</span></div>
    <div className="metric-grid">
      <article className="metric-card"><span>Total employees</span><strong>{data.employee_count.toLocaleString("en")}</strong><small>Across the organization</small><div className="metric-icon blue">↗</div></article>
      <article className="metric-card"><span>Active employees</span><strong>{data.active_employee_count.toLocaleString("en")}</strong><small>{data.employee_count ? Math.round(data.active_employee_count / data.employee_count * 100) : 0}% of headcount</small><div className="metric-icon green">✓</div></article>
      <article className="metric-card"><span>Countries</span><strong>{data.countries_count}</strong><small>Global workforce footprint</small><div className="metric-icon purple">◎</div></article>
    </div>
    <div className="dashboard-grid">
      <section className="panel payroll-panel"><div className="panel-heading"><div><p className="eyebrow">COMPENSATION</p><h2>Annual payroll</h2></div><span className="tag">Gross base salary</span></div>
        <p className="muted small">Totals are shown separately by currency. No foreign exchange conversion is applied.</p>
        {data.payroll_by_currency.map(row => <div className="payroll-currency" key={row.currency}><div className="payroll-line"><strong>{row.currency}</strong><span>{formatMoney(row.annual_total, row.currency)}</span></div><div className="payroll-meta"><span>{row.employee_count.toLocaleString("en")} employees</span><span>Annual</span></div><div className="progress-track"><div className="progress-fill" style={{ width: `${Math.min(100, row.employee_count / Math.max(1, data.employee_count) * 100)}%` }} /></div></div>)}
      </section>
      <section className="panel country-panel"><div className="panel-heading"><div><p className="eyebrow">DISTRIBUTION</p><h2>Employees by country</h2></div></div>
        {data.headcount_by_country.map(row => <div className="country-row" key={row.country_code}><span className="country-code">{row.country_code}</span><div className="country-bar"><div style={{ width: `${row.count / maxCountry * 100}%` }} /></div><strong>{row.count.toLocaleString("en")}</strong></div>)}
      </section>
    </div>
    <section className="panel department-panel"><div className="panel-heading"><div><p className="eyebrow">ORGANIZATION</p><h2>Active employees by department</h2></div></div><div className="department-grid">{data.departments.map(row => <div className="department-item" key={row.department}><span>{row.department}</span><strong>{row.count.toLocaleString("en")}</strong></div>)}</div></section>
  </div>;
}
