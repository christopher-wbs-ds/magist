use magist123;

/* 1. How many orders are there in the dataset? */
SELECT 
    COUNT(*)
FROM
    orders;

/* 2. Are orders actually delivered? */
-- Let's check the order statuses first
SELECT DISTINCT order_status FROM orders;

-- Count the different order statuses, specifically when the order isn't delivered
-- Some are expected (unavailable, canceled)
-- Some are odd (delivered, shipped, invoiced, processing)
SELECT 
    order_status, COUNT(*)
FROM
    orders
WHERE
    order_delivered_customer_date IS NULL
GROUP BY order_status;

-- Is is just the new orders that are unexpectedly undelivered?
-- What is the latest order date?
SELECT 
    order_purchase_timestamp
FROM
    orders
ORDER BY order_purchase_timestamp DESC
LIMIT 1;
-- or
SELECT max(order_purchase_timestamp) FROM orders;

-- What if we focus just on the 'shipped' orders?
SELECT 
    *
FROM
    orders
WHERE
    order_status = 'shipped'
ORDER BY order_purchase_timestamp DESC;


/* What are the reviews for cancelled orders? 
Do they mention no delivery?*/
SELECT 
    review_comment_title, review_comment_message
FROM
    orders
        JOIN
    order_reviews USING (order_id)
WHERE
    order_status = 'canceled';

/* 3. Is Magist having user growth? */
-- Most users are new, so we'll just track orders
SELECT COUNT(*), COUNT(DISTINCT customer_unique_id) FROM customers;

SELECT 
    MONTH(order_purchase_timestamp) AS `month`,
    YEAR(order_purchase_timestamp) AS `year`,
    COUNT(*) AS orders_placed
FROM
    orders
GROUP BY 
	MONTH(order_purchase_timestamp), 
    YEAR(order_purchase_timestamp)
ORDER BY 
	YEAR(order_purchase_timestamp), 
    MONTH(order_purchase_timestamp);

/* 4. How many products are there on the products table? */
SELECT 
    COUNT(*)
FROM
    products;

/* 5. Which are the categories with the most products? */
SELECT 
    product_category_name_english, COUNT(*) AS product_count
FROM
    products
        JOIN
    product_category_name_translation USING (product_category_name)
GROUP BY product_category_name
ORDER BY product_count DESC;


/* 6. How many of those products were present in actual transactions? */
SELECT 
    COUNT(DISTINCT product_id)
FROM
    order_items;


/* 7. What’s the price for the most expensive and cheapest products? */
SELECT 
    MIN(price) AS min_price, MAX(price) AS max_price
FROM
    order_items;

/* 8. What are the highest and lowest payment values? */
SELECT 
    MIN(payment_value) AS min_payment,
    MAX(payment_value) AS max_payment
FROM
    order_payments;