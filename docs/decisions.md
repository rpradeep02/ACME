# Engineering decisions and trade-offs

| Decision | Rationale | Trade-off |
|---|---|---|
| Rails JSON API + React SPA | Role-aligned backend and explicit separation of domain/API from UI | Two runtimes to deploy and monitor |
| SQLite locally, PostgreSQL in production | Frictionless local assessment setup while using a production-grade relational DB | SQL behavior and migration parity must be checked against PostgreSQL before launch |
| JWT bearer auth | Simple API-native auth for a single HR persona and SPA | Token revocation is not immediate; production should prefer SSO/OIDC and short sessions |
| Effective-dated salary rows | Retains auditable compensation history and supports future-dated changes | Requires interval validation and clear inclusive date semantics |
| Currency-separated totals | Prevents mathematically invalid totals without FX rates and valuation date | No single global payroll figure |
| Server-side pagination/filtering | Avoids shipping all 10,000 employees to the browser | More API query code and pagination state |
| Deactivation rather than hard deletion | Preserves historical references and audit trail | Requires status filters in day-to-day work |
| No tax/net pay calculations | No country rules or legal assumptions invented | This is salary administration, not a payroll engine |

## Known next steps before real production use

1. Replace demo JWT login with the organization's OIDC/SSO and MFA.
2. Add fine-grained scopes (view salary vs edit salary), approval workflow and immutable tamper-evident audit storage.
3. Run PostgreSQL integration tests and load/performance tests on representative hardware.
4. Define data retention, encryption/key management, access reviews and breach response with security/legal teams.
5. Specify and validate localized compensation rules before considering net pay or compliance modules.

## Caching and asynchronous work

The dashboard is an aggregate read model, so a short-lived Redis cache avoids repeating the same grouped SQL on every HR page load. Successful employee/salary writes invalidate the snapshot and enqueue a low-priority Sidekiq refresh. The request path does not wait for the aggregate refresh. The next read can rebuild the cache if the worker is delayed. A two-minute TTL is a safety net for missed invalidations. Development and test use memory cache to avoid requiring Redis for basic local work; production uses shared Redis so web and worker processes see the same cache.

Sidekiq is used through Active Job to keep job callers framework-agnostic. The sample background job refreshes an aggregate snapshot; real integrations such as payroll-provider exports or notification delivery should also be idempotent, retry-safe, and observable before production use.

## Query shape

Employee index preloads a single date-scoped current salary association rather than loading all salary history for every row. The detail endpoint loads full history by design. Dashboard payroll totals and counts are grouped in SQL by currency, avoiding per-currency N+1 count queries and preventing invalid cross-currency arithmetic.
