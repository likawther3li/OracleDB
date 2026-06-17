-- =====================================================
-- SECTION 07 - VIEWS
-- Easy and Medium Tasks Only
-- =====================================================
-- TASK 1: Create a Simple View
-- =====================================================

-- Create a view that shows employee basic information
-- with department name and salary amount.

CREATE OR REPLACE VIEW employee_basic_view AS
SELECT e.emp_ID,
       e.fname || ' ' || e.lname AS employee_name,
       e.gender,
       e.age,
       e.emp_email,
       d.name AS department_name,
       sb.amount AS salary_amount
FROM EMPLOYEE e
JOIN JOB_DEPARTMENT d
    ON e.job_ID = d.job_ID
JOIN SALARY_BONUS sb
    ON e.salary_ID = sb.salary_ID;

-- Test the view
SELECT *
FROM employee_basic_view
ORDER BY emp_ID;

-- =====================================================
-- TASK 2: Create a Complex View
-- =====================================================

-- Create a view that summarizes payroll by department.

CREATE OR REPLACE VIEW department_payroll_summary AS
SELECT d.job_ID,
       d.name AS department_name,
       COUNT(DISTINCT e.emp_ID) AS total_employees,
       NVL(SUM(p.total_amount), 0) AS total_payroll,
       ROUND(AVG(p.total_amount), 2) AS average_payroll
FROM JOB_DEPARTMENT d
LEFT JOIN EMPLOYEE e
    ON d.job_ID = e.job_ID
LEFT JOIN PAYROLL p
    ON e.emp_ID = p.emp_ID
GROUP BY d.job_ID, d.name;


-- Test the view
SELECT *
FROM department_payroll_summary
ORDER BY total_payroll DESC;

-- =====================================================
-- TASK 3: Create an Updatable View
-- =====================================================

-- Create an updatable view for employee contact information.

CREATE OR REPLACE VIEW employee_contact_view AS
SELECT emp_ID,
       fname,
       lname,
       contact_add,
       emp_email
FROM EMPLOYEE;


-- Test the updatable view
SELECT *
FROM employee_contact_view
ORDER BY emp_ID;


-- Update one employee email through the view
UPDATE employee_contact_view
SET emp_email = 'ahmed.updated@ems.com'
WHERE emp_ID = 1;


-- Verify update through the view
SELECT *
FROM employee_contact_view
WHERE emp_ID = 1;


-- Restore original email to keep data consistent
UPDATE employee_contact_view
SET emp_email = 'ahmed@ems.com'
WHERE emp_ID = 1;


-- Final check
SELECT *
FROM employee_contact_view
WHERE emp_ID = 1;

COMMIT;
-- =====================================================
-- TASK 4: View with CHECK OPTION
-- =====================================================

-- Create a view for employees in Engineering department only.
-- WITH CHECK OPTION prevents changing rows so they no longer
-- satisfy the view condition.

CREATE OR REPLACE VIEW engineering_employees_view AS
SELECT emp_ID,
       fname,
       lname,
       gender,
       age,
       contact_add,
       emp_email,
       emp_pass,
       job_ID,
       salary_ID
FROM EMPLOYEE
WHERE job_ID = 1
WITH CHECK OPTION CONSTRAINT chk_engineering_view;


-- Test the view
SELECT emp_ID,
       fname || ' ' || lname AS employee_name,
       job_ID
FROM engineering_employees_view
ORDER BY emp_ID;


-- Valid update: update contact address while employee remains Engineering
UPDATE engineering_employees_view
SET contact_add = 'Muscat - Updated'
WHERE emp_ID = 1;


-- Verify valid update
SELECT emp_ID,
       fname || ' ' || lname AS employee_name,
       contact_add,
       job_ID
FROM engineering_employees_view
WHERE emp_ID = 1;


-- Restore original contact address
UPDATE engineering_employees_view
SET contact_add = 'Muscat'
WHERE emp_ID = 1;

COMMIT;
-- TASK 5 is Hard and is not included in this solution.