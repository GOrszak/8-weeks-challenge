## Case Study #4: Data Bank

<img src="https://user-images.githubusercontent.com/81607668/130343294-a8dcceb7-b6c3-4006-8ad2-fab2f6905258.png" alt="Image" width="500" height="520">

## 📚 Table of Contents
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Question and Solution](#question-and-solution)

Please note that all the information regarding the case study has been sourced from the following link: [here](https://8weeksqlchallenge.com/case-study-4/). 

***

## Business Task
Danny launched a new initiative, Data Bank which runs **banking activities** and also acts as the world’s most secure distributed **data storage platform**!

Customers are allocated cloud data storage limits which are directly linked to how much money they have in their accounts. 

The management team at Data Bank want to increase their total customer base - but also need some help tracking just how much data storage their customers will need.

This case study is all about calculating metrics, growth and helping the business analyse their data in a smart way to better forecast and plan for their future developments!

## Entity Relationship Diagram

<img width="631" alt="image" src="https://user-images.githubusercontent.com/81607668/130343339-8c9ff915-c88c-4942-9175-9999da78542c.png">

**Table 1: `regions`**

This regions table contains the `region_id` and their respective `region_name` values.

<img width="176" alt="image" src="https://user-images.githubusercontent.com/81607668/130551759-28cb434f-5cae-4832-a35f-0e2ce14c8811.png">

**Table 2: `customer_nodes`**

Customers are randomly distributed across the nodes according to their region. This random distribution changes frequently to reduce the risk of hackers getting into Data Bank’s system and stealing customer’s money and data!

<img width="412" alt="image" src="https://user-images.githubusercontent.com/81607668/130551806-90a22446-4133-45b5-927c-b5dd918f1fa5.png">

**Table 3: Customer Transactions**

This table stores all customer deposits, withdrawals and purchases made using their Data Bank debit card.

<img width="343" alt="image" src="https://user-images.githubusercontent.com/81607668/130551879-2d6dfc1f-bb74-4ef0-aed6-42c831281760.png">

***

## Question and Solution


## 🏦 A. Customer Nodes Exploration

**1. How many unique nodes are there on the Data Bank system?**

````sql
SELECT COUNT(DISTINCT node_id)
FROM customer_nodes;

````

![obraz](https://github.com/user-attachments/assets/c411e74f-56e1-4d7f-8bec-dbf8c2689222)

***

**2. What is the number of nodes per region?**

````sql
SELECT  region_name
		,COUNT(node_id)
	FROM regions AS r
LEFT JOIN customer_nodes AS cn
ON r.region_id = cn.region_id
GROUP BY r.region_name;

````

![obraz](https://github.com/user-attachments/assets/ecd1c6a2-e914-4e0b-b584-444500aac31f)

***

**3. How many customers are allocated to each region?**

````sql
SELECT  r.region_name
		,COUNT(DISTINCT customer_id)
	FROM customer_nodes AS ct
LEFT JOIN regions AS r
	ON ct.region_id = r.region_id
GROUP BY r.region_name;
````
![obraz](https://github.com/user-attachments/assets/ead8c930-1ede-441e-93e3-844103182dbf)


***

**4. How many days on average are customers reallocated to a different node?**

This questions is harder than is seems to be. Here is my approach step by step to help understand thought process behind solution.

````sql
SELECT *
		,case when lead(node_id) over(partition by customer_id order by customer_id asc, start_date asc) = node_id then 0 else 1 end as test
from customer_nodes
	order by customer_id asc, start_date asc)
````
![obraz](https://github.com/user-attachments/assets/caa44e9b-5069-448b-8c5c-988f7d808c00)

I created test column that will indefy if node has been changed. if yes it will show 1. For example first value is 0 because node did not change. Second value is 1 because it changed from node number 4 to node number 2. Therefore I found issue that even though there is no change between 2 last rows value is still one. It is same pattern (I checked for random clients) so 2nd step was to substract 1 from sum of change (on user level)

````sql
WITH cte AS (
SELECT *
		,case when lead(node_id) over(partition by customer_id order by customer_id asc, start_date asc) = node_id then 0 else 1 end as test
from customer_nodes
	order by customer_id asc, start_date asc),

count_changes AS (
	SELECT customer_id, SUM(test)-1 as changes_in_total
from cte
	group by customer_id)

	SELECT * from count_changes;
````

![obraz](https://github.com/user-attachments/assets/4217bda3-b70a-4850-9d95-b418898cc1ca)

Number of changes per client

````sql
WITH cte AS (
SELECT *
		,case when lead(node_id) over(partition by customer_id order by customer_id asc, start_date asc) = node_id then 0 else 1 end as test
from customer_nodes
	order by customer_id asc, start_date asc),

count_changes AS (
	SELECT customer_id, SUM(test)-1 as changes_in_total
from cte
	group by customer_id)

	
SELECT cc.customer_id, round((max(start_date) - min(start_date))*1.0/cc.changes_in_total,2)as relocation
from customer_nodes as cn
left join count_changes as cc
	on cn.customer_id = cc.customer_id
group by cc.customer_id,cc.changes_in_total
	order by cc.customer_id asc
````

![obraz](https://github.com/user-attachments/assets/349e63f0-5a58-40b1-bc83-ffdd27819f5f)

Amount of days that account is active divided by amount of node change per client. 

````sql
WITH cte AS (
SELECT *
		,case when lead(node_id) over(partition by customer_id order by customer_id asc, start_date asc) = node_id then 0 else 1 end as test
from customer_nodes
	order by customer_id asc, start_date asc),

count_changes AS (
	SELECT customer_id, SUM(test)-1 as changes_in_total
from cte
	group by customer_id)

	
SELECT ROUND(AVG(relocation),0) 
FROM(
	
SELECT cc.customer_id, round((max(start_date) - min(start_date))*1.0/cc.changes_in_total,2)as relocation
from customer_nodes as cn
left join count_changes as cc
	on cn.customer_id = cc.customer_id
group by cc.customer_id,cc.changes_in_total
	order by cc.customer_id asc  ) as sub;

````

Final code with solution

![obraz](https://github.com/user-attachments/assets/fc1e45c6-4f9d-4e97-a979-fc036615594c)




***

**5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?**

````sql
WITH cte AS (
SELECT cn.*
		,case when lead(node_id) over(partition by customer_id order by customer_id asc, start_date asc) = node_id then 0 else 1 end as test
from customer_nodes as cn
	order by customer_id asc, start_date asc),
	
count_changes AS (
	SELECT customer_id, region_id, SUM(test)-1 as changes_in_total
from cte
	group by customer_id, region_id
order by customer_id),

avg_per_client_and_region AS (
	SELECT cc.customer_id, r.region_name , round((max(start_date) - min(start_date))*1.0/cc.changes_in_total,2)as relocation
from customer_nodes as cn
	left join count_changes as cc
		on cn.customer_id = cc.customer_id
left join regions as r
	on r.region_id = cc.region_id
group by cc.customer_id, r.region_name,cc.changes_in_total
	order by cc.customer_id asc)


SELECT DISTINCT region_name,
	(SELECT ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY relocation)::NUMERIC,0) FROM avg_per_client_and_region AS apc WHERE apc.region_name = avg_per_client_and_region.region_name) AS median,
	(SELECT ROUND(PERCENTILE_CONT(0.8) WITHIN GROUP(ORDER BY relocation)::NUMERIC,0) FROM avg_per_client_and_region AS apc WHERE apc.region_name = avg_per_client_and_region.region_name) AS percentile_80, 
	(SELECT ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP(ORDER BY relocation)::NUMERIC,0) FROM avg_per_client_and_region AS apc WHERE apc.region_name = avg_per_client_and_region.region_name) AS percentile_95
FROM avg_per_client_and_region;


````
Same approach as in 4th Exercise 

![obraz](https://github.com/user-attachments/assets/bf2e4cb4-ee54-4775-9aac-c9c74b3e3ca8)




***

## 🏦 B. Customer Transactions

**1. What is the unique count and total amount for each transaction type?**

````sql
SELECT  txn_type
	,COUNT(*)
	,SUM(txn_amount)
FROM customer_transactions
GROUP BY txn_type;

````

![obraz](https://github.com/user-attachments/assets/5bde89db-a645-4140-bf45-ba19249a357f)

***

**2. What is the average total historical deposit counts and amounts for all customers?**

````sql
WITH cte AS (
SELECT  customer_id
		,COUNT(*) deposits
		,SUM(txn_amount) depo_sum
FROM customer_transactions
WHERE txn_type = 'deposit'
GROUP BY customer_id)


SELECT  ROUND(AVG(deposits),2) AS avg_nbr_depo
		,ROUND(AVG(depo_sum),2) as avg_sum_depo
FROM cte;
````

![obraz](https://github.com/user-attachments/assets/85133766-4810-4fd2-bc1a-e597b8e950b0)

***

**3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?**

First, create a CTE  to determine the count of deposit, purchase and withdrawal for each customer categorised by month using `CASE` statement and `SUM()`. 

In the main query, select the `mth` column and count the number of unique customers where:
- `depo` is greater than 1, indicating more than one deposit 
- Either `purch` is greater than or equal to 1  OR `withd` is greater than or equal to 1 

````sql
WITH cte AS (
SELECT   customer_id
		,EXTRACT(month from txn_date) as mth_number
		,sum(case when txn_type = 'deposit' then 1 else 0 end) as depo
		,sum(case when txn_type = 'purchase' then 1 else 0 end) as purch
		,sum(case when txn_type = 'withdrawal' then 1 else 0 end) as withd
FROM customer_transactions
GROUP BY customer_id,EXTRACT(month from txn_date)
order by customer_id asc)


SELECT  mth_number, COUNT(*)
FROM cte
WHERE depo > 1 AND (purch = 1 OR withd = 1)
GROUP BY mth_number;

````
![obraz](https://github.com/user-attachments/assets/03ca68ee-8752-447a-a5ab-d87239010b08)


***

**4. What is the closing balance for each customer at the end of the month? Also show the change in balance each month in the same table output.**


```sql
WITH cte as (SELECT customer_id, txn_date, txn_type, 
case when txn_type = 'purchase' then txn_amount*(-1)
when txn_type = 'withdrawal' then txn_amount*(-1)
	else txn_amount end as txn_amount_changed
	from customer_transactions
order by customer_id asc),
cte_final as (SELECT  customer_id
		,txn_date
		,txn_amount_changed
		,sum(txn_amount_changed) over(partition by customer_id  order by txn_date asc) as final_amount
		,rank() over(partition by customer_id, extract(month from txn_date) order by txn_date desc) as ranking
from cte)

SELECT  customer_id
		,EXTRACT(month from txn_date) as mth
		,final_amount
FROM cte_final
where ranking = 1;
```

![obraz](https://github.com/user-attachments/assets/1e084fff-cad0-4cd0-be40-11e4b9676958)

1. Dividing tranasction based on category (when withdrawal or purchase then value * (-1))

2. Sum over transaction amount 

3. rank function to determinate last transaction of the month which would be ranked as 1

4. Selecting latest transaction of each month, thanks to summing over we have balance at the end of the each month



***


**5. Comparing the closing balance of a customer’s first month and the closing balance from their second nth, what percentage of customers:**

For this question, I have created 2 temporary tables to solve the questions below:
- Create temp table #1 `customer_monthly_balances` by copying and pasting the code from the solution to Question 4. 
- Use temp table #1 `ranked_monthly_balances` to create temp table #2 by applying the `ROW_NUMBER()` function. 

```sql
WITH cte as (SELECT customer_id, txn_date, txn_type, 
case when txn_type = 'purchase' then txn_amount*(-1)
when txn_type = 'withdrawal' then txn_amount*(-1)
	else txn_amount end as txn_amount_changed
	from customer_transactions
order by customer_id asc),
cte_grouped as (SELECT  customer_id
		,txn_date
		,txn_amount_changed
		,sum(txn_amount_changed) over(partition by customer_id  order by txn_date asc) as final_amount
		,rank() over(partition by customer_id, extract(month from txn_date) order by txn_date desc) as ranking
from cte),

cte_test as (
SELECT * FROM(
	SELECT  customer_id
		,EXTRACT(month from txn_date) as mth
		,final_amount
		,COALESCE(LAG(final_amount) OVER (PARTITION BY customer_id ORDER BY EXTRACT(month from txn_date)),final_amount) as previous_month_amount
		,final_amount -  (COALESCE(LAG(final_amount) OVER (PARTITION BY customer_id ORDER BY EXTRACT(month from txn_date)),final_amount))
		,ROUND((final_amount -  (COALESCE(LAG(final_amount) OVER (PARTITION BY customer_id ORDER BY EXTRACT(month from txn_date)),final_amount)))*100.0
		/NULLIF(ABS(COALESCE(LAG(final_amount) OVER (PARTITION BY customer_id ORDER BY EXTRACT(month from txn_date)),0)),0),2) as prc
FROM cte_grouped
	WHERE ranking = 1)
WHERE prc is not null)
	
SELECT ROUND(COUNT(DISTINCT customer_id)*100.0/(SELECT COUNT(DISTINCT customer_id) FROM cte_test),2)
FROM cte_test 
WHERE customer_id NOT IN (
    SELECT customer_id
    FROM cte_test 
    WHERE prc < 5.00)
```

**- What percentage of customers have a negative first month balance? What percentage of customers have a positive first month balance?**

To address both questions, I'm using one solution since the questions are asking opposite spectrums of each other.  

````sql
-- Method 1
SELECT 
  ROUND(100.0 * 
    SUM(CASE 
      WHEN ending_balance::TEXT LIKE '-%' THEN 1 ELSE 0 END)
    /(SELECT COUNT(DISTINCT customer_id) 
    FROM customer_monthly_balances),1) AS negative_first_month_percentage,
  ROUND(100.0 * 
    SUM(CASE 
      WHEN ending_balance::TEXT NOT LIKE '-%' THEN 1 ELSE 0 END)
    /(SELECT COUNT(DISTINCT customer_id) 
    FROM customer_monthly_balances),1) AS positive_first_month_percentage
FROM ranked_monthly_balances
WHERE ranked_row = 1;
````

A cheeky solution would be to simply calculate one of the percentages requested and then deducting it from 100%.
```sql
-- Method 2
SELECT 
  ROUND(100.0 * 
    COUNT(customer_id)
    /(SELECT COUNT(DISTINCT customer_id) 
    FROM customer_monthly_balances),1) AS negative_first_month_percentage,
  100 - ROUND(100.0 * COUNT(customer_id)
    /(SELECT COUNT(DISTINCT customer_id) 
    FROM customer_monthly_balances),1) AS positive_first_month_percentage
FROM ranked_monthly_balances
WHERE ranked_row = 1
  AND ending_balance::TEXT LIKE '-%';
```

**Answer:**

|negative_first_month_percentage|positive_first_month_percentage|
|:----|:----|
|44.8|55.2|

**- What percentage of customers increase their opening month’s positive closing balance by more than 5% in the following month?**

I'm using `LEAD()` window function to query the balances for the following month and then, filtering the results to select only the records with balances for the 1st and 2nd month. 

Important assumptions:
- Negative balances in the `following_balance` field have been excluded from the results. This is because a higher negative balance in the following month does not represent a true increase in balances. 
- Including negative balances could lead to a misrepresentation of the answer as the percentage of variance would still appear as a positive percentage. 

````sql
WITH following_month_cte AS (
  SELECT
    customer_id, 
    ending_month, 
    ending_balance, 
    LEAD(ending_balance) OVER (
      PARTITION BY customer_id 
      ORDER BY ending_month) AS following_balance
  FROM ranked_monthly_balances
)
, variance_cte AS (
  SELECT 
    customer_id, 
    ending_month, 
    ROUND(100.0 * 
      (following_balance - ending_balance) / ending_balance,1) AS variance
  FROM following_month_cte  
  WHERE ending_month = '2020-01-31'
    AND following_balance::TEXT NOT LIKE '-%'
  GROUP BY 
    customer_id, ending_month, ending_balance, following_balance
  HAVING ROUND(100.0 * (following_balance - ending_balance) / ending_balance,1) > 5.0
)

SELECT 
  ROUND(100.0 * 
    COUNT(customer_id)
    / (SELECT COUNT(DISTINCT customer_id) 
    FROM ranked_monthly_balances),1) AS increase_5_percentage
FROM variance_cte; 
````

**Answer:**

|increase_5_percentage|
|:----|
|20.0|

- Among the customers, 20% experience a growth of more than 5% in their positive closing balance from the opening month to the following month.

**- What percentage of customers reduce their opening month’s positive closing balance by more than 5% in the following month?**

````sql
WITH following_month_cte AS (
  SELECT
    customer_id, 
    ending_month, 
    ending_balance, 
    LEAD(ending_balance) OVER (
      PARTITION BY customer_id 
      ORDER BY ending_month) AS following_balance
  FROM ranked_monthly_balances
)
, variance_cte AS (
  SELECT 
    customer_id, 
    ending_month, 
    ROUND((100.0 * 
      following_balance - ending_balance) / ending_balance,1) AS variance
  FROM following_month_cte  
  WHERE ending_month = '2020-01-31'
    AND following_balance::TEXT NOT LIKE '-%'
  GROUP BY 
    customer_id, ending_month, ending_balance, following_balance
  HAVING ROUND((100.0 * (following_balance - ending_balance)) / ending_balance,2) < 5.0
)

SELECT 
  ROUND(100.0 * 
    COUNT(customer_id)
    / (SELECT COUNT(DISTINCT customer_id) 
    FROM ranked_monthly_balances),1) AS reduce_5_percentage
FROM variance_cte; 
````

**Answer:**

|reduce_5_percentage|
|:----|
|25.6|

- Among the customers, 25.6% experience a drop of more than 5% in their positive closing balance from the opening month to the following month.

**- What percentage of customers move from a positive balance in the first month to a negative balance in the second month?**

````sql
WITH following_month_cte AS (
  SELECT
    customer_id, 
    ending_month, 
    ending_balance, 
    LEAD(ending_balance) OVER (
      PARTITION BY customer_id 
      ORDER BY ending_month) AS following_balance
  FROM ranked_monthly_balances
)
, variance_cte AS (
  SELECT *
  FROM following_month_cte
  WHERE ending_month = '2020-01-31'
    AND ending_balance::TEXT NOT LIKE '-%'
    AND following_balance::TEXT LIKE '-%'
)

SELECT 
  ROUND(100.0 * 
    COUNT(customer_id) 
    / (SELECT COUNT(DISTINCT customer_id) 
    FROM ranked_monthly_balances),1) AS positive_to_negative_percentage
FROM variance_cte;
````


