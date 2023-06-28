-- A. Customer Journey --
-- Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey. --

SELECT customer_id,
       p.plan_id,
       plan_name,
       start_date
FROM foodie_fi.subscriptions AS s
LEFT JOIN foodie_fi.plans AS p
ON s.plan_id = p.plan_id
WHERE customer_id =1;

--Customer after free trail immediately decide to use basic monthly plan

SELECT customer_id,
       p.plan_id,
       plan_name,
       start_date
FROM foodie_fi.subscriptions AS s
LEFT JOIN foodie_fi.plans AS p
ON s.plan_id = p.plan_id
WHERE customer_id =16;

-- Customer started the free trial on 31 May 2020 and subscribed to the basic monthly during the seven day the trial period to continue the subscription
-- He upgraded to pro annual after 4 months on 21-10-2020

SELECT customer_id,
       p.plan_id,
       plan_name,
       start_date
FROM foodie_fi.subscriptions AS s
LEFT JOIN foodie_fi.plans AS p
ON s.plan_id = p.plan_id
WHERE customer_id =33;

-- Client after 7 days decide to use pro monthly, he declined and terminated his account 3 months later

SELECT customer_id,
       p.plan_id,
       plan_name,
       start_date
FROM foodie_fi.subscriptions AS s
LEFT JOIN foodie_fi.plans AS p
ON s.plan_id = p.plan_id
WHERE customer_id =  77;

--Customer after free trial decided to use pro monthly, after half year he switched to pro annual

SELECT customer_id,
       p.plan_id,
       plan_name,
       start_date
FROM foodie_fi.subscriptions AS s
LEFT JOIN foodie_fi.plans AS p
ON s.plan_id = p.plan_id
WHERE customer_id =11;

-- It seems that client did not want to stay longer, he churned after free trial

SELECT customer_id,
       p.plan_id,
       plan_name,
       start_date
FROM foodie_fi.subscriptions AS s
LEFT JOIN foodie_fi.plans AS p
ON s.plan_id = p.plan_id
WHERE customer_id =88;

-- Client tried trial, after that he switched to pro monthly

SELECT customer_id,
       p.plan_id,
       plan_name,
       start_date
FROM foodie_fi.subscriptions AS s
LEFT JOIN foodie_fi.plans AS p
ON s.plan_id = p.plan_id
WHERE customer_id =7;

-- After trial customer used basic monthly plan, 3 months later switched to pro

SELECT customer_id,
       p.plan_id,
       plan_name,
       start_date
FROM foodie_fi.subscriptions AS s
LEFT JOIN foodie_fi.plans AS p
ON s.plan_id = p.plan_id
WHERE customer_id =23;

-- Right after trial client switched to pro annual


--Ex. 1.How many customers has Foodie-Fi ever had? --
SELECT COUNT(DISTINCT customer_id)
FROM foodie_fi.subscriptions;

-- Ex. 2 What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value --
SELECT 	date_trunc('month', start_date),
		    COUNT(*)
FROM foodie_fi.subscriptions AS s
LEFT JOIN foodie_fi.plans AS p
ON s.plan_id = p.plan_id
WHERE p.plan_name = 'trial'
GROUP BY date_trunc('month', start_date)
ORDER BY date_trunc('month', start_date) ASC;

-- Ex. 3 What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name --
SELECT  p.plan_name, 
		    COUNT(*)
FROM foodie_fi.subscriptions AS s
LEFT JOIN foodie_fi.plans AS p
ON s.plan_id = p.plan_id
WHERE s.start_date > '2020-12-31'
GROUP BY p.plan_name;


-- Ex. 4 What is the customer count and percentage of customers who have churned rounded to 1 decimal place? --
SELECT  COUNT(DISTINCT customer_id) AS customer_count,
		ROUND(100 * COUNT(*)::NUMERIC / ( SELECT COUNT(DISTINCT customer_id) 
    									  FROM foodie_fi.subscriptions),1) AS churn_percentage
FROM foodie_fi.subscriptions AS s
LEFT JOIN foodie_fi.plans AS p
ON s.plan_id = p.plan_id
WHERE s.plan_id = 4;

-- Ex. 5 How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number? --
WITH ranking AS (
SELECT  s.customer_id, 
		    s.plan_id, 
		    p.plan_name,
		    ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.plan_id) AS plan_rank 
