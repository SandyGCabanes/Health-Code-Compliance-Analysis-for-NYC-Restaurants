-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- STANDARDIZE CUISINES
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


DROP TABLE IF EXISTS dim_cuisine;

CREATE TABLE dim_cuisine (
    cuisine_description text,
    cuisine_group text
);

-- Pre-work: copy the csv file into the C:/data folder so postgres can access it
COPY dim_cuisine (
    cuisine_description, cuisine_group
)
FROM 'C:/data/dim_cuisine.csv'
DELIMITER ','
CSV HEADER;

ALTER TABLE resto_clean
DROP COLUMN cuisine_group;

SELECT * FROM resto_clean LIMIT 1;

-- Check
with joined as(
	SELECT *
	FROM resto_clean r
	LEFT JOIN dim_cuisine c
		ON r.cuisine_description = c.cuisine_description
)
SELECT  cuisine_group,
	COUNT(cuisine_group) as count_of_cuisines
FROM joined
GROUP BY cuisine_group
ORDER BY count_of_cuisines DESC
;

/**


"cuisine_group"	"count_of_cuisines"
"American"	24830
"European"	20126
"Latin American/Caribbean"	17615
"Beverages"	13167
"Chinese"	12032
"Bakery/Desserts"	11939
"Fast Food"	6330
"East Asian"	6273
"Light Meals"	4194
"Southeast Asian"	2778
"South Asian"	2379
"Asian Other"	2086
"Jewish/Kosher"	1731
"Middle Eastern/North African"	1613
"Mediterranean"	1459
"Other/Not Specified"	1342
"Seafood"	1050
"Vegetarian/Vegan"	625
"African"	554
"Fusion/Contemporary"	329
**/



-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- STANDARDIZE VIOLATIONS
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DROP TABLE IF EXISTS dim_violation;

CREATE TABLE dim_violation (
    violation_code text,
    violation_description text,
	code_group int,
	violation_group text	
);

-- Pre-work: copy the csv file into the C:/data folder so postgres can access it
COPY dim_violation (
    violation_code text,
    violation_description text,
	code_group int,
	violation_group text
)
FROM 'C:/data/dim_violation_pg.csv'
DELIMITER ','
CSV HEADER;

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- EXTRACT FIRST TWO NUMBERS AS CODE GROUP
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ALTER TABLE resto_clean
ADD COLUMN code_group TEXT;

UPDATE resto_clean
SET code_group= LEFT(violation_code, 2);

SELECT * FROM resto_clean limit 5;

