/* Ethan Sanchez: integrity_checks.sql */
USE ets103;

/* Data Integrity Check #1 */
SELECT COUNT(ea.patient_id) AS Original_Patient_Row_Count,
 COUNT(a.Patient_ID) AS Dimension_Patient_Row_Count
FROM emr.patient AS ea, PATIENT_DIM AS a
WHERE ea.patient_id = a.Patient_ID;
-- The row counts match between original and dimension patient tables: 50 rows.


/* Data Integrity Check #2 */
SELECT COUNT(er.provider_id) AS Original_Provider_Row_Count,
 COUNT(r.Provider_ID) AS Dimension_Provider_Row_Count
FROM emr.provider AS er, PROVIDER_DIM AS r
WHERE er.provider_id = r.Provider_ID;
-- The row counts match between original and dimension provider tables: 50 rows.


/* Data Integrity Check #3 */
SELECT COUNT(eo.procedure_id) AS Original_Procedure_Row_Count,
 COUNT(o.Procedure_ID) AS Dimension_Procedure_Row_Count
FROM emr.clinical_procedures AS eo, PROCEDURE_DIM AS o
WHERE eo.procedure_id = o.Procedure_ID - 1;
-- The minus 1 accounts for the MySQL Workbench limitations
--  requiring the index of PROCEDURE_DIM to be incremented by 1
--  from the original EMR table `clinical_procedures`.
-- The row counts match between original and dimension procedure tables: 500 rows.


/* Data Integrity Check #4 */
SELECT COUNT(el.lab_id) AS Original_Lab_Row_Count,
 COUNT(l.Lab_ID) AS Dimension_Lab_Row_Count
FROM emr.lab AS el, LAB_DIM AS l
WHERE el.lab_id = l.Lab_ID - 1;
-- The minus 1 accounts for the MySQL Workbench limitations
--  requiring the index of LAB_DIM to be incremented by 1
--  from the original EMR table `lab`.
-- The row counts match between original and dimension lab tables: 500 rows.


/* Data Integrity Check #5 */
SELECT COUNT(ed.diagnosis_id) AS Original_Diagnosis_Row_Count,
 COUNT(d.Diagnosis_ID) AS Dimension_Diagnosis_Row_Count
FROM emr.diagnosis AS ed, DIAGNOSIS_DIM AS d
WHERE ed.diagnosis_id = d.Diagnosis_ID - 1;
-- The minus 1 accounts for the MySQL Workbench limitations
--  requiring the index of DIAGNOSIS_DIM to be incremented by 1
--  from the original EMR table `diagnosis`.
-- The row counts match between original and dimension diagnosis tables: 500 rows.


/* Data Integrity Check #6 */
SELECT COUNT(et.visit_id) AS Original_Time_Row_Count,
 COUNT(t.Time_ID) AS Dimension_Time_Row_Count
FROM emr.visit AS et, TIME_DIM AS t
WHERE et.visit_id = t.Time_ID - 1;
-- The minus 1 accounts for the MySQL Workbench limitations
--  requiring the index of TIME_DIM to be incremented by 1
--  from the original EMR table `visit`.
-- The row counts match between original and dimension time tables: 306 rows.


/* Data Integrity Check #7 */
SELECT SUM(ISNULL(Procedure_ID)) AS Num_Nulls_PROCEDURE_DIM
FROM PROCEDURE_DIM; -- Procedure_ID is a surrogate key. Output is 0; no NULLs in this field.


/* Data Integrity Check #8 */
SELECT SUM(ISNULL(Lab_ID)) AS Num_Nulls_LAB_DIM
FROM LAB_DIM; -- Lab_ID is a surrogate key. Output is 0; no NULLs in this field.


/* Data Integrity Check #9 */
SELECT SUM(ISNULL(Diagnosis_ID)) AS Num_Nulls_DIAGNOSIS_DIM
FROM DIAGNOSIS_DIM; -- Diagnosis_ID is a surrogate key. Output is 0; no NULLs in this field.


/* Data Integrity Check #10 */
SELECT SUM(ISNULL(Time_ID)) AS Num_Nulls_TIME_DIM
FROM TIME_DIM; -- Time_ID is a surrogate key. Output is 0; no NULLs in this field.


/* Data Integrity Check #11 */
SELECT SUM(ISNULL(Occurrence_ID)) AS Num_Nulls_PROCEDURE_CT_FACT
FROM PROCEDURE_CT_FACT; -- Occurrence_ID is a surrogate key. Output is 0; no NULLs in this field.
    

/* Data Integrity Check #12 */
SELECT DISTINCT pcf.Patient_ID AS Fact_Patient_ID,
 ad.Patient_ID AS Dim_Patient_ID
FROM PROCEDURE_CT_FACT AS pcf
LEFT JOIN PATIENT_DIM AS ad ON
	pcf.Patient_ID = ad.Patient_ID
UNION
SELECT DISTINCT pcf.Patient_ID AS Fact_Patient_ID,
 ad.Patient_ID AS Dim_Patient_ID
FROM PROCEDURE_CT_FACT AS pcf
RIGHT JOIN PATIENT_DIM AS ad ON
	pcf.Patient_ID = ad.Patient_ID
ORDER BY Dim_Patient_ID;
-- Since the foreign key values denoted by Fact_Patient_ID
--  are a subset of the primary key values denoted by Dim_Patient_ID,
--  this constraint follows referential integrity rules.

    
/* Data Integrity Check #13 */
SELECT DISTINCT pcf.Provider_ID AS Fact_Provider_ID,
 rd.Provider_ID AS Dim_Provider_ID
