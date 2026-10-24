/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */

WITH yearlySales AS (
    SELECT
        YEAR(s.order_date) AS OrderYear,
        p.product_name AS ProductName,
        SUM(s.sales_amount) AS TotalSales
    FROM gold.fact_sales s INNER JOIN gold.dim_products p ON s.product_key = p.product_key
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date), p.product_name
) 
SELECT
    OrderYear,
    ProductName,
    TotalSales,
    AVG(TotalSales) OVER (PARTITION BY ProductName) AS AvgSales,
    TotalSales - AVG(TotalSales) OVER (PARTITION BY ProductName) AS DiffAvg,
    CASE
        WHEN TotalSales - AVG(TotalSales) OVER (PARTITION BY ProductName) > 0 THEN 'Above Average'
        WHEN TotalSales - AVG(TotalSales) OVER (PARTITION BY ProductName) < 0 THEN 'Below Average'
        ELSE 'Average'
    END AS AvgChange,
    LAG(TotalSales) OVER (PARTITION BY ProductName ORDER BY OrderYear) AS PreviousYearSales,
    TotalSales - LAG(TotalSales) OVER (PARTITION BY ProductName ORDER BY OrderYear) AS DiffPreviousYear,
    CASE
        WHEN TotalSales - LAG(TotalSales) OVER (PARTITION BY ProductName ORDER BY OrderYear) > 0 THEN 'Increase'
        WHEN TotalSales - LAG(TotalSales) OVER (PARTITION BY ProductName ORDER BY OrderYear) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS PreviousYearChange
FROM yearlySales
ORDER BY ProductName, OrderYear