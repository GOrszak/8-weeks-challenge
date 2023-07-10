-- A. Pizza Metrics --
-- Ex.1 How many pizzas were ordered? --
SELECT COUNT(*)
FROM pizza_runner.customer_orders_temp;

-- Ex.2 How many unique customer orders were made? --
SELECT COUNT(DISTINCT order_id)
FROM pizza_runner.customer_orders_temp;

-- Ex.3 How many successful orders were delivered by each runner? --

SELECT  runner_id, 
		COUNT(*)
FROM pizza_runner.runner_orders_temp
WHERE cancellation IS NULL
GROUP BY runner_id;

-- Ex.4 How many of each type of pizza was delivered?--

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


-- Ex.5 How many Vegetarian and Meatlovers were ordered by each customer?--

SELECT  customer_id,
		COUNT(pz.pizza_id),
		pizza_name 
FROM pizza_runner.customer_orders_temp as pz
LEFT JOIN  pizza_runner.pizza_names as p
ON p.pizza_id = pz.pizza_id
GROUP BY customer_id, 
		 pizza_name
ORDER BY customer_id;

-- Ex.6 What was the maximum number of pizzas delivered in a single order? --
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



-- Ex.7 For each customer, how many delivered pizzas had at least 1 change and how many had no changes? --
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

-- Ex.8 How many pizzas were delivered that had both exclusions and extras? --

SELECT  customer_id,
		SUM(CASE WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1 ELSE 0 END ) AS both_changed
FROM pizza_runner.customer_orders_temp AS pz
LEFT JOIN pizza_runner.runner_orders_temp AS r
ON pz.order_id = r.order_id
LEFT JOIN  pizza_runner.pizza_names as p
ON p.pizza_id = pz.pizza_id
WHERE  cancellation IS NULL
GROUP BY customer_id;

-- Ex.9 What was the total volume of pizzas ordered for each hour of the day? --

SELECT  EXTRACT(hour FROM order_time) as hrs, 
		COUNT(*),
		ROUND(COUNT(*)*100/ SUM(COUNT(*)) OVER(),2) AS percentage_of_all_orders
FROM pizza_runner.customer_orders_temp
GROUP BY hrs
ORDER BY hrs;

-- Ex.10 What was the volume of orders for each day of the week? --
SELECT  to_char(order_time, 'Day') as dayz,
		COUNT(*),
		ROUND(COUNT(*)*100/ SUM(COUNT(*)) OVER(),2) AS per
FROM pizza_runner.customer_orders_temp
GROUP BY dayz
ORDER BY dayz;


-- B. Runner and Customer Experience--

-- Ex.1 How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)--

SELECT  TO_CHAR(registration_date, 'ww')::INT AS week_number,
		COUNT(*)
FROM pizza_runner.runners
GROUP BY week_number;

-- What was the average time in minutes it took for 
-- each runner to arrive at the Pizza Runner HQ to pickup the order?


SELECT  runner_id,
		AVG(ROUND(EXTRACT(epoch FROM CAST(pickup_time AS TIMESTAMP) - c.order_time) / 60,2)) 
FROM pizza_runner.runner_orders AS r
LEFT JOIN pizza_runner.customer_orders AS c
ON r.order_id = c.order_id
WHERE pickup_time is not null 
	AND pickup_time<>'null'
GROUP BY runner_id;


-- Ex.3 Is there any relationship between the number of pizzas and
-- how long the order takes to prepare?

WITH no_of_pizza AS (
SELECT  r.order_id, 
		COUNT(r.order_id) as counted,
		ROUND(EXTRACT(epoch FROM CAST(pickup_time AS TIMESTAMP) - c.order_time)/ 60,2) AS time_counted
FROM pizza_runner.runner_orders AS r
LEFT JOIN pizza_runner.customer_orders AS c
ON r.order_id = c.order_id
WHERE pickup_time is not null 
	AND pickup_time<>'null'
GROUP BY r.order_id, pickup_time, order_time)

