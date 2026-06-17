-- =====================================================
-- SECTION 05 - JOINS
-- Easy and Medium Tasks Only
-- =====================================================
-- =====================================================
-- TASK 1: INNER JOIN - Employee Full Profile
-- =====================================================

-- Retrieve employee full profile.
-- Only employees who have both payroll and qualification records.

SELECT e.emp_ID,
       e.fname || ' ' || e.lname AS full_name,
       d.name AS department_name,
       q.position AS job_title,
       sb.amount AS salary_amount,
       MAX(l.leave_date) AS latest_leave_date
FROM EMPLOYEE e
INNER JOIN JOB_DEPARTMENT d
    ON e.job_ID = d.job_ID
INNER JOIN SALARY_BONUS sb
    ON e.salary_ID = sb.salary_ID
INNER JOIN QUALIFICATION q
    ON e.emp_ID = q.emp_ID
INNER JOIN PAYROLL p
    ON e.emp_ID = p.emp_ID
LEFT JOIN LEAVE l
    ON e.emp_ID = l.emp_ID
GROUP BY e.emp_ID,
         e.fname,
         e.lname,
         d.name,
         q.position,
         sb.amount
ORDER BY e.emp_ID;
-- =====================================================
-- TASK 2: LEFT OUTER JOIN - Missing Records
-- =====================================================

-- (a) List all employees who have never taken any leave.

SELECT e.emp_ID,
       e.fname || ' ' || e.lname AS employee_name
FROM EMPLOYEE e
LEFT JOIN LEAVE l
    ON e.emp_ID = l.emp_ID
WHERE l.leave_ID IS NULL
ORDER BY e.emp_ID;


-- (b) List all departments that have no salary/bonus records.

SELECT d.job_ID,
       d.name AS department_name,
       d.job_dept
FROM JOB_DEPARTMENT d
LEFT JOIN SALARY_BONUS sb
    ON d.job_ID = sb.job_ID
WHERE sb.salary_ID IS NULL
ORDER BY d.job_ID;

-- =====================================================
-- TASK 3: Multi-Table JOIN - Payroll Report
-- =====================================================

-- Complete payroll report joining all 6 tables.

SELECT p.payroll_ID,
       e.fname || ' ' || e.lname AS employee_name,
       d.name AS department_name,
       q.position AS position,
       sb.amount AS salary_amount,
       sb.bonus,
       l.reason AS leave_reason,
       p.total_amount
FROM PAYROLL p
JOIN EMPLOYEE e
    ON p.emp_ID = e.emp_ID
JOIN JOB_DEPARTMENT d
    ON p.job_ID = d.job_ID
JOIN SALARY_BONUS sb
    ON p.salary_ID = sb.salary_ID
LEFT JOIN LEAVE l
    ON p.leave_ID = l.leave_ID
LEFT JOIN QUALIFICATION q
    ON e.emp_ID = q.emp_ID
ORDER BY d.name, p.total_amount DESC;

-- =====================================================
-- TASK 4: SELF JOIN
-- =====================================================

-- Pair employees who work in the same department,
-- excluding pairing an employee with himself/herself.

SELECT e1.fname || ' ' || e1.lname AS employee_1,
       e2.fname || ' ' || e2.lname AS employee_2,
       d.name AS department_name
FROM EMPLOYEE e1
JOIN EMPLOYEE e2
    ON e1.job_ID = e2.job_ID
   AND e1.emp_ID < e2.emp_ID
JOIN JOB_DEPARTMENT d
    ON e1.job_ID = d.job_ID
ORDER BY d.name, employee_1, employee_2;
-- TASK 5 is Hard and is not included in this solution.