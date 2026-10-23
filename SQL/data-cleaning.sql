SET SQL_SAFE_UPDATES = 0;

-- 1. Create backup

CREATE TABLE laptop_backup LIKE laptopdataraw;

INSERT INTO laptop_backup 
SELECT * FROM laptopdataraw;

SELECT * FROM laptop_backup;

-- 2. Check number of rows
SELECT COUNT(*) FROM laptop_backup;

-- 3. Check memory consumption for reference
SELECT DATA_LENGTH/1024 AS 'memory(kb)' FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'learn' AND TABLE_NAME = 'laptop_backup';

-- 4. Drop non important cols or rename
ALTER TABLE laptop_backup DROP COLUMN `Unnamed: 0`;

ALTER TABLE laptop_backup RENAME COLUMN `Unnamed: 0` TO `index`;


-- 5. Drop null values
DELETE FROM laptop_backup
WHERE `index` IN (
	SELECT * FROM laptop_backup
	WHERE Company IS NULL AND TypeName IS NULL 
	AND Inches IS NULL AND ScreenResolution IS NULL 
	AND Cpu IS NULL AND Ram IS NULL AND Memory IS NULL 
	AND Gpu IS NULL AND OpSys IS NULL 
	AND WEIGHT IS NULL AND Price IS NULL
);


-- 6. Drop duplicates
DELETE FROM zomato.duplicates
WHERE id NOT IN (
	SELECT MIN(id) FROM Zomato.duplicates
	GROUP BY name, gender, age
);

-- 7. Clean Inches -> change col data type(double to decimal)
ALTER TABLE laptop_backup MODIFY COLUMN Inches DECIMAL(10, 1);

-- 8. Clean RAM -> change col data type

UPDATE laptop_backup
SET Ram = REPLACE(Ram, 'GB', '');

ALTER TABLE laptop_backup MODIFY COLUMN Ram INT;

-- 9. Clean Weight -> change col data type
UPDATE laptop_backup
SET Weight = REPLACE(Weight, 'kg', '');

-- Step 1: Replace all literal question marks with NULL
UPDATE laptop_backup 
SET Weight = NULL 
WHERE Weight = '?';

-- Step 2: Safely modify the column to DECIMAL
ALTER TABLE laptop_backup 
MODIFY COLUMN Weight DECIMAL(10, 2);

-- 10. Clean Weight -> change col data type
UPDATE laptop_backup 
SET Price = ROUND(Price);

ALTER TABLE laptop_backup 
MODIFY COLUMN Price INTEGER;

-- 11. work on OsSys Col

-- view level
SELECT OpSys,
CASE 
	WHEN OpSys LIKE '%mac%' THEN 'MacOS'
    WHEN OpSys LIKE '%windows%' THEN 'Windows'
    WHEN OpSys LIKE '%inux%' THEN 'Linux'
    WHEN OpSys = 'No OS' THEN 'N/A'
    ELSE 'Other'
END AS 'os'    
FROM laptop_backup;

UPDATE laptop_backup
SET OpSys = CASE 
	WHEN OpSys LIKE '%mac%' THEN 'MacOS'
    WHEN OpSys LIKE 'windows%' THEN 'Windows'
    WHEN OpSys LIKE '%linux%' THEN 'Linux'
    WHEN OpSys = 'No OS' THEN 'N/A'
    ELSE 'Other'
END;


-- 11. Work on Gpu Col - create 2 new cols
ALTER TABLE laptop_backup
ADD COLUMN gpu_brand VARCHAR(255) AFTER Gpu,
ADD COLUMN gpu_name VARCHAR(225) AFTER gpu_brand;

SELECT Gpu, SUBSTRING_INDEX(Gpu, ' ', 1 ) FROM laptop_backup;

UPDATE laptop_backup
SET gpu_brand = SUBSTRING_INDEX(Gpu, ' ', 1 );

SELECT REPLACE(Gpu, gpu_brand, '') FROM laptop_backup;

UPDATE laptop_backup
SET gpu_name =  REPLACE(Gpu, gpu_brand, '');

