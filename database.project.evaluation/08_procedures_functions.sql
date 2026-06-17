-- =====================================================
-- SECTION 08 - STORED PROCEDURES AND FUNCTIONS
-- Easy and Medium Tasks Only
-- =====================================================
-- =====================================================
-- TASK 1: Procedure - Add New Employee
-- =====================================================

SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE SP_ADD_EMPLOYEE (
    p_fname       IN EMPLOYEE.fname%TYPE,
    p_lname       IN EMPLOYEE.lname%TYPE,
    p_gender      IN EMPLOYEE.gender%TYPE,
    p_age         IN EMPLOYEE.age%TYPE,
    p_contact_add IN EMPLOYEE.contact_add%TYPE,
    p_emp_email   IN EMPLOYEE.emp_email%TYPE,
    p_emp_pass    IN EMPLOYEE.emp_pass%TYPE,
    p_job_ID      IN EMPLOYEE.job_ID%TYPE,
    p_salary_ID   IN EMPLOYEE.salary_ID%TYPE
)
AS
    v_email_count NUMBER;
BEGIN
    -- Check if email already exists
    SELECT COUNT(*)
    INTO v_email_count
    FROM EMPLOYEE
    WHERE LOWER(emp_email) = LOWER(p_emp_email);

    IF v_email_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Duplicate email. This employee email already exists.');
    END IF;

    -- Insert new employee
    INSERT INTO EMPLOYEE (
        emp_ID,
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
        employee_seq.NEXTVAL,
        p_fname,
        p_lname,
        p_gender,
        p_age,
        p_contact_add,
        LOWER(p_emp_email),
        p_emp_pass,
        p_job_ID,
        p_salary_ID
    );

    DBMS_OUTPUT.PUT_LINE('Employee added successfully: ' || p_fname || ' ' || p_lname);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in SP_ADD_EMPLOYEE: ' || SQLERRM);
        RAISE;
END;
/

-- =================================================
-- TEST TASK 1
-- =================================================

SET SERVEROUTPUT ON;

SAVEPOINT before_sp_add_employee_test;

-- First call: should insert successfully
BEGIN
    SP_ADD_EMPLOYEE(
        'Test',
        'Employee',
        'M',
        30,
        'Muscat',
        'test.employee@ems.com',
        'pass123',
        1,
        1
    );
END;
/

