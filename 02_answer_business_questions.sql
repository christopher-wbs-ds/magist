/*****
In relation to the products:
*****/

-- What categories of tech products does Magist have?
SELECT * FROM product_category_name_translation; -- read through and choose
-- e.g.
-- "audio", 
-- "electronics", 
-- "computers_accessories", 
-- "pc_gamer", 
-- "computers", 
-- "tablets_printing_image", 
-- "telephony"


-- How many products of these tech categories have been sold (within the time window of the database snapshot)? 
SELECT 
	COUNT(DISTINCT oi.product_id ) AS tech_products_sold
FROM 
	order_items oi
		LEFT JOIN 
	products p USING (product_id)
		LEFT JOIN 
	product_category_name_translation pt USING (product_category_name)
WHERE 
	product_category_name_english IN ("audio", "electronics", "computers_accessories", "pc_gamer",
    "computers", "tablets_printing_image", "telephony");
    

-- What percentage does that represent from the overall number of products sold?
	-- This can be solved manually: 3390 is the answer above
    SELECT -- this query counts all products sold
		COUNT(DISTINCT product_id ) AS products_sold
	FROM 
		order_items; -- 32951
	SELECT 3390 / 32951; -- can also be done on a calculator
    
    -- This can also be solved with a subquery
    SELECT 
	COUNT(DISTINCT oi.product_id ) / (SELECT COUNT(DISTINCT product_id ) FROM order_items )
FROM 
	order_items oi
		LEFT JOIN 
	products p USING (product_id)
		LEFT JOIN 
	product_category_name_translation pt USING (product_category_name)
WHERE 
	product_category_name_english IN ("audio", "electronics", "computers_accessories", "pc_gamer",
    "computers", "tablets_printing_image", "telephony");
    
    
-- What’s the average price of the products being sold?
SELECT ROUND(AVG(price), 2)
FROM order_items;

-- Are expensive tech products popular? 
SELECT 
    CASE 
        WHEN oi.price > (SELECT AVG(oi.price) FROM order_items oi) THEN 'Expensive'
        ELSE 'Affordable'
    END AS price_category,
    COUNT(oi.product_id) AS num_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN product_category_name_translation pct ON p.product_category_name = pct.product_category_name
WHERE pct.product_category_name_english IN (
    'audio', 'cine_photo', 'computers', 'computers_accessories', 'consoles_games',
    'electronics', 'fixed_telephony', 'home_appliances', 'home_appliances_2', 
    'pc_gamer', 'small_appliances', 'small_appliances_home_oven_and_coffee', 
    'tablets_printing_image', 'telephony'
)
GROUP BY price_category;
select count(*) from order_items;
    
    
/*****
In relation to the sellers:
*****/

-- How many months of data are included in the magist database?
SELECT 
    TIMESTAMPDIFF(MONTH,
        MIN(order_purchase_timestamp),
        MAX(order_purchase_timestamp)
        ) AS num_months
FROM
    orders;


-- How many sellers are there? 
SELECT 
    COUNT(DISTINCT seller_id)
FROM
    sellers;
    

-- How many Tech sellers are there? 
SELECT 
    COUNT(DISTINCT seller_id)
FROM
    sellers
        LEFT JOIN
    order_items USING (seller_id)
        LEFT JOIN
    products p USING (product_id)
        LEFT JOIN
    product_category_name_translation pt USING (product_category_name)
WHERE
    pt.product_category_name_english IN ('audio' , 'electronics', 'computers_accessories',
        'pc_gamer', 'computers', 'tablets_printing_image', 'telephony');
        
        
-- What percentage of overall sellers are Tech sellers?
	-- As above, either manually with 454 being the number of tech sellers
SELECT COUNT(*) from sellers; -- 3095 total sellers
SELECT (454 / 3095) * 100;
    
    -- Or with a subquery
SELECT 
    COUNT(DISTINCT seller_id) / (SELECT COUNT(*) from sellers )
FROM
    sellers
        LEFT JOIN
    order_items USING (seller_id)
        LEFT JOIN
    products p USING (product_id)
        LEFT JOIN
    product_category_name_translation pt USING (product_category_name)
WHERE
    pt.product_category_name_english IN ('audio' , 'electronics', 'computers_accessories',
        'pc_gamer', 'computers', 'tablets_printing_image', 'telephony');

-- What is the total amount earned by all sellers? 
	-- we use price from order_items and not payment_value from order_payments as an order may contain tech and non tech product. With payment_value we can't distinguish between items in an order
SELECT 
    SUM(oi.price) AS total
