# Product requirements — ACME Payroll

**Persona:** HR Manager · **Organization:** 10,000 employees across multiple countries

## Goal
Replace spreadsheet-based salary administration with a secure source of truth. HR must maintain employee and salary records, inspect compensation history, and answer basic workforce/payroll questions from one web application.

## Scope and features

- **Access:** authenticated HR Manager access; all sensitive endpoints require a valid token.
- **Employee directory:** searchable, filterable and server-paginated list (country, department, status, currency); create and update employee details; view an employee profile.
- **Salary history:** annual gross base salary in an ISO currency, with an effective date and preserved history. Overlapping salary periods are rejected; when a new period supersedes an open-ended prior period, the prior period ends the day before the new one begins.
- **Insights:** total/active headcount, headcount by country and annual payroll by currency. No aggregate combines different currencies.
- **Auditability:** log actor, action, target and timestamp for employee and salary mutations.
- **Experience:** responsive React UI, clear loading/error/empty states, and predictable pagination.
- **Scale validation:** seed exactly 10,000 deterministic employee records.

## Deliberately out of scope (and why)

- **Net pay, tax and statutory deductions:** jurisdiction-specific rules change; incorrect calculations could harm employees. Store gross annual base salary only.
- **FX conversion/global grand total:** no trusted rate source or valuation date was specified. Report totals separately by currency.
- **Payroll runs, bank transfers, payslips and benefits:** financial integrations and compliance need a separate scope and security review.
- **Self-service, multiple roles and approvals:** persona is the HR Manager; additional access rules need stakeholder input.
- **Bulk spreadsheet import/export:** robust mapping, deduplication and error recovery deserve a separately tested migration workflow.
- **Hard deletion:** deactivate employees and retain salary history to preserve auditability.

## Acceptance criteria

HR can authenticate; search a 10,000-person directory; filter and paginate results; view salary history; create/update employees; record a future/current salary change; and view headcount and currency-separated payroll insights. Core domain rules, authentication, authorization and API behavior are covered by deterministic tests. Setup, seed, deployment and demo steps are documented.
