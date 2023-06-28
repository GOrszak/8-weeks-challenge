/* Ex.1 What is the total amount each customer spent at the restaurant? */

SELECT  s.customer_id, 
		    SUM(m.price) as amount_spent_at_restaurant
FROM dannys_diner.sales AS s
LEFT JOIN dannys_diner.menu AS m
ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY amount_spent_at_restaurant DESC;

/* Ex.2 How many days has each customer visited the restaurant? */

SELECT  customer_id,
		    COUNT(DISTINCT(order_date)) FROM dannys_diner.sales
GROUP BY customer_id;


/* Ex.3 What was the first item from the menu purchased by each customer?  2 producst from A customer */

WITH  cte AS (SELECT  customer_id, 
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


/* Ex.4 What is the most purchased item on the menu and how many times was it purchased by all customers? */

SELECT CONCAT('Most bought was ', z.product_name, ' and was bought ' , cnt, ' times')
FROM
	(SELECT product_id,
 			    RANK() OVER (ORDER BY product_id DESC) AS rnk,
 			    COUNT(*) as cnt
 			FROM dannys_diner.sales 
			GROUP BY product_id) AS x
LEFT JOIN dannys_diner.menu AS z
ON x.product_id = z.product_id
WHERE rnk = 1;

/* Ex.5 Which item was the most popular for each customer? */
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

/* Ex.6 Which item was purchased first by the customer after they became a member?*/
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

/* Ex.7 Which item was purchased just before the customer became a member?*/

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




/* Ex.8 What is the total items and amount spent for each member before they became a member?*/
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


/* Ex.9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?  Ewentualnie doliczyć jeszcze dla użytkownika C */

SELECT  s.customer_id,
		    SUM(CASE WHEN men.product_name = 'sushi' then price * 2* 10 else price * 10 END) AS points
FROM dannys_diner.sales AS s
INNER JOIN dannys_diner.menu as men
ON men.product_id = s.product_id
GROUP BY s.customer_id
ORDER BY points DESC;

/*Ex.10 In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January? */


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


/*  The following questions are related creating basic data tables  that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL */

SELECT  s.customer_id,
		    s.order_date,
	    	men.product_name,
		    men.price,
	    CASE WHEN s.order_date >= m.join_date THEN 'Y' ELSE 'N' END AS member
FROM dannys_diner.sales as s
LEFT JOIN dannys_diner.menu as men
ON men.product_id = s.product_id
LEFT JOIN dannys_diner.members as m
ON m.customer_id = s.customer_id
ORDER BY s.customer_id, s.order_date;

/* Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member 
purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program. */

WITH cte AS
  (SELECT s.customer_id,
		      s.order_date,
		      men.product_name,
		      men.price,
	        CASE WHEN s.order_date >= m.join_date THEN 'Y' ELSE 'N' END AS mem
FROM dannys_diner.sales as s
LEFT JOIN dannys_diner.menu as men
	ON men.product_id = s.product_id
LEFT JOIN dannys_diner.members as m
	ON m.customer_id = s.customer_id
ORDER BY s.customer_id, s.order_date)

SELECT *,
CASE WHEN mem='N' THEN NULL ELSE DENSE_RANK() OVER (PARTITION BY customer_id, mem ORDER BY order_date) END AS ranking
FROM cte;
