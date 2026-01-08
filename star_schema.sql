/* Ethan Sanchez: star_schema.sql */
USE ets103;


/* This creates the dimension table that will use data from the `patient` table from `emr`. */
CREATE TABLE PATIENT_DIM
(Patient_ID INT AUTO_INCREMENT, -- primary key ("PK")
First_Name VARCHAR(50) NOT NULL,
Last_Name VARCHAR(50) NOT NULL,
Date_Of_Birth DATE,
Gender VARCHAR(10) NOT NULL,
CONSTRAINT PK_PATIENT_DIM PRIMARY KEY(Patient_ID));
-- PATIENT_DIM has a one-to-many (1:M) relationship with the fact table.


/* This creates the dimension table that will use data from the `provider` table from `emr`. */
CREATE TABLE PROVIDER_DIM
(Provider_ID INT AUTO_INCREMENT, -- PK
First_Name VARCHAR(50) NOT NULL,
Last_Name VARCHAR(50) NOT NULL,
Specialty VARCHAR(50) NOT NULL,
CONSTRAINT PK_PROVIDER_DIM PRIMARY KEY(Provider_ID));
-- PROVIDER_DIM has a one-to-many (1:M) relationship with the fact table.


/* This creates the dimension table that will use data from the `clinical_procedure` table from `emr`. */
CREATE TABLE PROCEDURE_DIM
(Procedure_ID INT AUTO_INCREMENT, -- PK
Icd10_Code VARCHAR(50) NOT NULL,
Proc_Name VARCHAR(100) NOT NULL,
Descript VARCHAR(255) NOT NULL,
CONSTRAINT PK_PROCEDURE_DIM PRIMARY KEY(Procedure_ID));
-- PROCEDURE_DIM has a one-to-many (1:M) relationship with the fact table.


/* This creates the dimension table that will use data from the `lab` table from `emr`. */
CREATE TABLE LAB_DIM
(Lab_ID INT AUTO_INCREMENT, -- PK
Cpt_Code VARCHAR(45) NOT NULL,
Lab_Name VARCHAR(255) NOT NULL,
CONSTRAINT PK_LAB_DIM PRIMARY KEY(Lab_ID));
-- LAB_DIM has a one-to-many (1:M) relationship with the fact table.


/* This creates the dimension table that will use data from the `diagnosis` table from `emr`. */
CREATE TABLE DIAGNOSIS_DIM
(Diagnosis_ID INT AUTO_INCREMENT, -- PK
Diag_Name VARCHAR(250) NOT NULL,
Icd10_Code VARCHAR(45) NOT NULL,
CONSTRAINT PK_DIAGNOSIS_DIM PRIMARY KEY(Diagnosis_ID));
-- DIAGNOSIS_DIM has a one-to-many (1:M) relationship with the fact table.


/* This creates the dimension table that will use data from the `visit` table from `emr`. */
CREATE TABLE TIME_DIM
(Time_ID INT AUTO_INCREMENT, -- PK
Patient_ID INT,
Provider_ID INT,
Visit_Date DATE,
CONSTRAINT PK_TIME_DIM PRIMARY KEY(Time_ID));
-- TIME_DIM has a one-to-many (1:M) relationship with the fact table.


/* This creates the fact table that includes the measure Procedure_Count.
   The level of granularity, aka grain, in the fact table
    is determined to be just the procedure count per visit.
   I chose a single fact table and this straightforward grain 
    because a simple focus on unique patient-provider pairs
    and associated procedure counts, while presented redundantly,
    would be a more financially useful data exploration,
    rather than attempt to replicate the raw data's complexity
    and increase the tendency of getting lost in the details.
   Also, the grain is determined using the pattern that
    every visit corresponds to one unique patient-provider pair.
   For the purpose of moving towards clear, effective EDA and data understanding,
    the only quantitatively salient measure in the fact table is Procedure_Count. */
CREATE TABLE PROCEDURE_CT_FACT
(Occurrence_ID INT AUTO_INCREMENT, -- PK
Patient_ID INT, -- foreign key ("FK") referencing PATIENT_DIM's PK
Provider_ID INT, -- FK referencing PROVIDER_DIM's PK
Procedure_ID INT, -- FK referencing PROCEDURE_DIM's PK
Lab_ID INT, -- FK referencing LAB_DIM's PK
Diagnosis_ID INT, -- FK referencing DIAGNOSIS_DIM's PK
Time_ID INT, -- FK referencing back to TIME_DIM's PK
Procedure_Count INT, -- In ETL processes, this incorporates COUNT() of `procedure_id` in table `clinical_procedures`.
CONSTRAINT PK_LTOF PRIMARY KEY(Occurrence_ID),
CONSTRAINT FK_PATIENT_DIM_PATIENT_ID FOREIGN KEY(Patient_ID)
 REFERENCES PATIENT_DIM(Patient_ID),
CONSTRAINT FK_PROVIDER_DIM_PROVIDER_ID FOREIGN KEY(Provider_ID)
 REFERENCES PROVIDER_DIM(Provider_ID),
CONSTRAINT FK_PROCEDURE_DIM_PROCEDURE_ID FOREIGN KEY(Procedure_ID)
 REFERENCES PROCEDURE_DIM(Procedure_ID),
CONSTRAINT FK_LAB_DIM_LAB_ID FOREIGN KEY(Lab_ID)
 REFERENCES LAB_DIM(Lab_ID),
CONSTRAINT FK_DIAGNOSIS_DIM_DIAGNOSIS_ID FOREIGN KEY(Diagnosis_ID)
 REFERENCES DIAGNOSIS_DIM(Diagnosis_ID),
CONSTRAINT FK_TIME_DIM_TIME_ID FOREIGN KEY(Time_ID)
 REFERENCES TIME_DIM(Time_ID));


