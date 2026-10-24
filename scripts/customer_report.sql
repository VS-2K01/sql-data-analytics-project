/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_customers
-- =============================================================================
IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS
WITH BaseQuery AS (
	SELECT
		s.order_number,
		s.product_key,
		s.order_date,
		s.sales_amount,
		s.quantity,
		c.customer_key,
		c.customer_number,
		CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
		DATEDIFF(year, c.birthdate, GETDATE()) AS age
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_customers c ON c.customer_key = s.customer_key
	WHERE s.order_date IS NOT NULL
)
, CustomerAggregates AS (
	SELECT 
		customer_key,
		customer_number,
		customer_name,
		age,
		COUNT(DISTINCT order_number) AS total_orders,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity,
		COUNT(DISTINCT product_key) AS total_products,
		MAX(order_date) AS last_order_date,
		DATEDIFF(month, MIN(order_date), MAX(order_date)) AS customerlifespan
	FROM BaseQuery
	GROUP BY customer_key, customer_number, customer_name, age
)
SELECT
	customer_key AS CustomerKey,
	customer_number AS CustomerNumber,
	customer_name AS CustomerName,
	age,
	CASE 
		 WHEN age < 20 THEN 'Under 20'
		 WHEN age between 20 and 29 THEN '20-29'
		 WHEN age between 30 and 39 THEN '30-39'
		 WHEN age between 40 and 49 THEN '40-49'
		 ELSE '50 and above'
	END AS AgeGroup,
	CASE 
		WHEN customerlifespan >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN customerlifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
		ELSE 'New'
	END AS CustomerSegment,
	last_order_date AS LastOrderDate,
	DATEDIFF(month, last_order_date, GETDATE()) AS Recency,
	total_orders AS TotalOrders,
	total_sales AS TotalSales,
	total_quantity AS TotalQuantity,
	total_products AS TotalProducts,
	customerlifespan AS CustomerLifespan,
	CASE WHEN total_sales = 0 THEN 0
		 ELSE total_sales / total_orders
	END AS AvgOrderValue,
	CASE WHEN customerlifespan = 0 THEN total_sales
		 ELSE total_sales / customerlifespan
	END AS AvgMonthlySpend
FROM CustomerAggregates;