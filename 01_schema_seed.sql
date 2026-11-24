-- ICT371 Q10 (a): tables, constraints, six PENDING applications
DROP TABLE IF EXISTS decision_audit, applications, students CASCADE;

CREATE TABLE students (
    student_id      SERIAL PRIMARY KEY,
    student_number  VARCHAR(20)  NOT NULL UNIQUE,
    full_name       VARCHAR(100) NOT NULL
);

CREATE TABLE applications (
    application_id      SERIAL PRIMARY KEY,
    student_id          INTEGER       NOT NULL REFERENCES students(student_id),
    age_at_application  INTEGER       NOT NULL CHECK (age_at_application > 0),
    monthly_income      NUMERIC(12,2) NOT NULL CHECK (monthly_income >= 0),
    average_mark        NUMERIC(5,2)  NOT NULL CHECK (average_mark BETWEEN 0 AND 100),
    submitted_on        DATE          NOT NULL,
    status              VARCHAR(10)   NOT NULL DEFAULT 'PENDING',
    CONSTRAINT ck_status CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED'))
);

CREATE TABLE decision_audit (
    audit_id        SERIAL PRIMARY KEY,
    application_id  INTEGER     NOT NULL REFERENCES applications(application_id),
    old_status      VARCHAR(10) NOT NULL,
    new_status      VARCHAR(10) NOT NULL,
    changed_at      TIMESTAMP   NOT NULL DEFAULT now()
);

INSERT INTO students (student_number, full_name) VALUES
    ('202406001', 'Thandiwe Mwansa'),
    ('202406002', 'Chola Mutale'),
    ('202406003', 'Yamikani Phiri');

-- Eligible: age 18-25, income <= 3000, mark >= 70
INSERT INTO applications
    (student_id, age_at_application, monthly_income, average_mark, submitted_on, status) VALUES
    (1, 20, 2500.00, 85.00, DATE '2026-10-02', 'PENDING'),   -- 1 qualifies
    (1, 18, 3000.00, 70.00, DATE '2026-10-05', 'PENDING'),   -- 2 boundary: all three limits (qualifies)
    (2, 25, 3000.00, 70.00, DATE '2026-10-09', 'PENDING'),   -- 3 boundary: age 25 (qualifies)
    (2, 17, 1000.00, 90.00, DATE '2026-10-14', 'PENDING'),   -- 4 too young
    (3, 22, 3000.01, 80.00, DATE '2026-10-20', 'PENDING'),   -- 5 income just over
    (3, 21, 1500.00, 69.99, DATE '2026-10-27', 'PENDING');   -- 6 mark just under
