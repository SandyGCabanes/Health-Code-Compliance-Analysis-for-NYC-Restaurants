-- This code details the table creation and loading using postgres.
-- Workflow:

-- Create table resto -> copy from C:/data/*.csv file -> create resto_raw
-- resto_raw -> resto_stage -> resto_clean
-- detect columns with 'date' and convert to timestamp
-- drop empty column 'location_point1'

-- Pre-work: Replace spaces in headers with underscore, Use UTF-8 encoding for csv file in Notepad++

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Create the table structure
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~
DROP TABLE IF EXISTS resto;

CREATE TABLE resto (
    camis text,
    dba text,
    boro text,
    building text,
    street text,
    zipcode text,
    phone text,
    cuisine_description text,
    inspection_date text,
    action text,
    violation_code text,
    violation_description text,
    critical_flag text,
    score text,
    grade text,
    grade_date text,
    record_date text,
    inspection_type text,
    latitude text,
    longitude text,
    community_board text,
    council_district text,
    census_tract text,
    bin text,
    bbl text,
    nta text,
    location_point1 text
);

-- Pre-work: copy the csv file into the C:/data folder so postgres can access it
COPY resto (
    camis, dba, boro, building, street, zipcode, phone,
    cuisine_description, inspection_date, action, violation_code,
    violation_description, critical_flag, score, grade, grade_date,
    record_date, inspection_type, latitude, longitude, community_board,
    council_district, census_tract, bin, bbl, nta, location_point1
)
FROM 'C:/data/resto_copy.csv'
DELIMITER ','
CSV HEADER;

-- ~~~~~~~
-- Inspect
-- ~~~~~~~
SELECT * FROM resto LIMIT 20;

SELECT DISTINCT(location_point1) FROM resto
LIMIT 20;

SELECT DISTINCT(cuisine_description) FROM resto 
LIMIT 100;


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 0. CREATE STAGING TABLE (resto_raw)
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CREATE TABLE resto_raw AS
SELECT *
FROM resto;



-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 1. CREATE resto_stage (DEDUP + BLANK→NULL NORMALIZATION)
--    This table is still row-level raw data, but cleaned.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CREATE TABLE resto_stage AS
SELECT DISTINCT *
FROM resto_raw;

UPDATE resto_stage
SET
    action = NULLIF(action, ''),
    violation_code = NULLIF(violation_code, ''),
    score = NULLIF(score, ''),
    grade = NULLIF(grade, ''),
    grade_date = NULLIF(grade_date, ''),
    inspection_type = NULLIF(inspection_type, '');



-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 2. CREATE resto_clean (REMOVE ROWS MISSING REQUIRED FIELDS)
--    Convert score to numeric
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CREATE TABLE resto_clean AS
SELECT *
FROM resto_stage
WHERE action IS NOT NULL
  AND violation_code IS NOT NULL
  AND score IS NOT NULL
  AND grade IS NOT NULL
  AND grade_date IS NOT NULL
  AND inspection_type IS NOT NULL;

-- Check if null scores are removed
SELECT * FROM public.resto_clean
WHERE score is NULL
LIMIT 100;

-- Convert score from text to numeric
UPDATE resto_clean
SET score = score::numeric;

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 3. AUTO-DETECT ALL COLUMNS WITH "date" IN THEIR NAME
--    AND CAST THEM TO TIMESTAMP IN resto_clean
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SET datestyle = 'MDY';

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = 'resto_clean'
          AND column_name ILIKE '%date%'
    LOOP
        EXECUTE format(
            'ALTER TABLE resto_clean
             ALTER COLUMN %I
             TYPE timestamp
             USING NULLIF(%I, '''')::timestamp;',
            r.column_name, r.column_name
        );
    END LOOP;
END $$;

-- Check if date is timestamp format
SELECT * FROM resto_clean LIMIT 100;

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 4. DROP EMPTY COLUMN location_point1 FROM resto_clean
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ALTER TABLE resto_clean
DROP COLUMN IF EXISTS location_point1;


-- Check if dropped
SELECT * FROM resto_clean LIMIT 100;




