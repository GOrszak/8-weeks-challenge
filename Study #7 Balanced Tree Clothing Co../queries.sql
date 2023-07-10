-- High Level Sales Analysis --

-- Ex.1 What was the total quantity sold for all products? --

SELECT SUM(qty)
FROM balanced_tree.sales;

-- Ex.2 What is the total generated revenue for all products before discounts? --
SELECT SUM(qty * price) AS total_revenue
FROM balanced_tree.sales;

-- Ex.3 What was the total discount amount for all products? --
SELECT SUM(qty*price*discount/100) AS total_discount
FROM  balanced_tree.sales;


-- Transaction Analysis --

-- Ex.1 How many unique transactions were there? --

SELECT COUNT (DISTINCT txn_id) AS unique_transactions
FROM balanced_tree.sales;

-- Ex.2 What is the average unique products purchased in each transaction? --
SELECT ROUND(AVG(to_count))
FROM ( SELECT txn_id, COUNT(DISTINCT prod_id) AS to_count 
	  FROM balanced_tree.sales
	  GROUP BY txn_id) AS x;
	  
-- Ex.3 What are the 25th, 50th and 75th percentile values for the revenue per transaction? --
SELECT  PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY revenue),
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY revenue),
		PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY revenue)
FROM(
	SELECT SUM(qty*price) AS revenue
	FROM balanced_tree.sales
	GROUP BY txn_id) AS x;

-- Ex.4 What is the average discount value per transaction? --
SELECT ROUND(AVG(dsc)) as avg_discount
FROM (
SELECT SUM(qty*price*discount/100) AS dsc
FROM  balanced_tree.sales
GROUP BY txn_id ) AS x;


-- Ex.5 What is the percentage split of all transactions for members vs non-members? --
SELECT 
ROUND(100*SUM(CASE WHEN member = true THEN 1 ELSE 0 END) :: NUMERIC / (COUNT(*) :: NUMERIC),2) AS member_perc_of_transactions,
ROUND(SUM(100* CASE WHEN member = false THEN 1 ELSE 0 END) :: NUMERIC / (COUNT(*) :: NUMERIC),2) AS non_member_perc_of_transactions
FROM(
SELECT txn_id, member, RANK() OVER(PARTITION BY txn_id ORDER BY price DESC) AS rnk
FROM balanced_tree.sales
GROUP BY txn_id, price, member) AS x
WHERE rnk=1;

-- Ex.6 What is the average revenue for member transactions and non-member transactions? --
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


-- Product Analysis --

-- Ex.1 What are the top 3 products by total revenue before discount? --

SELECT product_name, SUM(qty*s.price) as total_revenue
FROM balanced_tree.sales AS s
LEFT JOIN balanced_tree.product_details AS pd ON
s.prod_id = pd.product_id
GROUP BY product_name
ORDER BY total_revenue DESC
LIMIT 3;


-- Ex.2 What is the total quantity, revenue and discount for each segment? --

SELECT  pd.segment_name,
		SUM(qty) AS quantity,
		SUM(qty*s.price) - SUM((qty*s.price)*discount/100) AS gross_revenue,
		SUM((qty*s.price)*discount/100) AS discount
FROM balanced_tree.product_details AS pd
LEFT JOIN balanced_tree.sales AS s
ON pd.product_id = s.prod_id
GROUP BY segment_name;

-- Ex.3 What is the top selling product for each segment? --

WITH top_selling AS (
SELECT  product_name,
		segment_name,
		SUM(qty) AS quantity,
		RANK() OVER (PARTITION BY segment_name ORDER BY SUM(qty) DESC) AS ranking
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


-- Ex.4 What is the total quantity, revenue and discount for each category? --

SELECT  pd.category_name,
		SUM(qty) AS quantity,
		SUM(qty*s.price) AS revenue,
		SUM((qty*s.price) * discount/100) AS discount
FROM balanced_tree.product_details AS pd
LEFT JOIN balanced_tree.sales AS s
ON pd.product_id = s.prod_id
GROUP BY category_name;


-- Ex.5 What is the top selling product for each category? --

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

-- Ex.6 What is the percentage split of revenue by product for each segment? --

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
	 
-- Ex.7 What is the percentage split of revenue by segment for each category? --

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


-- Ex.8 What is the percentage split of total revenue by category? --


SELECT  x.category_id,
		CONCAT(ROUND(sum1/ SUM(sum1) OVER () * 100,2),'%') AS percentage_by_segment
FROM(SELECT  pd.category_id,
			 SUM(qty*s.price) AS sum1
	 FROM balanced_tree.product_details AS pd
	 LEFT JOIN balanced_tree.sales AS s
	 ON pd.product_id = s.prod_id
	 GROUP BY pd.category_id) AS x;
	 
	 
	 
-- Ex.9 What is the total transaction “penetration” for each product? (hint: penetration = number of transactions
-- where at least 1  quantity of a product was purchased divided by total number of transactions) --


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



-- Ex.10 What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction? --




