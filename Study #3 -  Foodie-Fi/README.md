## Introduction
Subscription based businesses are super popular and Danny realised that there was a large gap in the market - he wanted to create a new streaming service that only had food related content - something like Netflix but with only cooking shows!

Danny finds a few smart friends to launch his new startup Foodie-Fi in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world!

Danny created Foodie-Fi with a data driven mindset and wanted to ensure all future investment decisions and new features were decided using data. This case study focuses on using subscription style digital data to answer important business questions.

## Datasets

**plans table** : Customers can choose which plans to join Foodie-Fi when they first sign up.

There are 5 customer plans.
- Basic plan - customers have limited access and can only stream their videos and is only available monthly at $9.90
- Pro plan - customers have no watch time limits and are able to download videos for offline viewing. Pro plans start at $19.90 a month or $199 for an annual subscription.
- Trial plan - Customers can sign up to an initial 7 day free trial will automatically continue with the pro monthly subscription plan unless they cancel, downgrade to basic or upgrade to an annual pro plan at any point during the trial.
- Churn plan - When customers cancel their Foodie-Fi service - they will have a churn plan record with a null price but their plan will continue until the end of the billing period.

**subscriptions table** 
- Customer subscriptions show the *exact date where their specific plan_id starts*.
- If customers *downgrade* from a pro plan or *cancel their subscription* - the higher plan will remain in place until the period is over - the start_date in the subscriptions table will reflect the date that the actual plan changes.
- When customers *upgrade* their account from a basic plan to a pro or annual pro plan - the higher plan will take effect straightaway.
- When customers *churn* - they will keep their access until the end of their current billing period but the start_date will be technically the day they decided to cancel their service.

