-- EXPLORATORY ANALYSIS USING SQL

-- Analyze by cuisine_group, nta_name neighborhood and borough
-- -- Top average scores
-- -- Top percent critical violations
-- -- Top 20 highest violations
-- Analyze by quarter and year
-- -- Inspections by quarter
-- -- Inspections by year
-- -- Average scores by year


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Create a view for 2025 only to minimize cte 
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CREATE OR REPLACE VIEW resto_clean_2025 AS
SELECT * FROM resto_clean
WHERE EXTRACT (YEAR FROM inspection_date) = 2025;


SELECT * FROM resto_clean_2025 LIMIT 3;


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Average Score and Percent critical per cuisine  
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- SELECT count(*) FROM resto_clean_2025;

SELECT  
    c.cuisine_group,  
	ROUND(AVG(score_numeric),1) AS average_score,
    ROUND(100* COUNT(*)::numeric/
		(SELECT count(*) FROM resto_clean_2025) , 2) AS percent_of_inspections,  
    COUNT(*) FILTER (WHERE critical_flag = 'Critical') AS critical_count,  
    ROUND(100*COUNT(*) FILTER (WHERE critical_flag = 'Critical')::numeric  
        / COUNT(*)::numeric, 1) AS pct_critical
FROM resto_clean_2025 r
LEFT JOIN dim_cuisine c  
    ON r.cuisine_description = c.cuisine_description  
GROUP BY c.cuisine_group  
ORDER BY average_score DESC;

/**
"cuisine_group"		"average_score"	"percent_of_inspections"	"critical_count"	"pct_critical"
"South Asian"		30.1	2.14	389	58.0
"African"			23.9	0.43	77	56.6
"Southeast Asian"	22.6	2.34	408	55.6
"Middle Eastern/North African"	22.2	1.52	248	51.9
"Chinese"			21.4	9.75	1625	53.1
"Asian Other"		20.9	1.91	323	53.8
"Vegetarian/Vegan"	20.0	0.45	70	49.6
"Latin American/Caribbean"	20.0	13.55	2185	51.4
"Jewish/Kosher"		19.2	1.27	204	51.1
"East Asian"		18.7	5.14	870	53.9
"European"			18.4	14.28	2285	51.0
"Fusion/Contemporary"	18.3	0.32	49	48.0
"Seafood"			17.4	0.78	122	50.0
"American"			16.1	16.86	2571	48.6
"Mediterranean"		15.9	1.00	149	47.5
"Fast Food"			15.5	4.57	663	46.3
"Beverages"			15.4	10.20	1579	49.3
"Light Meals"		15.4	3.11	468	48.0
"Bakery/Desserts"	14.8	8.98	1315	46.6
"Other/Not Specified"	14.4	1.39	206	47.1
**/

-- Indicated Action: Focusing on top 3 specific cuisines that have higher 
-- percent critical violations may not be worth the time since they only 
-- account for less than 5% of total violations, and are likely 
-- spread across all boroughs and neighborhoods.  
-- The scatterplot by neighborhood and borough and cuisine in Power BI
-- later confirms this.


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Average Score and Percent critical per neighborhood (NTA)  
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SELECT  
    n.nta_name,  
    r.boro,  
    ROUND(AVG(score_numeric),1) AS average_score,
    ROUND(100* COUNT(*)::numeric/
		(SELECT count(*) FROM resto_clean_2025) , 2) AS percent_of_inspections,  
    COUNT(*) FILTER (WHERE critical_flag = 'Critical') AS critical_count,  
    ROUND(100*COUNT(*) FILTER (WHERE critical_flag = 'Critical')::numeric  
        / COUNT(*)::numeric, 1) AS pct_critical	
FROM resto_clean_2025 r  
LEFT JOIN dim_nta n  
    ON r.nta = n.nta_code  
GROUP BY n.nta_name, r.boro
ORDER BY average_score DESC
LIMIT 20;

/**
"nta_name"								"boro"			"average_score"	"percent_of_inspections"	"critical_count"	"pct_critical"
"Port Richmond"							"Staten Island"	35.6			0.16	27	52.9
"Pomonok-Flushing Heights-Hillcrest"	"Queens"		28.3			0.21	39	60.0
"Kensington-Ocean Parkway"				"Brooklyn"		27.7			0.28	50	56.2
"Bronxdale"								"Bronx"			27.7			0.30	50	53.2
"Arden Heights"							"Staten Island"	27.0			0.02	4	80.0
"South Ozone Park"						"Queens"		26.7			0.73	127	55.7
"Jamaica"								"Queens"		26.1			1.01	163	51.3
"Homecrest"								"Brooklyn"		26.0			0.41	75	58.1
"Bellerose"								"Queens"		25.7			0.22	34	50.0
"Richmond Hill"							"Queens"		25.6			0.46	81	56.6
"Woodside"								"Queens"		24.9			0.61	108	56.3
"Morningside Heights"					"Manhattan"		24.5			0.61	96	49.7
"Elmhurst-Maspeth"						"Queens"		24.4			0.43	74	54.8
"Flatbush"								"Brooklyn"		24.2			0.84	136	51.5
"Flushing"								"Queens"		24.1			2.40	426	56.6
"Morrisania-Melrose"					"Bronx"			23.9			0.19	32	53.3
"Bath Beach"							"Brooklyn"		23.6			0.20	38	61.3
"Norwood"								"Bronx"			23.6			0.49	82	53.2
"Queensboro Hill"						"Queens"		23.4			0.14	27	61.4
"Todt Hill-Emerson 
Hill-Heartland 
Village-Lighthouse Hill"				"Staten Island"	23.4			0.23	41	56.9
**/

