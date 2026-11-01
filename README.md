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

## Run the complete app (recommended)

Prerequisites: Docker Desktop with Docker Compose, and an internet connection for the first image/dependency download.

From the repository root:

```bash
docker compose up --build
```

Wait for the API health check to pass, then open <http://localhost:5173>. The API is available at <http://localhost:3000> and its health endpoint is <http://localhost:3000/up>. Compose installs the Ruby and Node dependencies, prepares the database, seeds the 10,000-employee demo dataset, and starts both servers. The SQLite database is stored in the backend `storage/` directory and survives container restarts.

Demo credentials (local development only):

- Email: `hr.manager@acme.example`
- Password: `ChangeMe123!`

Override the demo password before starting the stack:

```bash
SEED_ADMIN_PASSWORD='use-a-strong-local-password' docker compose up --build
```

Stop the stack with `Ctrl+C`; use `docker compose down` to remove containers. To reset the local database and reseed from scratch, run:

```bash
docker compose run --rm api bundle exec rails db:drop db:create db:migrate db:seed
```

### Run without Docker

Prerequisites: Ruby 3.2+, Bundler, Node 20+, npm.

Terminal 1:

```bash
cd backend
bundle install
mkdir -p storage
bin/rails db:prepare db:seed
bin/rails server -p 3000
```

Terminal 2:

```bash
cd frontend
npm install
npm run dev
```

Open <http://localhost:5173>.

### Tests and production build

```bash
(cd backend && bundle exec rails test)
(cd frontend && npm test && npm run build)
```

The seed is deterministic and idempotent. It creates `EMP00001` through `EMP10000`, with one opening salary record per employee. Seeding does not delete existing application data.

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

## Product and engineering artifacts

- [`docs/requirements.md`](docs/requirements.md) — one-page product requirements.
- [`docs/architecture.md`](docs/architecture.md) — system design and data model.
- [`docs/decisions.md`](docs/decisions.md) — trade-offs and deliberate exclusions.
- [`docs/ai-usage.md`](docs/ai-usage.md) — AI-assisted workflow and verification.
- [`docs/performance-security.md`](docs/performance-security.md) — security and scale considerations.
- [`docs/demo-script.md`](docs/demo-script.md) — 3–5 minute walkthrough outline.
- [`docs/verification.md`](docs/verification.md) — exact checks completed and environment blockers.

## Important assessment caveats

This is an assessment-grade product foundation, not a certified payroll processor. It deliberately does not calculate statutory deductions, taxes, exchange rates, payslips, bank transfers, or country-specific compliance. Those require validated jurisdictional rules and specialist review. A production rollout also needs organization-specific identity provider integration, formal role administration, security review, backups, monitoring, and a privacy/legal assessment.


## Production-minded Rails implementation

- **No infrastructure trap:** the default app uses Rails' in-process Active Job adapter and memory cache. The dashboard and employee workflows do not require Redis or a Sidekiq worker to boot or run.
- **Optional scale-out:** set `CACHE_REDIS_URL` to share dashboard and rate-limit cache across multiple web instances. These are deployment options, not local prerequisites.
- **Caching:** dashboard aggregates are cached for two minutes and invalidated after successful writes. A cache miss recomputes the grouped SQL snapshot.
- **Query efficiency:** dashboard totals use grouped SQL aggregates; employee list pages preload only the current salary association, while detail views load salary history intentionally. Bullet detects N+1 queries in development/test and raises in tests.
- **Abuse protection:** Rack::Attack throttles session creation by client IP using the configured Rails cache.
- **Data integrity:** database indexes, foreign keys, check constraints, transactional salary changes, and immutable employee identifiers complement model validations.

## Deployment notes

The repository is ready to deploy but is not deployed from this workspace. See [`docs/deployment.md`](docs/deployment.md) for the recommended Render + managed PostgreSQL + static React deployment, production environment variables, and smoke checks. A real deployment requires an account, repository access, secrets, and hosting configuration.
