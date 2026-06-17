-- =============================================
-- SECTION 10 - SCHEDULER JOBS
-- Easy and Medium Tasks Only
-- =============================================
-- =====================================================
-- TASK 1: Simple One-Time Scheduler Job
-- =====================================================

SET SERVEROUTPUT ON;

BEGIN
    -- Drop job if it already exists
    BEGIN
        DBMS_SCHEDULER.DROP_JOB(
            job_name => 'JOB_GREET_EMPLOYEES',
            force    => TRUE
        );
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -27475 THEN
                RAISE;
            END IF;
    END;

    -- Create one-time job to run 2 minutes from now
    DBMS_SCHEDULER.CREATE_JOB(
        job_name   => 'JOB_GREET_EMPLOYEES',
        job_type   => 'PLSQL_BLOCK',
        job_action => q'[
            BEGIN
                DBMS_OUTPUT.PUT_LINE('Payroll System Initialized');

                INSERT INTO EMPLOYEE_LOG (
                    log_ID,
                    emp_ID,
                    action,
                    log_timestamp
                )
                VALUES (
                    EMPLOYEE_LOG_SEQ.NEXTVAL,
                    NULL,
                    'Payroll System Initialized',
                    SYSDATE
                );

                COMMIT;
            END;
        ]',
        start_date => SYSTIMESTAMP + INTERVAL '2' MINUTE,
        enabled    => TRUE,
        auto_drop  => FALSE
    );

    DBMS_OUTPUT.PUT_LINE('JOB_GREET_EMPLOYEES created successfully.');
END;
/

-- =====================================================
-- TEST TASK 1: Check Scheduler Job Result
-- =====================================================

-- Check job status
SELECT job_name,
       enabled,
       state,
       auto_drop
FROM USER_SCHEDULER_JOBS
WHERE job_name = 'JOB_GREET_EMPLOYEES';


-- Check if the job inserted the log message
SELECT log_ID,
       emp_ID,
       action,
       log_timestamp
FROM EMPLOYEE_LOG
WHERE action = 'Payroll System Initialized'
ORDER BY log_ID DESC;


-- Check scheduler run details
SELECT job_name,
       status,
       actual_start_date,
       run_duration,
       error#
FROM USER_SCHEDULER_JOB_RUN_DETAILS
WHERE job_name = 'JOB_GREET_EMPLOYEES'
ORDER BY log_date DESC;
-- =====================================================
-- TASK 2: Recurring Job - Daily Leave Report
-- =====================================================

SET SERVEROUTPUT ON;

BEGIN
    -- Drop job if it already exists
    BEGIN
        DBMS_SCHEDULER.DROP_JOB(
            job_name => 'JOB_DAILY_LEAVE_REPORT',
            force    => TRUE
        );
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -27475 THEN
                RAISE;
            END IF;
    END;

    -- Create recurring daily job
    DBMS_SCHEDULER.CREATE_JOB(
        job_name        => 'JOB_DAILY_LEAVE_REPORT',
        job_type        => 'PLSQL_BLOCK',
        job_action      => q'[
            DECLARE
                v_leave_count NUMBER;
            BEGIN
                SELECT COUNT(*)
                INTO v_leave_count
                FROM LEAVE
                WHERE TRUNC(leave_date) = TRUNC(SYSDATE);

                INSERT INTO EMPLOYEE_LOG (
                    log_ID,
                    emp_ID,
                    action,
                    log_timestamp
                )
                VALUES (
                    EMPLOYEE_LOG_SEQ.NEXTVAL,
                    NULL,
                    'Daily Leave Count: ' || v_leave_count,
                    SYSDATE
                );

                COMMIT;
            END;
        ]',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY; BYHOUR=7; BYMINUTE=0; BYSECOND=0',
        enabled         => TRUE,
        auto_drop       => FALSE
    );

    DBMS_OUTPUT.PUT_LINE('JOB_DAILY_LEAVE_REPORT created successfully.');
END;
/
-- =====================================================
-- TEST TASK 2: Check Daily Leave Report Job
-- =====================================================

SELECT job_name,
       enabled,
       state,
       repeat_interval,
       auto_drop
FROM USER_SCHEDULER_JOBS
WHERE job_name = 'JOB_DAILY_LEAVE_REPORT';

-- =====================================================
-- TASK 3: Job with Program and Schedule Objects
-- =====================================================

SET SERVEROUTPUT ON;