/**
THERE ARE CLEAR GROUP MEANINGS FOR THE FIRST TWO DIGITS OF THE VIOLATION CODES.
CODE GROUPS WILL BE AS FOLLOWS.

02 | Temperature Control (TCS)
03 | Food Source / Water / Raw Food Safety
04 | Contamination / Hygiene / Vermin
05 | Plumbing / Water Supply / Ventilation
06 | Food Protection / Cleanliness / HACCP
07 | Administrative Obstruction
08 | Pest Control / Waste / Chemicals
09 | Equipment Construction / Thawing / Food Contact Surfaces
10 | Facility Maintenance / Lighting / Dishwashing / Thermometers
28 | Administrative / Miscellaneous / Adulteration

List of Violation Codes and Violation Descriptions,
code,desc
02A,Time/Temperature Control for Safety (TCS) food not cooked to required minimum internal temperature.   â€¢ Poultry, poultry parts, ground and comminuted poultry, all stuffing containing poultry, meats, fish or ratites to or above 165 Â°F for 15 seconds with no interruption of the cooking process   â€¢ Ground meat, and food containing ground and comminuted meat, to or above 158 Â°F for 15 seconds with no interruption of the cooking process, except per individual customer request  â€¢ Pork, any food containing pork to or above 150 Â°F for 15 seconds  â€¢ Mechanically tenderized or injected meats to or above 155 Â°F.  â€¢ Whole meat roasts and beef steak to or above required temperature and time except per individual customer request  â€¢ Raw animal foods cooked in microwave to or above165 Â°F, covered, rotated or stirred   â€¢ All other foods to or above 140 Â°F for 15 seconds; shell eggs to or above 145 Â°F for 15 seconds except per individual customer request.
02A,Time/Temperature Control for Safety (TCS) food not cooked to required minimum internal temperature. â€¢ Poultry, poultry parts, ground and comminuted poultry, all stuffing containing poultry, meats, fish or ratites to or above 165 Â°F for 15 seconds with no interruption of the cooking process  â€¢ Ground meat, and food containing ground and comminuted meat, to or above 158 Â°F for 15 seconds with no interruption of the cooking process, except per individual customer requestâ€¢ Pork, any food containing pork to or above 150 Â°F for 15 secondsâ€¢ Mechanically tenderized or injected meats to or above 155 Â°F.â€¢ Whole meat roasts and beef steak to or above required temperature and time except per individual customer requestâ€¢ Raw animal foods cooked in microwave to or above165 Â°F, covered, rotated or stirred  â€¢ All other foods to or above 140 Â°F for 15 seconds; shell eggs to or above 145 Â°F for 15 seconds except per individual customer request.
02B,Hot TCS food item not held at or above 140 Â°F.
02C,Hot TCS food item that has been cooked and  cooled is being held for service without first being reheated to 165Âº F or above within 2 hours.
02C,Hot TCS food item that has been cooked and cooled is being held for service without first being reheated to 165Âº F or above within 2 hours.
02D,Commercially processed pre-cooked TCS in hermetically sealed containers and precooked TCS in intact packages from non-retail food processing establishments not heated to 140 Â°F within 2 hours of removal from container or package.
02F,Meat, fish, molluscan shellfish, unpasteurized raw shell eggs, poultry or other TCS offered or served raw or undercooked and written notice not provided to consumer.
02G,Cold TCS food item held above 41 Â°F; smoked or processed fish held above 38 Â°F; intact raw eggs held above 45 Â°F; or reduced oxygen packaged (ROP) TCS foods held above required temperatures except during active necessary preparation.
02H,After cooking or removal from hot holding, TCS food not cooled by an approved method whereby the internal temperature is reduced from 140 Â°F to 70 Â°F or less within 2  hours, and from 70 Â°F to 41 Â°F or less within 4 additional hours.
02H,After cooking or removal from hot holding, TCS food not cooled by an approved method whereby the internal temperature is reduced from 140 Â°F to 70 Â°F or less within 2 hours, and from 70 Â°F to 41 Â°F or less within 4 additional hours.
02I,TCS food removed from cold holding or prepared from or combined with ingredients at room temperature not cooled by an approved method to 41 Â°F or below within 4 hours.
03A,Food, prohibited, from unapproved or unknown source, home canned or home prepared.  Animal slaughtered, butchered or dressed (eviscerated, skinned) in establishment. Reduced Oxygen Packaged (ROP) fish not frozen before processing.  ROP food prepared on premises transported to another site.
03A,Food, prohibited, from unapproved or unknown source, home canned or home prepared. Animal slaughtered, butchered or dressed (eviscerated, skinned) in establishment. Reduced Oxygen Packaged (ROP) fish not frozen before processing. ROP food prepared on premises transported to another site.
03B,Shellfish not from approved source, not or improperly tagged/labeled; tags not retained for 90 days.
03C,Unclean or cracked whole eggs or unpasteurized liquid, frozen or powdered eggs kept or used.
03E,No or inadequate potable water supply. Water or ice not potable or from unapproved source. Bottled water not NY State certified. Cross connection in potable water supply system.
03G,Raw fruit or vegetable not properly washed prior to cutting or serving.
03I,Juice packaged on premises with no or incomplete label, no warning statement
04A,Food Protection Certificate (FPC) not held by manager or supervisor of food operations.
04B,Food worker or vendor working or is knowingly or negligently permitted to work in FSE while afflicted with infected wound or reportable communicable disease. No spitting allowed. Spitting anywhere in the establishment is prohibited.
04C,Food worker/food vendor does not use utensil or other barrier to eliminate bare hand contact with food that will not receive adequate additional heat treatment.
04D,Food worker/food vendor does not wash hands thoroughly after using the toilet, or after coughing, sneezing, smoking, eating, preparing raw foods or otherwise contaminating hands or does not change gloves when required; Worker fails to refrain from smoking or being fully clothed in clean outer garments.
04E,Toxic chemical or pesticide improperly stored or used such that food contamination may occur.
04F,Food preparation area, food storage area, or other area used by employees or patrons, contaminated by sewage or liquid waste.
04F,Food, food preparation area, food storage area, or other area used by employees or patrons, contaminated by sewage or liquid waste.
04H,Raw, cooked or prepared food is adulterated, contaminated, cross-contaminated, or not discarded in accordance with HACCP plan.
04I,Non-TCS food that has been served to the public being re-served. (Does not apply to wrapped foods where the wrapper seal has not been broken or opened).
04J,Properly scaled and calibrated thermometer or thermocouple not provided or not readily accessible in food preparation and hot/cold holding areas to measure temperatures of TCS foods during cooking, cooling, reheating, and holding.
04K,Evidence of rats or live rats in establishment's food or non-food areas.
04L,Evidence of mice or live mice in establishment's food or non-food areas.
04M,Live roaches in facility's food or non-food area.
04N,Filth flies or food/refuse/sewage associated with (FRSA) flies or other nuisance pests  in  establishmentâ€™s food and/or non-food areas. FRSA flies include house flies, blow flies, bottle flies, flesh flies, drain flies, Phorid flies and fruit flies.
04N,Filth flies or food/refuse/sewage associated with (FRSA) flies or other nuisance pests in establishmentâ€™s food and/or non-food areas. FRSA flies include house flies, blow flies, bottle flies, flesh flies, drain flies, Phorid flies and fruit flies.
04O,Live animal other than fish in tank or service animal present in facilityâ€™s food or non-food area.
04P,Food containing a prohibited substance held, kept, offered, prepared, processed, packaged, or served.
05A,Sewage disposal system is not provided, improper, inadequate or unapproved.
05B,Harmful noxious gas or vapor detected. Carbon Monoxide (CO) level exceeds nine (9) ppm
05C,Food contact surface, refillable, reusable containers, or equipment improperly constructed, placed or maintained. Unacceptable material used. Culinary sink or other acceptable method not provided for washing food.
05D,No hand washing facility in or adjacent to toilet room or within 25 feet of a food preparation, food service or ware washing area.  Hand washing facility not accessible, obstructed or used for non-hand washing purposes. No hot and cold running water or water at inadequate pressure. No soap or acceptable hand-drying device.
05D,No hand washing facility in or adjacent to toilet room or within 25 feet of a food preparation, food service or ware washing area. Hand washing facility not accessible, obstructed or used for non-hand washing purposes. No hot and cold running water or water at inadequate pressure. No soap or acceptable hand-drying device.
05E,Toilet facility not provided for employees or for patrons when required. Shared patron-employee toilet accessed through kitchen, food prep or storage area or utensil washing area.
05F,Insufficient or no hot holding, cold storage or cold holding equipment provided to maintain Time/Temperature Control for Safety Foods (TCS) at required temperatures
05H,No approved written standard operating procedure for avoiding contamination by refillable returnable containers.
06A,Personal cleanliness is inadequate. Outer garment soiled with possible contaminant. Effective hair restraint not worn where required.  Jewelry is worn on hands or arms.  Fingernail polish worn or fingernails not kept clean and trimmed.
06A,Personal cleanliness is inadequate. Outer garment soiled with possible contaminant. Effective hair restraint not worn where required. Jewelry worn on hands or arms. Fingernail polish worn or fingernails not kept clean and trimmed.
06B,Tobacco or electronic cigarette use, eating, or drinking from open container in food preparation, food storage or dishwashing area.
06C,Food, supplies, and equipment not protected from potential source of contamination during storage, preparation, transportation, display or service.
06C,Food, supplies, or equipment not protected from potential source of contamination during storage, preparation, transportation, display, service or from customerâ€™s refillable, reusable container. Condiments not in single-service containers or dispensed directly by the vendor.
06D,Food contact surface not properly washed, rinsed and sanitized after each use and following any activity when contamination may have occurred.
06E,Sanitized equipment or utensil, including in-use food dispensing utensil, improperly used or stored.
06F,Wiping cloths not stored clean and dry, or in a sanitizing solution, between uses.
06G,HACCP plan not approved or approved HACCP plan not maintained on premises.
07A,Duties of an officer of the Department interfered with or obstructed.
08A,Establishment is not free of harborage or conditions conducive to rodents, insects or other pests.
08B,Garbage receptacle not pest or water resistant, with tight-fitting lids, and covered except while in active use. Garbage receptacle and cover not cleaned after emptying and prior to reuse. Garbage, refuse and other solid and liquid waste not collected, stored, removed and disposed of so as to prevent a nuisance.
08C,Pesticide not properly labeled or used by unlicensed individual.  Pesticide, other toxic chemical improperly used/stored. Unprotected, unlocked bait station used.
08C,Pesticide not properly labeled or used by unlicensed individual. Pesticide, other toxic chemical improperly used/stored. Unprotected, unlocked bait station used.
09A,Swollen, leaking, rusted or otherwise damaged canned food to be returned to distributor not segregated from intact product and clearly labeled DO NOT USE
09B,Thawing procedure improper.
09C,Design, construction, materials used or maintenance of food contact surface improper.  Surface not easily cleanable, sanitized and maintained.
09C,Design, construction, materials used or maintenance of food contact surface improper. Surface not easily cleanable, sanitized and maintained.
09D,Food service operation occurring in room or area used as living or sleeping quarters.
09E,Wash hands sign not posted near or above hand washing sink.
10A,Toilet facility not maintained or provided with toilet paper, waste receptacle or self-closing door.
10B,Anti-siphonage or back-flow prevention device not provided where required; equipment or floor not properly drained; sewage disposal system in disrepair or not functioning properly. Condensation or liquid waste improperly disposed of.
10C,Lighting inadequate; permanent lighting not provided in food preparation areas, ware washing areas, and storage rooms. Shatterproof bulb or shield to prevent broken glass from falling into food or onto surfaces, not installed.
10D,Mechanical or natural ventilation not provided, inadequate, improperly installed, in disrepair or fails to prevent and control excessive build-up of grease, heat, steam condensation, vapors, odors, smoke or fumes.
10E,Accurate thermometer not provided or properly located in refrigerated, cold storage or hot holding equipment
10F,Non-food contact surface or equipment made of unacceptable material, not kept clean, or not properly sealed, raised, spaced or movable to allow accessibility for cleaning on all sides, above and underneath the unit.
10G,Dishwashing and ware washing:  Cleaning and sanitizing of tableware, including dishes, utensils, and equipment deficient.
10G,Dishwashing and ware washing: Cleaning and sanitizing of tableware, including dishes, utensils, and equipment deficient.
10H,Single service article not provided.  Single service article reused or not protected from contamination when transported, stored, dispensed.  Drinking straws not completely enclosed in wrapper or dispensed from a sanitary device.
10H,Single service article not provided. Single service article reused or not protected from contamination when transported, stored, dispensed. Drinking straws not completely enclosed in wrapper or dispensed from a sanitary device.
28-05,Food adulterated or misbranded.  Adulterated or misbranded food possessed, being manufactured, produced, packed, sold, offered for sale, delivered or given away
28-05,Food adulterated or misbranded. Adulterated or misbranded food possessed, being manufactured, produced, packed, sold, offered for sale, delivered or given away
28-06,Contract with a pest management professional not in place.  Record of extermination activities not kept on premises.
28-06,Contract with a pest management professional not in place. Record of extermination activities not kept on premises.
28-07,Unapproved outdoor, street or sidewalk cooking.
**/