FROM PROCEDURE_CT_FACT AS pcf
LEFT JOIN PROVIDER_DIM AS rd ON
	pcf.Provider_ID = rd.Provider_ID
UNION
SELECT DISTINCT pcf.Provider_ID AS Fact_Provider_ID,
 rd.Provider_ID AS Dim_Provider_ID
FROM PROCEDURE_CT_FACT AS pcf
RIGHT JOIN PROVIDER_DIM AS rd ON
	pcf.Provider_ID = rd.Provider_ID
ORDER BY Dim_Provider_ID;
-- Since the foreign key values denoted by Fact_Provider_ID
--  are a subset of the primary key values denoted by Dim_Provider_ID,
--  this constraint follows referential integrity rules.


/* Data Integrity Check #14 */
SELECT DISTINCT pcf.Procedure_ID AS Fact_Procedure_ID,
 od.Procedure_ID - 1 AS Dim_Procedure_ID_Minus_One
FROM PROCEDURE_CT_FACT AS pcf
LEFT JOIN PROCEDURE_DIM AS od ON
	pcf.Procedure_ID = od.Procedure_ID - 1
UNION
SELECT DISTINCT pcf.Procedure_ID AS Fact_Procedure_ID,
 od.Procedure_ID - 1 AS Dim_Procedure_ID_Minus_One
FROM PROCEDURE_CT_FACT AS pcf
RIGHT JOIN PROCEDURE_DIM AS od ON
	pcf.Procedure_ID = od.Procedure_ID - 1
ORDER BY Dim_Procedure_ID_Minus_One;
-- Due to MySQL Workbench limitations/errors with AUTO_INCREMENT = 0,
--  Dim_Procedure_ID - 1, aka Dim_Procedure_ID_Minus_One,
--  is used to accurately represent the given data's indices.
-- Since the foreign key values denoted by Fact_Procedure_ID
--  are a subset of the primary key values denoted by Dim_Procedure_ID_Minus_One,
--  this constraint follows referential integrity rules.


/* Data Integrity Check #15 */
SELECT DISTINCT pcf.Lab_ID AS Fact_Lab_ID,
 ld.Lab_ID - 1 AS Dim_Lab_ID_Minus_One
FROM PROCEDURE_CT_FACT AS pcf
LEFT JOIN LAB_DIM AS ld ON
	pcf.Lab_ID = ld.Lab_ID - 1
UNION
SELECT DISTINCT pcf.Lab_ID AS Fact_Lab_ID,
 ld.Lab_ID - 1 AS Dim_Lab_ID_Minus_One
FROM PROCEDURE_CT_FACT AS pcf
RIGHT JOIN LAB_DIM AS ld ON
	pcf.Lab_ID = ld.Lab_ID - 1
ORDER BY Dim_Lab_ID_Minus_One;
-- Due to MySQL Workbench limitations/errors with AUTO_INCREMENT = 0,
--  Dim_Lab_ID - 1, aka Dim_Lab_ID_Minus_One,
--  is used to accurately represent the given data's indices.
-- Since the foreign key values denoted by Fact_Lab_ID
--  are a subset of the primary key values denoted by Dim_Lab_ID_Minus_One,
--  this constraint follows referential integrity rules.


/* Data Integrity Check #16 */
SELECT DISTINCT pcf.Diagnosis_ID AS Fact_Diagnosis_ID,
 dd.Diagnosis_ID - 1 AS Dim_Diagnosis_ID_Minus_One
FROM PROCEDURE_CT_FACT AS pcf
LEFT JOIN DIAGNOSIS_DIM AS dd ON
	pcf.Diagnosis_ID = dd.Diagnosis_ID - 1
UNION
SELECT DISTINCT pcf.Diagnosis_ID AS Fact_Diagnosis_ID,
 dd.Diagnosis_ID - 1 AS Dim_Diagnosis_ID_Minus_One
FROM PROCEDURE_CT_FACT AS pcf
RIGHT JOIN DIAGNOSIS_DIM AS dd ON
	pcf.Diagnosis_ID = dd.Diagnosis_ID - 1
ORDER BY Dim_Diagnosis_ID_Minus_One;
-- Due to MySQL Workbench limitations/errors with AUTO_INCREMENT = 0,
--  Dim_Diagnosis_ID - 1, aka Dim_Diagnosis_ID_Minus_One,
--  is used to accurately represent the given data's indices.
-- Since the foreign key values denoted by Fact_Diagnosis_ID
--  are a subset of the primary key values denoted by Dim_Diagnosis_ID_Minus_One,
--  this constraint follows referential integrity rules.


/* Data Integrity Check #17 */
SELECT DISTINCT pcf.Time_ID AS Fact_Time_ID,
 td.Time_ID - 1 AS Dim_Time_ID_Minus_One
FROM PROCEDURE_CT_FACT AS pcf
LEFT JOIN TIME_DIM AS td ON
	pcf.Time_ID = td.Time_ID - 1
UNION
SELECT DISTINCT pcf.Time_ID AS Fact_Time_ID,
 td.Time_ID - 1 AS Dim_Time_ID_Minus_One
FROM PROCEDURE_CT_FACT AS pcf
RIGHT JOIN TIME_DIM AS td ON
	pcf.Time_ID = td.Time_ID - 1
ORDER BY Dim_Time_ID_Minus_One;
-- Due to MySQL Workbench limitations/errors with AUTO_INCREMENT = 0,
--  Dim_Time_ID - 1, aka Dim_Time_ID_Minus_One,
--  is used to accurately represent the given data's indices.
-- Since the foreign key values denoted by Fact_Time_ID
--  are a subset of the primary key values denoted by Dim_Time_ID_Minus_One,
--  this constraint follows referential integrity rules.


