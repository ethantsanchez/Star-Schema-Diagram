/* Ethan Sanchez: etl_star_migration.sql */
USE ets103;

/* This comment block was part of the organizational setup process;
checks were added to each criterion once each INSERT statement was successful
for the following dimension tables.

START SMALL TABLES
PATIENT_DIM (emr - patient - patient_id/first_name/last_name/dob/gender) √
PROVIDER_DIM (emr - provider - provider_id/first_name/last_name/specialty) √
PROCEDURE_DIM (emr - clinical_procedures - procedure_id/icd10_code/proc_name/description) √
LAB_DIM (emr - lab - lab_id/cpt_code/lab_name) √
DIAGNOSIS_DIM (emr - diagnosis - diagnosis_id/name/icd10_code) √
TIME_DIM (emr - visit - visit_id/patient_id/provider_id/visit_date) √
*/


/* Migrating data into the dimension table PATIENT_DIM, from the EMR table `patient` */
DESC PATIENT_DIM;

SELECT * FROM emr.patient; -- This table (and further EMR tables) is part of the original operational data.

INSERT INTO PATIENT_DIM
(Patient_ID,First_Name,Last_Name,Date_Of_Birth,Gender)
SELECT * FROM emr.patient;

SELECT * FROM PATIENT_DIM;


/* Migrating data into the dimension table PROVIDER_DIM, from the EMR table `provider` */
DESC PROVIDER_DIM;

SELECT * FROM emr.provider;

INSERT INTO PROVIDER_DIM
(Provider_ID,First_Name,Last_Name,Specialty)
SELECT * FROM emr.provider;

SELECT * FROM PROVIDER_DIM;


/* Migrating data into the dimension table PROCEDURE_DIM, from the EMR table `clinical_procedures` */
DESC PROCEDURE_DIM;

SELECT * FROM emr.clinical_procedures; -- This shows the procedure_id values go from 0 to 499.
-- Since the AUTO_INCREMENT does not perform accurately if the first row has index 0
--  (as per previous failed trials), the data when migrated is reset to start at index 1.

INSERT INTO PROCEDURE_DIM 
(Icd10_Code,Proc_Name,Descript) 
SELECT icd10_code, proc_name, description FROM emr.clinical_procedures;

SELECT * FROM PROCEDURE_DIM; -- This verifies the new Procedure_ID values go from 1 to 500.
-- Note that due to MySQL Workbench limitations, every shown surrogate key ID
--  had to be artificially incremented by one.
-- For example, if this dimension table's Procedure_ID = 3,
--  then this refers to this original EMR table's lab_id = 2.

--    The two SQL statements below, in comments,
--     are just in case the INSERT statement was run more than once.
-- DELETE FROM PROCEDURE_DIM;
-- ALTER TABLE PROCEDURE_DIM AUTO_INCREMENT = 1;


/* Migrating data into the dimension table LAB_DIM, from the EMR table `lab` */
DESC LAB_DIM;

SELECT * FROM emr.lab; -- This shows the lab_id values go from 0 to 499.
-- Since the AUTO_INCREMENT does not perform accurately if the first row has index 0
--  (as per previous failed trials), the data when migrated is reset to start at index 1.

INSERT INTO LAB_DIM
(Cpt_Code,Lab_Name)
SELECT cpt_code, lab_name FROM emr.lab;

SELECT * FROM LAB_DIM; -- This verifies the new Lab_ID values go from 1 to 500.
-- Due to MySQL Workbench limitations, every shown surrogate key ID
--  had to be artificially incremented by one.
-- For example, if this dimension table's Lab_ID = 3,
--  then this refers to this original EMR table's lab_id = 2.


/* Migrating data into the dimension table DIAGNOSIS_DIM, from the EMR table `diagnosis` */
DESC DIAGNOSIS_DIM;

SELECT * FROM emr.diagnosis; -- This shows the diagnosis_id values go from 0 to 499.
-- Since the AUTO_INCREMENT does not perform accurately if the first row has index 0
--  (as per previous failed trials), the data when migrated is reset to start at index 1.

INSERT INTO DIAGNOSIS_DIM
(Diag_Name,Icd10_Code)
SELECT name, icd10_code FROM emr.diagnosis;

SELECT * FROM DIAGNOSIS_DIM; -- This verifies the new Diagnosis_ID values go from 1 to 500.
-- Because of MySQL Workbench limitations, every shown surrogate key ID
--  had to be artificially incremented by one.
-- For example, if this dimension table's Diagnosis_ID = 3,
--  then this refers to this original EMR table's diagnosis_id = 2.


/* Migrating data into the dimension table TIME_DIM, from the EMR table `visit` */
DESC TIME_DIM;

SELECT * FROM emr.visit; -- This shows the visit_id values go from 0 to 305.
-- Since the AUTO_INCREMENT does not perform accurately if the first row has index 0
--  (as per previous failed trials), the data when migrated is reset to start at index 1.

