SELECT * FROM learn.movies;

-- Find the highest rated movie
SELECT * FROM movies
WHERE score = (SELECT MAX(score) FROM movies);


-- ###### ==============   Independent Subquery - Scalar Subquery  ========================= #####

-- Q1. Find the movie with highest profit(vs order by)
SELECT * FROM movies
WHERE (gross - budget) = (SELECT MAX(gross - budget) FROM movies);
-- === Order By === 
SELECT * FROM movies
ORDER BY(gross - budget) DESC LIMIT 1;

-- Q2. Find how many movies have a rating > the avg of all the movie ratings(Find the count of above average movies)
SELECT COUNT(*) FROM movies
WHERE score > (SELECT AVG(score) FROM movies);

-- Q3. Find the highest rated movie of 2000
SELECT * FROM movies
where year = 2000 AND score = (SELECT MAX(score) FROM movies WHERE year = 2000);

-- Q4. Find the highest rated movie among all movies whose number of votes are > the dataset avg votes

SELECT * FROM movies
WHERE score = (
				SELECT MAX(score) FROM movies WHERE score > (
				  SELECT AVG(score) FROM movies
				)
			 );




-- ###### ==============   Independent Subquery - Row Subquery(One Col Multi Rows)  ========================= #####

-- Q1. Find all users who never ordered
SELECT * FROM zomato_users WHERE user_id NOT IN (SELECT DISTINCT(user_id) FROM zomato_orders);

-- Q2. Find all the movies made by top 3 directors (in terms of total gross income) 
WITH top_directors AS (
  SELECT director from movies
  GROUP BY director
  ORDER BY SUM(gross) DESC
  LIMIT 3
)

SELECT * FROM movies
WHERE director IN (SELECT * FROM top_directors);

-- Q3. Find all movies of all those actors whose filmography's avg rating > 8.5(take 25000 votes as cutoff)

SELECT m.* 
FROM movies m
JOIN (
    SELECT star 
    FROM movies 
    WHERE votes > 25000 
    GROUP BY star 
    HAVING AVG(score) > 8.5
) AS qualified_stars ON m.star = qualified_stars.star
WHERE m.votes > 25000;



-- ###### ==============  Independent Subquery - Table Subquery(Multi Col Multi Row)  ========================= #####
-- Q1. Find the most profitable movie of each year
SELECT * FROM movies
WHERE (year, gross-budget) IN (
		SELECT year, MAX(gross - budget) FROM movies
		GROUP BY year
);

-- Q2. Find the highest rated movie of each genre votes cutoff of 25000
SELECT m.*
FROM movies m
JOIN (
    SELECT genre, MAX(score) AS max_score
    FROM movies
    WHERE votes > 25000
    GROUP BY genre
) top_genres ON m.genre = top_genres.genre AND m.score = top_genres.max_score
WHERE m.votes > 25000;

-- Q3. Find the highest grossing movies of top 5 actor/director combo in terms of total gross income
WITH top_duos AS (
  SELECT star, director, MAX(gross) FROM  movies
  GROUP BY star, director
  ORDER BY SUM(gross) DESC
  LIMIT 5
)

SELECT * FROM movies
WHERE (star, director, gross) IN (SELECT * FROM top_duos);


-- ###### ==============  Correlated Subquery  ========================= #####
-- Q1. Find all the movies that have a rating higher than the average rating of movies in the same genre.

SELECT * FROM movies m1
WHERE score > (SELECT AVG(score) FROM movies m2 WHERE m2.genre = m1.genre);

-- Q2. Find the favorite food of each customer.

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


-- ###### ============== Usage with SELECT ========================= #####

-- Q1. Get the percentage of votes for each movie compared to the total number of votes.
SELECT name, (votes/ (SELECT SUM(votes) FROM movies)) * 100 FROM movies;

-- Q2. Display all movie names,genre, score and avg(score) of genre
SELECT name, genre score, (SELECT AVG(score) FROM movies m2 WHERE m2.genre = m1.genre) AS 'Avg_genere' FROM movies m1;

-- ###### ==============  Usage with FROM  ========================= #####

-- Q1. Display average rating of all the restaurants
SELECT r_name, avg_rating FROM (
	SELECT r_id, AVG(restaurant_rating) AS 'avg_rating' 
    FROM zomato_orders GROUP BY r_id
    ) t1 
JOIN zomato_restaurants t2 
ON t1.r_id = t2.r_id;

-- ###### ==============  Usage with HAVING  ========================= #####

-- Q1. Find genres having avg score > avg score of all the movies
SELECT genre, AVG(score) AS 'avg_rating'
FROM movies
GROUP BY genre
HAVING avg_rating > (SELECT AVG(score) FROM movies);

-- ###### ==============  Subquery In INSERT ========================= #####

-- ► Populate & already created loyal_customers table with records of only those customers who have ordered food more than 3 times.
INSERT INTO zomato_loyal_customers (user_id, name)
SELECT t1.user_id, t2.name 
FROM zomato_orders t1
JOIN zomato_users t2 ON t1.user_id = t2.user_id
GROUP BY t1.user_id, t2.name
HAVING COUNT(*) > 3;

SELECT * FROM zomato_loyal_customers;

-- ###### ==============  Subquery in UPDATE  ========================= #####

-- ► Populate the money col of loyal_cutomer table using the orders table. Provide a 10% app money to all customers based on their order value.

-- Disable safe update mode temporarily
SET SQL_SAFE_UPDATES = 0;

-- Your update query
UPDATE zomato_loyal_customers u
SET money = (
    SELECT SUM(o.amount) * 0.1
    FROM zomato_orders o
    WHERE o.user_id = u.user_id
);

-- Re-enable safe update mode
SET SQL_SAFE_UPDATES = 1;


-- ###### ==============  Subquery in DELETE ========================= ##### 
-- ► Delete all the customers record who have never ordered.

DELETE FROM  zomato_users 
WHERE user_id IN (
	SELECT user_id FROM zomato_users WHERE user_id NOT IN (SELECT DISTINCT(user_id) FROM zomato_orders)
)