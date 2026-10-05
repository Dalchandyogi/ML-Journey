create database learn;

select * from titanic;

select count(PassengerId) from titanic;

select avg(Age) as 'Avg. Age' from titanic;

select * from titanic where Age > 50;

select * from titanic where Pclass = 1 and Survived = 1;

-- group by

SELECT 
    Sex, 
    SUM(CASE WHEN Survived = 1 THEN 1 ELSE 0 END) AS `Survived`,
    SUM(CASE WHEN Survived = 0 THEN 1 ELSE 0 END) AS `Not Survived`,
    COUNT(Survived) AS 'Total'
FROM titanic
GROUP BY Sex;
