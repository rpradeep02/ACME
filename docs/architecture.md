# Architecture

## Topology

```mermaid
flowchart LR
  HR[HR Manager] --> WEB[React + TypeScript SPA]
  WEB -->|HTTPS + Bearer JWT| API[Rails JSON API]
  API --> DB[(Relational DB<br/>SQLite local / PostgreSQL production)]
  API --> AUD[Audit events]
```

The UI is a thin client. Business rules, filtering, pagination, aggregation and authorization live in Rails so they remain consistent across clients.

## Data model

- `users`: HR identity, password digest and role.
- `employees`: stable employee code, contact/work identity, country, department, title, employment status and hire date.
- `salary_records`: employee, annual gross amount, ISO currency, effective start and optional end date. Historical rows are retained.
- `audit_events`: actor, action, target type/id and structured metadata.

Each employee can have many salary records. A salary interval is inclusive (`effective_from` through `effective_to`); null end date means open-ended. The salary creation service locks the employee, closes a superseded open interval, and rejects remaining overlaps within a transaction.

## API boundaries

`/api/v1` JSON endpoints. JWT is issued at sign-in and expires after 8 hours. Only the HR Manager role is admitted by the API guard. Pagination is server-side and capped at 100. Filter/sort inputs are allow-listed; SQL values are parameterized. API responses expose only fields needed by the UI.

## Performance approach

- Index employee code, email, country, department, status, salary currency/effective dates and audit target.
- Search is bounded and paginated; response payloads do not include full salary histories in list endpoints.
- Dashboard aggregates execute in SQL and group by currency.
- Seed data is deterministic and generated in batches to avoid 10,000 individual insert round trips where practical.

## Production posture

Use PostgreSQL in production, HTTPS, strong `SECRET_KEY_BASE`, a rotated seed/admin password, strict CORS allow-list, managed backups, centralized logs and monitoring. Add SSO/MFA, fine-grained permissions and privacy retention policy before real payroll data is loaded.