-- A lot of the top 20 scores come from Queens.


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Percent critical per borough
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SELECT  
    boro,  
    ROUND(AVG(score_numeric),1) AS average_score,
    ROUND(100* COUNT(*)::numeric/
		(SELECT count(*) FROM resto_clean_2025) , 2) AS percent_of_inspections,  
    COUNT(*) FILTER (WHERE critical_flag = 'Critical') AS critical_count,  
    ROUND(100*COUNT(*) FILTER (WHERE critical_flag = 'Critical')::numeric  
        / COUNT(*)::numeric, 1) AS pct_critical	
FROM resto_clean_2025  
GROUP BY boro  
ORDER BY average_score DESC;

/**
"boro"			"average_score"	"percent_of_inspections"	"critical_count"	"pct_critical"
"Queens"		19.8			26.98						4391				51.8
"Bronx"			17.8			10.50						1646				49.9
"Brooklyn"		17.6			23.53						3678				49.8
"Staten Island"	17.6			2.38						386					51.7
"Manhattan"		17.2			36.61						5705				49.6
**/

-- Queens has the highest average score
-- supporting the by-neighborhood finding earlier.


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Highest violations by group (violation type)
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SELECT  
	v.violation_group,
    count(v.violation_group) as violation_grp_counts
FROM resto_clean_2025 r
LEFT JOIN dim_violation v  
    ON r.violation_code = v.violation_code
GROUP BY v.violation_group
ORDER BY violation_grp_counts DESC;


/**
"violation_group"							"violation_grp_counts"
"Facility Maintenance / Lighting / 
				Dishwashing / Thermometers"	10723
"Food Protection / Cleanliness / HACCP"	6365
"Contamination / Hygiene / Vermin"			4587
"Temperature Control (TCS)"					4083
"Pest Control / Waste / Chemicals"			3122
"Equipment Construction / Thawing / 
					Food Contact Surfaces"	1521
"Plumbing / Water Supply / Ventilation"	560
"Administrative / Miscellaneous / 
							Adulteration"	252
"Food Source / Water / Raw Food Safety"	176
**/

-- Indicated actions:  Facility Maintenance, Lighting, Dishwashing, Thermometers 
-- are common violations. Focus education on these areas to improve safety.


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Top 20 Highest violations 
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
With cte as(
SELECT  
	violation_code,
    count(*) as violation_counts
FROM resto_clean_2025  r
GROUP BY violation_code
ORDER BY violation_counts DESC
)

-- Use violation_code for joining, not duplicated violation_descriptions
-- Extract description from dim_violation, not from resto_clean
SELECT DISTINCT cte.* ,
	v.violation_group,
	v.violation_description,
	r.critical_flag
FROM cte 
LEFT JOIN dim_violation v
	ON cte.violation_code = v.violation_code
LEFT JOIN resto_clean r
	ON cte.violation_code = r.violation_code
ORDER BY violation_counts DESC
LIMIT 20
;

