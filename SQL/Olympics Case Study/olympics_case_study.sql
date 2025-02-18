
-- 1. How many olympics games have been held?
-- Problem Statement: Write a SQL query to find the total no of Olympic
-- Games held as per the dataset.
SELECT 
    COUNT(DISTINCT(games)) AS total_olympic_games
FROM 
	olympics_history;


-- 2. List down all Olympics games held so far.
--Problem Statement: Write a SQL query to list down all the Olympic Games held so far.

SELECT 
	year,season,city 
FROM 
	olympics_history
GROUP BY
	year,season,city 
ORDER BY 
	year;


-- 3. Mention the total no of nations who participated in each olympics game?
-- Problem Statement: SQL query to fetch total no of countries participated 
-- in each olympic games.	

WITH all_countries AS (

SELECT 
	o.games,nr.region
FROM
	olympics_history o
JOIN
	olympics_history_noc_regions nr
ON 
	o.noc=nr.noc
GROUP BY
	o.games,nr.region
)
SELECT
	games,COUNT(1) AS total_countries
FROM
	all_countries
GROUP BY
	games
ORDER BY
	games;



-- 4. Which year saw the highest and lowest no of countries participating in olympics
-- Problem Statement: Write a SQL query to return the Olympic Games which had the highest
-- participating countries and the lowest participating countries.

WITH all_countries AS (

SELECT
	oh.games,nr.region
FROM
	OLYMPICS_HISTORY oh
JOIN
	OLYMPICS_HISTORY_NOC_REGIONS nr
ON
	oh.noc=nr.noc
GROUP BY 
	oh.games,nr.region
),

tot_countries AS(

SELECT 
	games,COUNT(*) AS total_countries
FROM
	all_countries 
GROUP BY 
	games
)
	
SELECT 
	CONCAT((
SELECT 
	games || ' - ' || total_countries
FROM
	tot_countries
ORDER BY 
	total_countries ASC LIMIT 1
	
	))
	AS lowest_countries,

	CONCAT((
SELECT
	games || ' - ' || total_countries
FROM
	tot_countries
ORDER BY 
	total_countries DESC LIMIT 1 
	))
	AS highest_countries
FROM 
	tot_countries
LIMIT 1;



-- 5. Which nation has participated in all of the olympic games
-- Problem Statement: SQL query to return the list of countries who have been part of every Olympics games.

WITH tot_games AS(
SELECT
	COUNT(DISTINCT games) AS total_games
FROM 
	olympics_history
),
countries AS(
SELECT 
	oh.games,nr.region AS country
FROM
	olympics_history oh
JOIN
	olympics_history_noc_regions nr
ON
	oh.noc = nr.noc
GROUP BY 
	oh.games,nr.region
),
countries_participated AS(
SELECT
	country,COUNT(1) AS total_participated_games
FROM 
	countries
GROUP BY
	country
)
SELECT
	cp.*
FROM
	countries_participated cp
JOIN
	tot_games tg
ON 
	cp.total_participated_games = tg.total_games
ORDER BY
	1;

-- 6. Identify the sport which was played in all summer olympics.
-- Problem Statement: SQL query to fetch the list of all sports which have been part of every olympics.

WITH t1 AS (
SELECT
	COUNT(DISTINCT games) AS total_games
FROM 
	olympics_history
WHERE
	season = 'Summer'
	),
t2 AS (
SELECT 
	DISTINCT sport,games
FROM 
	olympics_history
WHERE
	season = 'Summer'
ORDER BY 
	games
),
t3 AS (
SELECT 
	sport , COUNT(games) AS no_of_games
FROM
	t2
GROUP BY 
	sport)
SELECT
	t3.sport,t3.no_of_games,t1.total_games
FROM 
	t3
JOIN
	t1
ON
	t3.no_of_games = t1.total_games;

-- 7. Which Sports were just played only once in the olympics.
-- Problem Statement: Using SQL query, Identify the sport which were just played once in all of olympics.

WITH t1 AS (
SELECT 
	DISTINCT games,sport
FROM
	olympics_history
ORDER BY 
	games
),
t2 AS (
SELECT
	sport,COUNT(games) AS no_of_games
FROM
	t1
GROUP BY 
	sport
)
SELECT 
	t1.sport,t2.no_of_games,t1.games
