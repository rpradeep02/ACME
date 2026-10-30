# Performance, privacy and security notes

## Performance

- Server-side pagination with `per_page <= 100`; never return all 10,000 employees at once.
- Index employee code/email/country/department/status and salary employee/currency/effective date.
- Dashboard aggregates use database grouping and return compact summaries.
- List serialization returns one current salary only; profile endpoint returns history.
- Seed uses deterministic values so test and demo runs are reproducible.

## Sensitive data controls

- Authenticated endpoints only; API rejects invalid/expired tokens and any role other than `hr_manager`.
- Passwords are stored using bcrypt; secrets/passwords are not logged.
- CORS is restricted to configured frontend origin(s); use HTTPS in production.
- Strong secret and admin password must be provided through environment variables.
- No endpoint hard-deletes employee or salary history.
- Audit records store action/target and minimal metadata; avoid duplicating salary or personal data in free-form logs.

## Gaps before production

The assessment implementation uses one HR role and a self-managed JWT. Real payroll use requires OIDC/SSO, MFA, least-privilege salary scopes, tested token revocation, field-level access policy, encryption-at-rest verification, key rotation, database backups/restore drills, audit immutability, dependency scanning, penetration testing, observability and jurisdiction-specific privacy/compliance approval.
