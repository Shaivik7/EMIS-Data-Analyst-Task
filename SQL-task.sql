-- Part 1
-- Getting patient counts across different postcodes and grouping them by with gender and postcode to identify most suitable postcodes
SELECT postcode, gender, COUNT(patient_id) AS PatientCount
FROM dbo.patient
GROUP BY postcode, gender
ORDER BY PatientCount DESC;

-- PART 2
-- Getting Asthma patients by creating a temp table to hold values separate from our actual tables from the highest patient count postcode from part 1 and applying other filters
IF OBJECT_ID('tempdb..#PatientObs') IS NOT NULL
    DROP TABLE #PatientObs;
SELECT 
    dbo.patient.registration_guid,
    patient_id,
    CONCAT(patient_givenname, ' ', patient_surname) AS full_name,
    emis_original_term, 
    postcode, 
    DATEDIFF(YEAR, dbo.patient.date_of_birth, GETDATE()) AS age, 
    gender
INTO #PatientObs
FROM dbo.observation
FULL OUTER JOIN dbo.patient ON dbo.observation.registration_guid = dbo.patient.registration_guid
WHERE dbo.observation.snomed_concept_id IN (
    SELECT snomed_concept_id
    FROM dbo.clinical_codes
    WHERE refset_simple_id = 999012891000230104
)AND dbo.patient.postcode = 'LS99 9ZZ'
AND dbo.observation.snomed_concept_id NOT IN (
        SELECT snomed_concept_id
        FROM dbo.clinical_codes
        WHERE refset_simple_id = '999004211000230104'
    )
AND snomed_concept_id NOT IN (27113001)
AND dbo.observation.snomed_concept_id NOT IN (
        SELECT snomed_concept_id
        FROM dbo.clinical_codes
        WHERE refset_simple_id = '999011571000230107'
    )
AND dbo.observation.opt_out_9nu0_flag = 'FALSE';

-- Used common table expression to remove duplicates from the PatientObs table
WITH CTE AS (
    SELECT 
        full_name
        patient_id,
        emis_original_term,
        ROW_NUMBER() OVER (PARTITION BY patient_id ORDER BY emis_original_term) AS RowNum
    FROM #PatientObs
)
DELETE FROM CTE WHERE RowNum > 1;

SELECT * FROM #PatientObs;