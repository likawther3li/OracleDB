-- ===============================================
-- SECTION 09 - TRIGGERS
-- Easy and Medium Tasks Only
-- ===============================================
-- =====================================================
-- TASK 1: BEFORE INSERT - Auto Assign emp_ID
-- =====================================================

SET SERVEROUTPUT ON;

-- Create EMP_SEQ if it does not already exist
BEGIN
    EXECUTE IMMEDIATE '
        CREATE SEQUENCE EMP_SEQ
        START WITH 1000
        INCREMENT BY 1
    ';

    DBMS_OUTPUT.PUT_LINE('EMP_SEQ created.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN
            DBMS_OUTPUT.PUT_LINE('EMP_SEQ already exists.');
        ELSE
            RAISE;
        END IF;
END;
/

-- Create trigger to auto assign emp_ID
CREATE OR REPLACE TRIGGER TRG_EMP_ID
BEFORE INSERT ON EMPLOYEE
FOR EACH ROW
BEGIN
    IF :NEW.emp_ID IS NULL THEN
        :NEW.emp_ID := EMP_SEQ.NEXTVAL;
    END IF;
END;
/
-- =====================================================
-- TEST TASK 1: TRG_EMP_ID
-- =====================================================

SET SERVEROUTPUT ON;

SAVEPOINT before_trg_emp_id_test;

-- Insert employee without emp_ID
INSERT INTO EMPLOYEE (
    fname,
    lname,
    gender,
    age,
    contact_add,
    emp_email,
    emp_pass,
    job_ID,
    salary_ID
)
VALUES (
    'Trigger',
    'Test',
    'F',
    27,
    'Muscat',
    'trigger.task1@test.com',
    'pass123',
    1,
    1
);

-- Verify emp_ID was auto assigned
SELECT emp_ID,
       fname,
       lname,
       emp_email,
       job_ID,
       salary_ID
FROM EMPLOYEE
WHERE emp_email = 'trigger.task1@test.com';

-- Rollback test data
ROLLBACK TO before_trg_emp_id_test;

-- Final check: employee should be removed
SELECT COUNT(*) AS test_employee_count
FROM EMPLOYEE
WHERE emp_email = 'trigger.task1@test.com';
-- =====================================================
-- TASK 2: AFTER INSERT - Welcome Log
-- =====================================================

SET SERVEROUTPUT ON;

-- Create EMPLOYEE_LOG table if it does not already exist
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE EMPLOYEE_LOG (
            log_ID NUMBER PRIMARY KEY,
            emp_ID NUMBER,
            action VARCHAR2(50),
            log_timestamp DATE
        )
    ';

    DBMS_OUTPUT.PUT_LINE('EMPLOYEE_LOG table created.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN
            DBMS_OUTPUT.PUT_LINE('EMPLOYEE_LOG table already exists.');
        ELSE
            RAISE;
        END IF;
END;
/

-- Create EMPLOYEE_LOG_SEQ if it does not already exist
BEGIN
    EXECUTE IMMEDIATE '
        CREATE SEQUENCE EMPLOYEE_LOG_SEQ
        START WITH 1
        INCREMENT BY 1
    ';

    DBMS_OUTPUT.PUT_LINE('EMPLOYEE_LOG_SEQ created.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN
            DBMS_OUTPUT.PUT_LINE('EMPLOYEE_LOG_SEQ already exists.');
        ELSE
            RAISE;
        END IF;
END;
/

-- Create trigger to insert welcome log after new employee insert
CREATE OR REPLACE TRIGGER TRG_EMP_WELCOME_LOG
AFTER INSERT ON EMPLOYEE
FOR EACH ROW
BEGIN
    INSERT INTO EMPLOYEE_LOG (
        log_ID,
        emp_ID,
        action,
        log_timestamp
    )
    VALUES (
        EMPLOYEE_LOG_SEQ.NEXTVAL,
        :NEW.emp_ID,
        'NEW HIRE',
        SYSDATE
    );
END;
/
-- =====================================================
-- TEST TASK 2: TRG_EMP_WELCOME_LOG
-- =====================================================

SET SERVEROUTPUT ON;

SAVEPOINT before_trg_welcome_log_test;

-- Insert employee to test welcome log trigger
INSERT INTO EMPLOYEE (
    fname,
    lname,
    gender,
    age,
    contact_add,
    emp_email,
    emp_pass,
    job_ID,
    salary_ID
)
VALUES (
    'Welcome',
    'LogTest',
    'M',
    29,
    'Muscat',
    'welcome.logtest@test.com',
    'pass123',
    2,
    2
);

-- Verify employee was inserted
SELECT emp_ID,
       fname,
       lname,
       emp_email
FROM EMPLOYEE
WHERE emp_email = 'welcome.logtest@test.com';

-- Verify log was inserted automatically
SELECT l.log_ID,
       l.emp_ID,
       l.action,
       l.log_timestamp
FROM EMPLOYEE_LOG l
JOIN EMPLOYEE e
    ON l.emp_ID = e.emp_ID
WHERE e.emp_email = 'welcome.logtest@test.com';

-- Rollback test data
ROLLBACK TO before_trg_welcome_log_test;

-- Final check: employee should be removed
SELECT COUNT(*) AS test_employee_count
FROM EMPLOYEE
WHERE emp_email = 'welcome.logtest@test.com';

-- Final check: related log should also be removed
SELECT COUNT(*) AS test_log_count
FROM EMPLOYEE_LOG l
WHERE l.emp_ID >= 1000;

-- =====================================================
-- FINAL TEST TASK 2: Insert 2 Employees and Check Log
-- =====================================================

SET SERVEROUTPUT ON;

SAVEPOINT before_trg_welcome_log_test_2;

-- Insert first employee
INSERT INTO EMPLOYEE (
    fname,
    lname,
    gender,
    age,
    contact_add,
    emp_email,
    emp_pass,
    job_ID,
    salary_ID
)
VALUES (
    'WelcomeOne',
    'LogTest',
    'M',
    29,
    'Muscat',
    'welcome.one@test.com',
    'pass123',
    2,
    2
);

-- Insert second employee
INSERT INTO EMPLOYEE (
    fname,
    lname,
    gender,
    age,
    contact_add,
    emp_email,
    emp_pass,
    job_ID,
    salary_ID
)
VALUES (
    'WelcomeTwo',
    'LogTest',
    'F',
    28,
    'Muscat',
    'welcome.two@test.com',
    'pass123',
    2,
    2
);

-- Verify two employees were inserted
SELECT emp_ID,
       fname,
       lname,
       emp_email
FROM EMPLOYEE
WHERE emp_email IN ('welcome.one@test.com', 'welcome.two@test.com')
ORDER BY emp_ID;

-- Verify two NEW HIRE logs were inserted automatically
SELECT l.log_ID,
       l.emp_ID,
       e.fname,
       e.lname,
       l.action,
       l.log_timestamp
FROM EMPLOYEE_LOG l
JOIN EMPLOYEE e
    ON l.emp_ID = e.emp_ID
WHERE e.emp_email IN ('welcome.one@test.com', 'welcome.two@test.com')
ORDER BY l.log_ID;

-- Rollback test data
ROLLBACK TO before_trg_welcome_log_test_2;

-- Final check
SELECT COUNT(*) AS test_employee_count
FROM EMPLOYEE
WHERE emp_email IN ('welcome.one@test.com', 'welcome.two@test.com');

-- =====================================================
-- TASK 3: BEFORE UPDATE - Prevent Salary Decrease
-- =====================================================

SET SERVEROUTPUT ON;

CREATE OR REPLACE TRIGGER TRG_PREVENT_SALARY_CUT
BEFORE UPDATE OF amount ON SALARY_BONUS
FOR EACH ROW
BEGIN
    IF :NEW.amount < :OLD.amount THEN
        RAISE_APPLICATION_ERROR(-20001, 'Salary decrease is not allowed.');
    END IF;
END;
/
-- =====================================================
-- TEST TASK 3: TRG_PREVENT_SALARY_CUT
-- =====================================================

SET SERVEROUTPUT ON;

SAVEPOINT before_salary_cut_test;

-- Check salary before update
SELECT salary_ID,
       job_ID,
       amount,
       annual,
       bonus
FROM SALARY_BONUS
WHERE job_ID = 3;


-- Test salary decrease: should be blocked
BEGIN
    UPDATE SALARY_BONUS
    SET amount = 4000
    WHERE job_ID = 3;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected salary decrease error: ' || SQLERRM);
END;
/


-- Check salary after failed decrease
SELECT salary_ID,
       job_ID,
       amount,
       annual,
       bonus
FROM SALARY_BONUS
WHERE job_ID = 3;


-- Test salary increase: should be allowed
UPDATE SALARY_BONUS
SET amount = 4600
WHERE job_ID = 3;


-- Check salary after allowed increase
SELECT salary_ID,
       job_ID,
       amount,
       annual,
       bonus
FROM SALARY_BONUS
WHERE job_ID = 3;


-- Rollback test changes
ROLLBACK TO before_salary_cut_test;


-- Final check after rollback
SELECT salary_ID,
       job_ID,
       amount,
       annual,
       bonus
FROM SALARY_BONUS
WHERE job_ID = 3;
-- =====================================================
-- TASK 4: AFTER DELETE - Archive Deleted Employees
-- =====================================================

SET SERVEROUTPUT ON;

-- Create EMPLOYEE_ARCHIVE table if it does not already exist
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE EMPLOYEE_ARCHIVE (
            emp_ID NUMBER,
            fname VARCHAR2(50),
            lname VARCHAR2(50),
            gender CHAR(1),
            age NUMBER,
            contact_add VARCHAR2(100),
            emp_email VARCHAR2(100),
            emp_pass VARCHAR2(50),
            job_ID NUMBER,
            salary_ID NUMBER,
            archived_at DATE,
            archived_by VARCHAR2(50)
        )
    ';

    DBMS_OUTPUT.PUT_LINE('EMPLOYEE_ARCHIVE table created.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN
            DBMS_OUTPUT.PUT_LINE('EMPLOYEE_ARCHIVE table already exists.');
        ELSE
            RAISE;
        END IF;
END;
/

-- Create trigger to archive deleted employees
CREATE OR REPLACE TRIGGER TRG_ARCHIVE_EMPLOYEE
AFTER DELETE ON EMPLOYEE
FOR EACH ROW
BEGIN
    INSERT INTO EMPLOYEE_ARCHIVE (
        emp_ID,
        fname,
        lname,
        gender,
        age,
        contact_add,
        emp_email,
        emp_pass,
        job_ID,
        salary_ID,
        archived_at,
        archived_by
    )
    VALUES (
        :OLD.emp_ID,
        :OLD.fname,
        :OLD.lname,
        :OLD.gender,
        :OLD.age,
        :OLD.contact_add,
        :OLD.emp_email,
        :OLD.emp_pass,
        :OLD.job_ID,
        :OLD.salary_ID,
        SYSDATE,
        USER
    );
END;
/

-- =====================================================
-- TEST TASK 4: TRG_ARCHIVE_EMPLOYEE
-- =====================================================

SET SERVEROUTPUT ON;

SAVEPOINT before_archive_employee_test;

-- Insert temporary employee
INSERT INTO EMPLOYEE (
    fname,
    lname,
    gender,
    age,
    contact_add,
    emp_email,
    emp_pass,
    job_ID,
    salary_ID
)
VALUES (
    'Archive',
    'Test',
    'M',
    31,
    'Muscat',
    'archive.test@test.com',
    'pass123',
    1,
    1
);

-- Verify employee exists before delete
SELECT emp_ID,
       fname,
       lname,
       emp_email
FROM EMPLOYEE
WHERE emp_email = 'archive.test@test.com';

-- Delete employee to activate archive trigger
DELETE FROM EMPLOYEE
WHERE emp_email = 'archive.test@test.com';

-- Verify employee was deleted
SELECT COUNT(*) AS employee_count_after_delete
FROM EMPLOYEE
WHERE emp_email = 'archive.test@test.com';

-- Verify employee was archived automatically
SELECT emp_ID,
       fname,
       lname,
       emp_email,
       job_ID,
       salary_ID,
       archived_by
FROM EMPLOYEE_ARCHIVE
WHERE emp_email = 'archive.test@test.com';

-- Rollback test changes
ROLLBACK TO before_archive_employee_test;

-- Final check: archive test record should be removed
SELECT COUNT(*) AS archive_count_after_rollback
FROM EMPLOYEE_ARCHIVE
WHERE emp_email = 'archive.test@test.com';
-- TASK 5 is Hard and is not included in this solution.