-- (b) boundaries
SELECT fn_scholarship_eligible(18, 3000, 70)      AS lower_boundary,   -- true
       fn_scholarship_eligible(25, 3000, 70)      AS upper_age,        -- true
       fn_scholarship_eligible(17, 1000, 90)      AS too_young,        -- false
       fn_scholarship_eligible(22, 3000.01, 80)   AS income_over,      -- false
       fn_scholarship_eligible(21, 1500, 69.99)   AS mark_under;       -- false
DO $$ BEGIN PERFORM fn_scholarship_eligible(NULL, 1000, 80);
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Rejected: %', SQLERRM; END $$;
DO $$ BEGIN PERFORM fn_scholarship_eligible(20, -1, 80);
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Rejected: %', SQLERRM; END $$;
DO $$ BEGIN PERFORM fn_scholarship_eligible(0, 1000, 80);
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Rejected: %', SQLERRM; END $$;
DO $$ BEGIN PERFORM fn_scholarship_eligible(20, 1000, 101);
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Rejected: %', SQLERRM; END $$;

-- (c) assess one, then rejections
CALL pr_assess_application(1);                        -- APPROVED
DO $$ BEGIN CALL pr_assess_application(1);            -- already assessed
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Rejected: %', SQLERRM; END $$;
DO $$ BEGIN CALL pr_assess_application(999);          -- unknown
EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Rejected: %', SQLERRM; END $$;

-- (d) a no-change update creates no audit row
UPDATE applications SET status = status WHERE application_id = 1;
SELECT * FROM decision_audit ORDER BY audit_id;       -- 1 row so far

-- (g) assess the rest; rerun changes nothing
CALL pr_assess_pending();
SELECT COUNT(*) AS audit_rows FROM decision_audit;    -- 6
CALL pr_assess_pending();
SELECT COUNT(*) AS audit_rows_after_rerun FROM decision_audit;   -- still 6
SELECT application_id, status FROM applications ORDER BY 1;      -- 1,2,3 APPROVED; 4,5,6 REJECTED

-- (e)
SELECT * FROM v_approved_applicants;

-- (f) EXPLAIN again now that the tables contain data
ANALYZE applications;
SET enable_seqscan = off;   -- tiny table: force the planner to show the index

EXPLAIN
SELECT application_id, student_id, submitted_on
FROM applications
WHERE status = 'PENDING'
  AND submitted_on BETWEEN DATE '2026-10-01' AND DATE '2026-10-31';

RESET enable_seqscan;
