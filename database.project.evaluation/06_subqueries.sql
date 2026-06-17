-- =====================================================
-- SECTION 06 - SUBQUERIES
-- Easy and Medium Tasks Only
-- =====================================================
-- =====================================================
-- TASK 1: Single-Row Subqueries
-- =====================================================

-- (a) Find employees whose salary is greater than
-- the average salary amount.

SELECT e.emp_ID,
       e.fname || ' ' || e.lname AS employee_name,
       sb.amount AS salary_amount
FROM EMPLOYEE e
JOIN SALARY_BONUS sb
    ON e.salary_ID = sb.salary_ID
WHERE sb.amount > (
    SELECT AVG(amount)
    FROM SALARY_BONUS
)
ORDER BY sb.amount DESC;


-- (b) Find the employee who has the highest payroll amount.

SELECT e.emp_ID,
       e.fname || ' ' || e.lname AS employee_name,
       p.total_amount
FROM EMPLOYEE e
JOIN PAYROLL p
    ON e.emp_ID = p.emp_ID
WHERE p.total_amount = (
    SELECT MAX(total_amount)
    FROM PAYROLL
);


-- (c) Find departments whose salary range belongs to
-- the department with the minimum salary amount.

SELECT d.job_ID,
       d.name AS department_name,
       d.salary_range
FROM JOB_DEPARTMENT d
WHERE d.job_ID = (
    SELECT job_ID
    FROM SALARY_BONUS
    WHERE amount = (
        SELECT MIN(amount)
        FROM SALARY_BONUS
    )
);

-- =====================================================
-- TASK 2: Multi-Row Subqueries
-- =====================================================

-- (a) Find employees who work in departments that have payroll records.

SELECT emp_ID,
       fname || ' ' || lname AS employee_name,
       job_ID
FROM EMPLOYEE
WHERE job_ID IN (
    SELECT DISTINCT job_ID
    FROM PAYROLL
)
ORDER BY emp_ID;


-- (b) Find employees whose salary is greater than ANY salary
-- in the HR department.

SELECT e.emp_ID,
       e.fname || ' ' || e.lname AS employee_name,
       sb.amount AS salary_amount
FROM EMPLOYEE e
JOIN SALARY_BONUS sb
    ON e.salary_ID = sb.salary_ID
WHERE sb.amount > ANY (
    SELECT sb2.amount
    FROM EMPLOYEE e2
    JOIN SALARY_BONUS sb2
        ON e2.salary_ID = sb2.salary_ID
    JOIN JOB_DEPARTMENT d2
        ON e2.job_ID = d2.job_ID
    WHERE d2.job_dept = 'HR'
)
ORDER BY sb.amount DESC;


-- (c) Find employees whose salary is greater than ALL salaries
-- in the Maintenance department.

SELECT e.emp_ID,
       e.fname || ' ' || e.lname AS employee_name,
       sb.amount AS salary_amount
FROM EMPLOYEE e
JOIN SALARY_BONUS sb
    ON e.salary_ID = sb.salary_ID
WHERE sb.amount > ALL (
    SELECT sb2.amount
    FROM EMPLOYEE e2
    JOIN SALARY_BONUS sb2
        ON e2.salary_ID = sb2.salary_ID
    JOIN JOB_DEPARTMENT d2
        ON e2.job_ID = d2.job_ID
    WHERE d2.job_dept = 'Maintenance'
)
ORDER BY sb.amount DESC;

-- =====================================================
-- TASK 3: EXISTS / NOT EXISTS Subqueries
-- =====================================================

-- (a) Find employees who have at least one leave record.
-- Using EXISTS.

SELECT e.emp_ID,
       e.fname || ' ' || e.lname AS employee_name
FROM EMPLOYEE e
WHERE EXISTS (
    SELECT 1
    FROM LEAVE l
    WHERE l.emp_ID = e.emp_ID
)
ORDER BY e.emp_ID;


-- (b) Find employees who do not have a qualification record.
-- Using NOT EXISTS.

SELECT e.emp_ID,
       e.fname || ' ' || e.lname AS employee_name
FROM EMPLOYEE e
WHERE NOT EXISTS (
    SELECT 1
    FROM QUALIFICATION q
    WHERE q.emp_ID = e.emp_ID
)
ORDER BY e.emp_ID;


-- (c) Find departments that have employees but no leave records.

SELECT d.job_ID,
       d.name AS department_name
FROM JOB_DEPARTMENT d
WHERE EXISTS (
    SELECT 1
    FROM EMPLOYEE e
    WHERE e.job_ID = d.job_ID
)
AND NOT EXISTS (
    SELECT 1
    FROM EMPLOYEE e
    JOIN LEAVE l
        ON e.emp_ID = l.emp_ID
    WHERE e.job_ID = d.job_ID
);
-- =====================================================
-- TASK 4: Correlated Subqueries
-- =====================================================

-- (a) Find employees whose salary is greater than
-- the average salary of their own department.

SELECT e.emp_ID,
       e.fname || ' ' || e.lname AS employee_name,
       sb.amount AS salary_amount,
       e.job_ID
FROM EMPLOYEE e
JOIN SALARY_BONUS sb
    ON e.salary_ID = sb.salary_ID
WHERE sb.amount > (
    SELECT AVG(sb2.amount)
    FROM EMPLOYEE e2
    JOIN SALARY_BONUS sb2
        ON e2.salary_ID = sb2.salary_ID
    WHERE e2.job_ID = e.job_ID
)
ORDER BY e.job_ID, sb.amount DESC;


-- (b) Find departments where at least one employee has payroll
-- greater than the average payroll of that same department.

SELECT d.job_ID,
       d.name AS department_name
FROM JOB_DEPARTMENT d
WHERE EXISTS (
    SELECT 1
    FROM PAYROLL p
    WHERE p.job_ID = d.job_ID
      AND p.total_amount > (
          SELECT AVG(p2.total_amount)
          FROM PAYROLL p2
          WHERE p2.job_ID = d.job_ID
      )
);


-- (c) Find employees whose payroll amount is equal to their
-- own maximum payroll amount.

SELECT e.emp_ID,
       e.fname || ' ' || e.lname AS employee_name,
       p.total_amount
FROM EMPLOYEE e
JOIN PAYROLL p
    ON e.emp_ID = p.emp_ID
WHERE p.total_amount = (
    SELECT MAX(p2.total_amount)
    FROM PAYROLL p2
    WHERE p2.emp_ID = e.emp_ID
)
ORDER BY e.emp_ID;
-- TASK 5 is Hard and is not included in this solution.