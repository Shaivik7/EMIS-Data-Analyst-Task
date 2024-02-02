-- Part 1
-- Getting patient counts across different postcodes and grouping them by with gender and postcode to identify most suitable postcodes
SELECT postcode, gender, COUNT(patient_id) AS PatientCount
FROM dbo.patient
GROUP BY postcode, gender
ORDER BY PatientCount DESC;



