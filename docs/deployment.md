# Deployment guide

The application is deployed as two services: a Rails API and a React static site. The local development workflow does not require Docker. The backend is configured to use PostgreSQL when `DATABASE_URL` is present. A practical assessment deployment is:

1. Push the repository to a GitHub repository.
2. Provision managed PostgreSQL (Render, Railway, or equivalent).
3. Deploy `backend/` as a Rails web service. Set `RAILS_ENV=production`, `DATABASE_URL`, `SECRET_KEY_BASE`, `FRONTEND_ORIGIN`, `RAILS_LOG_TO_STDOUT=true`, and `SEED_ADMIN_PASSWORD`. Build command: `bundle install && bundle exec rails db:prepare`; start command: `bundle exec puma -C config/puma.rb`.
4. Deploy `frontend/` as a static site. Build command: `npm install && npm run build`; publish directory: `dist`. Set `VITE_API_BASE_URL` to the deployed API origin.
5. Run `rails db:seed` once in a controlled release/console task to create the assessment account and 10,000 sample employees. Do not use the demo password in a real environment.
6. Add the exact frontend origin to `FRONTEND_ORIGIN`, redeploy the API, then run smoke checks below.

## Production environment variables

- `DATABASE_URL`: PostgreSQL URL.
- `SECRET_KEY_BASE`: unique high-entropy Rails secret.
- `FRONTEND_ORIGIN`: exact trusted SPA origin (no wildcard).
- `SEED_ADMIN_PASSWORD`: strong initial HR password. Rotate after first login; do not reuse in another environment.
- `RAILS_ENV=production`, `RAILS_LOG_TO_STDOUT=true`.

## Smoke checks

- `GET /up` returns 200.
- Sign in via `POST /api/v1/session` and confirm a token is returned.
- `GET /api/v1/dashboard` returns headcount and currency-separated totals.
- Search `EMP10000` and confirm the API returns the matching employee.
- Create a salary change and confirm history shows both periods, with no overlap.
- Confirm the frontend can make authenticated calls from its deployed origin.

A deployment is not included in this source package: it needs an account, repository, database, environment secrets and deployment permissions.
