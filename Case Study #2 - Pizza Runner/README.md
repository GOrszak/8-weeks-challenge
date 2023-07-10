<p align="center">
<img src="https://8weeksqlchallenge.com/images/case-study-designs/2.png" alt="Image" width="450" height="450">

View the case study [here](https://8weeksqlchallenge.com/case-study-2/)

## Table Of Contents
  - [Introduction](#introduction)
  - [Problem Statement](#problem-statement)
  - [Entity Relationship Diagram](#entity-relationship-diagram)
  - [Questions and answers](#questions-and-answers)
  
## Introduction
Did you know that over 115 million kilograms of pizza is consumed daily worldwide??? (Well according to Wikipedia anyway…)

Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!”

Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so Pizza Runner was launched!

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.

## Problem Statement 
Because Danny had a few years of experience as a data scientist - he was very aware that data collection was going to be critical for his business’ growth.

He has prepared for us an entity relationship diagram of his database design but requires further assistance to clean his data and apply some basic calculations so he can better direct his runners and optimise Pizza Runner’s operations.

All datasets exist within the pizza_runner database schema - be sure to include this reference within your SQL scripts as you start exploring the data and answering the case study questions.

## Entity Relationship Diagram


![Study2](https://github.com/GOrszak/8-weeks-challenge/assets/134173513/eacc70e3-16c4-4f03-a127-cd539ea37ea9)


## Questions and answers

### A. Pizza Metrics


#### 1. How many pizzas were ordered?

```sql

SELECT COUNT(*)
FROM pizza_runner.customer_orders_temp;

```
|count|
|---| 
|14|


-------------


#### 2. How many unique customer orders were made?

```sql

SELECT COUNT(DISTINCT order_id)
FROM pizza_runner.customer_orders_temp;

```
|count|
|---| 
|10|

-------------

#### 3.How many successful orders were delivered by each runner?

```sql

SELECT  runner_id, 
		COUNT(*)
FROM pizza_runner.runner_orders_temp
WHERE cancellation IS NULL
GROUP BY runner_id;

```
|runner_id|count|
|---|---| 
|1|4|
|2|3|
|3|1|

-------------

#### 4. How many of each type of pizza was delivered?

```sql

SELECT  pz.pizza_id, 
		COUNT(pz.pizza_id),
		p.pizza_name
FROM pizza_runner.customer_orders_temp AS pz
LEFT JOIN pizza_runner.runner_orders_temp AS r
ON pz.order_id = r.order_id
LEFT JOIN  pizza_runner.pizza_names as p
ON p.pizza_id = pz.pizza_id
WHERE cancellation IS NULL
GROUP BY pz.pizza_id,
		 p.pizza_name;


```
|pizza_id|count|pizza_name|
|---|---|---|
|1|9|Meatlovers|
|2|3|Vegetarian|

-------------


#### 5. How many Vegetarian and Meatlovers were ordered by each customer?

```sql

SELECT  customer_id,
		COUNT(pz.pizza_id),
		pizza_name 
FROM pizza_runner.customer_orders_temp as pz
LEFT JOIN  pizza_runner.pizza_names as p
ON p.pizza_id = pz.pizza_id
GROUP BY customer_id, 
		 pizza_name
ORDER BY customer_id;


```
|customer_id|count|pizza_name|
|---|---|---|
|101|	2|	Meatlovers|
|101|	1|	Vegetarian|
|102|	2|	Meatlovers|
|102|	1|	Vegetarian|
|103|	3|	Meatlovers|
|103|	1|	Vegetarian|
|104|	3|	Meatlovers|
|105|	1|	Vegetarian|


-------------


#### 6. What was the maximum number of pizzas delivered in a single order?

```sql

WITH new_cte AS (
SELECT  COUNT(pz.pizza_id) as ordered_pizza,
		r.order_id
FROM pizza_runner.customer_orders_temp AS pz
LEFT JOIN pizza_runner.runner_orders_temp AS r
ON pz.order_id = r.order_id
LEFT JOIN  pizza_runner.pizza_names as p
ON p.pizza_id = pz.pizza_id
WHERE cancellation IS NULL
GROUP BY r.order_id)


SELECT MAX(ordered_pizza)
FROM new_cte;


```
|max|
|---|
|3|



-------------


#### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

```sql

SELECT  customer_id,
		SUM( CASE WHEN exclusions IS NULL AND extras IS NULL THEN 1 ELSE 0 END ) AS no_changes,
		SUM( CASE WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 1 ELSE 0 END) AS changes
FROM pizza_runner.customer_orders_temp AS pz
LEFT JOIN pizza_runner.runner_orders_temp AS r
ON pz.order_id = r.order_id
LEFT JOIN  pizza_runner.pizza_names as p
ON p.pizza_id = pz.pizza_id
WHERE  cancellation IS NULL
GROUP BY customer_id;


```
|customer_id|no_changes|changes|
|---|---|---|
|105|	0|1|
|101|	2|0|
|102|	3|0|
|103|	0|3|
|104|	1|2|



-------------


#### 8. How many pizzas were delivered that had both exclusions and extras?


```sql

SELECT  customer_id,
		SUM(CASE WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1 ELSE 0 END ) AS both_changed
FROM pizza_runner.customer_orders_temp AS pz
LEFT JOIN pizza_runner.runner_orders_temp AS r
ON pz.order_id = r.order_id
LEFT JOIN  pizza_runner.pizza_names as p
ON p.pizza_id = pz.pizza_id
WHERE  cancellation IS NULL
GROUP BY customer_id;


```
|customer_id|both_changed|
|---|---|
|105|	0|
|101|	0|
|102|	0|
|103|	0|
|104|	1|



-------------

#### 9. What was the total volume of pizzas ordered for each hour of the day?

```sql

SELECT  EXTRACT(hour FROM order_time) as hrs, 
		COUNT(*),
		ROUND(COUNT(*)*100/ SUM(COUNT(*)) OVER(),2) AS percentage_of_all_orders
FROM pizza_runner.customer_orders_temp
GROUP BY hrs
ORDER BY hrs;

```
|hrs|count|percentage_of_all_orders|
|---|---|---|
|11|	1|	7.14|
|13|	3|	21.43|
|18|	3|	21.43|
|19|	1|	7.14|
|21|	3|	21.43|
|23|	3|	21.43|


-------------

#### 10. What was the volume of orders for each day of the week?
```sql

SELECT  to_char(order_time, 'Day') as dayz,
		COUNT(*),
		ROUND(COUNT(*)*100/ SUM(COUNT(*)) OVER(),2)
FROM pizza_runner.customer_orders_temp
GROUP BY dayz
ORDER BY dayz;

```
|dayz|count|round|
|---|---|---|
|Friday|	1	|7.14|
|Saturday|	5	|35.71|
|Thursday|	3	|21.43|
|Wednesday|	5	|35.71|


-------------

### B. Runner and Customer Experience


-------------

#### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)


-------------

#### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?


-------------

#### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?


-------------

#### 4. What was the average distance travelled for each customer?

-------------

#### 5. What was the difference between the longest and shortest delivery times for all orders?


-------------

#### 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?


-------------

#### 7. What is the successful delivery percentage for each runner?


-------------


