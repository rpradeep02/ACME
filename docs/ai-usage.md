# AI-assisted development notes

## Intended use

AI is used to accelerate scaffolding, enumerate edge cases, draft tests/documentation and review implementation risks. It is not treated as an authority for payroll law, currency conversion, security certification or production readiness.

## Prompts / working instructions

- “Act as a senior Rails engineer. Design a small salary-management domain for 10,000 employees. Keep historical salary periods, prevent overlaps, and explain transaction/concurrency behavior.”
- “Review the employee directory API for N+1 queries, unbounded result sets, unsafe sorting, SQL injection and accidental exposure of salary history.”
- “Generate deterministic Minitest cases for salary interval boundaries, invalid currency, authentication and pagination limits.”
- “Review the React flows for loading, empty and API error states, keyboard labels and accidental mixing of currencies.”
- “Challenge the product scope: identify country/payroll compliance assumptions that should not be guessed.”

## Verification protocol

1. Inspect every generated diff; do not accept unexplained code.
2. Run Rails tests and frontend tests locally; add regression tests for any corrected issue.
3. Run seed twice to check repeatability, then verify exactly 10,000 employee codes.
4. Exercise the browser workflow against the seeded API.
5. Run security/performance review separately; tests passing do not imply production certification.

## Human decisions retained

- Gross annual salary is stored; net pay and tax are excluded.
- Currency totals remain separated absent a rate source and date.
- Salary history is retained; no delete endpoint is exposed.
- Employee directory pages and filters are server-side.