BEGIN
    -- Drop old job if exists
    BEGIN
        DBMS_SCHEDULER.DROP_JOB(
            job_name => 'JOB_MONTHLY_PAYROLL',
            force    => TRUE
        );
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;

    -- Drop old program if exists
    BEGIN
        DBMS_SCHEDULER.DROP_PROGRAM(
            program_name => 'PROG_MONTHLY_PAYROLL',
            force        => TRUE
        );
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;

    -- Drop old schedule if exists
    BEGIN
        DBMS_SCHEDULER.DROP_SCHEDULE(
            schedule_name => 'SCH_FIRST_OF_MONTH',
            force         => TRUE
        );
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;


    -- Create program pointing to SP_PROCESS_PAYROLL
    DBMS_SCHEDULER.CREATE_PROGRAM(
        program_name        => 'PROG_MONTHLY_PAYROLL',
        program_type        => 'STORED_PROCEDURE',
        program_action      => 'SP_PROCESS_PAYROLL',
        number_of_arguments => 2,
        enabled             => FALSE
    );

    -- Define program arguments
    DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(
        program_name      => 'PROG_MONTHLY_PAYROLL',
        argument_position => 1,
        argument_name     => 'P_JOB_ID',
        argument_type     => 'NUMBER'
    );

    DBMS_SCHEDULER.DEFINE_PROGRAM_ARGUMENT(
        program_name      => 'PROG_MONTHLY_PAYROLL',
        argument_position => 2,
        argument_name     => 'P_PAY_DATE',
        argument_type     => 'DATE'
    );

    DBMS_SCHEDULER.ENABLE('PROG_MONTHLY_PAYROLL');


    -- Create schedule: first day of every month at 6 AM
    DBMS_SCHEDULER.CREATE_SCHEDULE(
        schedule_name    => 'SCH_FIRST_OF_MONTH',
        start_date       => SYSTIMESTAMP,
        repeat_interval  => 'FREQ=MONTHLY; BYMONTHDAY=1; BYHOUR=6; BYMINUTE=0; BYSECOND=0'
    );


    -- Create job using program and schedule
    DBMS_SCHEDULER.CREATE_JOB(
        job_name      => 'JOB_MONTHLY_PAYROLL',
        program_name  => 'PROG_MONTHLY_PAYROLL',
        schedule_name => 'SCH_FIRST_OF_MONTH',
        enabled       => FALSE,
        auto_drop     => FALSE
    );

    -- Set job argument values
    DBMS_SCHEDULER.SET_JOB_ARGUMENT_VALUE(
        job_name          => 'JOB_MONTHLY_PAYROLL',
        argument_position => 1,
        argument_value    => '1'
    );

    DBMS_SCHEDULER.SET_JOB_ANYDATA_VALUE(
        job_name          => 'JOB_MONTHLY_PAYROLL',
        argument_position => 2,
        argument_value    => SYS.ANYDATA.ConvertDate(TRUNC(SYSDATE))
    );

    DBMS_SCHEDULER.ENABLE('JOB_MONTHLY_PAYROLL');

    DBMS_OUTPUT.PUT_LINE('PROG_MONTHLY_PAYROLL created successfully.');
    DBMS_OUTPUT.PUT_LINE('SCH_FIRST_OF_MONTH created successfully.');
    DBMS_OUTPUT.PUT_LINE('JOB_MONTHLY_PAYROLL created successfully.');
END;
/


-- Check Program
SELECT program_name,
       program_type,
       program_action,
       number_of_arguments,
       enabled
FROM USER_SCHEDULER_PROGRAMS
WHERE program_name = 'PROG_MONTHLY_PAYROLL';


-- Check Schedule
SELECT schedule_name,
       repeat_interval
FROM USER_SCHEDULER_SCHEDULES
WHERE schedule_name = 'SCH_FIRST_OF_MONTH';


-- Check Job
SELECT job_name,
       enabled,
       state,
       program_name,
       schedule_name,
       auto_drop
FROM USER_SCHEDULER_JOBS
WHERE job_name = 'JOB_MONTHLY_PAYROLL';

-- =====================================================
-- TASK 4: Job Error Handling and Notifications
-- =====================================================

SET SERVEROUTPUT ON;

-- Helper procedure to log scheduler job errors
CREATE OR REPLACE PROCEDURE SP_LOG_JOB_ERROR (
    p_error_message IN VARCHAR2
)
AS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO EMPLOYEE_LOG (
        log_ID,
        emp_ID,
        action,
        log_timestamp
    )
    VALUES (
        EMPLOYEE_LOG_SEQ.NEXTVAL,
        NULL,
        'JOB_ERROR: ' || SUBSTR(p_error_message, 1, 80),
        SYSDATE
    );

    COMMIT;