/**
"violation_code"	"violation_counts"	"violation_group"	"violation_description"	"critical_flag"
"10F"	6130	"Facility Maintenance / Lighting / Dishwashing / Thermometers"	"Non-food contact surface improperly constructed. Unacceptable material used. Non-food contact surface or equipment improperly maintained and/or not properly sealed, raised, spaced or movable to allow accessibility for cleaning on all sides, above and underneath the unit."	"Not Critical"
"10B"	2532	"Facility Maintenance / Lighting / Dishwashing / Thermometers"	"Anti-siphonage or back-flow prevention device not provided where required; equipment or floor not properly drained; sewage disposal system in disrepair or not functioning properly. Condensation or liquid waste improperly disposed of."	"Not Critical"
"08A"	2395	"Pest Control / Waste / Chemicals"	"Establishment is not free of harborage or conditions conducive to rodents, insects or other pests."	"Not Critical"
"06C"	2265	"Food Protection / Cleanliness / HACCP"	"Food not protected from potential source of contamination during storage, preparation, transportation, display or service."	"Critical"
"06D"	2196	"Food Protection / Cleanliness / HACCP"	"Food contact surface not properly washed, rinsed and sanitized after each use and following any activity when contamination may have occurred."	"Critical"
"02G"	2024	"Temperature Control (TCS)"	"Cold food item held above 41º F (smoked fish and reduced oxygen packaged foods above 38 ºF) except during necessary preparation."	"Critical"
"02B"	1702	"Temperature Control (TCS)"	"Hot food item not held at or above 140º F."	"Critical"
"04L"	1380	"Contamination / Hygiene / Vermin"	"Evidence of mice or live mice in establishment's food or non-food areas."	"Critical"
"04N"	925	"Contamination / Hygiene / Vermin"	"Filth flies or food/refuse/sewage-associated (FRSA) flies present in facility’s food and/or non-food areas.  Filth flies include house flies, little house flies, blow flies, bottle flies and flesh flies.  Food/refuse/sewage-associated flies include fruit flies, drain flies and Phorid flies."	"Critical"
"10G"	822	"Facility Maintenance / Lighting / Dishwashing / Thermometers"	"Dishwashing and ware washing:  Cleaning and sanitizing of tableware, including dishes, utensils, and equipment deficient."	"Not Critical"
"04A"	775	"Contamination / Hygiene / Vermin"	"Food Protection Certificate (FPC) not held by manager or supervisor of food operations."	"Critical"
"09C"	720	"Equipment Construction / Thawing / Food Contact Surfaces"	"Design, construction, materials used or maintenance of food contact surface improper.  Surface not easily cleanable, sanitized and maintained."	"Not Critical"
"06E"	634	"Food Protection / Cleanliness / HACCP"	"Sanitized equipment or utensil, including in-use food dispensing utensil, improperly used or stored."	"Critical"
"06F"	579	"Food Protection / Cleanliness / HACCP"	"Wiping cloths not stored clean and dry, or in a sanitizing solution, between uses."	"Critical"
"08C"	548	"Pest Control / Waste / Chemicals"	"Pesticide not properly labeled or used by unlicensed individual.  Pesticide, other toxic chemical improperly used/stored. Unprotected, unlocked bait station used."	"Not Critical"
"06A"	532	"Food Protection / Cleanliness / HACCP"	"Personal cleanliness inadequate. Outer garment soiled with possible contaminant. Effective hair restraint not worn in an area where food is prepared."	"Critical"
"10H"	515	"Facility Maintenance / Lighting / Dishwashing / Thermometers"	"Proper sanitization not provided for utensil ware washing operation."	"Not Critical"
"04H"	505	"Contamination / Hygiene / Vermin"	"Raw, cooked or prepared food is adulterated, contaminated, cross-contaminated, or not discarded in accordance with HACCP plan."	"Critical"
"04M"	405	"Contamination / Hygiene / Vermin"	"Live roaches in facility's food or non-food area."	"Critical"
"05D"	380	"Plumbing / Water Supply / Ventilation"	"Hand washing facility not provided in or near food preparation area and toilet room. Hot and cold running water at adequate pressure to enable cleanliness of employees not provided at facility. Soap and an acceptable hand-drying device not provided."	"Critical"
**/

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Inspections over time (when to really start the trend visuals)
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Quarterly inspections really started around 2022

SELECT COUNT(camis),
	DATE_TRUNC('quarter', grade_date) as quarter
FROM resto_clean
GROUP BY quarter
ORDER BY quarter
;

/**
"count"	"quarter"
1	"2015-07-01 00:00:00"
7	"2015-10-01 00:00:00"
7	"2016-01-01 00:00:00"
39	"2016-04-01 00:00:00"
29	"2016-07-01 00:00:00"
43	"2016-10-01 00:00:00"
62	"2017-01-01 00:00:00"
50	"2017-04-01 00:00:00"
97	"2017-07-01 00:00:00"
51	"2017-10-01 00:00:00"
80	"2018-01-01 00:00:00"
127	"2018-04-01 00:00:00"
70	"2018-07-01 00:00:00"
82	"2018-10-01 00:00:00"
83	"2019-01-01 00:00:00"
211	"2019-04-01 00:00:00"
94	"2019-07-01 00:00:00"
94	"2019-10-01 00:00:00"
183	"2020-01-01 00:00:00"
956	"2021-07-01 00:00:00"
861	"2021-10-01 00:00:00"
4705	"2022-01-01 00:00:00"
4767	"2022-04-01 00:00:00"
6525	"2022-07-01 00:00:00"
8316	"2022-10-01 00:00:00"
11270	"2023-01-01 00:00:00"
9143	"2023-04-01 00:00:00"
5222	"2023-07-01 00:00:00"
6839	"2023-10-01 00:00:00"
9161	"2024-01-01 00:00:00"
9552	"2024-04-01 00:00:00"
10000	"2024-07-01 00:00:00"
12336	"2024-10-01 00:00:00"
10601	"2025-01-01 00:00:00"
9715	"2025-04-01 00:00:00"
11073	"2025-07-01 00:00:00"
**/


