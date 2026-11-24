# ICT371 Q10 - Scholarship Application Assessment

**Student:** Steven Miti (202405283)  
**DBMS:** PostgreSQL 13+ with the pg_cron extension

## How to run
Use a fresh database for this question (several questions share table names such as `students`):

```bash
createdb ict371_q10
psql -d ict371_q10 -f run_all.sql
```

Files run in order: schema, function, procedure, trigger, view, index, scheduled job, data load, tests.
The data load (`08_load_data.sql`) runs after the trigger/procedure exist, as the question requires.

| Part | File |
|------|------|
| (a) Tables + seed data | `01_schema_seed.sql`, `08_load_data.sql` |
| (b) Function | `02_function.sql` |
| (c) Procedure | `03_procedure.sql` |
| (d) Trigger | `04_trigger.sql` |
| (e) View | `05_view.sql` |
| (f) Index + EXPLAIN | `06_index.sql` |
| (g) Scheduled job | `07_scheduled_job.sql` |
| Demonstration queries | `09_tests.sql` |

## Index
`idx_applications_status_submitted ON applications (status, submitted_on)`

The search is status = 'X' within a submitted_on range: equality column first, range column second, so matching rows sit together in date order.

## Design notes
- Eligibility: age 18-25 inclusive, income <= K3,000, average mark >= 70.
- pr_assess_pending selects only PENDING rows, so reruns never reassess or duplicate audit entries.
- Seed data includes boundary cases (18/25, K3000/K3000.01, 70/69.99).

## Output
_Paste screenshots / output of `09_tests.sql` and the `EXPLAIN` plan here._
