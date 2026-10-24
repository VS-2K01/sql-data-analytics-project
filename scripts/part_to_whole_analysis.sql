/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/
-- Which categories contribute the most to overall sales?
WITH SalesByCategory AS (
    SELECT
        p.category AS ProductCategory,
        SUM(sales_amount) AS TotalSales
    FROM gold.fact_sales s 
    INNER JOIN gold.dim_products p ON s.product_key = p.product_key
    GROUP BY p.category
)
SELECT
    ProductCategory,
    TotalSales,
    SUM(TotalSales) OVER () AS AllCatSales,
    CONCAT(ROUND((CAST(TotalSales AS FLOAT) / SUM(TotalSales) OVER ()) * 100, 2), '%') AS PercentOfAllCatSales
FROM SalesByCategory
ORDER BY TotalSales DESC;