# ACME Payroll — HR salary management

A focused, full-stack salary management application for an HR Manager overseeing 10,000 employees across multiple countries.

## What is included

- Ruby on Rails 7.1 JSON API, SQLite for local development, PostgreSQL for production.
- React 18 + TypeScript + Vite single-page application.
- HR Manager sign-in using short-lived JWT bearer tokens.
- Employee directory with search, country/department/status/currency filters and server-side pagination.
- Effective-dated salary records and salary history.
- Dashboard with headcount and payroll totals **grouped by currency** (no unsafe cross-currency addition).
- Audit events for employee and salary changes.
- Deterministic seed script creating exactly 10,000 employees.
- Rails Minitest and React/Vitest tests.
- Dockerfiles, compose setup, CI workflow and design artifacts.

## Local setup

Prerequisites: Ruby 3.2+, Bundler, Node 20+, npm.

### 1. Start the API

```bash
cd backend
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails server -p 3000
```

Demo credentials (development only):

- Email: `hr.manager@acme.example`
- Password: `ChangeMe123!`

The backend does not auto-load `.env` files. Set `SEED_ADMIN_PASSWORD` in your shell before seeding to use a different password. Never use the development default in a deployed environment.

### 2. Start the React app

In a second terminal:

```bash
cd frontend
npm install
cp .env.example .env
npm run dev
```

Open <http://localhost:5173>. The API defaults to <http://localhost:3000>.

### 3. Run tests

```bash
cd backend && bin/rails test
cd frontend && npm test
```

### 4. Seed data

`bin/rails db:seed` is idempotent for the HR account and employees. It creates `EMP00001` through `EMP10000`, with deterministic identities, countries, departments, and one opening salary record per employee. To rebuild a disposable local database from scratch, run `bin/rails db:drop db:create db:migrate db:seed`.

## Core API

All endpoints except sign-in require `Authorization: Bearer <token>`.

| Method | Path | Purpose |
|---|---|---|
| POST | `/api/v1/session` | Sign in |
| GET | `/api/v1/me` | Current HR user |
| GET | `/api/v1/dashboard` | Dashboard aggregates |
| GET | `/api/v1/employees` | Filtered, paginated directory |
| POST | `/api/v1/employees` | Create employee and opening salary |
| GET | `/api/v1/employees/:id` | Employee profile and salary history |
| PATCH | `/api/v1/employees/:id` | Update employee details |
| POST | `/api/v1/employees/:employee_id/salary_records` | Add effective-dated salary |

Pagination parameters: `page`, `per_page` (maximum 100). Filters: `q`, `country_code`, `department`, `status`, `currency`.

## Deployment notes

The repository is ready to deploy but is not deployed from this workspace. See [`docs/deployment.md`](docs/deployment.md) for the recommended Render + managed PostgreSQL + static React deployment, production environment variables, and smoke checks. A real deployment requires an account, repository access, secrets, and domain/hosting configuration.

## Product and engineering artifacts

- [`docs/requirements.md`](docs/requirements.md) — one-page product requirements.
- [`docs/architecture.md`](docs/architecture.md) — system design and data model.
- [`docs/decisions.md`](docs/decisions.md) — trade-offs and deliberate exclusions.
- [`docs/ai-usage.md`](docs/ai-usage.md) — AI-assisted workflow and verification.
- [`docs/performance-security.md`](docs/performance-security.md) — security and scale considerations.
- [`docs/demo-script.md`](docs/demo-script.md) — 3–5 minute walkthrough outline.

## Important assessment caveats

This is an assessment-grade product foundation, not a certified payroll processor. It deliberately does not calculate statutory deductions, taxes, exchange rates, payslips, bank transfers, or country-specific compliance. Those require validated jurisdictional rules and specialist review. A production rollout also needs organization-specific identity provider integration, formal role administration, security review, backups, monitoring, and a privacy/legal assessment.
