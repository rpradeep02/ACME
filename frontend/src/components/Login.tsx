import { FormEvent, useState } from "react";

type Props = { onLogin: (email: string, password: string) => Promise<void> };

export default function Login({ onLogin }: Props) {
  const [email, setEmail] = useState("hr.manager@acme.example");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  async function submit(event: FormEvent) {
    event.preventDefault(); setError(""); setLoading(true);
    try { await onLogin(email, password); }
    catch (err) { setError(err instanceof Error ? err.message : "Unable to sign in"); }
    finally { setLoading(false); }
  }

  return <main className="login-shell">
    <section className="login-card">
      <div className="brand-mark">A</div>
      <p className="eyebrow">ACME · PEOPLE OPERATIONS</p>
      <h1>People & Pay</h1>
      <p className="muted">A clearer view of your global workforce.</p>
      <form onSubmit={submit} className="login-form">
        <label>Email address<input type="email" autoComplete="username" value={email} onChange={e => setEmail(e.target.value)} required /></label>
        <label>Password<input type="password" autoComplete="current-password" value={password} onChange={e => setPassword(e.target.value)} required /></label>
        {error && <p className="form-error" role="alert">{error}</p>}
        <button className="primary-button full-width" disabled={loading}>{loading ? "Signing in…" : "Sign in"}</button>
      </form>
      <p className="login-footnote">HR Manager access · Authorized users only</p>
    </section>
  </main>;
}