-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- STANDARDIZE VIOLATION CODE GROUPS
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


ALTER TABLE resto_clean
ADD COLUMN violation_group TEXT;

UPDATE resto_clean
SET
    code_group = LEFT(violation_code, 2),
    violation_group = CASE
        WHEN LEFT(violation_code, 2) = '02' THEN 'Temperature Control (TCS)'
        WHEN LEFT(violation_code, 2) = '03' THEN 'Food Source / Water / Raw Food Safety'
        WHEN LEFT(violation_code, 2) = '04' THEN 'Contamination / Hygiene / Vermin'
        WHEN LEFT(violation_code, 2) = '05' THEN 'Plumbing / Water Supply / Ventilation'
        WHEN LEFT(violation_code, 2) = '06' THEN 'Food Protection / Cleanliness / HACCP'
        WHEN LEFT(violation_code, 2) = '07' THEN 'Administrative Obstruction'
        WHEN LEFT(violation_code, 2) = '08' THEN 'Pest Control / Waste / Chemicals'
        WHEN LEFT(violation_code, 2) = '09' THEN 'Equipment Construction / Thawing / Food Contact Surfaces'
        WHEN LEFT(violation_code, 2) = '10' THEN 'Facility Maintenance / Lighting / Dishwashing / Thermometers'
        WHEN LEFT(violation_code, 2) = '28' THEN 'Administrative / Miscellaneous / Adulteration'
        ELSE NULL
    END;