-- ~~~~~~~~~~~~~~~~~~~~
-- Inspections by year
-- ~~~~~~~~~~~~~~~~~~~~
SELECT EXTRACT(YEAR from inspection_date) AS year,
       count(camis) as inspections
FROM resto_clean
GROUP BY EXTRACT(YEAR from inspection_date)
ORDER BY EXTRACT(YEAR from inspection_date);

/**
"year"	"inspections"
2015	8
2016	118
2017	260
2018	359
2019	482
2020	183
2021	1817
2022	24313
2023	32474
2024	41049
2025	31389
**/


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Average scores over time (lower = better)
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SELECT ROUND( avg(score_numeric),2)AS avg_score,
	EXTRACT(YEAR from inspection_date) AS year
FROM resto_clean
GROUP BY EXTRACT(YEAR from inspection_date)
ORDER BY EXTRACT(YEAR from inspection_date)
;

/**
"avg_score"	"year"
8.25	2015
9.45	2016
10.54	2017
11.52	2018
12.63	2019
16.87	2020
11.60	2021
13.19	2022
15.16	2023
16.14	2024
18.09	2025
**/


-- Indicated action: Average scores are starting
-- to get worse, which may require more more 
-- education.

-- This is confirmed by lower grade A proportions in Power BI later.


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Percent Grade A over time
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


SELECT ROUND(100* COUNT(*) FILTER (WHERE grade = 'A'):: numeric/
			count(*)::numeric,2) AS pct_grade_a,
	   EXTRACT(YEAR from inspection_date) AS year
FROM resto_clean
GROUP BY EXTRACT(YEAR from inspection_date)
ORDER BY EXTRACT(YEAR from inspection_date)
;

/**
"pct_grade_a"	"year"
87.50	2015
96.61	2016
87.31	2017
83.29	2018
86.10	2019
66.12	2020
88.77	2021
78.61	2022
73.29	2023
71.74	2024
64.31	2025
**/


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Percent grade A by borough
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WITH by_year AS (
    SELECT
        boro as borough,
        EXTRACT(YEAR FROM inspection_date) AS yr,
        ROUND(100*COUNT(*) FILTER (WHERE grade = 'A')::numeric
            / COUNT(*)::numeric, 2) AS pct_gradeA
    FROM resto_clean
    GROUP BY boro, yr
)
SELECT *
FROM by_year
ORDER BY borough, yr;

/**
"borough"	"yr"	"pct_gradea"
"Bronx"	2016	100.00
"Bronx"	2017	71.43
"Bronx"	2018	100.00
"Bronx"	2019	82.35
"Bronx"	2020	100.00
"Bronx"	2021	90.35
"Bronx"	2022	78.66
"Bronx"	2023	68.31
"Bronx"	2024	70.49
"Bronx"	2025	63.30
"Brooklyn"	2016	82.35
"Brooklyn"	2017	73.68
"Brooklyn"	2018	94.23
"Brooklyn"	2019	74.22
"Brooklyn"	2020	51.43
"Brooklyn"	2021	85.99
"Brooklyn"	2022	77.63
"Brooklyn"	2023	73.99
"Brooklyn"	2024	71.74
"Brooklyn"	2025	65.59
"Manhattan"	2015	87.50
"Manhattan"	2016	98.04
"Manhattan"	2017	85.11
"Manhattan"	2018	80.69
"Manhattan"	2019	90.06
"Manhattan"	2020	75.00
"Manhattan"	2021	89.59
"Manhattan"	2022	79.52
"Manhattan"	2023	75.84
"Manhattan"	2024	73.89
"Manhattan"	2025	67.81
"Queens"	2016	100.00
"Queens"	2017	97.06
"Queens"	2018	81.95
"Queens"	2019	95.07
"Queens"	2020	62.16
"Queens"	2021	88.78
"Queens"	2022	77.04
"Queens"	2023	69.69
"Queens"	2024	68.37
"Queens"	2025	58.26
"Staten Island"	2016	100.00
"Staten Island"	2017	83.33
"Staten Island"	2018	73.68
"Staten Island"	2019	70.83
"Staten Island"	2020	100.00
"Staten Island"	2021	100.00
"Staten Island"	2022	84.82
"Staten Island"	2023	77.50
"Staten Island"	2024	75.50
"Staten Island"	2025	70.91
**/

-- Indicated Action: Steady decline in percent grade A
-- per borough in past 4 years indicates a need for a
-- revitalized education program to boost grade A scores.
