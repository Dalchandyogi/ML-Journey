-- Q1. select a particular database
USE learn;

-- Q2. count number of rows
SELECT COUNT(*) FROM zomato_order_details;
SELECT COUNT(*) FROM zomato_orders;

-- Q3. return n random records
SELECT * FROM zomato_users ORDER BY rand() LIMIT 5;

-- Q4. Find null values
SELECT * FROM zomato_orders WHERE restaurant_rating IS NULL;

-- Q5. find the number of orders placed by each customer
SELECT t1.user_id, t1.name , COUNT(*) AS 'total_orders'
FROM zomato_users t1
JOIN zomato_orders t2
ON t1.user_id = t2.user_id
GROUP BY t1.user_id, t1.name;

-- Q6. find restaurant with most number of menu items
SELECT t1.r_id, t1.r_name, COUNT(*) As 'menu_items'
FROM zomato_restaurants t1
JOIN zomato_menu t2 
ON t1.r_id = t2.r_id
GROUP BY t1.r_id, t1.r_name;

-- Q7. find number of votes and avg rating for all the restaurants
SELECT t2.r_id, t2.r_name,
COUNT(*) AS 'total_votes',
ROUND(AVG(restaurant_rating), 2) AS 'avg_rating'
FROM zomato_orders t1
JOIN zomato_restaurants t2
ON t1.r_id = t2.r_id
WHERE t1.restaurant_rating IS NOT NULL
GROUP BY t2.r_id, t2.r_name;

-- Q8. find the food that is being sold at most number of restaurants
SELECT t1.f_id, t2.f_name, COUNT(*) AS 'count'
FROM zomato_menu t1
JOIN zomato_food t2
ON t1.f_id = t2.f_id
GROUP BY t1.f_id, t2.f_name
ORDER BY count DESC
LIMIT 1;

-- Q9. find restaurant with max revenue in a given month
SELECT t1.r_id, t2.r_name, SUM(amount) AS 'revenue' 
FROM zomato_orders t1
JOIN zomato_restaurants t2 
ON t1.r_id = t2.r_id
WHERE MONTHNAME(date) = 'May' -- change month here
GROUP BY t1.r_id, t2.r_name
ORDER BY revenue DESC 
LIMIT 1;

-- Q10. find restaurants with sales > 1500
SELECT t1.r_id, r_name, SUM(amount) AS 'revenue'
FROM zomato_orders t1
JOIN zomato_restaurants t2 
ON t1.r_id = t2.r_id
GROUP BY t1.r_id, r_name
HAVING revenue > 1500;

-- Q11. find customers who have never ordered
SELECT u.user_id, u.name 
FROM zomato_users u
LEFT JOIN zomato_orders o ON u.user_id = o.user_id
WHERE o.user_id IS NULL;

-- Q12. Show order details of a particular customer in a given date range 
SELECT t1.order_id, f_name, date FROM zomato_orders t1
JOIN zomato_order_details t2
ON t1.order_id = t2.order_id
JOIN zomato_food t3
ON t2.f_id = t3.f_id
WHERE user_id = 1 AND date BETWEEN '2022-05-15' AND '2022-06-25';

-- Q13. Customer favorite food
WITH fav_food AS (
	SELECT t2.user_id, t1.name, t4.f_name, COUNT(*) AS frequency
	FROM zomato_users t1
	JOIN zomato_orders t2 ON t1.user_id = t2.user_id
	JOIN zomato_order_details t3 ON t2.order_id = t3.order_id
	JOIN zomato_food t4 ON t3.f_id = t4.f_id
	GROUP BY t2.user_id, t1.name, t3.f_id, t4.f_name
)

SELECT * FROM fav_food f1
WHERE frequency = (SELECT MAX(frequency) FROM fav_food f2 WHERE f2.user_id = f1.user_id);

-- Q14. find most costly restaurants(Avg price/dish)
SELECT t1.r_id, t2.r_name,
SUM(price) / COUNT(*) AS 'avg_price' 
FROM zomato_menu t1
JOIN zomato_restaurants t2
ON t1.r_id = t2.r_id
GROUP BY t1.r_id, t2.r_name
ORDER BY avg_price DESC LIMIT 1;


-- Q15. find delivery partner compensation using the formula (#deliveries 100 + 1000*avg_rating)
SELECT t1.partner_id,
t2.partner_name,
COUNT(*) AS 'total_orders',
ROUND(AVG(delivery_rating), 2) AS 'avg_rating',
COUNT(*) * 100 + ROUND(AVG(delivery_rating), 2)*1000 AS 'compensation'
FROM zomato_orders t1
JOIN zomato_delivery_partner t2
ON t1.partner_id = t2.partner_id
GROUP BY t1.partner_id, t2.partner_name;


-- Q16. find revenue per month for a restaurant
SELECT MONTHNAME(date) AS 'month',
SUM(t1.amount) AS 'revenue'
FROM zomato_orders t1
JOIN zomato_restaurants t2 
ON t1.r_id = t2.r_id
WHERE t2.r_name = 'kfc'  -- change restaurant here
GROUP BY MONTHNAME(date);

-- Q17. find correlation between delivery_time and delivery_rating 
SELECT 
    (
        COUNT(*) * SUM(delivery_time * delivery_rating) - SUM(delivery_time) * SUM(delivery_rating)
    ) / 
    (
        SQRT(COUNT(*) * SUM(delivery_time * delivery_time) - POW(SUM(delivery_time), 2)) * 
        SQRT(COUNT(*) * SUM(delivery_rating * delivery_rating) - POW(SUM(delivery_rating), 2))
    ) AS correlation_delivery_time_vs_rating
FROM zomato_orders
WHERE delivery_time IS NOT NULL 
  AND delivery_rating IS NOT NULL;

-- Q18. find all the veg restaurants
SELECT r_id, r_name 
FROM zomato_restaurants
WHERE r_id NOT IN (
    SELECT DISTINCT t1.r_id 
    FROM zomato_menu t1
    JOIN zomato_food t2 ON t1.f_id = t2.f_id
    WHERE t2.type = 'non-veg'
);
-- Q19. find min, avg, total and max order value for all the customers  
SELECT t1.user_id, t2.name, 
MIN(amount) AS 'min',
MAX(amount) AS 'max',
ROUND(AVG(amount)) AS 'avg', 
COUNT(*) AS 'total_orders'
FROM zomato_orders t1
JOIN zomato_users t2
ON t1.user_id = t2.user_id
GROUP BY t1.user_id, t2.name