-- delte old Gpu col 
ALTER TABLE laptop_backup DROP Gpu;

-- ======================== 12 Work on CPU col - create 3 new cols =======================================

ALTER TABLE laptop_backup
ADD COLUMN cpu_brand VARCHAR(255) AFTER Cpu,
ADD COLUMN cpu_name VARCHAR(225) AFTER cpu_brand,
ADD COLUMN cpu_speed DECIMAL(10,2) AFTER cpu_name;

ALTER TABLE laptop_backup RENAME COLUMN `cpu_speed` TO `cpu_speed(GHz)`;


-- cpu_brand
SELECT Cpu, substring_index(Cpu, ' ', 1) FROM laptop_backup;

UPDATE laptop_backup
SET cpu_brand = substring_index(Cpu, ' ', 1);

-- cpu_speed
SELECT Cpu, CAST(replace(substring_index(Cpu, ' ', -1), 'GHz', '') AS DECIMAL(10,2)) FROM laptop_backup;

UPDATE laptop_backup 
SET `cpu_speed(GHz)` = CAST(replace(substring_index(Cpu, ' ', -1), 'GHz', '') AS DECIMAL(10,2));

-- cpu_name
SELECT
REPLACE(REPLACE(Cpu, cpu_brand, ''), substring_index(REPLACE(Cpu, cpu_brand, ''), ' ', -1), '')
FROM laptop_backup;

UPDATE laptop_backup
SET cpu_name = REPLACE(REPLACE(Cpu, cpu_brand, ''), substring_index(REPLACE(Cpu, cpu_brand, ''), ' ', -1), '');

-- drop Cpu col
ALTER TABLE laptop_backup DROP COLUMN Cpu;


-- ======================== 13 Work on ScreenResulation col - create 3 new cols =======================================
-- height & width 
SELECT ScreenResolution,
substring_index(substring_index(ScreenResolution, ' ', -1), 'x', 1),
substring_index(substring_index(ScreenResolution, ' ', -1), 'x', -1)
FROM laptop_backup;

-- create new cols
ALTER TABLE laptop_backup 
ADD COLUMN resolution_width INTEGER AFTER ScreenResolution,
ADD COLUMN resolution_height INTEGER AFTER resolution_width;

-- add values to height and width
UPDATE laptop_backup
SET resolution_width = substring_index(substring_index(ScreenResolution, ' ', -1), 'x', 1),
resolution_height = substring_index(substring_index(ScreenResolution, ' ', -1), 'x', -1);

-- touch screen 
SELECT ScreenResolution, 
ScreenResolution LIKE '%touch%'
FROM laptop_backup;

-- create new cols - is_touchscreen
ALTER TABLE laptop_backup ADD COLUMN is_touchscreen INT AFTER resolution_height;

-- add Values 
UPDATE laptop_backup
SET is_touchscreen = ScreenResolution LIKE '%touch%';

-- display_type
SELECT ScreenResolution,
       TRIM(
           REPLACE(
               REPLACE(
                   REPLACE(
                       REPLACE(
                           REPLACE(ScreenResolution, SUBSTRING_INDEX(ScreenResolution, ' ', -1), ''),
                       'Touchscreen / ', ''),
                   '/ Touchscreen', ''),
               '/Touchscreen', ''),
           'Touchscreen', '')
       ) AS display_type
FROM laptop_backup;

-- create new col
ALTER TABLE laptop_backup ADD COLUMN display_type VARCHAR(255) AFTER is_touchscreen;

-- add vlaues
UPDATE laptop_backup
SET display_type = TRIM(
					   REPLACE(
						   REPLACE(
							   REPLACE(
								   REPLACE(
									   REPLACE(ScreenResolution, SUBSTRING_INDEX(ScreenResolution, ' ', -1), ''),
								   'Touchscreen / ', ''),
							   '/ Touchscreen', ''),
						   '/Touchscreen', ''),
					   'Touchscreen', '')
                     );


-- delete ScreenResolution col
ALTER TABLE laptop_backup DROP COLUMN ScreenResolution;


-- ======================== 14. clean cpu_name col =======================================

