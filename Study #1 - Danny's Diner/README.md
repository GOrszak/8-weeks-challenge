# :ramen: :curry: :sushi: Case Study #1: Danny's Diner 
<p align="center">
<img src="https://8weeksqlchallenge.com/images/case-study-designs/1.png" alt="Image" width="450" height="450">

View the case study [here](https://8weeksqlchallenge.com/case-study-1/)

## Table Of Contents
  - [Introduction](#introduction)
  - [Problem Statement](#problem-statement)
  - [Datasets used](#datasets-used)
  - [Entity Relationship Diagram](#entity-relationship-diagram)
  - [Case Study Questions](#case-study-questions)
  
## Introduction
Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

## Problem Statement
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.
He plans on using these insights to help him decide whether he should expand the existing customer loyalty program.

## Datasets used
Three key datasets for this case study
- sales: The sales table captures all customer_id level purchases with an corresponding order_date and product_id information for when and what menu items were ordered.
- menu: The menu table maps the product_id to the actual product_name and price of each menu item.
- members: The members table captures the join_date when a customer_id joined the beta version of the Danny’s Diner loyalty program.

## Entity Relationship Diagram

![Schema](https://github.com/GOrszak/8-weeks-challenge/assets/134173513/46d5cd43-29c1-4937-8c47-fb41fe10e07a)

## Case Study Questions
1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
  
Click [here](do dodania!)  to view the solution solution of the case study!


## Queries and answers


#### 1. What is the total amount each customer spent at the restaurant?

```sql
SELECT  s.customer_id, 
		SUM(m.price) as amount_spent_at_restaurant
FROM dannys_diner.sales AS s
LEFT JOIN dannys_diner.menu AS m
ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY amount_spent_at_restaurant DESC;
```

| customer_id    | amount_spent_at_restaurant |
| --------- | ------- |
| A         |       76|
|  B        |   74    |
|   C       |     36  |


-------------


#### 2. How many days has each customer visited the restaurant?

```sql
SELECT  customer_id,
		COUNT(DISTINCT(order_date)) FROM dannys_diner.sales
GROUP BY customer_id;
```

| customer_id  | count |
| --------- | ------- |
| A         |     4   |
|  B        |     6   |
|   C       |     2   |


-------------

#### 3. What was the first item from the menu purchased by each customer?

```sql
WITH cte AS (SELECT  customer_id, 
		product_name,
		DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY order_date) AS rnk
FROM dannys_diner.sales AS s
LEFT JOIN dannys_diner.menu AS m
ON m.product_id = s.product_id
GROUP BY customer_id,product_name,order_date)

SELECT  customer_id,
		string_agg(product_name, ',')
FROM cte
WHERE rnk = 1
GROUP BY customer_id;
```

| customer_id  | string_agg |
| --------- | ------- |
| A         |    curry,sushi   |
|  B        |     curry   |
|   C       |     ramen   |


-------------

#### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

```sql
SELECT CONCAT('Most bought was ', z.product_name, ' and was bought ' , cnt, ' times')
FROM
	(SELECT product_id,
 			RANK() OVER (ORDER BY product_id DESC) AS rnk,
 			COUNT(*) as cnt
 			FROM dannys_diner.sales 
			GROUP BY product_id) AS x
LEFT JOIN dannys_diner.menu AS z
ON x.product_id = z.product_id
WHERE rnk = 1;;
```
|concat  | 
| --------- |
|Most bought was ramen and was bought 8 times|


-------------

#### 5. Which item was the most popular for each customer?

```sql
SELECT  customer_id,
		string_agg(z.product_name, ','),
		cnt AS amount_ordered
FROM
	(SELECT customer_id,
	 		product_id,COUNT(*) AS cnt,
	 		RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(*) DESC) AS rnk
			FROM dannys_diner.sales
			GROUP BY customer_id, product_id) AS x
LEFT JOIN dannys_diner.menu as z
ON x.product_id = z.product_id
WHERE rnk = 1
GROUP BY customer_id, cnt;
```

| customer_id  | string_agg |amount_ordered |
| --------- | ------- |-----| 
| A         |    ramen| 3|
|  B        |     sushi,curry,ramen   | 2 |
|   C       |     ramen   | 2 |
-------------

#### 6. Which item was purchased first by the customer after they became a member?

```sql
WITH cte AS
	(SELECT  m.customer_id, 
	 		 product_id,
	 		 order_date,
	 		 join_date,
			 DENSE_RANK() OVER(PARTITION BY m.customer_id ORDER BY order_date) AS rnk
	 FROM dannys_diner.sales AS s
	 LEFT JOIN dannys_diner.members as m
	 ON m.customer_id = s.customer_id
	 WHERE join_date < order_date
	 GROUP BY m.customer_id, product_id, order_date, join_date)
	 
SELECT  customer_id, 
		c.product_id,
		product_name,
		order_date, 
		join_date
FROM cte AS c
LEFT JOIN dannys_diner.menu as m
ON m.product_id = c.product_id
WHERE rnk =1;
```
| customer_id |	product_id |	product_name |	order_date |	join_date |
| --------- | --------- | ----- | ------- | --------- | 
|A|	3|	ramen|	2021-01-10|	2021-01-07|
|B|	1|	sushi|	2021-01-11|	2021-01-09|



-------------

#### 7. Which item was purchased just before the customer became a member?


```sql
WITH cte AS
	(SELECT  m.customer_id, 
	 		 product_id,
	 		 order_date,
	 		 join_date,
			 DENSE_RANK() OVER(PARTITION BY m.customer_id ORDER BY order_date DESC) AS rnk
	 FROM dannys_diner.sales AS s
	 LEFT JOIN dannys_diner.members as m
	 ON m.customer_id = s.customer_id
	 WHERE join_date > order_date
	 GROUP BY m.customer_id, product_id, order_date, join_date)
	 
SELECT  customer_id, 
		string_agg(product_name, ','),
		order_date, 
		join_date
FROM cte AS c
LEFT JOIN dannys_diner.menu as m
ON m.product_id = c.product_id
WHERE rnk =1
GROUP BY customer_id, order_date, join_date;
```

| customer_id |	string_agg|	order_date | join_date |
| --------- | --------- | ----- | -------|
|A|	sushi,curry |	2021-01-01|	2021-01-07|
|B|		sushi|	2021-01-04|	2021-01-09|
-------------
#### 8. What is the total items and amount spent for each member before they became a member?


```sql
SELECT  customer_id,
		SUM(price),
		COUNT(counted) AS items_bought
FROM
	(SELECT  m.customer_id,
			 men.product_name,
			 men.product_id,
			 men.price,
			 COUNT(men.product_name) OVER (PARTITION BY m.customer_id, men.product_name) as counted
	 FROM dannys_diner.sales AS s
	 INNER JOIN dannys_diner.menu as men
	 ON men.product_id = s.product_id
	 RIGHT JOIN dannys_diner.members as m
	 ON m.customer_id = s.customer_id
	 WHERE join_date > order_date
	 GROUP BY m.customer_id, men.product_id, order_date, men.price, men.product_name ) AS x
GROUP BY customer_id;
```
"customer_id"	"sum"	"items_bought"
"A"	25	2
"B"	40	3

| customer_id |sum |	items_bought |
| --------- | --------- | ----- | 
|A|	25 |	2|	
|B|		40|	3|	
-------------
#### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

```sql
SELECT  s.customer_id,
		SUM(CASE WHEN men.product_name = 'sushi' then price * 2* 10 else price * 10 END) AS points
FROM dannys_diner.sales AS s
INNER JOIN dannys_diner.menu as men
ON men.product_id = s.product_id
GROUP BY s.customer_id
ORDER BY points DESC;
```

| customer_id |points|	
| --------- | --------- | 
|A|		940|	
|B|		860|
|C|  360|	
-------------
-------------
#### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?


```sql
SELECT  s.customer_id,
		SUM(CASE
 				WHEN order_date BETWEEN join_date AND (join_date + INTERVAL '7 DAY') THEN price*10*2
				WHEN men.product_name = 'sushi' AND (order_date > (join_date + INTERVAL '7 DAY') OR order_date < join_date) THEN price * 2 *10
		   		ELSE price * 10 END)AS points
FROM dannys_diner.sales AS s
	INNER JOIN dannys_diner.menu as men
	ON men.product_id = s.product_id
	RIGHT JOIN dannys_diner.members as m
	ON m.customer_id = s.customer_id
WHERE order_date <= '2021-01-31'
GROUP BY s.customer_id
ORDER BY points DESC;
```


| customer_id |points|	
| --------- | --------- | 
|A|		1370|	
|B|		940|

-------------

## Bonus questions

####  Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)


```sql
SELECT  s.customer_id,
		SUM(CASE
 				WHEN order_date BETWEEN join_date AND (join_date + INTERVAL '7 DAY') THEN price*10*2
				WHEN men.product_name = 'sushi' AND (order_date > (join_date + INTERVAL '7 DAY') OR order_date < join_date) THEN price * 2 *10
		   		ELSE price * 10 END)AS points
FROM dannys_diner.sales AS s
	INNER JOIN dannys_diner.menu as men
	ON men.product_id = s.product_id
	RIGHT JOIN dannys_diner.members as m
	ON m.customer_id = s.customer_id
WHERE order_date <= '2021-01-31'
GROUP BY s.customer_id
ORDER BY points DESC;
```


|customer_id|order_date|product_name|price|member|
| --------- | --------- | ----- | ------- | --------- | 
|A|2021-01-01|sushi|10|N|
|A|2021-01-01|curry|15|N|
|A|2021-01-07|curry|15|Y|
|A|2021-01-10|ramen|12|Y|
|A|2021-01-11|ramen|12|Y|
|A|2021-01-11|ramen|12|Y|
|B|2021-01-01|curry|15|N|
|B|2021-01-02|curry|15|N|
|B|2021-01-04|sushi|10|N|
|B|2021-01-11|sushi|10|Y|
|B|2021-01-16|ramen|12|Y|
|B|2021-02-01|ramen|12|Y|
|C|2021-01-01|ramen|12|N|
|C|2021-01-01|ramen|12|N|
|C|2021-01-07|ramen|12|N|

-----------------------------

#### Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program


```sql
SELECT  s.customer_id,
		SUM(CASE
 				WHEN order_date BETWEEN join_date AND (join_date + INTERVAL '7 DAY') THEN price*10*2
				WHEN men.product_name = 'sushi' AND (order_date > (join_date + INTERVAL '7 DAY') OR order_date < join_date) THEN price * 2 *10
		   		ELSE price * 10 END)AS points
FROM dannys_diner.sales AS s
	INNER JOIN dannys_diner.menu as men
	ON men.product_id = s.product_id
	RIGHT JOIN dannys_diner.members as m
	ON m.customer_id = s.customer_id
WHERE order_date <= '2021-01-31'
GROUP BY s.customer_id
ORDER BY points DESC;
```

|customer_id|order_date|product_name|price|mem|ranking|
| --------- | --------- | ----- | ------- | --------- | ----- |
|A|2021-01-01|sushi|10|N|NULL|
|A|2021-01-01|curry|15|N|NULL|
|A|2021-01-07|curry|15|Y|1|
|A|2021-01-10|ramen|12|Y|2|
|A|2021-01-11|ramen|12|Y|3|
|A|2021-01-11|ramen|12|Y|3|
|B|2021-01-01|curry|15|N|NULL|
|B|2021-01-02|curry|15|N|NULL|
|B|2021-01-04|sushi|10|N|NULL|
|B|2021-01-11|sushi|10|Y|1|
|B|2021-01-16|ramen|12|Y|2|
|B|2021-02-01|ramen|12|Y|3|
|C|2021-01-01|ramen|12|N|NULL|
|C|2021-01-01|ramen|12|N|NULL|
|C|2021-01-07|ramen|12|N|NULL|


