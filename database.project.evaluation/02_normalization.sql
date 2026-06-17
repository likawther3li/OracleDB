-- =====================================================
-- SECTION 02 - NORMALIZATION
-- Employee Management System
-- =====================================================


-- =====================================================
-- TASK 1: First Normal Form (1NF) Analysis
-- =====================================================

-- Given un-normalized table:
-- EMP_RAW (
--   emp_id,
--   full_name,
--   phone_numbers,
--   dept_name,
--   dept_location,
--   job_titles,
--   salary
-- )

-- (a) 1NF Violations:
-- 1. full_name is not atomic because it contains first name and last name together.
--    It should be separated into fname and lname.
--
-- 2. phone_numbers violates 1NF because one employee may have more than one phone number
--    inside the same column. 1NF requires one value only in each cell.
--
-- 3. job_titles violates 1NF because it may contain multiple job titles in one column.
--    Each field must contain a single atomic value.
--
-- 4. Repeating employee and department information with multiple phone numbers or job titles
--    creates duplicated data and makes the table difficult to update correctly.


-- (b) Rewrite the table in 1NF.
-- The table is rewritten so every field contains one atomic value only.

-- EMP_RAW_1NF (
--   emp_id,
--   fname,
--   lname,
--   phone_number,
--   dept_name,
--   dept_location,
--   job_title,
--   salary
-- )

-- Sample data showing the 1NF structure:
SELECT 1 AS emp_id,
       'Ahmed' AS fname,
       'Al-Balushi' AS lname,
       '91234567' AS phone_number,
       'Engineering' AS dept_name,
       'Muscat' AS dept_location,
       'Engineer' AS job_title,
       5000 AS salary
FROM dual
UNION ALL
SELECT 2,
       'Fatma',
       'Al-Harthi',
       '92345678',
       'HR',
       'Sohar',
       'HR Officer',
       3000
FROM dual
UNION ALL
SELECT 3,
       'Khalid',
       'Al-Rashdi',
       '93456789',
       'Finance',
       'Nizwa',
       'Accountant',
       4500
FROM dual;


-- Alternative better 1NF design:
-- EMPLOYEE_1NF (
--   emp_id PK,
--   fname,
--   lname,
--   dept_name,
--   dept_location,
--   salary
-- )
--
-- EMP_PHONE_1NF (
--   emp_id FK,
--   phone_number
-- )
--
-- EMP_JOB_1NF (
--   emp_id FK,
--   job_title
-- )

-- (c) Check EMS schema against 1NF:
-- All six EMS tables satisfy 1NF because:
-- 1. Every table has a primary key.
-- 2. Every column stores atomic values only.
-- 3. There are no repeating groups in a single column.
-- 4. Multi-value information is separated into related tables.
--
-- JOB_DEPARTMENT: atomic department information.
-- SALARY_BONUS: atomic salary and bonus values.
-- EMPLOYEE: one employee per row with atomic attributes.
-- QUALIFICATION: one qualification record per row.
-- LEAVE: one leave record per row.
-- PAYROLL: one payroll record per row.



-- =====================================================
-- TASK 2: Second Normal Form (2NF) Analysis
-- =====================================================

-- Given table:
-- PAYROLL_RAW (
--   emp_ID,
--   job_ID,
--   emp_name,
--   job_title,
--   salary_range,
--   pay_date,
--   total_amount
-- )
--
-- Composite Primary Key: (emp_ID, job_ID)

-- (a) Partial dependencies:
-- emp_name depends only on emp_ID.
-- job_title depends only on job_ID.
-- salary_range depends only on job_ID.
--
-- These are partial dependencies because they depend on part of the composite key,
-- not on the whole key (emp_ID, job_ID).

-- Functional dependencies:
-- emp_ID -> emp_name
-- job_ID -> job_title, salary_range
-- emp_ID, job_ID -> pay_date, total_amount


-- (b) Decompose into 2NF relations:

-- EMPLOYEE_2NF (
--   emp_ID PK,
--   emp_name
-- )

-- JOB_2NF (
--   job_ID PK,
--   job_title,
--   salary_range
-- )

-- PAYROLL_2NF (
--   emp_ID FK,
--   job_ID FK,
--   pay_date,
--   total_amount,
--   PRIMARY KEY (emp_ID, job_ID)
-- )