INSERT INTO TIME_DIM
(Patient_ID,Provider_ID,Visit_Date)
SELECT patient_id, provider_id, visit_date FROM emr.visit;

SELECT * FROM TIME_DIM; -- This verifies the new Time_ID values go from 1 to 306.
-- Due to MySQL Workbench limitations, every shown surrogate key ID
--  had to be artificially incremented by one.
-- For instance, if this dimension table's Time_ID = 3,
--  then this refers to this original EMR table's visit_id = 2.


/* Migrating data into the fact table PROCEDURE_CT_FACT, from several EMR tables
    including `visit`, `visit_diagnosis`, `visit_lab`, and `visit_procedure`,
    alongside a workaround COUNT() quantitative measure to fulfill given analytics requirements. */
DESC PROCEDURE_CT_FACT;

SELECT v.patient_id, v.provider_id,
p.procedure_id, l.lab_id, d.diagnosis_id, v.visit_id,
c.Procedure_Count AS Procedure_Count_Of_This_Visit_ID
FROM emr.visit AS v
JOIN emr.visit_diagnosis AS d ON
	v.visit_id = d.visit_id
JOIN emr.visit_lab AS l ON
	v.visit_id = l.visit_id
JOIN emr.visit_procedure AS p ON
	v.visit_id = p.visit_id
JOIN (SELECT v.visit_id,
COUNT(p.procedure_id) AS Procedure_Count
FROM emr.visit AS v
JOIN emr.visit_procedure AS p ON
	v.visit_id = p.visit_id
GROUP BY visit_id
ORDER BY visit_id) AS c ON
	v.visit_id = c.visit_id
ORDER BY visit_id;
-- Note: The Procedure_Count_Of_This_Visit_ID values
--  are repeated as many times as each visit_id value appears.
-- For example, if Procedure_Count_of_This_Visit_ID = 10 for visit_id = 1,
--  this means there were a total of 10 procedures on the 1st visit,
--  NOT meaning that every single row had 10 procedures.
-- The 10-procedure count is strictly associated with visit #1,
--  a visit that is uniquely associated with a single patient-provider pair.
-- These Procedure_Count_of_This_Visit_ID values appear redundantly
--  and are repeated excessively as a consequence
--  of the star schema design that is implemented on this EMR data.

-- Below is the query, in parentheses from above after the last JOIN,
--  that was used to count procedures per visit.
SELECT v.visit_id, COUNT(p.procedure_id) AS Procedure_Count
FROM emr.visit AS v
JOIN emr.visit_procedure AS p ON
	v.visit_id = p.visit_id
GROUP BY visit_id
ORDER BY visit_id;

-- This INSERT statement creates the fact table,
--  which contains its primary key being an auto-incrementing surrogate key,
--  all foreign keys referencing previous dimension tables,
--  and a quantitative measure keeping track of the grain,
--  the number of procedures that occurred per visit 
--  (aka per unique patient-provider pair).
INSERT INTO PROCEDURE_CT_FACT
(Patient_ID,Provider_ID,Procedure_ID,Lab_ID,Diagnosis_ID,Time_ID,Procedure_Count)
SELECT v.patient_id, v.provider_id,
p.procedure_id, l.lab_id, d.diagnosis_id, v.visit_id,
c.Procedure_Count AS Procedure_Count_Of_This_Visit_ID
FROM emr.visit AS v
JOIN emr.visit_diagnosis AS d ON
	v.visit_id = d.visit_id
JOIN emr.visit_lab AS l ON
	v.visit_id = l.visit_id
JOIN emr.visit_procedure AS p ON
	v.visit_id = p.visit_id
JOIN (SELECT v.visit_id,
COUNT(p.procedure_id) AS Procedure_Count
FROM emr.visit AS v
JOIN emr.visit_procedure AS p ON
	v.visit_id = p.visit_id
GROUP BY visit_id
ORDER BY visit_id) AS c ON
	v.visit_id = c.visit_id
ORDER BY visit_id;

SELECT * FROM PROCEDURE_CT_FACT;
-- This fact table has redundant and duplicate rows as per star schema design,
--  though the attributes of most interest, regarding the grain,
--  are Time_ID and Procedure_Count.
-- PROCEDURE_CT_FACT demonstrates a highly denormalized table
--  that provides all possible combinations
--  from the given data, notably from EMR tables `visit`, `visit_diagnosis`,
--  `visit_lab`, and `visit_procedure`.
-- Several of these EMR tables provide simply a `visit_id` and the noted information,
--  leading to several combinations that excessively repeat said information.
-- To simplify understanding the grain, however, the final two attributes (of most interest)
--  in PROCEDURE_CT_FACT always pair a Time_ID value with its unique Procedure_Count,
--  ensuring that the grain, the number of procedures per visit, can easily be found
--  in the fact table.
-- Additionally, the surrogate key `Occurrence_ID` was generated for PROCEDURE_CT_FACT.