-- Second call with same email: should fire duplicate email exception
BEGIN
    SP_ADD_EMPLOYEE(
        'Test',
        'Duplicate',
        'M',
        31,
        'Muscat',
        'test.employee@ems.com',
        'pass123',
        1,
        1
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected duplicate email error: ' || SQLERRM);
END;
/

-- Verify inserted employee before rollback
SELECT emp_ID,
       fname || ' ' || lname AS employee_name,
       emp_email
FROM EMPLOYEE
WHERE emp_email = 'test.employee@ems.com';

-- Rollback test data to keep database clean
ROLLBACK TO before_sp_add_employee_test;

-- Verify test employee was removed
SELECT COUNT(*) AS test_employee_count
FROM EMPLOYEE
WHERE emp_email = 'test.employee@ems.com';
-- =====================================================
-- TASK 2: Function - Calculate Net Salary
-- =====================================================

CREATE OR REPLACE FUNCTION FN_CALC_NET_SALARY (
    p_emp_ID IN EMPLOYEE.emp_ID%TYPE
)
RETURN NUMBER
AS
    v_salary  NUMBER;
    v_bonus   NUMBER;
    v_net     NUMBER;
BEGIN
    SELECT sb.amount,
           NVL(sb.bonus, 0)
    INTO v_salary,
         v_bonus
    FROM EMPLOYEE e
    JOIN SALARY_BONUS sb
        ON e.salary_ID = sb.salary_ID
    WHERE e.emp_ID = p_emp_ID;

    v_net := v_salary + v_bonus;

    RETURN v_net;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;
/
-- =====================================================
-- TEST TASK 2
-- =====================================================

SET SERVEROUTPUT ON;

-- Test the function for selected employees
SELECT emp_ID,
       fname || ' ' || lname AS employee_name,
       FN_CALC_NET_SALARY(emp_ID) AS net_salary
FROM EMPLOYEE
WHERE emp_ID IN (1, 2, 6)
ORDER BY emp_ID;


-- Test invalid employee ID
SELECT FN_CALC_NET_SALARY(999) AS invalid_employee_result
FROM dual;
-- =====================================================
-- TASK 3: Procedure - Update Salary by Department
-- =====================================================

CREATE OR REPLACE PROCEDURE SP_UPDATE_DEPARTMENT_SALARY (
    p_job_ID      IN JOB_DEPARTMENT.job_ID%TYPE,
    p_percentage  IN NUMBER
)
AS
    v_count NUMBER;
BEGIN
    -- Check if department exists
    SELECT COUNT(*)
    INTO v_count
    FROM JOB_DEPARTMENT
    WHERE job_ID = p_job_ID;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Department does not exist.');
    END IF;

    -- Increase salary and annual salary by percentage
    UPDATE SALARY_BONUS
    SET amount = amount + (amount * p_percentage / 100),
        annual = annual + (annual * p_percentage / 100)
    WHERE job_ID = p_job_ID;

    DBMS_OUTPUT.PUT_LINE('Salary updated successfully for department ID: ' || p_job_ID);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in SP_UPDATE_DEPARTMENT_SALARY: ' || SQLERRM);
        RAISE;
END;
/
-- =====================================================
-- TEST TASK 3
-- =====================================================

SET SERVEROUTPUT ON;

SAVEPOINT before_salary_update_test;

-- Preview salary before update for HR department
SELECT salary_ID,
       amount,
       annual,
       bonus,
       job_ID
FROM SALARY_BONUS
WHERE job_ID = 2;


-- Call procedure: increase HR salary by 5%
BEGIN
    SP_UPDATE_DEPARTMENT_SALARY(2, 5);
END;
/


-- Verify salary after update
SELECT salary_ID,
       amount,
       annual,
       bonus,
       job_ID
FROM SALARY_BONUS
WHERE job_ID = 2;


-- Test invalid department ID
BEGIN
    SP_UPDATE_DEPARTMENT_SALARY(999, 5);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected invalid department error: ' || SQLERRM);
END;
/


-- Rollback test changes to keep data consistent
ROLLBACK TO before_salary_update_test;


-- Final check after rollback
SELECT salary_ID,
       amount,
       annual,
       bonus,
       job_ID
FROM SALARY_BONUS
WHERE job_ID = 2;
-- Extra procedure test for salary update. This is not part of the Hard tasks.

-- =====================================================
-- TASK 3: Procedure - Process Monthly Payroll
-- =====================================================

CREATE OR REPLACE PROCEDURE SP_PROCESS_PAYROLL (
    p_job_ID    IN JOB_DEPARTMENT.job_ID%TYPE,
    p_pay_date  IN PAYROLL.payroll_date%TYPE
)
AS
    CURSOR emp_cur IS
        SELECT e.emp_ID,
               e.salary_ID,
               e.job_ID,
               sb.amount,
               NVL(sb.bonus, 0) AS bonus
        FROM EMPLOYEE e
        JOIN SALARY_BONUS sb
            ON e.salary_ID = sb.salary_ID
        WHERE e.job_ID = p_job_ID;

    v_emp_rec       emp_cur%ROWTYPE;
    v_leave_count   NUMBER;
    v_daily_rate    NUMBER;
    v_total_amount  NUMBER;
    v_insert_count  NUMBER := 0;
BEGIN
    OPEN emp_cur;

    LOOP
        FETCH emp_cur INTO v_emp_rec;
        EXIT WHEN emp_cur%NOTFOUND;

        SELECT COUNT(*)
        INTO v_leave_count
        FROM LEAVE
        WHERE emp_ID = v_emp_rec.emp_ID;

        v_daily_rate := v_emp_rec.amount / 30;

        v_total_amount := v_emp_rec.amount
                          + v_emp_rec.bonus
                          - (v_leave_count * v_daily_rate);

        INSERT INTO PAYROLL (
            payroll_ID,
            payroll_date,
            report,
            total_amount,
            emp_ID,
            job_ID,
            salary_ID,
            leave_ID
        )
        VALUES (
            payroll_seq.NEXTVAL,
            p_pay_date,
            'Monthly payroll processed by procedure',
            ROUND(v_total_amount, 2),
            v_emp_rec.emp_ID,
            v_emp_rec.job_ID,
            v_emp_rec.salary_ID,
            NULL
        );

        v_insert_count := v_insert_count + 1;
    END LOOP;

    CLOSE emp_cur;

    DBMS_OUTPUT.PUT_LINE('Payroll records inserted: ' || v_insert_count);

EXCEPTION
    WHEN OTHERS THEN
        IF emp_cur%ISOPEN THEN
            CLOSE emp_cur;
        END IF;

        DBMS_OUTPUT.PUT_LINE('Error in SP_PROCESS_PAYROLL: ' || SQLERRM);
        RAISE;
END;
/
-- =====================================================
-- TEST TASK 3: SP_PROCESS_PAYROLL
-- =====================================================

SET SERVEROUTPUT ON;

SAVEPOINT before_process_payroll_test;

-- Count payroll records before running the procedure
SELECT COUNT(*) AS payroll_count_before
FROM PAYROLL;

-- Run payroll process for Engineering department on a test date
BEGIN
    SP_PROCESS_PAYROLL(1, DATE '2024-05-31');
END;
/

-- Show inserted test payroll records
SELECT payroll_ID,
       payroll_date,
       report,
       total_amount,
       emp_ID,
       job_ID,
       salary_ID
FROM PAYROLL
WHERE payroll_date = DATE '2024-05-31'
ORDER BY emp_ID;

-- Count payroll records after running the procedure
SELECT COUNT(*) AS payroll_count_after
FROM PAYROLL;

-- Rollback test records to keep original data clean
ROLLBACK TO before_process_payroll_test;

-- Final count should return to original number
SELECT COUNT(*) AS payroll_count_final
FROM PAYROLL;

-- =====================================================
-- TASK 4: Procedure - Task 4: Salary Raise with Audit Table
-- =====================================================

SET SERVEROUTPUT ON;

-- Create SALARY_AUDIT table if it does not already exist
BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE SALARY_AUDIT (
            audit_ID NUMBER PRIMARY KEY,
            salary_ID NUMBER,
            job_ID NUMBER,
            old_amount NUMBER(10,2),
            new_amount NUMBER(10,2),
            old_annual NUMBER(10,2),
            new_annual NUMBER(10,2),
            raise_percentage NUMBER(5,2),
            changed_date DATE,
            changed_by VARCHAR2(50)
        )
    ';

    DBMS_OUTPUT.PUT_LINE('SALARY_AUDIT table created.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN
            DBMS_OUTPUT.PUT_LINE('SALARY_AUDIT table already exists.');
        ELSE
            RAISE;
        END IF;
END;
/

-- Create sequence for SALARY_AUDIT if it does not already exist
BEGIN
    EXECUTE IMMEDIATE '
        CREATE SEQUENCE salary_audit_seq
        START WITH 1
        INCREMENT BY 1
    ';

    DBMS_OUTPUT.PUT_LINE('SALARY_AUDIT_SEQ created.');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN
            DBMS_OUTPUT.PUT_LINE('SALARY_AUDIT_SEQ already exists.');
        ELSE
            RAISE;
        END IF;
END;
/

CREATE OR REPLACE PROCEDURE SP_RAISE_SALARY (
    p_job_ID      IN JOB_DEPARTMENT.job_ID%TYPE,
    p_percentage  IN NUMBER
)
AS
    v_dept_count NUMBER;
BEGIN
    -- Validate department
    SELECT COUNT(*)
    INTO v_dept_count
    FROM JOB_DEPARTMENT
    WHERE job_ID = p_job_ID;

    IF v_dept_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Department does not exist.');
    END IF;

    IF p_percentage <= 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Raise percentage must be greater than zero.');
    END IF;

    -- Insert old/new salary values into audit table
    INSERT INTO SALARY_AUDIT (
        audit_ID,
        salary_ID,
        job_ID,
        old_amount,
        new_amount,
        old_annual,
        new_annual,
        raise_percentage,
        changed_date,
        changed_by
    )
    SELECT salary_audit_seq.NEXTVAL,
           salary_ID,
           job_ID,
           amount AS old_amount,
           amount + (amount * p_percentage / 100) AS new_amount,
           annual AS old_annual,
           annual + (annual * p_percentage / 100) AS new_annual,
           p_percentage,
           SYSDATE,
           USER
    FROM SALARY_BONUS
    WHERE job_ID = p_job_ID;

    -- Update salary
    UPDATE SALARY_BONUS
    SET amount = amount + (amount * p_percentage / 100),
        annual = annual + (annual * p_percentage / 100)
    WHERE job_ID = p_job_ID;

    DBMS_OUTPUT.PUT_LINE('Salary raise completed for department ID: ' || p_job_ID);
    DBMS_OUTPUT.PUT_LINE('Audit records inserted: ' || SQL%ROWCOUNT);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in SP_RAISE_SALARY: ' || SQLERRM);
        RAISE;
END;
/
-- =====================================================
-- TEST TASK 4: SP_RAISE_SALARY
-- =====================================================

SET SERVEROUTPUT ON;

SAVEPOINT before_raise_salary_test;

-- Preview salary before raise for Finance department
SELECT salary_ID,
       job_ID,
       amount,
       annual,
       bonus
FROM SALARY_BONUS
WHERE job_ID = 3;


-- Apply 10% salary raise to Finance department
BEGIN
    SP_RAISE_SALARY(3, 10);
END;
/


-- Verify salary after raise
SELECT salary_ID,
       job_ID,
       amount,
       annual,
       bonus
FROM SALARY_BONUS
WHERE job_ID = 3;


-- Check audit records inserted
SELECT audit_ID,
       salary_ID,
       job_ID,
       old_amount,
       new_amount,
       old_annual,
       new_annual,
       raise_percentage,
       changed_by
FROM SALARY_AUDIT
WHERE job_ID = 3
ORDER BY audit_ID DESC;


-- Test invalid percentage
BEGIN
    SP_RAISE_SALARY(3, -5);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected invalid percentage error: ' || SQLERRM);
END;
/


-- Rollback test changes to keep original data clean
ROLLBACK TO before_raise_salary_test;


-- Final check after rollback
SELECT salary_ID,
       job_ID,
       amount,
       annual,
       bonus
FROM SALARY_BONUS
WHERE job_ID = 3;
-- TASK 5 is Hard and is not included in this solution.
