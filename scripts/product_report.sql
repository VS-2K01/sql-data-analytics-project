/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/
-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================
IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS
WITH BaseQuery AS (
    SELECT
	    s.order_number,
        s.order_date,
		s.customer_key,
        s.sales_amount,
        s.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    WHERE order_date IS NOT NULL
)
, ProductAggregations AS (
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS customerlifespan,
        MAX(order_date) AS last_sale_date,
        COUNT(DISTINCT order_number) AS total_orders,
	    COUNT(DISTINCT customer_key) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
	    ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
    FROM BaseQuery
    GROUP BY product_key, product_name, category, subcategory, cost
)
SELECT 
	product_key AS ProductKey,
	product_name AS ProductName,
	category AS Category,
	subcategory AS Subcategory,
	cost AS Cost,
	last_sale_date AS LastSaleDate,
	DATEDIFF(MONTH, last_sale_date, GETDATE()) AS RecencyInMonths,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS ProductSegment,
	customerlifespan AS CustomerLifespan,
	total_orders AS TotalOrders,
	total_sales AS TotalSales,
	total_quantity AS TotalQuantity,
	total_customers AS TotalCustomers,
	avg_selling_price AS AvgSellingPrice,
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END AS AvgOrderRevenue,
	CASE
		WHEN customerlifespan = 0 THEN total_sales
		ELSE total_sales / customerlifespan
	END AS AvgMonthlyRevenue
FROM ProductAggregations 