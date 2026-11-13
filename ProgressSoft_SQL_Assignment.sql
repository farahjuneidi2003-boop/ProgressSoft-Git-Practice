-- ============================================================
-- ProgressSoft Assignment - Part 2: SQL / PL/SQL
-- Oracle FreeSQL
-- Run the sections in order.
-- ============================================================


-- ============================================================
-- Q1 - Create the required tables and constraints
-- This section creates the four tables required by the assignment.
-- Primary Key, NOT NULL, Foreign Key, and CHECK constraints are included.
-- ============================================================

CREATE TABLE MyDepartment (
    Dept_ID NUMBER,
    Name VARCHAR2(100) NOT NULL,

    CONSTRAINT PK_MyDepartment
        PRIMARY KEY (Dept_ID)
);

CREATE TABLE Gender (
    Gender_ID NUMBER,
    Name VARCHAR2(20) NOT NULL,

    CONSTRAINT PK_Gender
        PRIMARY KEY (Gender_ID)
);

CREATE TABLE University (
    ID NUMBER,
    Name VARCHAR2(100) NOT NULL,

    CONSTRAINT PK_University
        PRIMARY KEY (ID)
);

CREATE TABLE MyEmployee (
    ID NUMBER,
    LAST_NAME VARCHAR2(100) NOT NULL,
    FIRST_NAME VARCHAR2(100) NOT NULL,
    HIRE_DATE DATE NOT NULL,
    USERID NUMBER,
    SALARY NUMBER,
    DEPT_ID NUMBER,
    GENDER_ID NUMBER,
    UNIVERSITY_ID NUMBER,
    EMP_IMAGE BLOB,

    CONSTRAINT PK_MyEmployee
        PRIMARY KEY (ID),

    CONSTRAINT CHK_Employee_Salary
        CHECK (SALARY >= 0),

    CONSTRAINT FK_Employee_Department
        FOREIGN KEY (DEPT_ID)
        REFERENCES MyDepartment(Dept_ID),

    CONSTRAINT FK_Employee_Gender
        FOREIGN KEY (GENDER_ID)
        REFERENCES Gender(Gender_ID),

    CONSTRAINT FK_Employee_University
        FOREIGN KEY (UNIVERSITY_ID)
        REFERENCES University(ID)
);

-- Verify that the required tables were created.
SELECT table_name
FROM user_tables
WHERE table_name IN (
    'MYEMPLOYEE',
    'MYDEPARTMENT',
    'GENDER',
    'UNIVERSITY'
)
ORDER BY table_name;


-- ============================================================
-- Q2 - Prepare test data and retrieve employee details
-- MANAGER_ID is added because Q2 asks for the manager name,
-- while the original MyEmployee structure does not include manager information.
-- ============================================================

ALTER TABLE MyEmployee
ADD MANAGER_ID NUMBER;

ALTER TABLE MyEmployee
ADD CONSTRAINT FK_Employee_Manager
FOREIGN KEY (MANAGER_ID)
REFERENCES MyEmployee(ID);

-- Insert departments.
INSERT INTO MyDepartment (Dept_ID, Name)
VALUES (10, 'IT');

INSERT INTO MyDepartment (Dept_ID, Name)
VALUES (20, 'HR');

-- Insert gender values.
INSERT INTO Gender (Gender_ID, Name)
VALUES (1, 'Male');

INSERT INTO Gender (Gender_ID, Name)
VALUES (2, 'Female');

-- Insert universities.
INSERT INTO University (ID, Name)
VALUES (1, 'University of Jordan');

INSERT INTO University (ID, Name)
VALUES (2, 'JUST');

-- Insert initial employees.
-- The hire dates for SCOTT, Ahmad, and Rami follow the sample data in the assignment.
INSERT INTO MyEmployee
(ID, LAST_NAME, FIRST_NAME, HIRE_DATE, USERID, SALARY,
 DEPT_ID, GENDER_ID, UNIVERSITY_ID, MANAGER_ID)
VALUES
(1, 'MILLER', 'SCOTT', DATE '1987-09-09', 101, 3000,
 10, 1, 1, NULL);

INSERT INTO MyEmployee
(ID, LAST_NAME, FIRST_NAME, HIRE_DATE, USERID, SALARY,
 DEPT_ID, GENDER_ID, UNIVERSITY_ID, MANAGER_ID)
VALUES
(2, 'HADDAD', 'AHMAD', DATE '1980-10-10', 102, 1800,
 10, 1, 2, 1);

INSERT INTO MyEmployee
(ID, LAST_NAME, FIRST_NAME, HIRE_DATE, USERID, SALARY,
 DEPT_ID, GENDER_ID, UNIVERSITY_ID, MANAGER_ID)
VALUES
(3, 'KHALIL', 'RAMI', DATE '1986-05-24', 103, 1600,
 20, 1, 1, 1);

COMMIT;