FROM foodie_fi.subscriptions s
JOIN foodie_fi.plans p
ON s.plan_id = p.plan_id)


SELECT  COUNT(DISTINCT customer_id),
		ROUND(100 * COUNT(DISTINCT customer_id)::NUMERIC / (SELECT COUNT(DISTINCT customer_id) 
    														FROM foodie_fi.subscriptions),1) AS churn_percentage
FROM ranking
WHERE plan_id = 4 AND plan_rank = 2;

  
-- Ex. 6 What is the number and percentage of customer plans after their initial free trial? --

WITH ranking AS (
SELECT  s.customer_id,
        s.plan_id, 
        p.plan_name,
	      LEAD(s.plan_id) OVER (PARTITION BY s.customer_id ORDER BY s.plan_id) AS lead_rank
FROM foodie_fi.subscriptions s
JOIN foodie_fi.plans p
  ON s.plan_id = p.plan_id)

SELECT p.plan_name,
COUNT(*),
ROUND(100 * COUNT(*)::NUMERIC / (
    SELECT COUNT(DISTINCT customer_id) 
    FROM foodie_fi.subscriptions),2) AS percentage
FROM ranking AS r
LEFT JOIN foodie_fi.plans AS p
ON p.plan_id = r.lead_rank
WHERE r.plan_id = 0
GROUP BY p.plan_name;


-- Ex. 7 What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31? --

WITH cte AS (
SELECT s.customer_id,
       s.plan_id, 
       p.plan_name,
	     LEAD(s.plan_id) OVER (PARTITION BY s.customer_id ORDER BY s.plan_id) AS lead_rank
FROM foodie_fi.subscriptions s
LEFT JOIN foodie_fi.plans as p
ON p.plan_id = s.plan_id
WHERE s.start_date <='2020-12-31')


SELECT  plan_id,
		    plan_name,
		    COUNT(*),
		    ROUND(100 * COUNT(*)::NUMERIC / (SELECT COUNT(DISTINCT customer_id) 
    									FROM foodie_fi.subscriptions),2) AS percentage
FROM cte
WHERE lead_rank IS NULL
GROUP BY plan_id, plan_name;

-- Ex. 8 How many customers have upgraded to an annual plan in 2020? --

SELECT COUNT(DISTINCT customer_id)
FROM foodie_fi.subscriptions
WHERE EXTRACT(YEAR FROM start_date) = 2020 AND plan_id = 3;


-- Ex. 9 How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi? --
WITH p0 AS (
SELECT  * FROM foodie_fi.subscriptions AS s
WHERE s.plan_id = 0),
p3 AS (
SELECT * FROM foodie_fi.subscriptions AS s
WHERE s.plan_id = 3)


SELECT ROUND(AVG(p3.start_date - p0.start_date),2)
FROM p0 
INNER JOIN p3 ON
p3.customer_id = p0.customer_id;


-- Ex. 10 Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc) --
WITH p0 AS (
SELECT  * FROM foodie_fi.subscriptions AS s
WHERE s.plan_id = 0),
p3 AS (
SELECT * FROM foodie_fi.subscriptions AS s
WHERE s.plan_id = 3),
connected AS (
SELECT p3.start_date - p0.start_date AS difference
FROM p0 
INNER JOIN p3 ON
p3.customer_id = p0.customer_id)


SELECT 
CASE WHEN difference < 31 THEN '0-30 days'
	 WHEN difference < 61 THEN '31-60 days'
	 WHEN difference < 91 THEN '61-90 days'
	 WHEN difference < 121 THEN '91-120 days'
	 WHEN difference < 151 THEN '121-150 days'
	 WHEN difference < 181 THEN '151-180  days'
	 ELSE '+180'
END AS test, COUNT(*)
FROM connected
GROUP BY test
ORDER BY COUNT(*);


-- Ex. 11 How many customers downgraded from a pro monthly to a basic monthly plan in 2020? --
WITH next_plan_cte AS (
  SELECT  customer_id, 
          plan_id, 
          start_date,
          LEAD(plan_id, 1) OVER(PARTITION BY customer_id 
      ORDER BY plan_id) as next_plan
  FROM foodie_fi.subscriptions)
  
 
SELECT 
  COUNT(*) AS downgraded
FROM next_plan_cte
WHERE start_date <= '2020-12-31'
  AND plan_id = 2 
  AND next_plan = 1;



