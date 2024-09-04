# :convenience_store: :shopping_cart: Case Study #5: Data Mart 
<p align="center">
<img src="https://8weeksqlchallenge.com/images/case-study-designs/5.png" alt="Image" width="450" height="450">

## Table Of Contents
  - [Introduction](#introduction)
  - [Problem Statement](#problem-statement)
  - [Dataset used](#dataset-used)
  - [Case Study Solutions](#case-study-solutions)
  
## Introduction
Data Mart is Danny’s latest venture and after running international operations for his online supermarket that specialises in fresh produce - Danny is asking for your support to analyse his sales performance.

In June 2020 - large scale supply changes were made at Data Mart. All Data Mart products now use sustainable packaging methods in every single step from the farm all the way to the customer.

Danny needs your help to quantify the impact of this change on the sales performance for Data Mart and it’s separate business areas.

## Problem Statement
The key business question he wants you to help him answer are the following:

- What was the quantifiable impact of the changes introduced in June 2020?
- Which platform, region, segment and customer types were the most impacted by this change?
 What can we do about future introduction of similar sustainability updates to the business to minimise impact on sales?
  
## Dataset used
![image](https://user-images.githubusercontent.com/77529445/189491024-b9d273be-b82e-4ded-af3e-6dbfac0ed6cb.png)

1. Data Mart has international operations using a multi-region strategy
2. Data Mart has both, a retail and online platform in the form of a Shopify store front to serve their customers
3. Customer segment and customer_type data relates to personal age and demographics information that is shared with Data Mart
4. transactions is the count of unique purchases made through Data Mart and sales is the actual dollar amount of purchases
Each record in the dataset is related to a specific aggregated slice of the underlying sales data rolled up into a week_date value which represents the start of the sales week.

## Case Study Solutions

#### 1. Data Cleansing Steps

In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:
  -Convert the week_date to a DATE format
  
  -Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc

  -Add a month_number with the calendar month for each week_date value as the 3rd column

  -Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values

  -Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value
  
  -Add a new demographic column using the following mapping for the first letter in the segment values:
  
  -Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns

  -Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record


  ```sql
BEGIN TRANSACTION;

DROP TABLE IF EXISTS clean_weekly_sales;
CREATE TABLE clean_weekly_sales (
  "week_date" VARCHAR(7),
  "week_number" INTEGER,
  "month_number" INTEGER,
  "calendar_year" INTEGER,
  "region" VARCHAR(13),
  "platform" VARCHAR(7),
  "segment" VARCHAR(8),
  "age_band" VARCHAR(25),
  "demographic"  VARCHAR(25),
  "customer_type" VARCHAR(8),
  "transactions" INTEGER,
  "sales" INTEGER,
  "avg_transaction"  NUMERIC(100,2)
);


INSERT INTO clean_weekly_sales (week_date, region, platform,segment,customer_type,transactions,sales)
	SELECT *
FROM weekly_sales;

ALTER TABLE clean_weekly_sales  ALTER COLUMN
week_date TYPE DATE
USING TO_DATE(week_date,'DD/MM/YY');

UPDATE clean_weekly_sales
SET week_number = EXTRACT(week FROM week_date);

UPDATE clean_weekly_sales
SET month_number = EXTRACT(month FROM week_date);

UPDATE clean_weekly_sales
SET calendar_year = EXTRACT(YEAR FROM week_date);


UPDATE clean_weekly_sales
SET age_band = CASE WHEN segment LIKE '%1%' THEN 'Young Adults' 
					   	 WHEN  segment LIKE '%2%' THEN 'Middle Aged'
						 WHEN  segment LIKE '%3%' OR segment LIKE '%4%' THEN 'Retirees'
						ELSE 'unknown' END;

UPDATE clean_weekly_sales
SET demographic = CASE WHEN segment  LIKE '%C%' THEN 'Couples'
					   WHEN segment  LIKE '%F%' THEN 'Families'
						ELSE 'unknown' END;

UPDATE clean_weekly_sales
SET segment = CASE WHEN segment = 'null' THEN 'unknown' ELSE segment END;


UPDATE clean_weekly_sales
SET avg_transaction = ROUND(sales/transactions,2);


END TRANSACTION;

SELECT * FROM clean_weekly_sales;
```

Output:

![obraz](https://github.com/user-attachments/assets/f3616817-4440-47b6-b16b-c87887548549)

***

## 2. Data Cleansing Steps

#### 1. What day of the week is used for each week_date value?

  ```sql
SELECT  TO_CHAR(week_date ,'DAY')
		,COUNT(*)
FROM clean_weekly_sales
GROUP BY TO_CHAR(week_date ,'DAY');

```

![obraz](https://github.com/user-attachments/assets/77cc9c31-d27b-4538-9426-4ec20d22c284)
***

#### 2. What range of week numbers are missing from the dataset?

  ```sql
WITH RECURSIVE cte(week) AS(

SELECT 1 as week

UNION ALL

SELECT c.week+1 as week
FROM cte AS c
WHERE c.week <52

),
sales AS (
	SELECT DISTINCT(week_number) as wn
FROM  clean_weekly_sales
)

SELECT *
FROM cte


EXCEPT

SELECT DISTINCT(week_number)
FROM  clean_weekly_sales
ORDER BY week ASC;

```


![obraz](https://github.com/user-attachments/assets/b4873936-3190-4427-b821-a05858f987f0)

***

#### 3. How many total transactions were there for each year in the dataset?

  ```sql
WITH RECURSIVE cte(week) AS(

SELECT 1 as week

UNION ALL

SELECT c.week+1 as week
FROM cte AS c
WHERE c.week <52

),
sales AS (
	SELECT DISTINCT(week_number) as wn
FROM  clean_weekly_sales
)

SELECT *
FROM cte


EXCEPT

SELECT DISTINCT(week_number)
FROM  clean_weekly_sales
ORDER BY week ASC;

```
![obraz](https://github.com/user-attachments/assets/e56b8967-d405-427a-b36a-75b0b68fa094)

***

#### 4. What is the total sales for each region for each month?

  ```sql
WITH RECURSIVE ctemth(mth) AS(

SELECT 1 as mth

UNION ALL

SELECT cm.mth+1 as week
FROM ctemth AS cm
WHERE cm.mth <12),

regions AS (
SELECT DISTINCT region 
FROM clean_weekly_sales),
	
report AS (
SELECT  region AS region
		,month_number AS month_nbr
		,SUM(sales) as total_sales
FROM clean_weekly_sales as cws
GROUP BY region, month_number
ORDER BY region, month_number ASC)

SELECT  rgn.region 
		,cm.mth
		,COALESCE(r.total_sales, 0) AS total_sales
FROM regions rgn
CROSS JOIN ctemth cm
LEFT JOIN report r
       ON rgn.region = r.region AND cm.mth = r.month_nbr
ORDER BY rgn.region, cm.mth;


```

![obraz](https://github.com/user-attachments/assets/76abc2a2-7108-4905-ad7d-19e0ed447c02)


***

#### 5. What is the total count of transactions for each platform

  ```sql

SELECT  platform
		,COUNT(transactions)
FROM clean_weekly_sales
GROUP BY platform;


```

![obraz](https://github.com/user-attachments/assets/5838be21-d646-4a8e-879d-86a75dc05ae9)

***

#### 6. What is the percentage of sales for Retail vs Shopify for each month?

  ```sql
WITH cte AS (
	SELECT  calendar_year
			,month_number
			,SUM(sales) filter (WHERE platform = 'Shopify') AS Shopify
			,SUM(sales) filter (WHERE platform = 'Retail') AS Retail
			,SUM(sales) as sales_total
	FROM clean_weekly_sales
GROUP BY calendar_year, month_number
)


SELECT  calendar_year
		,month_number
		,ROUND(100.0*Shopify/sales_total::NUMERIC,2) as shopify_perc
		,ROUND(100.0*Retail/sales_total::NUMERIC,2) as retail_perc
FROM cte
ORDER BY calendar_year,month_number;


```

![obraz](https://github.com/user-attachments/assets/fc2c8884-8373-40a9-85fb-b4cf828bc7ab)

***

#### 7. What is the percentage of sales by demographic for each year in the dataset?

  ```sql
WITH cte AS (
	SELECT 	 calendar_year
			,SUM(sales) filter (WHERE demographic = 'Couples') AS Couples
			,SUM(sales) filter (WHERE demographic = 'Families') AS Families
			,SUM(sales) filter (WHERE demographic = 'unknown') AS Not_classified
			,SUM(sales) as sales_total
	FROM clean_weekly_sales
group by calendar_year
)


SELECT  calendar_year
		,ROUND(100.0*Couples/sales_total::NUMERIC,2) as  Couples_perc
		,ROUND(100.0*Families/sales_total::NUMERIC,2) as Families_perc
		,ROUND(100.0*Not_classified/sales_total::NUMERIC,2) as Not_classified_perc
FROM cte

```

![obraz](https://github.com/user-attachments/assets/2c0686ef-cca6-4975-a631-62c3b727535f)

***


#### 8. Which age_band and demographic values contribute the most to Retail sales?

  ```sql

WITH cte AS (
	SELECT age_band,
	demographic,
	SUM(sales) OVER (PARTITION BY age_band,demographic) as contr,
	SUM(sales) OVER() as total
		FROM clean_weekly_sales
	WHERE platform='Retail'
	
)


	
SELECT cs.age_band,cs.demographic, c.contr, ROUND(100.0*contr/total,2) as perc_of_total
FROM clean_weekly_sales as cs
inner JOIN cte as c
	on  c.age_band = cs.age_band AND c.demographic = cs.demographic
WHERE platform='Retail'
GROUP BY cs.age_band,cs.demographic,c.contr,total
ORDER BY contr DESC


```

![obraz](https://github.com/user-attachments/assets/e78c7f6f-2e7f-44d7-9998-04b5cdf55c06)

***


#### 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

  ```sql

SELECT *
FROM crosstab(
    $$SELECT platform,
             calendar_year,
             ROUND(1.0 * SUM(sales) / SUM(transactions), 2) AS avg_sales_per_transaction
      FROM data_mart.clean_weekly_sales
      GROUP BY platform, calendar_year
      ORDER BY platform, calendar_year$$
) AS pivot_table (
    platform VARCHAR,
    y_2018 NUMERIC,
    y_2019 NUMERIC,
    y_2020 NUMERIC -- Add more years as needed
);


```

![obraz](https://github.com/user-attachments/assets/ec4869d4-dea0-43e3-9868-534081d6c07e)

***

#### 3. Before & After Analysis

This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.

We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before

Using this analysis approach - answer the following questions:

#### 1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?

  ```sql

with cte as(SELECT week_date, sales
from clean_weekly_sales
where week_date between to_date('2020-06-15','YYYY-MM-DD') - interval '4 weeks' 
	and to_date('2020-06-15','YYYY-MM-DD') + interval '4 weeks'
order by week_date desc	),
sums as (
select  sum(case when week_date < to_date('2020-06-15','YYYY-MM-DD') then sales else 0 end) as sales_before,
		sum(case when week_date > to_date('2020-06-15','YYYY-MM-DD') then sales else 0 end) as sales_after,
		sum(case when week_date <> to_date('2020-06-15','YYYY-MM-DD') then sales else 0 end) as sales_before_and_after
from cte)


SELECT  sales_before
		,sales_after
		,sales_before - sales_after as sales_diff
		,ROUND(100.0*(sales_before - sales_after)/sales_before,2) as perc_change
FROM sums;


```

![obraz](https://github.com/user-attachments/assets/4bee0bda-99de-4896-b016-4a3cfed12752)

***

#### 2. What about the entire 12 weeks before and after?

  ```sql

with cte as(SELECT week_date, sales
from clean_weekly_sales
where week_date between to_date('2020-06-15','YYYY-MM-DD') - interval '12 weeks' 
	and to_date('2020-06-15','YYYY-MM-DD') + interval '12 weeks'
order by week_date desc	),
sums as (
select  sum(case when week_date < to_date('2020-06-15','YYYY-MM-DD') then sales else 0 end) as sales_before,
		sum(case when week_date > to_date('2020-06-15','YYYY-MM-DD') then sales else 0 end) as sales_after,
		sum(case when week_date <> to_date('2020-06-15','YYYY-MM-DD') then sales else 0 end) as sales_before_and_after
from cte)


SELECT  sales_before
		,sales_after
		,sales_before - sales_after as sales_diff
		,ROUND(100.0*(sales_before - sales_after)/sales_before,2) as perc_change
FROM sums;

```

![obraz](https://github.com/user-attachments/assets/779917cf-3339-4681-957b-55d23a7f4e7d)

***

#### 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

 ```sql

with cte as (
	SELECT calendar_year
	, week_number
	, sales
	, (SELECT ANY_VALUE(week_number) FROM 
				clean_weekly_sales
				where week_date = to_date('2020-06-15','YYYY-MM-DD')) as benchmark
	from clean_weekly_sales
where week_number <= (SELECT ANY_VALUE(week_number) FROM 
clean_weekly_sales
where week_date = to_date('2020-06-15','YYYY-MM-DD'))+4 
	AND
	week_number >= (SELECT ANY_VALUE(week_number) FROM 
clean_weekly_sales
where week_date = to_date('2020-06-15','YYYY-MM-DD'))-4),

sums as(
select  calendar_year,
		sum(case when week_number < benchmark then sales else 0 end) as sales_before,
		sum(case when week_number > benchmark then sales else 0 end) as sales_after,
		sum(case when week_number <> benchmark then sales else 0 end) as sales_before_and_after
from cte
group by calendar_year)


SELECT  calendar_year
		,sales_before
		,sales_after
		,sales_before - sales_after as sales_diff
		,ROUND(100.0*(sales_before - sales_after)/sales_before,2) as perc_change
FROM sums;


```

![obraz](https://github.com/user-attachments/assets/63653a0d-f63c-42d9-8fa6-2d22b8febf20)

***






