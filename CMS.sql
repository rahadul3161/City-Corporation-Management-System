-------------------------------------------------
-- CLEAN UP OLD OBJECTS
-------------------------------------------------
BEGIN
    FOR rec IN (SELECT object_name, object_type 
                FROM user_objects 
                WHERE object_type IN ('TABLE','SEQUENCE','TRIGGER')) LOOP
        BEGIN
            IF rec.object_type = 'TABLE' THEN
                EXECUTE IMMEDIATE 'DROP TABLE "' || rec.object_name || '" CASCADE CONSTRAINTS';
            ELSE
                EXECUTE IMMEDIATE 'DROP ' || rec.object_type || ' "' || rec.object_name || '"';
            END IF;
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
    END LOOP;
END;
/

-------------------------------------------------
-- TABLE CREATION
-------------------------------------------------

-- 1. CITIZEN
CREATE TABLE CITIZEN (
    IDNO        NUMBER PRIMARY KEY,
    Gender      VARCHAR2(10),
    B_Day       DATE,
    PNo         VARCHAR2(15),
    Address     VARCHAR2(100) UNIQUE, -- Unique for FK reference
    City        VARCHAR2(50),
    Zip         VARCHAR2(10)
);

-- 2. FULLNAME
CREATE TABLE FULLNAME (
    IDNO        NUMBER PRIMARY KEY,
    F_name      VARCHAR2(30),
    M_name      VARCHAR2(30),
    L_name      VARCHAR2(30),
    Fin_name    VARCHAR2(30)
);

-- 3. STREET_ADDRESS
CREATE TABLE STREET_ADDRESS (
    Address         VARCHAR2(100) PRIMARY KEY,
    H_No            VARCHAR2(10),
    Street_Name     VARCHAR2(50),
    Street_No       VARCHAR2(10)
);

-- 4. DEPARTMENTS
CREATE TABLE DEPARTMENTS (
    DNO         NUMBER PRIMARY KEY,
    DNAME       VARCHAR2(50),
    DNAManager  NUMBER
);

-- 5. EMPLOYEES
CREATE TABLE EMPLOYEES (
    EID             NUMBER PRIMARY KEY,
    Email           VARCHAR2(100),
    Salary          NUMBER(10,2),
    Extra_Hours     NUMBER(5,2),
    Commission_Pct  NUMBER(5,2),
    Start_Date      DATE,
    IDNO            NUMBER,
    DNO             NUMBER
);

-- 6. PROJECTS
CREATE TABLE PROJECTS (
    PNO         NUMBER PRIMARY KEY,
    PNAME       VARCHAR2(50),
    P_Location  VARCHAR2(50),
    Start_Date  DATE,
    End_Date    DATE,
    DNO         NUMBER
);

-- 7. SERVICES
CREATE TABLE SERVICES (
    SID         NUMBER PRIMARY KEY,
    SNAME       VARCHAR2(50),
    Total_Amount NUMBER(10,2),
    DNO         NUMBER
);

-- 8. COMPLAINTS
CREATE TABLE COMPLAINTS (
    CID         NUMBER PRIMARY KEY,
    C_Date      DATE,
    CNAME       VARCHAR2(100),
    C_Status    VARCHAR2(20),
    Paid        NUMBER(10,2),
    Debt        NUMBER(10,2),
    P_Date      DATE,
    IDNO        NUMBER,
    SID         NUMBER
);

-------------------------------------------------
-- ADD FOREIGN KEYS
-------------------------------------------------
ALTER TABLE FULLNAME 
ADD CONSTRAINT fk_fullname_citizen FOREIGN KEY (IDNO) REFERENCES CITIZEN(IDNO);

ALTER TABLE STREET_ADDRESS 
ADD CONSTRAINT fk_streetaddress_citizen FOREIGN KEY (Address) REFERENCES CITIZEN(Address);

ALTER TABLE EMPLOYEES 
ADD CONSTRAINT fk_employees_citizen FOREIGN KEY (IDNO) REFERENCES CITIZEN(IDNO);

ALTER TABLE EMPLOYEES 
ADD CONSTRAINT fk_employees_department FOREIGN KEY (DNO) REFERENCES DEPARTMENTS(DNO);

ALTER TABLE DEPARTMENTS
ADD CONSTRAINT fk_departments_manager FOREIGN KEY (DNAManager) REFERENCES EMPLOYEES(EID);

ALTER TABLE PROJECTS
ADD CONSTRAINT fk_projects_department FOREIGN KEY (DNO) REFERENCES DEPARTMENTS(DNO);

ALTER TABLE SERVICES
ADD CONSTRAINT fk_services_department FOREIGN KEY (DNO) REFERENCES DEPARTMENTS(DNO);

