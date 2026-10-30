import { useEffect, useState } from "react";
import Login from "./components/Login";
import Dashboard from "./pages/Dashboard";
import Employees from "./pages/Employees";
import { api, setToken } from "./lib/api";

type User = { id: number; email: string; role: string };
type Page = "dashboard" | "employees";

export default function App() {
  const [user, setUser] = useState<User | null>(null);
  const [page, setPage] = useState<Page>("dashboard");
  const [checking, setChecking] = useState(true);

  useEffect(() => {
    if (sessionStorage.getItem("acme_payroll_token")) api.me().then(setUser).catch(() => setToken(null)).finally(() => setChecking(false));
    else setChecking(false);
  }, []);

  async function login(email: string, password: string) {
    const result = await api.login(email, password); setToken(result.token); setUser(result.user);
  }

  function logout() { setToken(null); setUser(null); setPage("dashboard"); }
  if (checking) return <div className="loading-screen">Loading ACME People & Pay…</div>;
  if (!user) return <Login onLogin={login} />;

  return <div className="app-shell">
    <aside className="sidebar">
      <div className="sidebar-brand"><div className="brand-mark small-mark">A</div><div><strong>ACME</strong><span>PEOPLE & PAY</span></div></div>
      <div className="nav-label">WORKSPACE</div>
      <button className={`nav-item ${page === "dashboard" ? "active" : ""}`} onClick={() => setPage("dashboard")}><span>▦</span> Overview</button>
      <button className={`nav-item ${page === "employees" ? "active" : ""}`} onClick={() => setPage("employees")}><span>♙</span> Employees</button>
      <div className="sidebar-bottom"><div className="help-card"><strong>Need a hand?</strong><span>Explore the employee directory to get started.</span></div><div className="user-card"><div className="avatar">HR</div><div className="user-info"><strong>HR Manager</strong><span>{user.email}</span></div><button className="logout-button" onClick={logout} aria-label="Sign out" title="Sign out">↪</button></div></div>
    </aside>
    <main className="main-area"><header className="topbar"><div className="breadcrumb">ACME <span>/</span> {page === "dashboard" ? "Overview" : "Employees"}</div><div className="topbar-right"><span className="secure-label">⌑ Secure HR workspace</span><div className="avatar small-avatar">HR</div></div></header>{page === "dashboard" ? <Dashboard /> : <Employees />}</main>
  </div>;
}
