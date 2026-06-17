SELECT 'JOB_DEPARTMENT' AS table_name, COUNT(*) AS total_rows FROM JOB_DEPARTMENT
UNION ALL
SELECT 'SALARY_BONUS', COUNT(*) FROM SALARY_BONUS
UNION ALL
SELECT 'EMPLOYEE', COUNT(*) FROM EMPLOYEE
UNION ALL
SELECT 'QUALIFICATION', COUNT(*) FROM QUALIFICATION
UNION ALL
SELECT 'LEAVE', COUNT(*) FROM LEAVE
UNION ALL
SELECT 'PAYROLL', COUNT(*) FROM PAYROLL;

-- =====================================================
-- SECTION 03 - TASK 1
-- Step 1: Insert JOB_DEPARTMENT records
-- =====================================================

INSERT INTO JOB_DEPARTMENT VALUES
(job_department_seq.NEXTVAL, 'Engineering', 'Engineering Department', 'Handles technical projects', '3000-8000');

INSERT INTO JOB_DEPARTMENT VALUES
(job_department_seq.NEXTVAL, 'HR', 'Human Resources', 'Manages employees and recruitment', '1500-4000');

INSERT INTO JOB_DEPARTMENT VALUES
(job_department_seq.NEXTVAL, 'Finance', 'Finance Department', 'Handles payroll and budgets', '2500-7000');

INSERT INTO JOB_DEPARTMENT VALUES
(job_department_seq.NEXTVAL, 'Maintenance', 'Maintenance Department', 'Responsible for repairs and support', '1000-3500');

INSERT INTO JOB_DEPARTMENT VALUES
(job_department_seq.NEXTVAL, 'IT', 'Information Technology', 'Manages systems and networks', '2500-7500');

-- Check departments
SELECT * FROM JOB_DEPARTMENT;
-- =====================================================
-- SECTION 03 - TASK 1
-- Step 2: Insert SALARY_BONUS records
-- =====================================================

INSERT INTO SALARY_BONUS VALUES
(salary_bonus_seq.NEXTVAL, 5000, 60000, 700, 1);

INSERT INTO SALARY_BONUS VALUES
(salary_bonus_seq.NEXTVAL, 3000, 36000, 400, 2);

INSERT INTO SALARY_BONUS VALUES
(salary_bonus_seq.NEXTVAL, 4500, 54000, 600, 3);

INSERT INTO SALARY_BONUS VALUES
(salary_bonus_seq.NEXTVAL, 2500, 30000, 300, 4);

INSERT INTO SALARY_BONUS VALUES
(salary_bonus_seq.NEXTVAL, 5500, 66000, 800, 5);

-- Check salary bonus records
SELECT * FROM SALARY_BONUS;
-- =====================================================
-- SECTION 03 - TASK 1
-- Step 3: Insert EMPLOYEE records
-- =====================================================

INSERT INTO EMPLOYEE VALUES
(employee_seq.NEXTVAL, 'Ahmed', 'Al-Balushi', 'M', 32, 'Muscat', 'ahmed@ems.com', 'pass123', 1, 1);

INSERT INTO EMPLOYEE VALUES
(employee_seq.NEXTVAL, 'Fatma', 'Al-Harthi', 'F', 29, 'Sohar', 'fatma@ems.com', 'pass123', 2, 2);

INSERT INTO EMPLOYEE VALUES
(employee_seq.NEXTVAL, 'Khalid', 'Al-Rashdi', 'M', 41, 'Nizwa', 'khalid@ems.com', 'pass123', 3, 3);

INSERT INTO EMPLOYEE VALUES
(employee_seq.NEXTVAL, 'Muna', 'Al-Zadjali', 'F', 27, 'Muscat', 'muna@ems.com', 'pass123', 1, 1);

INSERT INTO EMPLOYEE VALUES
(employee_seq.NEXTVAL, 'Salim', 'Al-Maamari', 'M', 35, 'Ibri', 'salim@ems.com', 'pass123', 4, 4);

