## 🌲 Case Study #7: Balanced Tree

<img src="https://github.com/katiehuangx/8-Week-SQL-Challenge/assets/81607668/8ada3c0c-e90a-47a7-9a5c-8ffd6ee3eef8" alt="Image" width="500" height="520">

## 📚 Table of Contents
- [Introduction](#introduction)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Question and Solution](#question-and-solution)

Please note that all the information regarding the case study has been sourced from the following link: [here](https://8weeksqlchallenge.com/case-study-7/). 

***

## Introduction

Balanced Tree Clothing Company prides themselves on providing an optimised range of clothing and lifestyle wear for the modern adventurer!

Danny, the CEO of this trendy fashion company has asked you to assist the team’s merchandising teams **analyse their sales performance and generate a basic financial report** to share with the wider business.

## Entity Relationship Diagram

<img width="932" alt="image" src="https://github.com/katiehuangx/8-Week-SQL-Challenge/assets/81607668/2ce4df84-2b05-4fe9-a50c-47c903b392d5">

**Table 1: `product_details`**

|product_id|price|product_name|category_id|segment_id|style_id|category_name|segment_name|style_name|
|:----|:----|:----|:----|:----|:----|:----|:----|:----|
|c4a632|13|Navy Oversized Jeans - Womens|1|3|7|Womens|Jeans|Navy Oversized|
|e83aa3|32|Black Straight Jeans - Womens|1|3|8|Womens|Jeans|Black Straight|
|e31d39|10|Cream Relaxed Jeans - Womens|1|3|9|Womens|Jeans|Cream Relaxed|
|d5e9a6|23|Khaki Suit Jacket - Womens|1|4|10|Womens|Jacket|Khaki Suit|
|72f5d4|19|Indigo Rain Jacket - Womens|1|4|11|Womens|Jacket|Indigo Rain|
|9ec847|54|Grey Fashion Jacket - Womens|1|4|12|Womens|Jacket|Grey Fashion|
|5d267b|40|White Tee Shirt - Mens|2|5|13|Mens|Shirt|White Tee|
|c8d436|10|Teal Button Up Shirt - Mens|2|5|14|Mens|Shirt|Teal Button Up|
|2a2353|57|Blue Polo Shirt - Mens|2|5|15|Mens|Shirt|Blue Polo|
|f084eb|36|Navy Solid Socks - Mens|2|6|16|Mens|Socks|Navy Solid|


**Table 2: `sales`**

|prod_id|qty|price|discount|member|txn_id|start_txn_time|
|:----|:----|:----|:----|:----|:----|:----|
|c4a632|4|13|17|true|54f307|2021-02-13T01:59:43.296Z|
|5d267b|4|40|17|true|54f307|2021-02-13T01:59:43.296Z|
|b9a74d|4|17|17|true|54f307|2021-02-13T01:59:43.296Z|
|2feb6b|2|29|17|true|54f307|2021-02-13T01:59:43.296Z|
|c4a632|5|13|21|true|26cc98|2021-01-19T01:39:00.345Z|
|e31d39|2|10|21|true|26cc98|2021-01-19T01:39:00.345Z|
|72f5d4|3|19|21|true|26cc98|2021-01-19T01:39:00.345Z|
|2a2353|3|57|21|true|26cc98|2021-01-19T01:39:00.345Z|
|f084eb|3|36|21|true|26cc98|2021-01-19T01:39:00.345Z|
|c4a632|1|13|21|false|ef648d|2021-01-27T02:18:17.164Z|

**Table 3: `product_hierarchy`**

|id|parent_id|level_text|level_name|
|:----|:----|:----|:----|
|1|null|Womens|Category|
|2|null|Mens|Category|
|3|1|Jeans|Segment|
|4|1|Jacket|Segment|
|5|2|Shirt|Segment|
|6|2|Socks|Segment|
|7|3|Navy Oversized|Style|
|8|3|Black Straight|Style|
|9|3|Cream Relaxed|Style|
|10|4|Khaki Suit|Style|

**Table 4: `product_prices`**

|id|product_id|price|
|:----|:----|:----|
|7|c4a632|13|
|8|e83aa3|32|
|9|e31d39|10|
|10|d5e9a6|23|
|11|72f5d4|19|
|12|9ec847|54|
|13|5d267b|40|
|14|c8d436|10|
|15|2a2353|57|
|16|f084eb|36|

***

## Question and Solution

## 📈 A. High Level Sales Analysis

**1. What was the total quantity sold for all products?**

```sql
SELECT SUM(qty)
FROM balanced_tree.sales;
```

**Answer:**

|sum|
|:----|
|45216|


***

**2. What is the total generated revenue for all products before discounts?**

```sql
SELECT SUM(qty * price) AS total_revenue
FROM balanced_tree.sales;
```

**Answer:**

|total_revenue|
|:----|
|1289453|


***

**3. What was the total discount amount for all products?**

```sql
SELECT SUM(qty*price*discount/100) AS total_discount
FROM  balanced_tree.sales;
```

**Answer:**

|total_discount|
|:----|
|149486|

***

## 🧾 B. Transaction Analysis

**1. How many unique transactions were there?**

```sql
SELECT COUNT (DISTINCT txn_id) AS unique_transactions
FROM balanced_tree.sales;
```

**Answer:**

|unique_transactions|
|:----|
|2500|

***

**2. What is the average unique products purchased in each transaction?**

```sql
SELECT ROUND(AVG(to_count))
FROM ( SELECT txn_id, COUNT(DISTINCT prod_id) AS to_count 
	  FROM balanced_tree.sales
	  GROUP BY txn_id) AS x;
```

**Answer:**

|round|
|:----|
|6|

***

**3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?**

```sql
SELECT  PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY revenue),
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY revenue),
		PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY revenue)
FROM(
	SELECT SUM(qty*price) AS revenue
	FROM balanced_tree.sales
	GROUP BY txn_id) AS x;

```

**Answer:**

|percentile_cont|percentile_cont|percentile_cont|
|:----|:----|:----|
|375.75|509.5|647|

***

**4. What is the average discount value per transaction?**

```sql
SELECT ROUND(AVG(dsc)) as avg_discount
FROM (
SELECT SUM(qty*price*discount/100) AS dsc
FROM  balanced_tree.sales
GROUP BY txn_id ) AS x;
```

**Answer:**

|avg_discount|
|:----|
|60|

**5. What is the percentage split of all transactions for members vs non-members?**

```sql
SELECT 
ROUND(100*SUM(CASE WHEN member = true THEN 1 ELSE 0 END) :: NUMERIC / (COUNT(*) :: NUMERIC),2) AS member_perc_of_transactions,
ROUND(SUM(100* CASE WHEN member = false THEN 1 ELSE 0 END) :: NUMERIC / (COUNT(*) :: NUMERIC),2) AS non_member_perc_of_transactions
FROM(
SELECT txn_id, member, RANK() OVER(PARTITION BY txn_id ORDER BY price DESC) AS rnk
FROM balanced_tree.sales
GROUP BY txn_id, price, member) AS x
WHERE rnk=1;

```

**Answer:**

Members have a transaction count at 60% compared to than non-members who account for almost 40% of the transactions.

|member_perc_of_transactions|non_member_perc_of_transactions|
|:----|:----|
|60.20|39.80|


***

**6. What is the average revenue for member transactions and non-member transactions?**

```sql
SELECT  x.member,
		ROUND(AVG(revenue), 2) AS avg_revenue
FROM (
SELECT  member,
	txn_id,
	SUM(price * qty) AS revenue
FROM balanced_tree.sales
GROUP BY member,
		txn_id) AS x
GROUP BY x.member;
```

**Answer:**

The average revenue per transaction for members is only $1.23 higher compared to non-members.

|member|avg_revenue|
|:----|:----|
|false|515.04|
|true|516.27|

***

## 👚 C. Product Analysis

**1. What are the top 3 products by total revenue before discount?**

```sql
SELECT product_name, SUM(qty*s.price) as total_revenue
FROM balanced_tree.sales AS s
LEFT JOIN balanced_tree.product_details AS pd ON
s.prod_id = pd.product_id
GROUP BY product_name
ORDER BY total_revenue DESC
LIMIT 3;
```

**Answer:**

|product_id|total_revenue|
|:----|:----|
|Blue Polo Shirt - Mens|217683|
|Grey Fashion Jacket - Womens|209304|
|White Tee Shirt - Mens|152000|

***

**2. What is the total quantity, revenue and discount for each segment?**

```sql
SELECT  pd.segment_name,
		SUM(qty) AS quantity,
		SUM(qty*s.price) - SUM((qty*s.price)*discount/100) AS gross_revenue,
		SUM((qty*s.price)*discount/100) AS discount
FROM balanced_tree.product_details AS pd
LEFT JOIN balanced_tree.sales AS s
ON pd.product_id = s.prod_id
GROUP BY segment_name;
```

**Answer:**

|segment_name|quantity|gross_revenue|discount|
|:----|:----|:----|:----|
|Shirt|11265|358061|48082|
|Jeans|11349|184677|23673|
|Jacket|11385|324532|42451|
|Socks|11217|272697|35280|

***

**3. What is the top selling product for each segment?**

```sql
WITH top_selling AS (
SELECT  product_name,
		segment_name,
		SUM(qty) AS quantity,
		RANK() OVER (PARTITION BY segment_name ORDER BY SUM(qty)) AS ranking
FROM balanced_tree.product_details AS pd
LEFT JOIN balanced_tree.sales AS s
ON pd.product_id = s.prod_id
GROUP BY pd.product_name, segment_name
ORDER BY SUM(qty))

SELECT  product_name,
		segment_name,
		quantity
FROM top_selling
WHERE ranking =1;
```

**Answer:**

|product_name|segment_name|quantity|
|:----|:----|:----|
|Navy Solid Socks - Mens|Socks|3792|
|Blue Polo Shirt - Mens|Shirt|3819|
|Navy Oversized Jeans - Womens|Jeans|3856|
|Grey Fashion Jacket - Womens|Jacket|3876|

***

**4. What is the total quantity, revenue and discount for each category?**

```sql
SELECT  pd.category_name,
		SUM(qty) AS quantity,
		SUM(qty*s.price) AS revenue,
		SUM((qty*s.price) * discount/100) AS discount
FROM balanced_tree.product_details AS pd
LEFT JOIN balanced_tree.sales AS s
ON pd.product_id = s.prod_id
GROUP BY category_name;
```

**Answer:**

|category_name|quantity|revenue|discount|
|:----|:----|:----|:----|
|Womens|22734|575333|66124|
|Mens|22482|714120|83362|

***

**5. What is the top selling product for each category?**

```sql
WITH top_selling_product_by_category AS (
SELECT  pd.category_name,
		pd.segment_name,
		pd.product_name,
		SUM(qty) AS quantity_sold,
		RANK() OVER (PARTITION BY segment_name ORDER BY SUM(qty)) AS ranking
FROM balanced_tree.product_details AS pd
LEFT JOIN balanced_tree.sales AS s
ON pd.product_id = s.prod_id
GROUP BY pd.category_name, pd.segment_name, pd.product_name)

SELECT *
FROM top_selling_product_by_category
WHERE ranking =1;
```

**Answer:**

|category_name|segment_name|product_name|quantity_sold|ranking |
|:----|:----|:----|:----|:----|
|Womens|Jacket|Khaki Suit Jacket - Womens|3752|1|
|Womens|Jeans|Cream Relaxed Jeans - Womens|3707|1|
|Mens|Shirt|Teal Button Up Shirt - Mens|3646|1|
|Mens|Socks|White Striped Socks - Mens|3655|1|

***

**6. What is the percentage split of revenue by product for each segment?**

```sql
SELECT  category_name,
		segment_name,
		product_name,
		CONCAT(ROUND(sum1/ SUM(sum1) OVER (PARTITION BY segment_name) * 100,2),'%') AS percentage_by_segment
FROM(SELECT  pd.category_name,
	  		 pd.segment_name,
			 pd.product_name,
			 SUM(qty*s.price) AS sum1,
			 RANK() OVER (PARTITION BY segment_name ORDER BY SUM(qty*s.price)) AS ranking
	 FROM balanced_tree.product_details AS pd
	 LEFT JOIN balanced_tree.sales AS s
	 ON pd.product_id = s.prod_id
	 GROUP BY pd.category_name, pd.segment_name, pd.product_name) AS x;
```

**Answer:**
|category_name|segment_name|product_name|percentage_by_segment|
|:----|:----|:----|:----|
|Womens|Jacket|Khaki Suit Jacket - Womens|23.51%|
|Womens|Jacket|Grey Fashion Jacket - Womens|57.03%|
|Womens|Jacket|Indigo Rain Jacket - Womens|19.45%|
|Womens|Jeans|Cream Relaxed Jeans - Womens|17.79%|
|Womens|Jeans|Navy Oversized Jeans - Womens|24.06%|
|Womens|Jeans|Black Straight Jeans - Womens|58.15%|
|Mens|Shirt|Teal Button Up Shirt - Mens|8.98%|
|Mens|Shirt|White Tee Shirt - Mens|37.43%|
|Mens|Shirt|Blue Polo Shirt - Mens|53.60%|
|Mens|Socks|White Striped Socks - Mens|20.18%|
|Mens|Socks|Navy Solid Socks - Mens|44.33%|
|Mens|Socks|Pink Fluro Polkadot Socks - Mens|35.50%|

***

**7. What is the percentage split of revenue by segment for each category?**

```sql
SELECT  category_name,
		segment_name,
		CONCAT(ROUND(sum1/ SUM(sum1) OVER (PARTITION BY category_name) * 100,2),'%') AS percentage_by_segment
FROM(SELECT  pd.category_name,
	  		 pd.segment_name,
			 SUM(qty*s.price) AS sum1
	 FROM balanced_tree.product_details AS pd
	 LEFT JOIN balanced_tree.sales AS s
	 ON pd.product_id = s.prod_id
	 GROUP BY pd.category_name, pd.segment_name) AS x
ORDER BY category_name, percentage_by_segment DESC;
```

**Answer:**

|category_name|segment_name|percentage_by_segment|
|:----|:----|:----|
|Mens|Shirt|56.87%|
|Mens|Socks|43.13%|
|Womens|Jacket|63.79%|
|Womens|Jeans|36.21%|

***

**8. What is the percentage split of total revenue by category?**

```sql
SELECT  x.category_id,
		CONCAT(ROUND(sum1/ SUM(sum1) OVER () * 100,2),'%') AS percentage_by_segment
FROM(SELECT  pd.category_id,
			 SUM(qty*s.price) AS sum1
	 FROM balanced_tree.product_details AS pd
	 LEFT JOIN balanced_tree.sales AS s
	 ON pd.product_id = s.prod_id
	 GROUP BY pd.category_id) AS x;
	 
```

**Answer:**

|category_id|percetnage_by_segment|
|:----|:----|
|2|55.38%|
|1|44.62%|


***

**9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)**

```sql
SELECT  DISTINCT(product_id),
		pd.product_name,
		CONCAT( ROUND(100*COUNT(DISTINCT txn_id) :: NUMERIC /
		(SELECT COUNT(DISTINCT txn_id)
		FROM balanced_tree.product_details AS pd
		LEFT JOIN balanced_tree.sales AS s
		ON pd.product_id = s.prod_id),2),'%') AS penetration
FROM balanced_tree.product_details AS pd
LEFT JOIN balanced_tree.sales AS s
ON pd.product_id = s.prod_id
GROUP BY pd.product_id, pd.product_name;
```

**Answer:**

|product_id|product_name|penetration|
|:----|:----|:----|
|2a2353|Blue Polo Shirt - Mens|50.72%|
|2feb6bPink Fluro Polkadot Socks - Mens|50.32%|
|5d267b|White Tee Shirt - Mens|50.72%|
|72f5d4|Indigo Rain Jacket - Women|50.00%|
|9ec847|Grey Fashion Jacket - Womens|51.00%|
|b9a74d|White Striped Socks - Mens|49.72%|
|c4a632|Navy Oversized Jeans - Womens|50.96%|
|c8d436|Teal Button Up Shirt - Mens|49.68%|
|d5e9a6|Khaki Suit Jacket - Womens|49.88%|
|e31d39|Cream Relaxed Jeans - Womens|49.72%|
|e83aa3|Black Straight Jeans - Womens|49.84%|
|f084eb|Navy Solid Socks - Mens|51.24%|



"2a2353"	"Blue Polo Shirt - Mens"	"50.72%"
"2feb6b"	"Pink Fluro Polkadot Socks - Mens"	"50.32%"
"5d267b"	"White Tee Shirt - Mens"	"50.72%"
"72f5d4"	"Indigo Rain Jacket - Womens"	"50.00%"
"9ec847"	"Grey Fashion Jacket - Womens"	"51.00%"
"b9a74d"	"White Striped Socks - Mens"	"49.72%"
"c4a632"	"Navy Oversized Jeans - Womens"	"50.96%"
"c8d436"	"Teal Button Up Shirt - Mens"	"49.68%"
"d5e9a6"	"Khaki Suit Jacket - Womens"	"49.88%"
"e31d39"	"Cream Relaxed Jeans - Womens"	"49.72%"
"e83aa3"	"Black Straight Jeans - Womens"	"49.84%"
"f084eb"	"Navy Solid Socks - Mens"	"51.24%"

***

**10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?**

```sql


**Answer:**

***

## 📝 Reporting Challenge

Write a single SQL script that combines all of the previous questions into a scheduled report that the Balanced Tree team can run at the beginning of each month to calculate the previous month’s values.

Imagine that the Chief Financial Officer (which is also Danny) has asked for all of these questions at the end of every month.

He first wants you to generate the data for January only - but then he also wants you to demonstrate that you can easily run the samne analysis for February without many changes (if at all).

Feel free to split up your final outputs into as many tables as you need - but be sure to explicitly reference which table outputs relate to which question for full marks :)

***