ALTER TABLE COMPLAINTS
ADD CONSTRAINT fk_complaints_citizen FOREIGN KEY (IDNO) REFERENCES CITIZEN(IDNO);

ALTER TABLE COMPLAINTS
ADD CONSTRAINT fk_complaints_services FOREIGN KEY (SID) REFERENCES SERVICES(SID);

-------------------------------------------------
-- CREATE SEQUENCES
-------------------------------------------------
CREATE SEQUENCE seq_citizen START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_department START WITH 10 INCREMENT BY 1;
CREATE SEQUENCE seq_employee START WITH 100 INCREMENT BY 1;
CREATE SEQUENCE seq_project START WITH 1000 INCREMENT BY 1;
CREATE SEQUENCE seq_service START WITH 2000 INCREMENT BY 1;
CREATE SEQUENCE seq_complaint START WITH 3000 INCREMENT BY 1;

-------------------------------------------------
-- CREATE TRIGGERS
-------------------------------------------------
CREATE OR REPLACE TRIGGER trg_citizen_pk
BEFORE INSERT ON CITIZEN
FOR EACH ROW
BEGIN
    IF :NEW.IDNO IS NULL THEN
        :NEW.IDNO := seq_citizen.NEXTVAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_department_pk
BEFORE INSERT ON DEPARTMENTS
FOR EACH ROW
BEGIN
    IF :NEW.DNO IS NULL THEN
        :NEW.DNO := seq_department.NEXTVAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_employee_pk
BEFORE INSERT ON EMPLOYEES
FOR EACH ROW
BEGIN
    IF :NEW.EID IS NULL THEN
        :NEW.EID := seq_employee.NEXTVAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_project_pk
BEFORE INSERT ON PROJECTS
FOR EACH ROW
BEGIN
    IF :NEW.PNO IS NULL THEN
        :NEW.PNO := seq_project.NEXTVAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_service_pk
BEFORE INSERT ON SERVICES
FOR EACH ROW
BEGIN
    IF :NEW.SID IS NULL THEN
        :NEW.SID := seq_service.NEXTVAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_complaint_pk
BEFORE INSERT ON COMPLAINTS
FOR EACH ROW
BEGIN
    IF :NEW.CID IS NULL THEN
        :NEW.CID := seq_complaint.NEXTVAL;
    END IF;
END;
/

-------------------------------------------------
-- INSERT DATA IN CORRECT ORDER
-------------------------------------------------
-- Citizen
INSERT INTO CITIZEN (Gender, B_Day, PNo, Address, City, Zip)
VALUES ('Male', DATE '1990-05-10', '01711111111', 'A001', 'Dhaka', '1207');

-- Full name
INSERT INTO FULLNAME (IDNO, F_name, M_name, L_name, Fin_name)
VALUES (1, 'Rahim', NULL, 'Ahmed', NULL);

-- Street address
INSERT INTO STREET_ADDRESS VALUES ('A001', '12', 'Lake Road', '5');

-- Department
INSERT INTO DEPARTMENTS (DNAME) VALUES ('Public Works');

-- Employee
INSERT INTO EMPLOYEES (Email, Salary, Extra_Hours, Commission_Pct, Start_Date, IDNO, DNO)
VALUES ('rahim.ahmed@example.com', 50000, 10, 5, SYSDATE, 1, 10);

-- Assign department manager
UPDATE DEPARTMENTS SET DNAManager = 100 WHERE DNO = 10;

-- Project
INSERT INTO PROJECTS (PNAME, P_Location, Start_Date, End_Date, DNO)
VALUES ('Road Repair', 'Dhaka North', SYSDATE, NULL, 10);

-- Service
INSERT INTO SERVICES (SNAME, Total_Amount, DNO)
VALUES ('Garbage Collection', 150000, 10);

-- Complaint
INSERT INTO COMPLAINTS (C_Date, CNAME, C_Status, Paid, Debt, P_Date, IDNO, SID)
VALUES (SYSDATE, 'Street Light Broken', 'Pending', 0, 500, NULL, 1, 2000);

-------------------------------------------------
-- SAMPLE QUERIES
-------------------------------------------------
-- All citizens
SELECT * FROM CITIZEN;

-- Employees and departments
SELECT E.EID, E.Email, D.DNAME
FROM EMPLOYEES E
JOIN DEPARTMENTS D ON E.DNO = D.DNO;

-- Complaints with citizen and service
SELECT CM.CID, FN.F_name, FN.L_name, S.SNAME, CM.C_Status
FROM COMPLAINTS CM
JOIN CITIZEN C ON CM.IDNO = C.IDNO
JOIN FULLNAME FN ON C.IDNO = FN.IDNO
JOIN SERVICES S ON CM.SID = S.SID;
