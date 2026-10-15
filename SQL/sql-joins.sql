SELECT * FROM users;

-- #### ------------------------------------- Joins ------------------------------- #####

--  =========== Cross Join =============

SELECT * FROM learn.users1 
CROSS JOIN learn.groups;

-- ============ Inner Join ==============
SELECT * FROM learn.users1 t1
INNER JOIN learn.membership t2
ON t1.user_id = t2.user_id;

-- ============== Left Join ===========
SELECT * FROM learn.membership t1
LEFT JOIN learn.users1 t2 
ON t1.user_id = t2.user_id;

-- ===== Rignt Join ===== 
SELECT * FROM learn.membership t1
RIGHT JOIN learn.users1 t2 
ON t1.user_id = t2.user_id;

-- =========== FULL OUTER JION ========

SELECT * FROM learn.membership t1
LEFT JOIN learn.users1 t2 
ON t1.user_id = t2.user_id
UNION 
SELECT * FROM learn.membership t1
RIGHT JOIN learn.users1 t2 
ON t1.user_id = t2.user_id;


-- ========= Self Jion ===========
SELECT * FROM learn.users1 t1
JOIN learn.users1 t2 
ON t1.user_id = t2.user_id;

-- ============== Join more than one cols =============
SELECT * FROM learn.students s
JOIN learn.class c
ON s.class_id = c.class_id AND s.enrollment_year = c.class_year;

-- ============ Join Multiple Tables ========
SELECT t1.order_id, t1.amount, t1.profit, t3.name FROM learn.order_details t1
JOIN learn.orders t2
ON t1.order_id = t2.order_id
JOIN learn.users t3
ON t2.user_id = t3.user_id;

-- Q. Find all order that placed in pune
SELECT * FROM learn.orders t1
JOIN learn.users t2 
ON t1.user_id = t2.user_id
WHERE t2.city = 'Pune';

-- #### ---------------- Set Operations -------------------------- ####

-- ================ Union : (common) ===========
SELECT * FROM person1
UNION
SELECT * FROM person2;

-- ================ Union ALL (All) ===========
SELECT * FROM person1
UNION ALL
SELECT * FROM person2;

-- ================ Intersect ===========
SELECT * FROM person1
INTERSECT
SELECT * FROM person2; 

-- =======  EXCEPT ====== 
SELECT * FROM person1
EXCEPT
SELECT * FROM person2; 


-- =============================================== Practice Questions =========================================

-- Q1. Find all profitable orders
SELECT t1.order_id,
SUM(t2.profit) AS profit 
FROM learn.orders t1
JOIN learn.order_details t2
ON t1.order_id = t2.order_id
GROUP BY t1.order_id
HAVING profit > 0;

-- Q2. Find the customer who has placed max number of orders 
SELECT name,
COUNT(*) AS total_orders
FROM learn.orders t1
JOIN learn.users t2
ON t1.user_id = t2.user_id
GROUP BY t2.name
ORDER BY total_orders DESC
LIMIT 1;

-- Q3. Which is the most profitable category(top 5)
SELECT t2.vertical, SUM(t1.profit) AS 'total_money'
FROM learn.order_details t1
JOIN learn.category t2
ON t1.category_id = t2.category_id
GROUP BY t2.vertical
ORDER BY total_money DESC
LIMIT 5;

-- Q4. Which is the most profitable state(top 6)
SELECT t3.state,
SUM(t1.profit) AS 'total_sales'
FROM learn.order_details t1
JOIN learn.orders t2
ON t1.order_id = t2.order_id
JOIN learn.users t3
ON t2.user_id = t3.user_id
GROUP BY t3.state
ORDER BY total_sales DESC
LIMIT 6;

-- Q5. Find all categories with profit higher than 5000
SELECT t2.vertical, SUM(t1.profit) AS 'profit'
FROM learn.order_details t1
JOIN learn.category t2
ON t1.category_id = t2.category_id
GROUP BY t2.vertical
HAVING profit > 5000;