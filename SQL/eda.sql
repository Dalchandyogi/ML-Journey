--  ======================================= head -> tail -> sample  ===============================================================

SELECT * FROM laptop_backup LIMIT 5;

SELECT * FROM laptop_backup
ORDER BY `index` DESC LIMIT 5;

SELECT * FROM laptop_backup
ORDER BY rand() LIMIT 5;

-- =================================************** UNIVARIATE ANALYSIS ********=========================================

-- ==================  for numerical cols (8 number summary [count,min,max,mean,std,q1,q2,q3]) =================

-- #### 1. Price Column

-- 8 number summary [count,min,max,mean,std,q1,q2,q3]
WITH RankedPrices AS (
    SELECT Price,
           ROW_NUMBER() OVER (ORDER BY Price) AS rn,
           COUNT(*) OVER () AS total_rows
    FROM laptop_backup
    WHERE Price IS NOT NULL
)
SELECT 
    (SELECT COUNT(*) FROM laptop_backup) AS 'count',
    (SELECT MIN(Price) FROM laptop_backup) AS 'minimum',
    (SELECT MAX(Price) FROM laptop_backup) AS 'maximum',
    (SELECT STD(Price) FROM laptop_backup) AS 'std',
    (SELECT AVG(Price) FROM RankedPrices WHERE rn = FLOOR(total_rows * 0.25)) AS 'Q1',
    (SELECT AVG(Price) FROM RankedPrices WHERE rn = FLOOR(total_rows * 0.50)) AS 'Median',
    (SELECT AVG(Price) FROM RankedPrices WHERE rn = FLOOR(total_rows * 0.75)) AS 'Q3'
LIMIT 1;

-- missing values
SELECT COUNT(Price) FROM laptop_backup
WHERE Price IS NULL;

-- outliers 

WITH RankedPrices AS (
    SELECT Price,
           ROW_NUMBER() OVER (ORDER BY Price) AS rn,
           COUNT(*) OVER () AS total_rows
    FROM laptop_backup
    WHERE Price IS NOT NULL
)
SELECT * FROM (
	SELECT *,
	(SELECT AVG(Price) FROM RankedPrices WHERE rn = FLOOR(total_rows * 0.25)) AS 'Q1',
	(SELECT AVG(Price) FROM RankedPrices WHERE rn = FLOOR(total_rows * 0.75)) AS 'Q3'
	FROM laptop_backup
) t
WHERE t.Price < t.Q1 + (1.5 *(t.Q3 - t.Q1)) OR t.Price > t.Q3 + (1.5 *(t.Q3 - t.Q1));

--  horizontal/vertical histograms
SELECT  t.bukets, repeat('*', COUNT(*)/10) AS 'count'
FROM (
	SELECT Price, 
	CASE
		WHEN Price BETWEEN 0 AND 25000 THEN '0-25k'
		WHEN Price BETWEEN 25000 AND 50000 THEN '25-50k'
		WHEN Price BETWEEN 50000 AND 75000 THEN '50k-75k'
		WHEN Price BETWEEN 75000 AND 100000 THEN '75k-100k'
		WHEN Price BETWEEN 100000 AND 200000 THEN '100-200k'
		WHEN Price > 200000 THEN  '>200k'
	END AS 'bukets'
FROM laptop_backup
) t
GROUP BY t.bukets; 

-- ### 2. Weight Column
WITH RankedWeight AS (
    SELECT Weight,
           ROW_NUMBER() OVER (ORDER BY Weight) AS rn,
           COUNT(*) OVER () AS total_rows
    FROM laptop_backup
    WHERE Weight is not null
)
SELECT 
    (SELECT COUNT(*) FROM laptop_backup WHERE Weight IS NOT NULL) AS 'count',
    (SELECT MIN(Weight) FROM laptop_backup) AS 'minimum',
    (SELECT MAX(Weight) FROM laptop_backup) AS 'maximum',
    (SELECT STD(Weight) FROM laptop_backup) AS 'std',
    (SELECT AVG(Weight) FROM RankedWeight WHERE rn = FLOOR(total_rows * 0.25)) AS 'Q1',
    (SELECT AVG(Weight) FROM RankedWeight WHERE rn = FLOOR(total_rows * 0.50)) AS 'Median',
    (SELECT AVG(Weight) FROM RankedWeight WHERE rn = FLOOR(total_rows * 0.75)) AS 'Q3'
