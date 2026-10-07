-- ============================ Sorting Data =========================
SELECT * FROM smartphones;

-- Q1. 1. find top 5 samsung phones with biggest screen size.
SELECT model, screen_size
FROM smartphones
WHERE brand_name = 'samsung'
ORDER BY screen_size DESC 
LIMIT 5;

-- Q2. sort all the phone in decending order of number of total cameras
SELECT model, (num_rear_cameras + num_front_cameras) AS 'Total_Camera' 
FROM smartphones
ORDER BY Total_Camera DESC;

-- Q3. sort data on the basis of ppi in decreasing order
SELECT model,
ROUND(SQRT(resolution_width*resolution_width + resolution_height*resolution_height) / screen_size) AS 'PPI'
FROM smartphones
ORDER BY PPI ASC; 

-- Q4. find the phone with 2nd largest battery
SELECT brand_name, model, battery_capacity
FROM smartphones
ORDER BY battery_capacity 
DESC LIMIT 1,1; -- start(index 0), items

-- Q5. find the name and rating of the worst rated apple phone
SELECT brand_name, model, rating 
FROM smartphones
WHERE brand_name = 'apple'
ORDER BY rating ASC LIMIT 1;

-- Q6. sort phones alphabetically and then on the basic of rating in desc order
SELECT brand_name, model, rating
FROM smartphones
ORDER BY model ASC, rating DESC;

-- Q7. sort phones alphabetically and then on the basic of price in asc order
SELECT brand_name, model, price
FROM smartphones
ORDER BY model ASC, price ASC;

-- Q8. find the phone name, price of the costliest phone
SELECT brand_name, model, price 
FROM smartphones
ORDER BY price DESC
LIMIT 1;


-- =========================== Grouping Data =======================================
-- Q1. Group smartphones by brand and get the count, average price, max rating, avg screen size and avg battery capacity
SELECT brand_name, 
COUNT(*) AS 'total_phones',
ROUND(AVG(price)) AS 'avg_price',
MAX(rating) AS 'max_rating',
ROUND(AVG(screen_size),2) AS 'avg_screen_size',
ROUND(AVG(battery_capacity)) AS 'avg_battary_capacity'
FROM smartphones
GROUP  BY brand_name
ORDER BY total_phones DESC;

-- Q2. Group smartphones by whether they have an NFC and get the average price and rating
SELECT has_nfc, 
COUNT(*) AS 'total_phones', 
ROUND(AVG(price)) AS 'avg_price',
ROUND(AVG(rating)) AS 'avg_rating' 
FROM smartphones
GROUP BY has_nfc;

-- Q3. Group smartphones by the extended memory available and get the average price
SELECT extended_memory_available, 
COUNT(*) AS 'total_phones', 
ROUND(AVG(price)) AS 'avg_price'
FROM smartphones
GROUP BY extended_memory_available;

-- Q4. Group smartphones by the brand and processor brand and get the count of models and the average primary camera resolution (rear)
SELECT brand_name, processor_brand,
COUNT(*) AS 'total_phones' ,
ROUND(AVG(primary_camera_rear)) AS 'avg_camera_resulation(rear)' 
FROM smartphones
GROUP BY brand_name, processor_brand;

-- Q5. find top 5 most costly phone brands
SELECT brand_name,
ROUND(AVG(price)) AS 'avg_price'
FROM smartphones
GROUP BY brand_name
ORDER BY avg_price DESC
LIMIT 5;

-- Q6. which brand makes the smallest screen smartphones
SELECT brand_name,
ROUND(AVG(screen_size)) AS 'avg_screen_size'
FROM smartphones
GROUP BY brand_name
ORDER BY avg_screen_size ASC
LIMIT 1;

-- Q7. Avg price of 5g phones vs avg price of non 5g phones
SELECT has_5g,
ROUND(AVG(price)) AS 'avg_price'
FROM smartphones
GROUP BY has_5g;

-- Q8. Group smartphones by the brand, and find the brand with the highest number of models that have both NFC and an IR blaster
SELECT brand_name, COUNT(*) AS 'count'
FROM smartphones
WHERE has_5g = 'True' AND has_ir_blaster = 'True'
GROUP BY brand_name
ORDER BY count DESC
LIMIT 1;

-- Q9. Find all samsung 5g enabled smartphones and find out the avg price for NFC and Non-NFC phones
SELECT has_nfc, AVG(price) AS 'avg_price'
FROM smartphones
WHERE brand_name = 'samsung' AND has_5g = 'True'
GROUP BY has_nfc; 


--  ============================= Having clause ============================
--  select  ->  where
--  group by  ->  having

-- Q1. find the avg rating of smartphone brands which have more than 20 phones
SELECT brand_name, 
COUNT(*) AS 'count',
ROUND(AVG(rating)) AS 'avg_rating'
FROM smartphones
GROUP BY brand_name
HAVING count > 20
ORDER BY avg_rating DESC;

-- Q2. Find the top 3 brands with the highest avg ram that have a refresh rate of at least 90 Hz and fast charging available and dont consider brands which have less than 10 phones
SELECT brand_name, 
ROUND(AVG(ram_capacity), 2) AS 'avg_ram'
FROM smartphones
WHERE refresh_rate > 90 AND fast_charging_available = 1
GROUP BY brand_name
HAVING COUNT(*) > 10
ORDER BY avg_ram DESC
LIMIT 3;

-- Q3. find the avg price of all the phone brands with avg rating > 70 and num_phones more than 10 among all 5g enabled phones
SELECT brand_name, ROUND(AVG(price)) AS 'avg_price' 
FROM smartphones
WHERE has_5g = 'True'
GROUP BY brand_name
HAVING AVG(rating) > 70 AND COUNT(*) > 10;



--  ===================================== Practice  ========================================
SELECT * FROM ipl;

-- Q1. Find the top 5 batsman in IPL
SELECT batter, SUM(batsman_run) AS 'Runs'
FROM ipl
GROUP BY batter 
ORDER BY Runs DESC
LIMIT 5;

-- Q2. Find the 2nd highest 6 hitter in IPL
SELECT batter, COUNT(*) AS 'sixes'
FROM ipl
WHERE batsman_run = 6
GROUP BY batter
ORDER BY sixes DESC
LIMIT 1,1; 

-- Q3. Find the top 5 batsman with highest strike rate who have played a min of 1000 balls
SELECT batter,
SUM(batsman_run) AS 'Runs',
COUNT(batsman_run) AS 'Balls', 
ROUND((SUM(batsman_run) / COUNT(batsman_run)) * 100, 2) AS 'SR'
FROM ipl
GROUP BY batter
HAVING COUNT(batsman_run) > 1000
ORDER BY SR DESC
LIMIT 5;