INSERT INTO EMPLOYEE VALUES
(employee_seq.NEXTVAL, 'Aisha', 'Al-Lawati', 'F', 31, 'Seeb', 'aisha@ems.com', 'pass123', 5, 5);

INSERT INTO EMPLOYEE VALUES
(employee_seq.NEXTVAL, 'Hamad', 'Al-Kindi', 'M', 24, 'Barka', 'hamad@ems.com', 'pass123', 2, 2);

INSERT INTO EMPLOYEE VALUES
(employee_seq.NEXTVAL, 'Noor', 'Al-Siyabi', 'F', 38, 'Sur', 'noor@ems.com', 'pass123', 3, 3);

INSERT INTO EMPLOYEE VALUES
(employee_seq.NEXTVAL, 'Omar', 'Al-Abri', 'M', 28, 'Sohar', 'omar@ems.com', 'pass123', 5, 5);

INSERT INTO EMPLOYEE VALUES
(employee_seq.NEXTVAL, 'Sara', 'Al-Hinai', 'F', 26, 'Muscat', 'sara@ems.com', 'pass123', 1, 1);

-- Check employee records
SELECT * FROM EMPLOYEE;

-- =====================================================
-- SECTION 03 - TASK 1
-- Step 4: Insert QUALIFICATION records
-- =====================================================

INSERT INTO QUALIFICATION VALUES
(qualification_seq.NEXTVAL, 'Engineer', 'Bachelor in Engineering', DATE '2022-01-15', 1);

INSERT INTO QUALIFICATION VALUES
(qualification_seq.NEXTVAL, 'HR Officer', 'Diploma in HR', DATE '2021-03-20', 2);

INSERT INTO QUALIFICATION VALUES
(qualification_seq.NEXTVAL, 'Accountant', 'Bachelor in Accounting', DATE '2020-06-10', 3);

INSERT INTO QUALIFICATION VALUES
(qualification_seq.NEXTVAL, 'Technician', 'Technical Certificate', DATE '2023-02-12', 5);

INSERT INTO QUALIFICATION VALUES
(qualification_seq.NEXTVAL, 'IT Specialist', 'Bachelor in IT', DATE '2022-09-05', 6);

-- Check qualification records
SELECT * FROM QUALIFICATION;

-- =====================================================
-- SECTION 03 - TASK 1
-- Step 5: Insert LEAVE records
-- =====================================================

INSERT INTO LEAVE VALUES
(leave_seq.NEXTVAL, DATE '2024-01-10', 'Sick leave', 1);

INSERT INTO LEAVE VALUES
(leave_seq.NEXTVAL, DATE '2024-02-15', 'Annual leave', 2);

INSERT INTO LEAVE VALUES
(leave_seq.NEXTVAL, DATE '2024-03-18', 'Emergency leave', 4);

INSERT INTO LEAVE VALUES
(leave_seq.NEXTVAL, DATE '2023-12-05', 'Sick leave', 6);

INSERT INTO LEAVE VALUES
(leave_seq.NEXTVAL, DATE '2024-04-22', 'Family reason', 8);

-- Check leave records
SELECT * FROM LEAVE;

-- =====================================================
-- SECTION 03 - TASK 1
-- Step 6: Insert PAYROLL records
-- =====================================================

INSERT INTO PAYROLL VALUES
(payroll_seq.NEXTVAL, DATE '2024-01-31', 'January payroll', 5700, 1, 1, 1, 1);

INSERT INTO PAYROLL VALUES
(payroll_seq.NEXTVAL, DATE '2024-01-31', 'January payroll', 3400, 2, 2, 2, 2);

INSERT INTO PAYROLL VALUES
(payroll_seq.NEXTVAL, DATE '2024-01-31', 'January payroll', 5100, 3, 3, 3, NULL);

INSERT INTO PAYROLL VALUES
(payroll_seq.NEXTVAL, DATE '2024-02-29', 'February payroll', 5700, 4, 1, 1, 3);