FROM
	t2
JOIN
	t1
ON
	t1.sport = t2.sport
WHERE
	t2.no_of_games = '1'
ORDER BY 
	t1.sport;


-- 8. Fetch the total no of sports played in each olympic games.
-- Problem Statement: Write SQL query to fetch the total no of sports played in each olympics.

SELECT
	games,COUNT(DISTINCT sport) AS no_of_sports
FROM
	olympics_history
GROUP BY
	games
ORDER BY
	no_of_sports DESC;

-- 9. Fetch oldest athletes to win a gold medal
-- Problem Statement: SQL Query to fetch the details of the oldest athletes to win a gold medal at the olympics.

WITH t1 AS (
SELECT 
	name,sex,CAST(CASE WHEN age = 'NA' THEN '0' ELSE age END AS int) as age,team,games,city,
	sport,event,medal
FROM
	olympics_history	
),
rank AS (
SELECT 
	*,RANK() OVER(ORDER BY age DESC) AS rnk
FROM
	t1
WHERE
	medal = 'Gold'
)
SELECT
	*
FROM 
	rank
WHERE 
	rnk = 1;

-- 10.Find the Ratio of male and female athletes participated in all olympic games.
-- Problem Statement: Write a SQL query to get the ratio of male and female participants

WITH t1 AS(
SELECT 
	sex, count(1) AS cnt
FROM
	olympics_history
GROUP BY 
	sex),
t2 AS(
SELECT 
	*,ROW_NUMBER() OVER(ORDER BY cnt) AS rn 
FROM
	t1
),
min_cnt AS(
SELECT
	cnt 
FROM
	t2
WHERE 
	rn = 1
),
max_cnt AS(
SELECT
	cnt
FROM
	t2
WHERE
	rn = 2
)
SELECT 
	CONCAT('1 : ', ROUND(max_cnt.cnt::decimal/min_cnt.cnt, 2)) AS ratio
FROM	
	min_cnt, max_cnt;

-- 11. Fetch the top 5 athletes who have won the most gold medals.
-- Problem Statement: SQL query to fetch the top 5 athletes who have won the most gold medals.

WITH RankedMedals AS (
SELECT
       name,team,COUNT(1) AS total_gold_medals,DENSE_RANK() OVER (ORDER BY COUNT(1) DESC) AS rank
FROM
      OLYMPICS_HISTORY
WHERE 
      medal = 'Gold'
GROUP BY
      name, team
)
SELECT
    name,team,total_gold_medals
FROM
    RankedMedals
WHERE
    rank <= 5
ORDER BY
    rank, total_gold_medals DESC;


-- 12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
-- Problem Statement: SQL Query to fetch the top 5 athletes who have won the most medals 
-- (Medals include gold, silver and bronze).	

WITH RankedMedals AS (
SELECT
       name,team,COUNT(1) AS total_medals,DENSE_RANK() OVER (ORDER BY COUNT(1) DESC) AS rank
FROM
      OLYMPICS_HISTORY
WHERE 
      medal in ('Gold', 'Silver', 'Bronze')
GROUP BY
      name, team
)
SELECT
    name,team,total_medals
FROM
    RankedMedals
WHERE
    rank <= 5
ORDER BY
    rank, total_medals DESC;



-- 13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
-- Problem Statement: Write a SQL query to fetch the top 5 most successful countries in olympics.
-- (Success is defined by no of medals won).
WITH RankedMedals AS (
SELECT
       nr.region,COUNT(o.Medal) AS total_medals,DENSE_RANK() OVER (ORDER BY COUNT(1) DESC) AS rank
FROM
      OLYMPICS_HISTORY o
JOIN
	OLYMPICS_HISTORY_NOC_REGIONS nr
ON
	o.noc = nr.noc
WHERE 
	medal <> 'NA'
GROUP BY
      nr.region
ORDER BY 
	total_medals DESC
)
SELECT
    region,total_medals,rank
FROM
    RankedMedals
WHERE
    rank <= 5
ORDER BY
    rank, total_medals DESC;

-- 14. List down total gold, silver and bronze medals won by each country.
-- Problem Statement: Write a SQL query to list down the  total gold, silver and bronze medals won by each country.