## Entity Relationship Diagram
![alt text](https://github.com/iweld/8-Week-SQL-Challenge/blob/main/Case%20Study%203%20-%20Foodie-Fi/ERD.JPG)



## Case Study Questions ##
This case study is split into an initial data understanding question before diving straight into data analysis questions before finishing with 1 single extension challenge.

### A. Customer Journey ###
Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!


```sql
SELECT customer_id,
       p.plan_id,
       plan_name,
       start_date
FROM foodie_fi.subscriptions AS s
LEFT JOIN foodie_fi.plans AS p
ON s.plan_id = p.plan_id
WHERE customer_id =1;
```

| customer_id | plan_id | plan_name| start_date|
| --------- | ------- | ----- | ------ |
| 1         |  0 | trial | 2020-08-01|
|  1        |   1 | basic monthly | 2020-08-08 |

Customer after free trail immediately decide to use basic monthly plan

------------- 

```sql
SELECT customer_id,
       p.plan_id,
       plan_name,
       start_date
FROM foodie_fi.subscriptions AS s
LEFT JOIN foodie_fi.plans AS p
ON s.plan_id = p.plan_id
WHERE customer_id =16;
```

| customer_id | plan_id | plan_name| start_date|
| --------- | ------- | ----- | ------ |
| 16       |  0 | trial | 2020-05-31|
|  16        |   1 | basic monthly | 2020-06-07|
| 16 |3 | pro annual |2020-10-21|

Customer started the free trial on 31 May 2020 and subscribed to the basic monthly during the seven day the trial period to continue the subscription.
He upgraded to pro annual after 4 months on 21-10-2020

------------- 

```sql
SELECT customer_id,
       p.plan_id,
       plan_name,
       start_date
FROM foodie_fi.subscriptions AS s
LEFT JOIN foodie_fi.plans AS p
ON s.plan_id = p.plan_id
WHERE customer_id =33;
```

| customer_id | plan_id | plan_name| start_date|
| --------- | ------- | ----- | ------ |
| 33       |  0 | trial | 2020-09-03|
|  33       |   4 | pro monthly | 2020-09-10|
| 33 |2| churn |2021-02-05|

Client after 7 days decide to use pro monthly, he declined and terminated his account 3 months later

------------- 


```sql
SELECT customer_id,
       p.plan_id,
       plan_name,
       start_date
FROM foodie_fi.subscriptions AS s
LEFT JOIN foodie_fi.plans AS p
ON s.plan_id = p.plan_id
WHERE customer_id =77;
```

| customer_id | plan_id | plan_name| start_date|
| --------- | ------- | ----- | ------ |
| 77       |  0 | trial | 2020-04-18|
|  77       |   2 | pro monthly | 2020-04-25|
| 77 |3| pro annual |2020-10-25|

Customer after free trial decided to use pro monthly, after half year he switched to pro annual

------------- 

```sql
SELECT customer_id,
       p.plan_id,
       plan_name,
       start_date
FROM foodie_fi.subscriptions AS s
LEFT JOIN foodie_fi.plans AS p
ON s.plan_id = p.plan_id
WHERE customer_id =11;
```


| customer_id | plan_id | plan_name| start_date|
| --------- | ------- | ----- | ------ |
| 11       |  0 | trial | 2020-11-19|
|  11       |   4 | churn | 2020-11-26|


It seems that client did not want to stay longer, he churned after free trial

------------- 


```sql
SELECT customer_id,
       p.plan_id,
       plan_name,
       start_date
FROM foodie_fi.subscriptions AS s
LEFT JOIN foodie_fi.plans AS p
ON s.plan_id = p.plan_id
WHERE customer_id =88;
```

| customer_id | plan_id | plan_name| start_date|
| --------- | ------- | ----- | ------ |
| 88       |  0 | trial | 2020-12-30|
|  88      |   2 | pro monthly | 2021-01-06|


Client tried trial, after that he switched to pro monthly

------------- 


```sql
SELECT customer_id,
       p.plan_id,
       plan_name,
       start_date
FROM foodie_fi.subscriptions AS s
LEFT JOIN foodie_fi.plans AS p
ON s.plan_id = p.plan_id
WHERE customer_id =7;
```

| customer_id | plan_id | plan_name| start_date|
| --------- | ------- | ----- | ------ |
| 7       |  0 | trial | 2020-02-05|
|  7      |   1 | basic monthly | 2020-02-12|
| 7 | 2 | pro monthly | 2020-05-22 |


After trial customer used basic monthly plan, 3 months later switched to pro

------------- 


```sql
SELECT customer_id,
       p.plan_id,
       plan_name,
       start_date
FROM foodie_fi.subscriptions AS s
LEFT JOIN foodie_fi.plans AS p
ON s.plan_id = p.plan_id
WHERE customer_id =23;
```


| customer_id | plan_id | plan_name| start_date|
| --------- | ------- | ----- | ------ |
|  23      |  0 | trial | 2020-05-13|
|  23      |   3 | pro annual | 2020-05-20|


After trial customer used basic monthly plan, 3 months later switched to pro

------------- 
### B. Data Analysis Questions ###


#### 1. How many customers has Foodie-Fi ever had?

```sql
SELECT COUNT(DISTINCT customer_id)
FROM foodie_fi.subscriptions;
```


| count | 
| --------- | 
|  1000      | 


------------- 


#### 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

```sql
SELECT 	date_trunc('month', start_date),
		COUNT(*)
FROM foodie_fi.subscriptions AS s
LEFT JOIN foodie_fi.plans AS p
ON s.plan_id = p.plan_id
WHERE p.plan_name = 'trial'
GROUP BY date_trunc('month', start_date)
ORDER BY date_trunc('month', start_date) ASC;
```

|date_trunc|count|
| --------- | --------- |
|2020-01-01 00:00:00+01|88|
|2020-02-01 00:00:00+01|68|
|2020-03-01 00:00:00+01|94|
|2020-04-01 00:00:00+02|81|
|2020-05-01 00:00:00+02|88|
|2020-06-01 00:00:00+02|79|
|2020-07-01 00:00:00+02|89|
|2020-08-01 00:00:00+02|88|
|2020-09-01 00:00:00+02|87|
|2020-10-01 00:00:00+02|79|
|2020-11-01 00:00:00+01|75|
|2020-12-01 00:00:00+01|84|




------------- 




#### 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

```sql
SELECT  p.plan_name, 
		COUNT(*)
FROM foodie_fi.subscriptions AS s
LEFT JOIN foodie_fi.plans AS p
ON s.plan_id = p.plan_id
WHERE s.start_date > '2020-12-31'
GROUP BY p.plan_name;

```


| plan_name| count |
| --------- |  ----- |
|  pro annual     | 63 |
| churn | 71 |
| pro monthly| 60 |
| basic monthly | 8 |


------------- 


#### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

```sql
SELECT  COUNT(DISTINCT customer_id) AS customer_count,
		ROUND(100 * COUNT(*)::NUMERIC / ( SELECT COUNT(DISTINCT customer_id) 
    									  FROM foodie_fi.subscriptions),1) AS churn_percentage
FROM foodie_fi.subscriptions AS s
LEFT JOIN foodie_fi.plans AS p
ON s.plan_id = p.plan_id
WHERE s.plan_id = 4;

```


| customer_count| churn_percantage |
| --------- |  ----- |
|  307 | 30.7 |



------------- 


#### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

```sql
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

```


| count| churn_percantage |
| --------- |  ----- |
|  92 | 9.2 |



------------- 


#### 6. What is the number and percentage of customer plans after their initial free trial?

```sql
WITH ranking AS (
SELECT 
 s.customer_id,
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

```

| plan_name| count | percentage |
| --------- |  ----- | --- |
|  pro annual     | 37 | 3.7|
| churn | 92 | 9.2 |
| pro monthly| 325 | 32.5 |
| basic monthly | 546 | 54.6 |




------------- 



#### 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

```sql
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

```

| plan_id| plan_name| count | percentage | 
| --------- |  ----- | --- | ---- |
| 0|  trial     | 19 |1.9| 
| 1| basic monthly | 224 | 22.4 | 
| 2| pro monthly| 326 | 32.6 | 
| 3|pro annual | 195 | 19.5 |  
| 4|  churn| 236 | 23.6| 



------------- 




#### 8. How many customers have upgraded to an annual plan in 2020?

```sql
SELECT COUNT(DISTINCT customer_id)
FROM foodie_fi.subscriptions
WHERE EXTRACT(YEAR FROM start_date) = 2020 AND plan_id = 3;

```

| count | 
| --------- | 
| 195     | 




------------- 


#### 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

```sql
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


```

| test | count |
| --------- | ---- |
| 31-60 days   | 24 |
| 61-90 days| 34|
| 91-120 days| 35 |
|151-180  days |36 |
| +180| 38|
|121-150 days | 42|
| 0-30 days| 49 |


------------- 



#### 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)


```sql
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


```

| round | 
| --------- | 
| 104.62     | 




------------- 


#### 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?




```sql
WITH next_plan_cte AS (
  SELECT 
    customer_id, 
    plan_id, 
    start_date,
    LEAD(plan_id, 1) OVER(
      PARTITION BY customer_id 
      ORDER BY plan_id) as next_plan
  FROM foodie_fi.subscriptions)
  
 
SELECT 
  COUNT(*) AS downgraded
FROM next_plan_cte
WHERE start_date <= '2020-12-31'
  AND plan_id = 2 
  AND next_plan = 1;



```

| downgraded| 
| --------- | 
| 0    | 

------------- 


