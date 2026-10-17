SELECT *, AVG(marks) OVER(PARTITION BY branch) FROM window_fun_students;

-- ======== Aggregate Function with OVER() ========= 
-- Q1. Find all the students who have marks higher than the avg marks of their respective branch
SELECT * FROM (
	SELECT *,
	AVG(marks) OVER(PARTITION BY branch) AS 'branch_avg'
	FROM window_fun_students
) t
WHERE t.marks > t.branch_avg;


-- ======= RANK/DENSE_RANK/ROW_NUMBER ============

-- Rank overall 
SELECT *, 
RANK() OVER(ORDER BY marks DESC) 
FROM window_fun_students;

-- Rank in Branch 
SELECT *, 
RANK() OVER(PARTITION BY branch ORDER BY marks DESC) AS 'Rank'
FROM window_fun_students;

-- Dense Rank 
SELECT *, 
RANK() OVER(PARTITION BY branch ORDER BY marks DESC) AS 'Rank',
DENSE_RANK() OVER(PARTITION BY branch ORDER BY marks DESC) AS 'Dense_Rank'
FROM window_fun_students;

-- Row Number 
SELECT *,
concat(branch, '-', ROW_NUMBER() OVER(PARTITION BY branch))
FROM window_fun_students;

-- Q1. Find top 2 most paying customers of each month
SELECT * FROM (
	SELECT 
    MONTHNAME(date) AS month,
    user_id, 
    SUM(amount) AS total,
    RANK() OVER (
        PARTITION BY MONTHNAME(date) 
        ORDER BY SUM(amount) DESC
    ) AS month_rank
	FROM zomato_orders
	GROUP BY MONTHNAME(date), user_id
	ORDER BY month DESC, month_rank ASC
) t

WHERE t.month_rank < 3
ORDER BY month DESC, month_rank ASC;

-- =======  FIRST_VALUE/LAST VALUE/NTH_VALUE  =========

-- Q1. Find the branch toppers

SELECT name, branch, marks FROM (
    SELECT *,
    FIRST_VALUE(name) OVER w AS 'topper_name',
    FIRST_VALUE(marks) OVER w AS 'topper_mark'
    FROM window_fun_students
    WINDOW w AS (PARTITION BY branch ORDER BY marks DESC) -- Alternate way of writing Window functions
) t
WHERE t.name = t.topper_name AND t.marks = t.topper_mark;


-- Q2. Find the last guy of each branch
SELECT branch, name, marks
FROM (
    SELECT 
        branch, 
        name, 
        marks,
        LAST_VALUE(name) OVER w AS last_guy_name,
        LAST_VALUE(marks) OVER w AS last_guy_mark
    FROM window_fun_students
    WINDOW w AS (
        PARTITION BY branch 
        ORDER BY marks DESC 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    )
) t
WHERE t.name = t.last_guy_name AND t.marks = t.last_guy_mark;


-- =================  LEAD & LAG  ==============
 
-- Q1.Find the Month on Month revenue growth of Zomato

WITH monthly_sales AS (
    SELECT 
        MONTH(date) AS month_num,        -- Used for correct chronological ordering
        MONTHNAME(date) AS month,        -- Display name for the month
        SUM(amount) AS revenue
    FROM zomato_orders
    GROUP BY MONTH(date), MONTHNAME(date)
)
SELECT 
    month,
    revenue,
    ((revenue - LAG(revenue) OVER (ORDER BY month_num)) / LAG(revenue) OVER (ORDER BY month_num)) * 100  AS 'groth(%)'
FROM monthly_sales
ORDER BY month_num;

-- ========================= Ranking Based On Categorical Column  ====================================

-- Find the top 5 batsmans of every team
SELECT * FROM (
	SELECT BattingTeam, batter,
	SUM(batsman_run) AS 'total_runs',
	DENSE_RANK() OVER(PARTITION BY BattingTeam ORDER BY SUM(batsman_run) DESC) AS 'rank_within_team'
	FROM ipl
	GROUP BY BattingTeam, batter
) t
WHERE t.rank_within_team < 6
ORDER BY t.BattingTeam, t.rank_within_team;


-- ================ Some mathmatical Quintity calculate using window functions ===========

-- Cumulative Sum
SELECT * FROM (
	SELECT 
	CONCAT('Match-', CAST(ROW_NUMBER() OVER(ORDER BY ID) AS CHAR)) AS 'match_no',
	SUM(batsman_run) AS 'runs',
	SUM(SUM(batsman_run)) OVER (ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS 'career_run'
	FROM ipl
	WHERE batter = 'V Kohli'
	GROUP BY ID
) t
WHERE match_no = 'Match-50' OR match_no = 'Match-100' OR match_no = 'Match-200';

-- Cumulative Average
SELECT * 
FROM (
    SELECT 
        CONCAT('Match-', CAST(ROW_NUMBER() OVER (ORDER BY ID) AS CHAR)) AS match_no,
        SUM(batsman_run) AS runs,
        SUM(SUM(batsman_run)) OVER w AS career_run,
        AVG(SUM(batsman_run)) OVER w AS career_avg
    FROM ipl
    WHERE batter = 'V Kohli'
    GROUP BY ID
    WINDOW w AS (
        ORDER BY ID 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )
) t;


-- Runing Average -> use to find current trends
SELECT * FROM (
	SELECT 
	CONCAT('Match-', CAST(ROW_NUMBER() OVER (ORDER BY ID) AS CHAR)) AS match_no,
    SUM(batsman_run) AS 'runs_scored',
	SUM(SUM(batsman_run)) OVER w AS 'career_runs',
	AVG(SUM(batsman_run)) OVER w AS 'career_avg',
	AVG(SUM(batsman_run)) OVER (ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) AS 'rolling_avg'
	FROM ipl
	WHERE batter = 'V Kohli'
	GROUP BY ID
	WINDOW W AS (ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
) t;

-- Percent of total 
SELECT f_name, 
(total_amount / SUM(total_amount) OVER()) * 100 AS 'percent'
FROM (
	SELECT f_id,
	SUM(amount) AS 'total_amount'
	FROM zomato_orders t1
	JOIN zomato_order_details t2
	ON t1.order_id = t2.order_id
	WHERE r_id = 1
	GROUP BY f_id
) t
JOIN zomato_food t3
ON t.f_id = t3.f_id
ORDER BY (total_amount / SUM(total_amount) OVER()) * 100 DESC;

-- Percent Change
SELECT 
    YEAR(Date) AS 'year', 
    MONTHNAME(Date) AS 'month',
    SUM(Views) AS 'views',
    (SUM(views) - LAG(SUM(views)) OVER (ORDER BY YEAR(Date), MONTH(Date))) / LAG(SUM(views)) OVER (ORDER BY YEAR(Date), MONTH(Date)) * 100 AS Percent_change
FROM youtube_views
GROUP BY YEAR(Date), MONTH(Date), MONTHNAME(Date)
ORDER BY YEAR(Date), MONTH(Date);

SELECT *, 
((views - LAG(views, 7) OVER (ORDER BY Date)) / LAG(views, 7) OVER (ORDER BY Date))*100 AS 'weekly_change'
FROM youtube_views;
