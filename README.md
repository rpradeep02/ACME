# ACME Payroll — HR salary management

A full-stack salary-management application for an HR Manager overseeing 10,000 employees across multiple countries. The backend is a Ruby on Rails JSON API and the frontend is a React + TypeScript single-page application.

## What is included

- Ruby on Rails 7.1 JSON API; SQLite for local development and PostgreSQL for production.
- React 18 + TypeScript + Vite frontend.
- HR Manager sign-in using short-lived JWT bearer tokens.
- Employee directory with search, country/department/status/currency filters and server-side pagination.
- Effective-dated salary records and salary history.
- Dashboard with headcount and payroll totals grouped by currency (different currencies are never added together).
- Audit events for employee and salary changes.
- Deterministic seed data for 10,000 employees.
- Rails Minitest and React/Vitest test suites.

## Run locally (no Docker required)

The application is run as two local processes: the Rails API and the Vite development server. **Docker, Redis, Sidekiq, PostgreSQL and Gradle are not required for the default local setup.** SQLite is used automatically in development.

### Prerequisites

Install the following before starting:

- Ruby 3.2 or newer (the repository pins Ruby 3.3.8 in `.ruby-version`).
- Bundler 2.x.
- Node.js 20 or newer and npm (Node.js 22 LTS is recommended).
- Git (optional, if cloning the repository).

Verify the tools are available:

```bash
ruby --version
bundle --version
node --version
npm --version
```

On Windows, install Ruby using a Windows-compatible Ruby distribution and install Node.js from <https://nodejs.org/>. After installation, close and reopen PowerShell so updated PATH entries are loaded. If PowerShell blocks the `npm.ps1` script because of its execution policy, use `npm.cmd` in the commands below; this avoids changing the machine-wide execution policy.

### 1. Prepare and seed the Rails backend

Open a terminal at the repository root, then run:

```bash
cd backend
bundle install
bundle exec rails db:prepare
bundle exec rails db:seed
```

`db:prepare` creates/prepares the development SQLite database and applies migrations. `db:seed` creates the HR Manager demo account and deterministic employee dataset. Seeding is designed to be repeatable and does not delete existing application data.

Start the API in this same terminal and leave it running:

```bash
bundle exec rails s -p 3000
```

The API is available at <http://localhost:3000>; its health endpoint is <http://localhost:3000/up>.

### 2. Install and start the React frontend

Open a **second terminal** at the repository root:

```bash
cd frontend
npm install
npm run dev
```

On Windows PowerShell, use the `.cmd` executable if `npm` is blocked by the PowerShell script execution policy:

```powershell
cd frontend
npm.cmd install
npm.cmd run dev
```

Vite prints the local URL when it starts. The default URL is <http://localhost:5173>. Keep both terminals running while using the application.

### Windows PowerShell: complete command sequence

From the extracted repository directory, use two PowerShell windows. In the first window:

```powershell
cd backend
bundle install
bundle exec rails db:prepare
bundle exec rails db:seed
bundle exec rails s -p 3000
```

In the second window:

```powershell
cd frontend
npm.cmd install
npm.cmd run dev
```

If `node` works but `npm` reports that `npm.ps1` cannot be loaded because script execution is disabled, use `npm.cmd` as shown above. Do not weaken the system execution policy just to run this project.

### Demo login

- Email: `hr.manager@acme.example`
- Password: `ChangeMe123!`

These credentials are for local assessment/demo use only. Do not use them in a deployed or production environment. Configure a strong `SEED_ADMIN_PASSWORD` before creating a production seed account.

### Reset local development data

This permanently deletes the local development database and recreates it. Run from `backend/` only when you intentionally want a clean reset:

```bash
bundle exec rails db:drop db:create db:migrate db:seed
```

On Windows PowerShell, the same `bundle exec rails ...` command works.

## Tests and frontend production build

Run backend tests from `backend/`:

```bash
bundle exec rails test
```

Run frontend tests and build from `frontend/`:

```bash
npm test
npm run build
```

In Windows PowerShell, use `npm.cmd test` and `npm.cmd run build` if required.

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

## Runtime and infrastructure notes

- The documented local workflow runs Rails and Vite directly; no container runtime is needed.
- The default Active Job adapter is in-process (`:async`); no background worker is needed for the core workflows.
- The default cache is Rails' in-memory cache. Redis is optional for a multi-instance deployment and can be configured with `CACHE_REDIS_URL`.
- Local development uses SQLite. Production should use PostgreSQL through `DATABASE_URL`.
- The backend includes `tzinfo-data` so time-zone data is available on Windows platforms.

## Product and engineering artifacts

- [`REQUIREMENTS.md`](REQUIREMENTS.md) — product requirements and acceptance criteria.
- [`docs/requirements.md`](docs/requirements.md) — concise product requirements.
- [`docs/architecture.md`](docs/architecture.md) — system design and data model.
- [`docs/decisions.md`](docs/decisions.md) — trade-offs and deliberate exclusions.
- [`docs/ai-usage.md`](docs/ai-usage.md) — AI-assisted workflow and verification approach.
- [`docs/performance-security.md`](docs/performance-security.md) — security and scale considerations.
- [`docs/demo-script.md`](docs/demo-script.md) — 3–5 minute walkthrough outline.
- [`docs/verification.md`](docs/verification.md) — verification status and known limitations.
- [`docs/deployment.md`](docs/deployment.md) — deployment guidance.

## Deployment

The local run instructions above are not deployment instructions. For a hosted environment, use a managed PostgreSQL database, configure production secrets and CORS, deploy the Rails API and React static build separately, and follow [`docs/deployment.md`](docs/deployment.md). This source package does not include a live deployment.

## Assessment scope and caveats

This is an assessment-grade salary-management application, not a certified payroll processor. It deliberately does not calculate statutory deductions, taxes, exchange rates, payslips, bank transfers or country-specific compliance. Those require validated jurisdictional rules and specialist review. A production rollout also needs organization-specific identity-provider integration, formal role administration, security review, backups, monitoring and a privacy/legal assessment.