CREATE EXTENSION TABLEFUNC;
SELECT 
	country
    	, coalesce(gold, 0) as gold
    	, coalesce(silver, 0) as silver
    	, coalesce(bronze, 0) as bronze
FROM CROSSTAB('
SELECT
	nr.region AS country,o.medal,COUNT(1) AS total_medals
FROM
      OLYMPICS_HISTORY o
JOIN
	OLYMPICS_HISTORY_NOC_REGIONS nr
ON
	o.noc = nr.noc
WHERE 
	medal <> ''NA''
GROUP BY
	nr.region,o.medal
ORDER BY
	nr.region,o.medal',
'VALUES (''Bronze''),(''Gold''),(''Silver'')')
AS FINAL_RESULT(country varchar, bronze bigint, gold bigint, silver bigint)
ORDER BY
	gold DESC, silver DESC, bronze DESC;

-- 15. List down total gold, silver and bronze medals won by each country corresponding to each olympic games.
-- Problem Statement: Write a SQL query to list down the  total gold, silver and bronze medals won by each 
-- country corresponding to each olympic games.
	
SELECT substring(games,1,position(' - ' in games) - 1) as games
        , substring(games,position(' - ' in games) + 3) as country
        , coalesce(gold, 0) as gold
        , coalesce(silver, 0) as silver
        , coalesce(bronze, 0) as bronze
FROM CROSSTAB('
SELECT CONCAT(games, '' - '', nr.region) as games, medal, count(1) as total_medals
FROM 
	olympics_history oh
JOIN 
	olympics_history_noc_regions nr ON nr.noc = oh.noc
WHERE 
	medal <> ''NA''
GROUP BY 
	games,nr.region,medal
ORDER BY 
	games,medal',
'values (''Bronze''), (''Gold''), (''Silver'')')
AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint);

-- 16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.
-- Problem Statement: Write SQL query to display for each Olympic Games, which country won the highest
-- gold, silver and bronze medals.

WITH temp AS(
SELECT substring(games,1,position(' - ' in games) - 1) as games
        , substring(games,position(' - ' in games) + 3) as country
        , coalesce(gold, 0) as gold
        , coalesce(silver, 0) as silver
        , coalesce(bronze, 0) as bronze
FROM CROSSTAB('
SELECT CONCAT(games, '' - '', nr.region) as games, medal, count(1) as total_medals
FROM 
	olympics_history oh
JOIN 
	olympics_history_noc_regions nr ON nr.noc = oh.noc
WHERE 
	medal <> ''NA''
GROUP BY 
	games,nr.region,medal
ORDER BY 
	games,medal',
'values (''Bronze''), (''Gold''), (''Silver'')')
AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint)
)
SELECT 
	DISTINCT games,
			CONCAT(FIRST_VALUE(country) OVER(PARTITION BY games ORDER BY gold DESC), ' - ',
			FIRST_VALUE(gold) OVER(PARTITION BY games ORDER BY gold DESC)) AS Max_Gold,
			CONCAT(FIRST_VALUE(country) OVER(PARTITION BY games ORDER BY silver DESC), ' - ',
			FIRST_VALUE(silver) OVER(PARTITION BY games ORDER BY silver DESC)) AS Max_Silver,
			CONCAT(FIRST_VALUE(country) OVER(PARTITION BY games ORDER BY bronze DESC), ' - ',
			FIRST_VALUE(bronze) OVER(PARTITION BY games ORDER BY bronze DESC)) AS Max_Bronze			
FROM 
	temp
ORDER BY 
	games;
	
-- 17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
-- Problem Statement: Similar to the previous query, identify during each Olympic Games, which country won the highest gold, 
-- silver and bronze medals. Along with this, identify also the country with the most medals in each olympic games.

