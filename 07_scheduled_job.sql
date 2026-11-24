-- ICT371 Q10 (g): pr_assess_pending + pg_cron
-- Only PENDING rows are selected, so completed applications are never
-- reassessed and no duplicate audit rows are created on a rerun.
CREATE OR REPLACE PROCEDURE pr_assess_pending()
LANGUAGE plpgsql
AS $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT application_id
        FROM applications
        WHERE status = 'PENDING'
        ORDER BY application_id
    LOOP
        CALL pr_assess_application(r.application_id);
    END LOOP;
END;
$$;

CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Every Monday at 08:00
SELECT cron.schedule(
    'q10_assess_pending_weekly',
    '0 8 * * 1',
    $$CALL pr_assess_pending()$$
);

-- Inspect:
-- SELECT jobid, jobname, schedule, command FROM cron.job;
-- SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 5;
