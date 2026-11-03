# Verification status for this delivery

## Local setup reported by the submitter

The submitter successfully prepared the Rails development database on Windows using Bundler and Rails commands, without Docker. During setup, two Windows compatibility issues were identified and addressed in the source: the memory-cache size is expressed as an integer byte count rather than relying on `Integer#megabytes`, and `tzinfo-data` is included so TZInfo has time-zone data on Windows.

PowerShell may block the `npm.ps1` shim under restrictive execution policies even when Node.js is installed. In that situation, use `npm.cmd install`, `npm.cmd run dev`, `npm.cmd test` and `npm.cmd run build`. This avoids changing the machine execution policy.

## Reproducible local startup

Backend, from `backend/`:

```powershell
bundle install
bundle exec rails db:prepare
bundle exec rails db:seed
bundle exec rails s -p 3000
```

Frontend, from `frontend/` in a second terminal:

```powershell
npm.cmd install
npm.cmd run dev
```

Open <http://localhost:5173>; the API health endpoint is <http://localhost:3000/up>. Both processes must remain running.

## Checks completed in the authoring environment

- Ruby parser accepted all 39 Ruby files (`ruby -c`).
- CI and database YAML files parsed successfully at the time of the original implementation.
- Frontend `package.json` parsed successfully.
- `git diff --check` passed for the original implementation.
- An unauthenticated `/up` health-check integration test was added.

## Checks not independently verified in this authoring environment

The authoring environment did not have the project's Ruby gems or frontend dependencies installed. Therefore it did not independently execute the complete Rails test suite, frontend test suite, frontend production build or browser end-to-end flow. The submitter's successful local database preparation is user-reported; do not interpret it as proof that every test has passed. Run the following before final assessment submission:

```bash
# backend/
bundle exec rails test

# frontend/
npm test
npm run build
```

On Windows PowerShell, use `npm.cmd` for the frontend commands if `npm.ps1` is blocked.

The application has not been deployed from this workspace and no demo video has been recorded. Those steps require the submitter's hosting/repository accounts, secrets and screen-recording environment. See `deployment.md` and `demo-script.md`.

## Runtime simplification

The default local workflow runs the Rails API and Vite frontend directly as separate processes. Redis and a background worker are not local prerequisites. Rails uses the in-process Active Job adapter and memory cache; an optional shared Redis cache can be configured for multi-instance deployments.
