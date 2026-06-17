-- =====================================================
-- SECTION 04 - AGGREGATION FUNCTIONS
-- Easy and Medium Tasks Only
-- =====================================================
-- =====================================================
-- TASK 1: Basic Aggregation
-- =====================================================

-- (a) Total number of employees in each department.

SELECT d.name AS department_name,
       COUNT(e.emp_ID) AS total_employees
FROM JOB_DEPARTMENT d
LEFT JOIN EMPLOYEE e
    ON d.job_ID = e.job_ID
GROUP BY d.name
ORDER BY d.name;


-- (b) Minimum, maximum, and average salary amount.

SELECT MIN(amount) AS minimum_salary,
       MAX(amount) AS maximum_salary,
       ROUND(AVG(amount), 2) AS average_salary
FROM SALARY_BONUS;


-- (c) Total bonus paid out across the entire company.

SELECT SUM(bonus) AS total_bonus
FROM SALARY_BONUS;

-- =====================================================
-- TASK 2: GROUP BY with HAVING
-- =====================================================

-- (a) List departments where the average employee age exceeds 30.

SELECT d.name AS department_name,
       ROUND(AVG(e.age), 2) AS average_age
FROM JOB_DEPARTMENT d
JOIN EMPLOYEE e
    ON d.job_ID = e.job_ID
GROUP BY d.name
HAVING AVG(e.age) > 30;


-- (b) Show all job titles where more than 2 employees share that qualification position.

SELECT q.position,
       COUNT(q.emp_ID) AS total_employees
FROM QUALIFICATION q
GROUP BY q.position
HAVING COUNT(q.emp_ID) > 2;


-- (c) Find months from PAYROLL where the total payroll amount exceeds 20000.

SELECT TO_CHAR(payroll_date, 'YYYY-MM') AS payroll_month,
       SUM(total_amount) AS total_monthly_payroll
FROM PAYROLL
GROUP BY TO_CHAR(payroll_date, 'YYYY-MM')
HAVING SUM(total_amount) > 20000
ORDER BY payroll_month;

-- =====================================================
-- TASK 3: Aggregation with Multiple Functions
-- =====================================================

-- Department summary report:
-- department name, employee count, total payroll,
-- average salary, highest salary, lowest salary.

SELECT d.name AS department_name,
       COUNT(DISTINCT e.emp_ID) AS total_employees,
       NVL(SUM(p.total_amount), 0) AS total_payroll_amount,
       ROUND(AVG(sb.amount), 2) AS average_salary,
       MAX(sb.amount) AS highest_salary,
       MIN(sb.amount) AS lowest_salary
FROM JOB_DEPARTMENT d
LEFT JOIN EMPLOYEE e
    ON d.job_ID = e.job_ID
LEFT JOIN SALARY_BONUS sb
    ON e.salary_ID = sb.salary_ID
LEFT JOIN PAYROLL p
    ON e.emp_ID = p.emp_ID
GROUP BY d.name
ORDER BY total_payroll_amount DESC;
-- =====================================================
-- TASK 4: Filtered Aggregation
-- HAVING with Multiple Conditions
-- =====================================================

-- (a) List departments where total payroll exceeds 15000
-- AND average salary is above 3000.

SELECT d.name AS department_name,
       SUM(p.total_amount) AS total_payroll,
       ROUND(AVG(sb.amount), 2) AS average_salary
FROM JOB_DEPARTMENT d
JOIN EMPLOYEE e
    ON d.job_ID = e.job_ID
JOIN SALARY_BONUS sb
    ON e.salary_ID = sb.salary_ID
JOIN PAYROLL p
    ON e.emp_ID = p.emp_ID
GROUP BY d.name
HAVING SUM(p.total_amount) > 15000
   AND AVG(sb.amount) > 3000;


-- (b) Find qualification positions where more than 2 employees hold that position
-- AND the average age of those employees exceeds 28.

SELECT q.position,
       COUNT(e.emp_ID) AS total_employees,
       ROUND(AVG(e.age), 2) AS average_age
FROM QUALIFICATION q
JOIN EMPLOYEE e
    ON q.emp_ID = e.emp_ID
GROUP BY q.position
HAVING COUNT(e.emp_ID) > 2
   AND AVG(e.age) > 28;


-- (c) Show all employees who have more than 1 leave record.
-- Display full name, department, and leave count.

SELECT e.fname || ' ' || e.lname AS employee_name,
       d.name AS department_name,
       COUNT(l.leave_ID) AS leave_count
FROM EMPLOYEE e
JOIN JOB_DEPARTMENT d
    ON e.job_ID = d.job_ID
JOIN LEAVE l
    ON e.emp_ID = l.emp_ID
GROUP BY e.fname, e.lname, d.name
HAVING COUNT(l.leave_ID) > 1;
-- TASK 5 is Hard and is not included in this solution.
