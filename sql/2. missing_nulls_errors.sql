-- Workflow: 
-- Create view v_resto_clean_columns
-- Create table resto_clean_null_counts -> populate using loop
-- Correct phone errors -> replace "__" strings, all non-digit values
-- Re-classify missing nta values into miscellaneou


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 1. View listing all columns in resto_clean with their data types
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CREATE OR REPLACE VIEW v_resto_clean_columns AS
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'resto_clean'
ORDER BY ordinal_position;



-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 2. Table to store NULL counts (views cannot store rows)
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CREATE TABLE IF NOT EXISTS resto_clean_null_counts (
    column_name text,
    null_count bigint
);



-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 3. Loop through columns and count NULLs safely by type
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DO $$
DECLARE
    r RECORD;                      -- holds column name + data type
    sql_text text;                 -- dynamic SQL to run per column
BEGIN
    DELETE FROM resto_clean_null_counts;   -- clear previous results

    FOR r IN SELECT * FROM v_resto_clean_columns LOOP

        -- Build the correct WHERE clause depending on column type
        IF r.data_type IN ('text', 'character varying') THEN
            -- Text columns: count NULLs and blanks
            sql_text := format(
                'INSERT INTO resto_clean_null_counts
                 SELECT %L AS column_name,
                        COUNT(*) FILTER (
                            WHERE %I IS NULL OR %I = ''''
                        ) AS null_count
                 FROM resto_clean;',
                r.column_name,
                r.column_name,
                r.column_name
            );

        ELSE
            -- Non-text columns: count only NULLs
            sql_text := format(
                'INSERT INTO resto_clean_null_counts
                 SELECT %L AS column_name,
                        COUNT(*) FILTER (
                            WHERE %I IS NULL
                        ) AS null_count
                 FROM resto_clean;',
                r.column_name,
                r.column_name
            );

        END IF;

        EXECUTE sql_text;          -- run the generated SQL

    END LOOP;
END $$;



-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 4. View results - exported as null_values.csv
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SELECT *
FROM resto_clean_null_counts
ORDER BY null_count DESC;

-- camis have no nulls
-- Check if camis are truly unique for each dba


SELECT camis, dba, COUNT(*) AS count_rows
FROM resto_clean
GROUP BY camis, dba
ORDER BY camis;


-- camis are unique, dba's are not

With cte as(
SELECT camis, dba, COUNT(*) AS count_rows
FROM resto_clean
GROUP BY camis, dba
)
SELECT * FROM (
SELECT 
camis, dba, lead(dba) OVER (ORDER BY camis) as next_dba,
  Case when dba = lead(dba) OVER (ORDER BY camis) then 1
       else NULL END as duplicated
FROM cte
) q
WHERE duplicated IS NOT NULL;


-- ~~~~~~~~~~~~~~~~~~~~~~~
-- 5. Correct phone errors
-- ~~~~~~~~~~~~~~~~~~~~~~~

-- There are errors in the phone field due to string of undescores
-- Clean up using regex match entire string of underscores
-- ^ = the string must start here
-- [ _] = the string may contain either a space or an underscore
-- + = one or more of those characters (not zero; at least one)
-- $ = no more characters after this
-- First check how many rows have a string of underscores
SELECT * FROM resto_clean
WHERE phone ~ '^[ _]+$';  -- 45 rows


-- Replace these phone strings of underscores with NULL
UPDATE resto_clean
SET phone = NULL
WHERE phone ~ '^[ _]+$';

-- Replace all non-digit characters (not digits [^0-9])
-- Entire string 'g' (global, not just first character))
UPDATE resto_clean
SET phone = regexp_replace(phone, '[^0-9]', '', 'g');



-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 6. Re-classify null nta values into Miscellaneous
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- Check null values for nta
SELECT boro, count(*)
FROM resto_clean
WHERE nta IS NULL
GROUP BY boro
;

/**
"boro"	"count"
"Bronx"	206
"Brooklyn"	175
"Manhattan"	849
"Queens"	792
"Staten Island"	62
**/


-- Impute nta NULLS as Miscellaneous based on boro
/**
('BK99','Brooklyn Miscellaneous','Brooklyn'),
('BX68','Bronx Miscellaneous','Bronx'),
('MN99','Manhattan Miscellaneous','Manhattan'),
('QN66','Queens Miscellaneous','Queens'),
('SI99','Staten Island Miscellaneous','Staten Island')
**/


UPDATE resto_clean
SET nta =
	CASE WHEN boro = 'Brooklyn' THEN 'BK99'
		 WHEN boro = 'Bronx' THEN 'BX68'
		 WHEN boro = 'Manhattan' THEN 'MN99'
		 WHEN boro = 'Queens' THEN 'QN66'
		 WHEN boro = 'Staten Island' THEN 'SI99'
	ELSE nta END 
WHERE nta IS NULL;

-- Check - no more nulls for nta
SELECT boro, count(*)
FROM resto_clean
WHERE nta IS NULL
GROUP BY boro
;