SELECT  counted,
		AVG(time_counted)
FROM no_of_pizza
GROUP BY counted;


-- Ex.4 What was the average distance travelled for each customer? --
SELECT customer_id,ROUND(AVG(CAST(distance AS numeric)),2)
FROM pizza_runner.runner_orders_temp AS r
LEFT JOIN pizza_runner.customer_orders AS c
ON r.order_id = c.order_id
WHERE pickup_time is not null 
	AND pickup_time<>'null'
GROUP BY customer_id;
						 
						 
						 
-- Ex.5 What was the difference between the longest and shortest delivery times for all orders? --



SELECT MIN(duration) minimum_duration,
       MAX(duration) AS maximum_duration,
       MAX(duration) - MIN(duration) AS maximum_difference
FROM runner_orders_temp;


-- Ex.6 What was the average speed for each runner for each delivery and do you notice any trend for these values? --

SELECT  runner_id,
		distance AS distance_km,
		ROUND(CAST(duration AS numeric)/60,2) AS duration_hr,
		CAST((distance/ (duration/60)) AS bigint) AS km_per_h
FROM runner_orders_temp
WHERE pickup_time is not null 
	AND pickup_time<>'null'
ORDER BY runner_id;

-- Ex.7 What is the successful delivery percentage for each runner? --

SELECT runner_id,
       COUNT(pickup_time) AS delivered_orders,
       COUNT(*) AS total_orders,
       ROUND(100 * COUNT(pickup_time) / COUNT(*)) AS delivery_success_percentage
FROM runner_orders_temp
GROUP BY runner_id
ORDER BY runner_id;


-- C. Ingredient Optimisation --

-- Ex.1 What are the standard ingredients for each pizza? --

SELECT  pn.pizza_id,
		pizza_name, 
		STRING_AGG(topping_name,',')
FROM pizza_runner.pizza_names  AS pn
LEFT JOIN  pizza_runner.pizza_recipes_clean AS prc
ON pn.pizza_id = prc.pizza_id
LEFT JOIN  pizza_runner.pizza_toppings AS pt
ON CAST(prc.toppings AS INTEGER) = pt.topping_id
GROUP BY pizza_name, pn.pizza_id;

-- Ex.2 What was the most commonly added extra? --

WITH tcol1 AS ( SELECT  split_part(extras, ',',1) AS col1
FROM pizza_runner.customer_orders_temp
			  WHERE extras IS NOT NULL),
tcol2 AS (SELECT split_part(extras, ',',2) AS col2
FROM pizza_runner.customer_orders_temp
		 WHERE extras IS NOT NULL),
merged AS (
SELECT * FROM tcol1
UNION ALL
SELECT * FROM tcol2)
		
		

SELECT col1 AS id,  COUNT(*) AS total, tn.topping_name
FROM merged
INNER JOIN pizza_runner.pizza_toppings  tn 
ON merged.col1 = CAST(tn.topping_id AS TEXT)
GROUP BY col1, tn.topping_name
ORDER BY total DESC
LIMIT 1;	
		
	
-- Ex.3 What was the most common exclusion? --

WITH tcol1 AS ( SELECT  split_part(exclusions, ',',1) AS col1
FROM pizza_runner.customer_orders_temp
			  WHERE exclusions IS NOT NULL),
tcol2 AS (SELECT split_part(exclusions, ',',2) AS col2
FROM pizza_runner.customer_orders_temp
		 WHERE exclusions IS NOT NULL),
merged AS (
SELECT * FROM tcol1
UNION ALL
SELECT * FROM tcol2)
	
-- SELECT * FROM  pizza_runner.customer_orders_temp;

SELECT col1 AS id,  COUNT(*) AS total, tn.topping_name
FROM merged
INNER JOIN pizza_runner.pizza_toppings  tn 
ON merged.col1 = CAST(tn.topping_id AS TEXT)
GROUP BY col1, tn.topping_name
ORDER BY total DESC
LIMIT 1;	



-- Ex.3 What was the most common exclusion? --