INSERT INTO PAYROLL VALUES
(payroll_seq.NEXTVAL, DATE '2024-02-29', 'February payroll', 2800, 5, 4, 4, NULL);

INSERT INTO PAYROLL VALUES
(payroll_seq.NEXTVAL, DATE '2024-02-29', 'February payroll', 6300, 6, 5, 5, 4);

INSERT INTO PAYROLL VALUES
(payroll_seq.NEXTVAL, DATE '2024-03-31', 'March payroll', 3400, 7, 2, 2, NULL);

INSERT INTO PAYROLL VALUES
(payroll_seq.NEXTVAL, DATE '2024-03-31', 'March payroll', 5100, 8, 3, 3, 5);

-- Check payroll records
SELECT * FROM PAYROLL;

SELECT 'JOB_DEPARTMENT' AS table_name, COUNT(*) AS total_rows FROM JOB_DEPARTMENT
UNION ALL
SELECT 'SALARY_BONUS', COUNT(*) FROM SALARY_BONUS
UNION ALL
SELECT 'EMPLOYEE', COUNT(*) FROM EMPLOYEE
UNION ALL
SELECT 'QUALIFICATION', COUNT(*) FROM QUALIFICATION
UNION ALL
SELECT 'LEAVE', COUNT(*) FROM LEAVE
UNION ALL
SELECT 'PAYROLL', COUNT(*) FROM PAYROLL;

COMMIT;
-- =====================================================
-- SECTION 03 - TASK 2
-- Conditional SELECT Queries
-- =====================================================

-- (a) List all employees whose age is between 25 and 40,
-- ordered by last name ascending.

SELECT emp_ID,
       fname || ' ' || lname AS full_name,
       gender,
       age,
       contact_add
FROM EMPLOYEE
WHERE age BETWEEN 25 AND 40
ORDER BY lname ASC;

-- (b) Retrieve all payroll records where total_amount exceeds 5000,
-- showing employee name and department.

SELECT p.payroll_ID,
       e.fname || ' ' || e.lname AS employee_name,
       d.name AS department_name,
       p.payroll_date,
       p.total_amount
FROM PAYROLL p
JOIN EMPLOYEE e
    ON p.emp_ID = e.emp_ID
JOIN JOB_DEPARTMENT d
    ON p.job_ID = d.job_ID
WHERE p.total_amount > 5000
ORDER BY p.total_amount DESC;

-- (c) Find all employees who have taken leave with reason
-- containing the word 'sick' case-insensitive.

SELECT e.emp_ID,
       e.fname || ' ' || e.lname AS employee_name,
       l.leave_date,
       l.reason
FROM EMPLOYEE e
JOIN LEAVE l
    ON e.emp_ID = l.emp_ID
WHERE LOWER(l.reason) LIKE '%sick%';

-- (d) List all departments that have no employees assigned.
-- Using NOT EXISTS.

SELECT d.job_ID,
       d.name AS department_name,
       d.job_dept
FROM JOB_DEPARTMENT d
WHERE NOT EXISTS (
    SELECT 1
    FROM EMPLOYEE e
    WHERE e.job_ID = d.job_ID
);

-- =====================================================
-- SECTION 03 - TASK 3
-- Bulk UPDATE Scenarios
-- =====================================================

-- (a) Give a 10% salary increase to all employees
-- in the 'Engineering' department.

-- Preview Engineering salary before update
SELECT sb.salary_ID,
       d.job_dept,
       sb.amount,
       sb.annual,
       sb.bonus
FROM SALARY_BONUS sb
JOIN JOB_DEPARTMENT d
    ON sb.job_ID = d.job_ID
WHERE d.job_dept = 'Engineering';


UPDATE SALARY_BONUS sb
SET sb.amount = sb.amount * 1.10,
    sb.annual = sb.annual * 1.10
