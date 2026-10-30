# ACME Payroll — Product requirements

**Owner:** HR Manager · **Users:** HR Manager (single privileged role in this assessment) · **Scale:** 10,000 employees, multiple countries and currencies

## Goal

Replace spreadsheet-based employee salary administration with one secure, searchable source of truth. An HR Manager must be able to maintain employee and salary records, inspect a person's compensation history, and answer basic workforce/payroll questions without manually reconciling spreadsheets.

## In scope

1. **Secure HR access.** Sign in as an authorized HR Manager; all employee, salary and dashboard endpoints require authentication.
2. **Employee directory.** Browse 10,000 seeded employees with server-side search, pagination and filters for country, department, employment status and currency. View and update employee details; create a new employee with an opening salary.
3. **Salary lifecycle.** Record annual base salary with ISO currency code and effective date. Preserve prior salary records and show chronological history. Prevent overlapping salary periods; a new effective-dated salary closes the previous open period on the preceding day.
4. **Management insights.** Show total/active headcount, country distribution and annual payroll totals by currency. Filter/search the directory to investigate a country, department or employee.
5. **Traceability.** Record who performed employee and salary changes, when they occurred, and the action/target.
6. **Usability.** Responsive web UI, clear empty/loading/error states, accessible labels and predictable pagination.

## Deliberately out of scope

- **Net-pay, tax and statutory calculations:** rules differ by country and change frequently; implementing guessed rules would be unsafe. The product stores annual gross base salary only.
- **Currency conversion and global grand total:** no trusted exchange-rate source/date is specified. Totals are grouped by currency, never summed together.
- **Payroll execution, bank files, payslips and benefits:** these introduce financial integrations and legal/security obligations beyond salary administration.
- **Employee self-service and manager approvals:** the stated persona is the HR Manager; additional roles/workflows need validated access policies.
- **Bulk Excel import/export:** valuable migration work, but robust mapping, validation, duplicate resolution and privacy controls deserve a separate workflow. The seeded dataset validates scale for the exercise.
- **Hard delete of employees or salary history:** records are deactivated instead to preserve traceability and historical reporting.

## Success criteria

- HR Manager can sign in, find an employee among 10,000 records, view salary history, edit profile details, add a salary change, and see dashboard aggregates.
- Directory queries are paginated on the server (maximum 100 rows/page); common search/filter fields are indexed.
- Payroll values remain separated by currency, and salary periods cannot overlap.
- Core business rules and API authorization have deterministic automated tests.
- Setup, seed, test and deployment steps are documented.
