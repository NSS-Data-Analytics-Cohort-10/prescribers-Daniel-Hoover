--1. a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT 
	x.npi,
	SUM(total_claim_count) as claim_count,
	nppes_provider_last_org_name as last_name
FROM prescription AS p
INNER JOIN prescriber AS x
ON p.npi=x.npi
GROUP BY x.npi, last_name
ORDER BY claim_count DESC
LIMIT 1;


--b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT 
	nppes_provider_first_name AS first_name,
	nppes_provider_last_org_name AS last_name,
	specialty_description AS specialty,
	SUM(total_claim_count) AS claim_count
FROM prescriber AS p
INNER JOIN prescription AS x
ON p.npi=x.npi
GROUP BY first_name, last_name, specialty
ORDER BY claim_count DESC
LIMIT 1;

--2. a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT
	specialty_description AS specialty,
	SUM(total_claim_count) AS claim_count
FROM prescriber AS p
INNER JOIN prescription AS x
ON p.npi=x.npi
GROUP BY specialty
ORDER BY claim_count DESC;


--b. Which specialty had the most total number of claims for opioids?
SELECT
	p.specialty_description AS specialty,
	SUM(x.total_claim_count) AS claim_count
	FROM prescriber AS p
INNER JOIN prescription AS x
	ON p.npi=x.npi
LEFT JOIN drug AS d
	ON x.drug_name=d.drug_name
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty
ORDER BY claim_count DESC;

--Nurse Practitioner has the most claims with 900845 claims for opioids


--c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

SELECT
	specialty_description,
	SUM(total_claim_count)
FROM prescriber AS scrib
FULL JOIN prescription AS scrip
ON scrib.npi=scrip.npi
GROUP BY specialty_description
HAVING SUM(total_claim_count) IS NULL
ORDER By specialty_description


--d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?
--HALP!!!

SELECT
	p.specialty_description AS specialty,
	COUNT(x.total_claim_count) AS claim_count,
	(CASE WHEN d.opioid_drug_flag ='Y' THEN COUNT(opioid_drug_flag)END) AS boogers,
	(COUNT(x.total_claim_count)*100/(SELECT
						SUM(total_claim_Count)
						FROM prescription)) AS percent
FROM prescriber AS p
INNER JOIN prescription AS x
	ON p.npi=x.npi
LEFT JOIN drug AS d
	ON x.drug_name=d.drug_name
WHERE opioid_drug_flag='Y'
GROUP BY specialty, d.opioid_drug_flag
ORDER BY percent DESC;


SELECT 

SELECT
	npi,
	COUNT(total_claim_count) AS claim_count,
	ROUND(total_claim_count*100/SUM(total_claim_count),1) AS percent
FROM prescription
WHERE npi=1003013160
GROUP BY total_claim_count, npi


/*SELECT
	p.specialty_description AS specialty,
	COUNT(x.total_claim_count) AS claim_count,
	(COUNT(x.total_claim_count)/SUM(x.total_claim_count)*100) AS percent
	FROM prescriber AS p
INNER JOIN prescription AS x
	ON p.npi=x.npi
LEFT JOIN drug AS d
	ON x.drug_name=d.drug_name
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty, x.total_claim_count
ORDER BY percent DESC;*/

--General Acute Care Hospital and Critical Care both have a 9.1 of total opioid claims%

--3. a. Which drug (generic_name) had the highest total drug cost?
SELECT
	generic_name,
	SUM(total_drug_cost)
FROM prescription AS x
LEFT JOIN drug AS d
ON x.drug_name=d.drug_name
GROUP BY generic_name
ORDER BY SUM(total_drug_cost) DESC

--Insulin has the has the highest total drug cost

--b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT
	generic_name,
	CAST(SUM(total_drug_cost)/SUM(total_day_supply) AS money) AS highest
FROM prescription AS x
LEFT JOIN drug AS d
ON x.drug_name=d.drug_name
GROUP BY generic_name
ORDER BY highest DESC;



--select *
--FROM prescription
--limit 10

--4. a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

SELECT
	drug_name,
	(CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag ='Y' THEN 'antibiotic'
	ELSE 'neither' END) AS drug_type
FROM drug


--b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
WITH ty AS (SELECT
				drug_name,
				(CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
				WHEN antibiotic_drug_flag ='Y' THEN 'antibiotic'
				ELSE 'neither' END) AS drug_type
			FROM drug)
SELECT
	CAST(SUM(total_drug_cost) AS money) AS tot,
	ty.drug_type
FROM prescription AS p
LEFT JOIN ty
ON p.drug_name=ty.drug_name
GROUP BY ty.drug_type
ORDER BY tot DESC	

--Opioids cost more than antibiotics

--5. a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.


SELECT DISTINCT(cbsaname)
FROM cbsa AS c
WHERE cbsaname LIKE '%TN%';

--10 in TN

--b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

WITH pop AS
	(SELECT *	
	FROM population)
SELECT		
	cbsaname,
	SUM(pop.population)