WHERE sb.salary_ID IN (
    SELECT DISTINCT e.salary_ID
    FROM EMPLOYEE e
    JOIN JOB_DEPARTMENT d
        ON e.job_ID = d.job_ID
    WHERE d.job_dept = 'Engineering'
);


-- Verify Engineering salary after update
SELECT sb.salary_ID,
       d.job_dept,
       sb.amount,
       sb.annual,
       sb.bonus
FROM SALARY_BONUS sb
JOIN JOB_DEPARTMENT d
    ON sb.job_ID = d.job_ID
WHERE d.job_dept = 'Engineering';

-- (b) Update the emp_email of all employees to lowercase
-- using Oracle LOWER() function.

-- Preview emails before update
SELECT emp_ID,
       fname || ' ' || lname AS employee_name,
       emp_email
FROM EMPLOYEE;


UPDATE EMPLOYEE
SET emp_email = LOWER(emp_email);


-- Verify emails after update
SELECT emp_ID,
       fname || ' ' || lname AS employee_name,
       emp_email
FROM EMPLOYEE;

-- (c) Set the salary_range in JOB_DEPARTMENT to 'REVISED'
-- for any department whose average total payroll exceeds 8000.
-- Using a subquery in the WHERE clause.

-- Preview departments before update
SELECT d.job_ID,
       d.job_dept,
       d.name,
       d.salary_range
FROM JOB_DEPARTMENT d;


UPDATE JOB_DEPARTMENT d
SET d.salary_range = 'REVISED'
WHERE d.job_ID IN (
    SELECT p.job_ID
    FROM PAYROLL p
    GROUP BY p.job_ID
    HAVING AVG(p.total_amount) > 8000
);


-- Verify departments after update
SELECT d.job_ID,
       d.job_dept,
       d.name,
       d.salary_range
FROM JOB_DEPARTMENT d;
-- Note: No department was updated because no department average payroll exceeds 8000.
COMMIT;

-- =====================================================
-- SECTION 03 - TASK 4
-- Controlled DELETE with Safety Checks
-- =====================================================

SAVEPOINT before_delete_task;

-- Preview leave records older than 2 years from today
SELECT *
FROM LEAVE
WHERE leave_date < ADD_MONTHS(SYSDATE, -24);
-- (a) Delete all LEAVE records older than 2 years from today.

-- First, remove optional leave references from PAYROLL
UPDATE PAYROLL
SET leave_ID = NULL
WHERE leave_ID IN (
    SELECT leave_ID
    FROM LEAVE
    WHERE leave_date < ADD_MONTHS(SYSDATE, -24)
);

-- Delete old leave records
DELETE FROM LEAVE
WHERE leave_date < ADD_MONTHS(SYSDATE, -24);

-- Verify the result with COUNT
SELECT COUNT(*) AS remaining_old_leave_records
FROM LEAVE
WHERE leave_date < ADD_MONTHS(SYSDATE, -24);

-- (c) Preview qualification records for employees who no longer exist

SELECT q.*
FROM QUALIFICATION q
WHERE NOT EXISTS (
    SELECT 1
    FROM EMPLOYEE e
    WHERE e.emp_ID = q.emp_ID
);

-- (b) Delete qualification records for employees who no longer exist

DELETE FROM QUALIFICATION q
WHERE NOT EXISTS (
    SELECT 1
    FROM EMPLOYEE e
    WHERE e.emp_ID = q.emp_ID
);

-- Verify the result with COUNT

SELECT COUNT(*) AS orphan_qualification_records
FROM QUALIFICATION q
WHERE NOT EXISTS (
    SELECT 1
    FROM EMPLOYEE e
    WHERE e.emp_ID = q.emp_ID
);
ROLLBACK TO before_delete_task;
SELECT COUNT(*) AS leave_records
FROM LEAVE;
-- The DELETE statements were tested successfully.
-- ROLLBACK TO before_delete_task was used to restore the original data
-- because the LEAVE records are needed for later sections.