LIMIT 1;


-- ================================  for categorical cols  =====================================

-- ## 1. Company Column
SELECT Company, COUNT(Company) AS 'count'
FROM laptop_backup
GROUP BY Company;

-- ## 2. touch_screen Column
SELECT is_touchscreen, COUNT(is_touchscreen) AS 'count'
FROM laptop_backup
GROUP BY is_touchscreen;

-- # 3. TypeName column
SELECT TypeName, COUNT(TypeName) AS 'count'
FROM laptop_backup
GROUP BY TypeName;

-- -- # 4. TypeName column
SELECT cpu_name, COUNT(cpu_name) AS 'count'
FROM laptop_backup
GROUP BY cpu_name;

-- ## 5. gpu_brand Column
SELECT gpu_brand, COUNT(gpu_brand)  AS 'count'
FROM laptop_backup
GROUP BY gpu_brand;

-- ## 6. OS Column
SELECT OpSys, COUNT(OpSys)  AS 'count'
FROM laptop_backup
GROUP BY OpSys;


-- =================================************** BIVARIATE ANALYSIS ********=========================================

-- ================================  Numerical - Numerical =====================================

SELECT `cpu_speed(GHz)`, Price FROM laptop_backup;
SELECT primary_storage, Price FROM laptop_backup;

-- ================================  Categorical - Categorical =====================================

-- company- touchscreen
SELECT Company,
SUM(CASE WHEN is_touchscreen = 1 THEN 1 ELSE 0 END) AS 'touchscreen', 
SUM(CASE WHEN is_touchscreen = 0 THEN 1 ELSE 0 END) AS 'not-touchscreen'
FROM laptop_backup
GROUP BY Company;

-- company- cpu_brand
SELECT Company,
SUM(CASE WHEN cpu_brand = 'Intel' THEN 1 ELSE 0 END) AS 'intel', 
SUM(CASE WHEN cpu_brand = 'AMD' THEN 1 ELSE 0 END) AS 'amd',
SUM(CASE WHEN cpu_brand = 'Samsung' THEN 1 ELSE 0 END) AS 'samsung'
FROM laptop_backup
GROUP BY Company;

-- ================================  Numerical - Categorical =====================================
SELECT * FROM laptop_backup;

-- Average and Max Price by Company
SELECT Company,
       COUNT(*) AS laptop_count,
       ROUND(AVG(Price), 2) AS avg_price,
       MIN(Price) AS min_price,
       MAX(Price) AS max_price
FROM laptop_backup
GROUP BY Company
ORDER BY avg_price DESC;

-- Average Weight by TypeName
SELECT TypeName,
       COUNT(*) AS total_laptops,
       ROUND(AVG(Weight), 2) AS avg_weight,
       ROUND(MAX(Weight), 2) AS max_weight
FROM laptop_backup
WHERE Weight IS NOT NULL
GROUP BY TypeName
ORDER BY avg_weight DESC;

-- Average Price by cpu_brand and TypeName
SELECT TypeName,
       ROUND(AVG(CASE WHEN cpu_brand = 'Intel' THEN Price END), 2) AS Intel_Avg_Price,
       ROUND(AVG(CASE WHEN cpu_brand = 'AMD' THEN Price END), 2) AS AMD_Avg_Price
FROM laptop_backup
GROUP BY TypeName;

-- Price Categories by Company
SELECT Company,
       SUM(CASE WHEN Price < 40000 THEN 1 ELSE 0 END) AS Budget_Laptops,
       SUM(CASE WHEN Price BETWEEN 40000 AND 90000 THEN 1 ELSE 0 END) AS MidRange_Laptops,
       SUM(CASE WHEN Price > 90000 THEN 1 ELSE 0 END) AS Premium_Laptops
FROM laptop_backup
GROUP BY Company
ORDER BY Premium_Laptops DESC;