END;
/

BEGIN
    -- Disable job before modifying it
    DBMS_SCHEDULER.DISABLE(
        name  => 'JOB_DAILY_LEAVE_REPORT',
        force => TRUE
    );

    -- Add error handling to the daily leave report job
    DBMS_SCHEDULER.SET_ATTRIBUTE(
        name      => 'JOB_DAILY_LEAVE_REPORT',
        attribute => 'job_action',
        value     => q'[
            DECLARE
                v_leave_count NUMBER;
            BEGIN
                SELECT COUNT(*)
                INTO v_leave_count
                FROM LEAVE
                WHERE TRUNC(leave_date) = TRUNC(SYSDATE);

                INSERT INTO EMPLOYEE_LOG (
                    log_ID,
                    emp_ID,
                    action,
                    log_timestamp
                )
                VALUES (
                    EMPLOYEE_LOG_SEQ.NEXTVAL,
                    NULL,
                    'Daily Leave Count: ' || v_leave_count,
                    SYSDATE
                );

                COMMIT;

            EXCEPTION
                WHEN OTHERS THEN
                    SP_LOG_JOB_ERROR(SQLERRM);
                    RAISE;
            END;
        ]'
    );

    -- Set max failures to 3
    DBMS_SCHEDULER.SET_ATTRIBUTE(
        name      => 'JOB_DAILY_LEAVE_REPORT',
        attribute => 'max_failures',
        value     => 3
    );

    -- Enable job again
    DBMS_SCHEDULER.ENABLE('JOB_DAILY_LEAVE_REPORT');

    DBMS_OUTPUT.PUT_LINE('JOB_DAILY_LEAVE_REPORT updated with error handling.');
    DBMS_OUTPUT.PUT_LINE('MAX_FAILURES set to 3.');
END;
/


-- Check updated job attributes
SELECT job_name,
       enabled,
       state,
       max_failures,
       repeat_interval
FROM USER_SCHEDULER_JOBS
WHERE job_name = 'JOB_DAILY_LEAVE_REPORT';

-- =====================================================
-- TEST TASK 4: Force Job Error and Check JOB_ERROR Log
-- =====================================================

SET SERVEROUTPUT ON;

BEGIN
    -- Disable job before changing action for failure test
    DBMS_SCHEDULER.DISABLE(
        name  => 'JOB_DAILY_LEAVE_REPORT',
        force => TRUE
    );

    -- Temporarily set job action to force an error
    DBMS_SCHEDULER.SET_ATTRIBUTE(
        name      => 'JOB_DAILY_LEAVE_REPORT',
        attribute => 'job_action',
        value     => q'[
            BEGIN
                RAISE_APPLICATION_ERROR(-20099, 'Manual test error for scheduler job');

            EXCEPTION
                WHEN OTHERS THEN
                    SP_LOG_JOB_ERROR(SQLERRM);
                    RAISE;
            END;
        ]'
    );

    DBMS_SCHEDULER.ENABLE('JOB_DAILY_LEAVE_REPORT');

    DBMS_OUTPUT.PUT_LINE('JOB_DAILY_LEAVE_REPORT temporarily changed for error test.');
END;
/

-- Run the job manually. It should fail and log JOB_ERROR.
BEGIN
    DBMS_SCHEDULER.RUN_JOB(
        job_name            => 'JOB_DAILY_LEAVE_REPORT',
        use_current_session => TRUE
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected scheduler job error: ' || SQLERRM);
END;
/

-- Check JOB_ERROR log inserted into EMPLOYEE_LOG
SELECT log_ID,
       emp_ID,
       action,
       log_timestamp
FROM EMPLOYEE_LOG
WHERE action LIKE 'JOB_ERROR:%'
ORDER BY log_ID DESC;

-- Restore the correct daily leave report job action
BEGIN
    DBMS_SCHEDULER.DISABLE(
        name  => 'JOB_DAILY_LEAVE_REPORT',
        force => TRUE
    );

    DBMS_SCHEDULER.SET_ATTRIBUTE(
        name      => 'JOB_DAILY_LEAVE_REPORT',
        attribute => 'job_action',
        value     => q'[
            DECLARE
                v_leave_count NUMBER;
            BEGIN
                SELECT COUNT(*)
                INTO v_leave_count
                FROM LEAVE
                WHERE TRUNC(leave_date) = TRUNC(SYSDATE);

                INSERT INTO EMPLOYEE_LOG (
                    log_ID,
                    emp_ID,
                    action,
                    log_timestamp
                )
                VALUES (
                    EMPLOYEE_LOG_SEQ.NEXTVAL,
                    NULL,
                    'Daily Leave Count: ' || v_leave_count,
                    SYSDATE
                );

                COMMIT;

            EXCEPTION
                WHEN OTHERS THEN
                    SP_LOG_JOB_ERROR(SQLERRM);
                    RAISE;
            END;
        ]'
    );

    DBMS_SCHEDULER.ENABLE('JOB_DAILY_LEAVE_REPORT');

    DBMS_OUTPUT.PUT_LINE('JOB_DAILY_LEAVE_REPORT restored successfully.');