-- Explanation:
-- emp_name is moved to EMPLOYEE_2NF because it depends only on emp_ID.
-- job_title and salary_range are moved to JOB_2NF because they depend only on job_ID.
-- PAYROLL_2NF keeps only the attributes that depend on the full composite key.


-- (c) Check EMS schema against 2NF:
-- The EMS schema does not have composite primary keys.
-- Each table uses a single-column primary key:
-- JOB_DEPARTMENT(job_ID)
-- SALARY_BONUS(salary_ID)
-- EMPLOYEE(emp_ID)
-- QUALIFICATION(qual_ID)
-- LEAVE(leave_ID)
-- PAYROLL(payroll_ID)
--
-- Therefore, there are no partial dependencies.
-- The EMS schema satisfies 2NF.



-- =====================================================
-- TASK 3: Third Normal Form (3NF) Analysis
-- =====================================================

-- Given table:
-- EMPLOYEE_EXT (
--   emp_ID,
--   dept_ID,
--   dept_name,
--   dept_manager,
--   manager_phone,
--   emp_salary
-- )

-- (a) Transitive dependencies:
-- Primary Key: emp_ID
--
-- emp_ID -> dept_ID, emp_salary
-- dept_ID -> dept_name, dept_manager
-- dept_manager -> manager_phone
--
-- Transitive dependencies:
-- emp_ID -> dept_ID -> dept_name
-- emp_ID -> dept_ID -> dept_manager
-- emp_ID -> dept_ID -> dept_manager -> manager_phone
--
-- dept_name, dept_manager, and manager_phone do not depend directly on emp_ID.
-- They depend on department or manager information, so they should be separated.


-- (b) Decompose into 3NF relations:

-- EMPLOYEE_3NF (
--   emp_ID PK,
--   dept_ID FK,
--   emp_salary
-- )

-- DEPARTMENT_3NF (
--   dept_ID PK,
--   dept_name,
--   dept_manager
-- )

-- MANAGER_3NF (
--   dept_manager PK,
--   manager_phone
-- )

-- Explanation:
-- Employee information stays in EMPLOYEE_3NF.
-- Department information is moved to DEPARTMENT_3NF.
-- Manager phone is moved to MANAGER_3NF because it depends on the manager,
-- not directly on the employee.

-- After decomposition:
-- EMPLOYEE_3NF has no non-key attribute determining another non-key attribute.
-- DEPARTMENT_3NF stores department facts only.
-- MANAGER_3NF stores manager contact facts only.
-- Therefore, no transitive dependencies remain.


-- (c) Analyze EMS schema against 3NF:

-- 1. JOB_DEPARTMENT:
-- job_ID -> job_dept, name, description, salary_range
-- No non-key attribute determines another non-key attribute.
-- This table is in 3NF.

-- 2. SALARY_BONUS:
-- salary_ID -> amount, annual, bonus, job_ID
-- The attributes depend on salary_ID.
-- No transitive dependency is stored in this table.
-- This table is in 3NF.

-- 3. EMPLOYEE:
-- emp_ID -> fname, lname, gender, age, contact_add, emp_email, emp_pass, job_ID, salary_ID
-- Department details are not stored in EMPLOYEE; only job_ID is stored as a foreign key.
-- Salary details are not stored in EMPLOYEE; only salary_ID is stored as a foreign key.
-- This table is in 3NF.

-- 4. QUALIFICATION:
-- qual_ID -> position, requirements, date_in, emp_ID
-- All attributes depend on qual_ID.
-- This table is in 3NF.

-- 5. LEAVE:
-- leave_ID -> leave_date, reason, emp_ID
-- All attributes depend on leave_ID.
-- This table is in 3NF.

-- 6. PAYROLL:
-- payroll_ID -> payroll_date, report, total_amount, emp_ID, job_ID, salary_ID, leave_ID
-- Payroll stores references to employee, department, salary, and optional leave record.
-- It does not store employee name, department name, or salary details directly.
-- This table is in 3NF.


-- (d) Final statement:
-- The complete EMS schema is in Third Normal Form (3NF) because:
-- 1. All tables satisfy 1NF.
-- 2. All tables satisfy 2NF.
-- 3. There are no transitive dependencies between non-key attributes.
-- 4. Related data is separated into suitable tables and connected using foreign keys.

-- =====================================================
-- END OF SECTION 02
-- =====================================================