-- Q2 query:
-- Retrieve employee name, salary, department, manager, gender, and university.
SELECT
    e.FIRST_NAME || ' ' || e.LAST_NAME AS Employee_Name,
    e.SALARY,
    d.Name AS Department_Name,
    m.FIRST_NAME || ' ' || m.LAST_NAME AS Manager_Name,
    g.Name AS Gender,
    u.Name AS University
FROM MyEmployee e
JOIN MyDepartment d
    ON e.DEPT_ID = d.DEPT_ID
JOIN Gender g
    ON e.GENDER_ID = g.GENDER_ID
JOIN University u
    ON e.UNIVERSITY_ID = u.ID
LEFT JOIN MyEmployee m
    ON e.MANAGER_ID = m.ID;


-- ============================================================
-- Q3 - Display job titles and total monthly salary
-- JOB_TITLE is added because Q3 asks for job titles,
-- while the original MyEmployee structure does not include this column.
-- ============================================================

ALTER TABLE MyEmployee
ADD JOB_TITLE VARCHAR2(100);

UPDATE MyEmployee
SET JOB_TITLE = 'MANAGER'
WHERE ID = 1;

UPDATE MyEmployee
SET JOB_TITLE = 'SALES EMPLOYEE'
WHERE ID = 2;

UPDATE MyEmployee
SET JOB_TITLE = 'SUPPORT ENGINEER'
WHERE ID = 3;

COMMIT;

SELECT
    JOB_TITLE,
    SUM(SALARY) AS TOTAL_MONTHLY_SALARY
FROM MyEmployee
WHERE JOB_TITLE <> 'SALES EMPLOYEE'
GROUP BY JOB_TITLE
HAVING SUM(SALARY) > 2500;


-- ============================================================
-- Q4 - Identify and correct the four coding errors
-- The corrected statement is shown below.
-- It is kept as a comment because the EMP table is not available
-- in the current FreeSQL schema.
-- ============================================================

-- Original statement:
-- SELECT empno, ename,
-- salary x 12 ANNUAL SALARY; FROM emp;

-- Correct statement:
-- SELECT empno,
--        ename,
--        sal * 12 AS ANNUAL_SALARY
-- FROM emp;


-- ============================================================
-- Q5 - Oracle function F_HR_QUERY
-- The assignment sample data contains no employee hired after SCOTT.
-- Two additional test employees are inserted below so the function
-- can be executed and return a visible result.
-- ============================================================

INSERT INTO MyEmployee
(ID, LAST_NAME, FIRST_NAME, HIRE_DATE, USERID, SALARY,
 DEPT_ID, GENDER_ID, UNIVERSITY_ID, MANAGER_ID, JOB_TITLE)
VALUES
(4, 'ALI', 'SARA', DATE '2015-03-01', 104, 2000,
 10, 2, 2, 1, 'SUPPORT ENGINEER');

INSERT INTO MyEmployee
(ID, LAST_NAME, FIRST_NAME, HIRE_DATE, USERID, SALARY,
 DEPT_ID, GENDER_ID, UNIVERSITY_ID, MANAGER_ID, JOB_TITLE)
VALUES
(5, 'SALEH', 'LINA', DATE '2020-06-15', 105, 1500,
 20, 2, 1, 1, 'SALES EMPLOYEE');

COMMIT;

CREATE OR REPLACE FUNCTION F_HR_QUERY
RETURN VARCHAR2
IS
    result VARCHAR2(1000) := '';
BEGIN
    FOR e IN (
        SELECT FIRST_NAME, LAST_NAME, HIRE_DATE
        FROM MyEmployee
        WHERE HIRE_DATE > (
            SELECT HIRE_DATE
            FROM MyEmployee
            WHERE FIRST_NAME = 'SCOTT'
        )
    )
    LOOP
        result := result ||
                  e.FIRST_NAME || ' ' ||
                  e.LAST_NAME || ' - ' ||
                  TO_CHAR(e.HIRE_DATE, 'DD/MM/YYYY') || ' ';
    END LOOP;

    IF result IS NULL THEN
        result := 'No employees were hired after SCOTT';
    END IF;

    RETURN result;
END;
/

-- Execute the function.
SELECT F_HR_QUERY()
FROM DUAL;


-- ============================================================
-- Q6 - Procedure P_COPY_EMPLOYEE
-- Create an empty table with the same columns as MyEmployee,
-- then use a PL/SQL procedure to copy all employee data into it.
-- ============================================================

CREATE TABLE MyEmployee_update
AS
SELECT *
FROM MyEmployee
WHERE 1 = 0;

CREATE OR REPLACE PROCEDURE P_COPY_EMPLOYEE
IS
BEGIN
    INSERT INTO MyEmployee_update
    SELECT * FROM MyEmployee;
END;
/

-- Execute the procedure.
BEGIN
    P_COPY_EMPLOYEE;
END;
/

COMMIT;

-- Verify that the data was copied successfully.
SELECT *
FROM MyEmployee_update
ORDER BY ID;