END;
/

-- Final check
SELECT job_name,
       enabled,
       state,
       max_failures
FROM USER_SCHEDULER_JOBS
WHERE job_name = 'JOB_DAILY_LEAVE_REPORT';

-- =====================================================
-- FIX TASK 4: Shorten JOB_ERROR message to fit ACTION column
-- =====================================================

CREATE OR REPLACE PROCEDURE SP_LOG_JOB_ERROR (
    p_error_message IN VARCHAR2
)
AS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO EMPLOYEE_LOG (
        log_ID,
        emp_ID,
        action,
        log_timestamp
    )
    VALUES (
        EMPLOYEE_LOG_SEQ.NEXTVAL,
        NULL,
        SUBSTR('JOB_ERROR: ' || p_error_message, 1, 50),
        SYSDATE
    );

    COMMIT;
END;
/

-- =====================================================
-- RETEST TASK 4: Force Job Error and Check JOB_ERROR Log
-- =====================================================

SET SERVEROUTPUT ON;

BEGIN
    DBMS_SCHEDULER.DISABLE(
        name  => 'JOB_DAILY_LEAVE_REPORT',
        force => TRUE
    );

    DBMS_SCHEDULER.SET_ATTRIBUTE(
        name      => 'JOB_DAILY_LEAVE_REPORT',
        attribute => 'job_action',
        value     => q'[
            BEGIN
                RAISE_APPLICATION_ERROR(-20099, 'Manual test error');

            EXCEPTION
                WHEN OTHERS THEN
                    SP_LOG_JOB_ERROR(SQLERRM);
                    RAISE;
            END;
        ]'
    );

    DBMS_SCHEDULER.ENABLE('JOB_DAILY_LEAVE_REPORT');

    DBMS_OUTPUT.PUT_LINE('JOB_DAILY_LEAVE_REPORT changed for error retest.');
END;
/

BEGIN
    DBMS_SCHEDULER.RUN_JOB(
        job_name            => 'JOB_DAILY_LEAVE_REPORT',
        use_current_session => TRUE
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected scheduler job error: ' || SQLERRM);
END;
/

SELECT log_ID,
       emp_ID,
       action,
       log_timestamp
FROM EMPLOYEE_LOG
WHERE action LIKE 'JOB_ERROR:%'
ORDER BY log_ID DESC;

BEGIN
    DBMS_SCHEDULER.DISABLE(
        name  => 'JOB_DAILY_LEAVE_REPORT',
        force => TRUE
    );

    DBMS_SCHEDULER.SET_ATTRIBUTE(
        name      => 'JOB_DAILY_LEAVE_REPORT',
        attribute => 'job_action',
        value     => q'[
            DECLARE
                v_leave_count NUMBER;
            BEGIN
                SELECT COUNT(*)
                INTO v_leave_count
                FROM LEAVE
                WHERE TRUNC(leave_date) = TRUNC(SYSDATE);

                INSERT INTO EMPLOYEE_LOG (
                    log_ID,
                    emp_ID,
                    action,
                    log_timestamp
                )
                VALUES (
                    EMPLOYEE_LOG_SEQ.NEXTVAL,
                    NULL,
                    'Daily Leave Count: ' || v_leave_count,
                    SYSDATE
                );

                COMMIT;

            EXCEPTION
                WHEN OTHERS THEN
                    SP_LOG_JOB_ERROR(SQLERRM);
                    RAISE;
            END;
        ]'
    );

    DBMS_SCHEDULER.ENABLE('JOB_DAILY_LEAVE_REPORT');

    DBMS_OUTPUT.PUT_LINE('JOB_DAILY_LEAVE_REPORT restored successfully.');
END;
/

SELECT job_name,
       enabled,
       state,
       max_failures
FROM USER_SCHEDULER_JOBS
WHERE job_name = 'JOB_DAILY_LEAVE_REPORT';
-- =====================================================
-- TASK 5: Hard Task
-- =====================================================

-- TASK 5 is Hard and is not included in this solution.