WITH temp AS(
SELECT substring(games,1,position(' - ' in games) - 1) as games
        , substring(games,position(' - ' in games) + 3) as country
        , coalesce(gold, 0) as gold
        , coalesce(silver, 0) as silver
        , coalesce(bronze, 0) as bronze
FROM CROSSTAB('
SELECT CONCAT(games, '' - '', nr.region) as games, medal, count(1) as total_medals
FROM 
	olympics_history oh
JOIN 
	olympics_history_noc_regions nr ON nr.noc = oh.noc
WHERE 
	medal <> ''NA''
GROUP BY 
	games,nr.region,medal
ORDER BY 
	games,medal',
'values (''Bronze''), (''Gold''), (''Silver'')')
AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint)
),
tot_medals AS(
SELECT
	o.games,nr.region AS country , COUNT(1) AS total_medals
FROM
	OLYMPICS_HISTORY o
JOIN
	OLYMPICS_HISTORY_NOC_REGIONS nr
ON
	o.noc = nr.noc
WHERE
	medal <> 'NA'
GROUP BY
	o.games,nr.region
ORDER BY
	1,2
)
SELECT 
	DISTINCT t.games,
			CONCAT(FIRST_VALUE(t.country) OVER(PARTITION BY t.games ORDER BY gold DESC), ' - ',
			FIRST_VALUE(gold) OVER(PARTITION BY t.games ORDER BY gold DESC)) AS Max_Gold,
			CONCAT(FIRST_VALUE(t.country) OVER(PARTITION BY t.games ORDER BY silver DESC), ' - ',
			FIRST_VALUE(silver) OVER(PARTITION BY t.games ORDER BY silver DESC)) AS Max_Silver,
			CONCAT(FIRST_VALUE(t.country) OVER(PARTITION BY t.games ORDER BY bronze DESC), ' - ',
			FIRST_VALUE(bronze) OVER(PARTITION BY t.games ORDER BY bronze DESC)) AS Max_Bronze,
			CONCAT(FIRST_VALUE(t.country) OVER(PARTITION BY t.games ORDER BY total_medals DESC), ' - ',
			FIRST_VALUE(tm.total_medals) OVER(PARTITION BY t.games ORDER BY tm.total_medals DESC)) AS Max_medals
FROM 
	temp t
JOIN
	tot_medals tm
ON
	t.games = tm.games and t.country = tm.country
ORDER BY 
	t.games;

-- 18. Which countries have never won gold medal but have won silver/bronze medals?
-- Problem Statement: Write a SQL Query to fetch details of countries which have won silver or bronze medal 
-- but never won a gold medal.

WITH temp AS(
SELECT country
        , coalesce(gold, 0) as gold
        , coalesce(bronze, 0) as bronze
		, coalesce(silver, 0) as silver
FROM CROSSTAB('
SELECT nr.region AS country, medal, count(1) as total_medals
FROM 
	olympics_history oh
JOIN 
	olympics_history_noc_regions nr 
ON
	nr.noc = oh.noc
WHERE 
	medal <> ''NA''
GROUP BY 
	nr.region,medal
ORDER BY 
	nr.region,medal',
'values (''Bronze''), (''Gold''), (''Silver'')')
AS FINAL_RESULT(country varchar, bronze bigint, gold bigint, silver bigint)
)
SELECT
	* 
FROM
	temp
WHERE
	gold = 0 and (silver > 0 or bronze >0)
ORDER BY 
	gold DESC nulls last, silver DESC nulls last, bronze DESC nulls last;

-- 19. In which Sport/event, Norway has won highest medals.
-- Problem Statement: Write SQL Query to return the sport which has won India the highest no of medals. 

WITH t1 AS(
SELECT 
	sport,COUNT(1) AS total_medals
FROM
	OLYMPICS_HISTORY 
WHERE
	medal <> 'NA' 
	AND
	team = 'Norway'
GROUP BY
	sport
ORDER BY
	total_medals DESC),
t2 AS(
SELECT
	*,RANK() OVER (ORDER BY total_medals DESC) as rnk
FROM 
	t1
)
SELECT
	sport,total_medals
FROM 
	t2
WHERE 
	rnk = 1;

-- 20. Break down all olympic games where Norway won medal for Hockey and how many medals in each olympic games
-- Problem Statement: Write an SQL Query to fetch details of all Olympic Games where India won medal(s) in hockey. 

Select * from OLYMPICS_HISTORY;
Select * from OLYMPICS_HISTORY_NOC_REGIONS;

SELECT 
	team,sport,games,COUNT(1) AS total_medals
FROM
	OLYMPICS_HISTORY
WHERE
	medal <> 'NA'
	AND
	team = 'Norway'
GROUP BY 
	team,sport,games
ORDER BY 
	total_medals DESC;

























