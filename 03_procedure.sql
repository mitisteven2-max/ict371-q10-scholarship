-- ICT371 Q10 (c): pr_assess_application
CREATE OR REPLACE PROCEDURE pr_assess_application(p_application_id INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    v_app      applications%ROWTYPE;
    v_eligible BOOLEAN;
BEGIN
    -- Lock the row so the same application cannot be assessed twice concurrently
    SELECT * INTO v_app
    FROM applications
    WHERE application_id = p_application_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Application % does not exist', p_application_id;
    END IF;
    IF v_app.status <> 'PENDING' THEN
        RAISE EXCEPTION 'Application % was already assessed (status: %)',
            p_application_id, v_app.status;
    END IF;

    v_eligible := fn_scholarship_eligible(
        v_app.age_at_application, v_app.monthly_income, v_app.average_mark);

    UPDATE applications
    SET status = CASE WHEN v_eligible THEN 'APPROVED' ELSE 'REJECTED' END
    WHERE application_id = p_application_id;
END;
$$;