FROM
    order_items oi
        LEFT JOIN
    orders o USING (order_id)
WHERE
    o.order_status NOT IN ('unavailable' , 'canceled');

-- What is the total amount earned by all Tech sellers?
SELECT 
    SUM(oi.price) AS total
FROM
    order_items oi
        LEFT JOIN
    orders o USING (order_id)
        LEFT JOIN
    products p USING (product_id)
        LEFT JOIN
    product_category_name_translation pt USING (product_category_name)
WHERE
    o.order_status NOT IN ('unavailable' , 'canceled')
        AND 
	pt.product_category_name_english IN ('audio' , 'electronics', 'computers_accessories',
        'pc_gamer', 'computers', 'tablets_printing_image', 'telephony');


-- Can you work out the average monthly income of all sellers? 
	-- Manually based on previous queries
SELECT 13494400.74/ 3095 / 25;

	-- With subqueries
SELECT 
	SUM(price) 
		/ 
	(SELECT COUNT(*) FROM sellers) 
		/ 
	(SELECT TIMESTAMPDIFF(MONTH, MIN(order_purchase_timestamp), MAX(order_purchase_timestamp)) FROM orders) 
AS monthly_all_sellers
FROM 
	order_items oi
        LEFT JOIN
    orders o USING (order_id)
WHERE
    o.order_status NOT IN ('unavailable' , 'canceled');

-- Can you work out the average monthly income of Tech sellers? */
	-- Manually
SELECT 1666211.28 / 454 / 25;
	
    -- Common table expression and subqueries
WITH num_tech_sellers AS (
SELECT 
    COUNT(DISTINCT seller_id) num_sellers
FROM
    sellers
        LEFT JOIN
    order_items USING (seller_id)
        LEFT JOIN
    products p USING (product_id)
        LEFT JOIN
    product_category_name_translation pt USING (product_category_name)
WHERE
    pt.product_category_name_english IN ('audio' , 'electronics', 'computers_accessories',
        'pc_gamer', 'computers', 'tablets_printing_image', 'telephony')
)
SELECT 
	SUM(price) 
		/ 
	(SELECT num_sellers FROM num_tech_sellers) 
		/ 
	(SELECT TIMESTAMPDIFF(MONTH, MIN(order_purchase_timestamp), MAX(order_purchase_timestamp)) FROM orders) 
AS monthly_all_sellers
FROM 
	order_items oi
        LEFT JOIN
    orders o USING (order_id)
        LEFT JOIN
    products p USING (product_id)
        LEFT JOIN
    product_category_name_translation pt USING (product_category_name)
WHERE
    o.order_status NOT IN ('unavailable' , 'canceled')
		AND 
	pt.product_category_name_english IN ('audio' , 'electronics', 'computers_accessories',
        'pc_gamer', 'computers', 'tablets_printing_image', 'telephony');


/*****
In relation to the delivery time:
*****/

-- What’s the average time between the order being placed and the product being delivered?
SELECT AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) avg_delivery_in_days
FROM orders;

-- How many orders are delivered on time vs orders delivered with a delay?
SELECT 
    CASE 
        WHEN TIMESTAMPDIFF(HOUR, order_estimated_delivery_date, order_delivered_customer_date) > 0 THEN 'Delayed' 
        ELSE 'On time'
    END AS delivery_status, 
    COUNT(DISTINCT order_id) AS orders_count
FROM orders 
WHERE order_status = 'delivered'
		AND 
    order_estimated_delivery_date IS NOT NULL
		AND 
    order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;


-- Is there any pattern for delayed orders, e.g. big products being delayed more often? */
SELECT
    CASE 
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) >= 100 THEN "> 100 day Delay"
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) >= 7 AND DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) < 100 THEN "1 week to 100 day delay"
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 3 AND DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) < 7 THEN "4-7 day delay"
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) >= 1  AND DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) <= 3 THEN "1-3 day delay"
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0  AND DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) < 1 THEN "less than 1 day delay"
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) <= 0 THEN 'On time' 
    END AS "delay_range", 
    AVG(product_weight_g) AS weight_avg,
    MAX(product_weight_g) AS max_weight,
    MIN(product_weight_g) AS min_weight,
    SUM(product_weight_g) AS sum_weight,
    COUNT(DISTINCT a.order_id) AS orders_count
FROM orders a
LEFT JOIN order_items b
    USING (order_id)
LEFT JOIN products c
    USING (product_id)
WHERE order_estimated_delivery_date IS NOT NULL
AND order_delivered_customer_date IS NOT NULL
AND order_status = 'delivered'
GROUP BY delay_range;
