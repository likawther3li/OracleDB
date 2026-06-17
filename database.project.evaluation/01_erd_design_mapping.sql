-- =====================================================
-- SECTION 01 - TASK 2
-- Map the ERD to Relational Schema
-- =====================================================

-- JOB_DEPARTMENT (
--   job_ID PK,
--   job_dept,
--   name,
--   description,
--   salary_range
-- )

-- SALARY_BONUS (
--   salary_ID PK,
--   amount,
--   annual,
--   bonus,
--   job_ID FK
-- )

-- EMPLOYEE (
--   emp_ID PK,
--   fname,
--   lname,
--   gender,
--   age,
--   contact_add,
--   emp_email,
--   emp_pass,
--   job_ID FK,
--   salary_ID FK
-- )

-- QUALIFICATION (
--   qual_ID PK,
--   position,
--   requirements,
--   date_in,
--   emp_ID FK
-- )

-- LEAVE (
--   leave_ID PK,
--   leave_date,
--   reason,
--   emp_ID FK
-- )

-- PAYROLL (
--   payroll_ID PK,
--   payroll_date,
--   report,
--   total_amount,
--   emp_ID FK,
--   job_ID FK,
--   salary_ID FK,
--   leave_ID FK
-- )

-- =====================================================
-- Foreign Key Summary
-- =====================================================

-- SALARY_BONUS.job_ID REFERENCES JOB_DEPARTMENT(job_ID)

-- EMPLOYEE.job_ID REFERENCES JOB_DEPARTMENT(job_ID)
-- EMPLOYEE.salary_ID REFERENCES SALARY_BONUS(salary_ID)

-- QUALIFICATION.emp_ID REFERENCES EMPLOYEE(emp_ID)

-- LEAVE.emp_ID REFERENCES EMPLOYEE(emp_ID)

-- PAYROLL.emp_ID REFERENCES EMPLOYEE(emp_ID)
-- PAYROLL.job_ID REFERENCES JOB_DEPARTMENT(job_ID)
-- PAYROLL.salary_ID REFERENCES SALARY_BONUS(salary_ID)
-- PAYROLL.leave_ID REFERENCES LEAVE(leave_ID)

-- Total Foreign Keys = 9
-- =====================================================
-- SECTION 01 - TASK 3
-- Full DDL CREATE Statements
-- =====================================================

-- 1) JOB_DEPARTMENT table
CREATE TABLE JOB_DEPARTMENT (
    job_ID NUMBER PRIMARY KEY,
    job_dept VARCHAR2(50) NOT NULL,
    name VARCHAR2(50) NOT NULL,
    description VARCHAR2(200),
    salary_range VARCHAR2(50)
);

CREATE SEQUENCE job_department_seq
START WITH 1
INCREMENT BY 1;


-- 2) SALARY_BONUS table
CREATE TABLE SALARY_BONUS (
    salary_ID NUMBER PRIMARY KEY,
    amount NUMBER(10,2) NOT NULL,
    annual NUMBER(10,2),
    bonus NUMBER(10,2),
    job_ID NUMBER NOT NULL,

    CONSTRAINT chk_salary_amount
        CHECK (amount > 0),

    CONSTRAINT fk_salary_department
        FOREIGN KEY (job_ID)
        REFERENCES JOB_DEPARTMENT(job_ID)
);

CREATE SEQUENCE salary_bonus_seq
START WITH 1
INCREMENT BY 1;


-- 3) EMPLOYEE table
CREATE TABLE EMPLOYEE (
    emp_ID NUMBER PRIMARY KEY,
    fname VARCHAR2(50) NOT NULL,
    lname VARCHAR2(50) NOT NULL,
    gender CHAR(1) NOT NULL,
    age NUMBER(3) NOT NULL,
    contact_add VARCHAR2(150),
    emp_email VARCHAR2(100) NOT NULL,
    emp_pass VARCHAR2(50) NOT NULL,
    job_ID NUMBER NOT NULL,
    salary_ID NUMBER NOT NULL,

    CONSTRAINT chk_employee_gender
        CHECK (gender IN ('M', 'F')),

    CONSTRAINT fk_employee_department
        FOREIGN KEY (job_ID)
        REFERENCES JOB_DEPARTMENT(job_ID),

    CONSTRAINT fk_employee_salary
        FOREIGN KEY (salary_ID)
        REFERENCES SALARY_BONUS(salary_ID)
);

CREATE SEQUENCE employee_seq
START WITH 1
INCREMENT BY 1;


-- 4) QUALIFICATION table
CREATE TABLE QUALIFICATION (
    qual_ID NUMBER PRIMARY KEY,
    position VARCHAR2(50) NOT NULL,
    requirements VARCHAR2(200),
    date_in DATE,
    emp_ID NUMBER NOT NULL,

    CONSTRAINT fk_qualification_employee
        FOREIGN KEY (emp_ID)
        REFERENCES EMPLOYEE(emp_ID)
);

CREATE SEQUENCE qualification_seq
START WITH 1
INCREMENT BY 1;


-- 5) LEAVE table
CREATE TABLE LEAVE (
    leave_ID NUMBER PRIMARY KEY,
    leave_date DATE NOT NULL,
    reason VARCHAR2(200),
    emp_ID NUMBER NOT NULL,

    CONSTRAINT fk_leave_employee
        FOREIGN KEY (emp_ID)
        REFERENCES EMPLOYEE(emp_ID)
);

CREATE SEQUENCE leave_seq
START WITH 1
INCREMENT BY 1;


-- 6) PAYROLL table
CREATE TABLE PAYROLL (
    payroll_ID NUMBER PRIMARY KEY,
    payroll_date DATE NOT NULL,
    report VARCHAR2(200),
    total_amount NUMBER(10,2) NOT NULL,
    emp_ID NUMBER NOT NULL,
    job_ID NUMBER NOT NULL,
    salary_ID NUMBER NOT NULL,
    leave_ID NUMBER,

    CONSTRAINT fk_payroll_employee
        FOREIGN KEY (emp_ID)
        REFERENCES EMPLOYEE(emp_ID),

    CONSTRAINT fk_payroll_department
        FOREIGN KEY (job_ID)
        REFERENCES JOB_DEPARTMENT(job_ID),

    CONSTRAINT fk_payroll_salary
        FOREIGN KEY (salary_ID)
        REFERENCES SALARY_BONUS(salary_ID),

    CONSTRAINT fk_payroll_leave
        FOREIGN KEY (leave_ID)
        REFERENCES LEAVE(leave_ID)
);

CREATE SEQUENCE payroll_seq
START WITH 1
INCREMENT BY 1;
-- Check created tables
SELECT table_name
FROM user_tables
WHERE table_name IN (
  'JOB_DEPARTMENT',
  'SALARY_BONUS',
  'EMPLOYEE',
  'QUALIFICATION',
  'LEAVE',
  'PAYROLL'
)
ORDER BY table_name;