FROM cbsa AS c
INNER JOIN pop
ON pop.fipscounty= c.fipscounty
GROUP BY cbsaname
ORDER BY SUM(pop.population) DESC;

--Nasville-Davidson-Murfreesboro-Franklin has the highest population with 1,830,410, while Morristown has the smallest with 116,352

/*SELECT *
FROM fips_county AS f
FULL JOIN population AS p
ON f.county=p.fipscounty
WHERE f.state = 'TN'*/

--c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
WITH big AS 
	(SELECT
	MAX(population) AS biggest,
	 fipscounty
	FROM population
	GROUP BY fipscounty
	ORDER BY biggest DESC)
	
SELECT 
	county,
	big.biggest
FROM fips_county AS f
LEFT JOIN big
ON f.fipscounty = big.fipscounty
WHERE big.fipscounty NOT IN(SELECT fipscounty
						   FROM cbsa)
ORDER BY big.biggest DESC

--OR 

SELECT *
FROM population
INNER JOIN fips_county AS fc 
USING(fipscounty)
LEFT JOIN cbsa USING(figpscounty)
WHERE cbsa IS NULL
ORDER BY population DESC
LIMIT 1;

--Sevier county is the largest

--6. a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT
	drug_name,
	total_claim_count
FROM prescription
WHERE total_claim_count >= 3000


--b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
WITH ty AS (SELECT
				drug_name,
				(CASE WHEN opioid_drug_flag = 'Y' THEN 'true'
				ELSE 'false' END) AS opioid
			FROM drug)
SELECT
	p.drug_name,
	total_claim_count,
	opioid
FROM prescription AS p
INNER JOIN ty
ON p.drug_name = ty.drug_name
WHERE total_claim_count >= 3000 

--c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

WITH ty AS (SELECT
				drug_name,
				(CASE WHEN opioid_drug_flag = 'Y' THEN 'true'
				ELSE 'false' END) AS opioid
			FROM drug)
SELECT
	p.drug_name,
	total_claim_count,
	opioid,
	nppes_provider_last_org_name,
	nppes_provider_first_name
FROM prescription AS p
INNER JOIN ty
ON p.drug_name = ty.drug_name
INNER JOIN prescriber AS ber
ON p.npi=ber.npi
WHERE total_claim_count >= 3000 


--7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

    --a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.			

WITH ty AS (SELECT
				drug_name
			FROM drug
		   	WHERE opioid_drug_flag = 'Y')
SELECT 
	npi,
	d.drug_name
FROM prescriber AS scrib
CROSS JOIN drug AS d
INNER JOIN ty
ON d.drug_name=ty.drug_name
WHERE scrib.specialty_description = 'Pain Management' AND scrib.nppes_provider_city = 'NASHVILLE'
GROUP BY d.drug_name, npi

--b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

WITH ty AS (SELECT
				drug_name
			FROM drug
		   	WHERE opioid_drug_flag = 'Y'),
			
drug_sum AS(SELECT
		drug_name,
		SUM(total_claim_count) AS total
		FROM prescription
		GROUP BY drug_name
		ORDER BY SUM(total_claim_count) DESC)
SELECT 
	scrib.npi,
	d.drug_name,
	total
FROM prescriber AS scrib
CROSS JOIN drug AS d
INNER JOIN ty
ON d.drug_name=ty.drug_name
FULL JOIN drug_sum AS dsum
ON d.drug_name=dsum.drug_name
WHERE scrib.specialty_description = 'Pain Management' AND scrib.nppes_provider_city = 'NASHVILLE'
GROUP BY scrib.npi, d.drug_name,dsum.total

SELECT 
	p.npi,
	d.drug_name,
	SUM(p2.total_claim_count)
FROM prescriber AS p
CROSS JOIN drug AS d
FULL JOIN prescription AS p2
	USING (drug_name)
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y'
GROUP BY d.drug_name, p.npi
ORDER BY SUM(p2.total_claim_count) DESC;


--c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
WITH ty AS (SELECT
				drug_name
			FROM drug
		   	WHERE opioid_drug_flag = 'Y'),
			
drug_sum AS(SELECT
		drug_name,
		SUM(total_claim_count) AS total
		FROM prescription
		GROUP BY drug_name
		ORDER BY SUM(total_claim_count) DESC)
SELECT 
	scrib.npi,
	d.drug_name,
	COALESCE(total, '0')
FROM prescriber AS scrib
CROSS JOIN drug AS d
INNER JOIN ty
ON d.drug_name=ty.drug_name
FULL JOIN drug_sum AS dsum
ON d.drug_name=dsum.drug_name
WHERE scrib.specialty_description = 'Pain Management' AND scrib.nppes_provider_city = 'NASHVILLE'
GROUP BY scrib.npi, d.drug_name,dsum.total
--OR 
SELECT 
	p.npi,
	d.drug_name,
	COALESCE(SUM(p2.total_claim_count), '0')
FROM prescriber AS p
CROSS JOIN drug AS d
FULL JOIN prescription AS p2
	USING (drug_name)
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y'
GROUP BY d.drug_name, p.npi
ORDER BY SUM(p2.total_claim_count) DESC;