SELECT cpu_name,
substring_index(trim(cpu_name), ' ', 2)
FROM laptop_backup;

-- update
UPDATE laptop_backup
SET cpu_name = substring_index(trim(cpu_name), ' ', 2);

-- ======================== 15. Work on Memory col - create 3 new cols =======================================

-- create 3 new cols
ALTER TABLE laptop_backup
ADD COLUMN memory_type VARCHAR(255) AFTER Memory,
ADD COLUMN primary_storage INTEGER AFTER memory_type,
ADD COLUMN secondary_storage INTEGER AFTER primary_storage;

-- memory type
SELECT Memory,
CASE 
	WHEN Memory LIKE '%ssd%' AND Memory LIKE '%hdd%' THEN 'Hybrid'
    WHEN Memory LIKE '%ssd%' AND Memory LIKE '%hybrid%' THEN 'Hybrid'
	WHEN Memory LIKE '%hdd%' AND Memory LIKE '%hybrid%' THEN 'Hybrid'
  	WHEN Memory LIKE '%ssd%' AND Memory LIKE '%flash storage%' THEN 'Hybrid'
	WHEN Memory LIKE '%hdd%' AND Memory LIKE '%flash storage%' THEN 'Hybrid'
    WHEN Memory LIKE '%ssd%' THEN 'SSD'
    WHEN Memory LIKE '%hdd%' THEN 'HDD'
    WHEN Memory LIKE '%flash storage%' THEN 'Flash'
    WHEN Memory LIKE '%hybrid%' THEN 'Hybrid'
    ELSE NULL
END AS memory_type
FROM laptop_backup;

-- update col
UPDATE laptop_backup
SET memory_type = CASE 
	WHEN Memory LIKE '%ssd%' AND Memory LIKE '%hdd%' THEN 'Hybrid'
    WHEN Memory LIKE '%ssd%' AND Memory LIKE '%hybrid%' THEN 'Hybrid'
	WHEN Memory LIKE '%hdd%' AND Memory LIKE '%hybrid%' THEN 'Hybrid'
  	WHEN Memory LIKE '%ssd%' AND Memory LIKE '%flash storage%' THEN 'Hybrid'
	WHEN Memory LIKE '%hdd%' AND Memory LIKE '%flash storage%' THEN 'Hybrid'
    WHEN Memory LIKE '%ssd%' THEN 'SSD'
    WHEN Memory LIKE '%hdd%' THEN 'HDD'
    WHEN Memory LIKE '%flash storage%' THEN 'Flash'
    WHEN Memory LIKE '%hybrid%' THEN 'Hybrid'
    ELSE NULL
END;

-- storage
SELECT Memory,
REGEXP_SUBSTR(substring_index(Memory, '+', 1), '[0-9]+'),
CASE 
	WHEN Memory LIKE '%+%' THEN REGEXP_SUBSTR(TRIM(substring_index(Memory, '+', -1)), '[0-9]+')
    ELSE 0 
END FROM laptop_backup;

-- Add values
UPDATE laptop_backup
SET primary_storage = REGEXP_SUBSTR(substring_index(Memory, '+', 1), '[0-9]+'),
secondary_storage = CASE WHEN Memory LIKE '%+%' THEN REGEXP_SUBSTR(TRIM(substring_index(Memory, '+', -1)), '[0-9]+') ELSE 0 END;

-- fix TB values 
SELECT primary_storage,
CASE 
	WHEN primary_storage <= 2 THEN primary_storage*1024 ELSE primary_storage END,
secondary_storage,
CASE 
	WHEN secondary_storage <= 2 THEN secondary_storage*1024 ELSE secondary_storage END
FROM laptop_backup;


-- apply changes 
UPDATE laptop_backup
SET primary_storage = CASE WHEN primary_storage <= 2 THEN primary_storage*1024 ELSE primary_storage END,
secondary_storage = CASE WHEN secondary_storage <= 2 THEN secondary_storage*1024 ELSE secondary_storage END;

-- delete old memory col
ALTER TABLE laptop_backup DROP COLUMN Memory;


SELECT * FROM laptop_backup;
