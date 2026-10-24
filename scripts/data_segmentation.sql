/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

/*Segment products into cost ranges and 
count how many products fall into each segment*/
WITH CostRanges AS (
    SELECT
        product_key AS ProductKey,
        product_name AS ProductName,
        cost AS Cost,
        CASE
            WHEN cost < 100 THEN '0-100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS CostRange
    FROM gold.dim_products
)
SELECT
    CostRange,
    COUNT(DISTINCT ProductName) AS NumProducts
FROM CostRanges
GROUP BY CostRange
ORDER BY NumProducts DESC;

/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/
WITH CustomerSpending AS (
    SELECT
        c.customer_key AS CustomerKey,
        SUM(s.sales_amount) AS TotalSales,
        MIN(order_date) AS FirstOrder,
        MAX(order_date) AS LastOrder,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS CustomerLifeSpan
    FROM gold.dim_customers c
    INNER JOIN gold.fact_sales s ON c.customer_key = s.customer_key
    GROUP BY c.customer_key
)
SELECT
    CustomerSegment,
    COUNT(CustomerKey) AS TotalCustomers
FROM (
    SELECT
        CustomerKey,
        CASE
            WHEN CustomerLifeSpan >= 12 AND TotalSales > 5000 THEN 'VIP'
            WHEN CustomerLifeSpan >= 12 AND TotalSales <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS CustomerSegment
    FROM CustomerSpending
) AS CustomerSegments
GROUP BY CustomerSegment
ORDER BY TotalCustomers DESC;