-- Check
SELECT violation_group,
	COUNT(violation_group) as count_of_violations
FROM resto_clean
GROUP BY violation_group
ORDER BY count_of_violations DESC
;

/**
"violation_group"	"count_of_violations"
"Facility Maintenance / Lighting / Dishwashing / Thermometers"	45000
"Food Protection / Cleanliness / HACCP"	26225
"Contamination / Hygiene / Vermin"	21968
"Temperature Control (TCS)"	15746
"Pest Control / Waste / Chemicals"	15093
"Equipment Construction / Thawing / Food Contact Surfaces"	5277
"Plumbing / Water Supply / Ventilation"	1908
"Administrative / Miscellaneous / Adulteration"	710
"Food Source / Water / Raw Food Safety"	520
"Administrative Obstruction"	3
**/


-- Check
SELECT * FROM resto_clean
LIMIT 10
;




-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- EXPLORE NTA AND BORO
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SELECT LEFT(nta, 2) AS ntacode, boro
FROM resto_clean
WHERE nta is NOT NULL
GROUP BY LEFT(nta, 2), boro
ORDER BY LEFT(nta, 2)
;

/**
"ntacode"	"boro"
"BK"	"Brooklyn"
"BX"	"Bronx"
"MN"	"Bronx"
"MN"	"Manhattan"
"QN"	"Queens"
"SI"	"Staten Island"
**/


SELECT * FROM resto_clean LIMIT 1;

