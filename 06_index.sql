-- ICT371 Q10 (f): index for status + submitted_on range searches
-- status (equality) first, submitted_on (range) second.
CREATE INDEX IF NOT EXISTS idx_applications_status_submitted
    ON applications (status, submitted_on);

ANALYZE applications;
SET enable_seqscan = off;   -- tiny table: force the planner to show the index

EXPLAIN
SELECT application_id, student_id, submitted_on
FROM applications
WHERE status = 'PENDING'
  AND submitted_on BETWEEN DATE '2026-10-01' AND DATE '2026-10-31';

RESET enable_seqscan;
