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
IF OBJECT_ID ('gold.report_products','V') IS NOT NULL

DROP VIEW gold.report_products ;

GO

CREATE VIEW gold.report_products AS 

WITH base_query as 
(
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact_sales and dim_products
---------------------------------------------------------------------------*/
select 
    s.price,
    s.customer_key,
    s.sales_amount,
    s.order_number,
    s.quantity,
    s.order_date,
    p.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    p.start_date as Startdate,
    p.cost
from gold.fact_sales s
left join gold.dim_products p
on p.product_key = s.product_key
where s.order_date is not null
)
, product_aggregation AS 
(
/*---------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
---------------------------------------------------------------------------*/
select 
    product_key,
    product_name,
    category,
    subcategory,
    Startdate,
    cost,
    sum(sales_amount) AS Totalrevenue,
    count(distinct order_number) TotalOrders,
    sum(quantity) as TotalQuantitySold,
    count(distinct customer_key) TotalCustomers,
    max(Order_date) LastSales,
    datediff(month, min(order_date), max(order_date)) Lifespan,
    datediff(month, Startdate, getdate()) MarketDuration
from base_query
group by 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    Startdate
)
/*---------------------------------------------------------------------------
  3) Final Query: Combines all product results into one output
---------------------------------------------------------------------------*/
select 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    MarketDuration,
    lifespan,
    lastSales,
    datediff(month, LastSales,getdate()) as Recency,
    CASE 
        WHEN Totalrevenue >= 50000 Then 'High-Performer'
        WHEN Totalrevenue >= 10000 then 'Mid-Range'
        ELSE 'Low-Performer'
    END AS Productsegment,
    TotalCustomers,
    TotalOrders,
    Totalrevenue,
    TotalQuantitySold,
    -- Compute Average order revenue 
    CASE 
        WHEN TotalOrders = 0 THEN 0
        ELSE Totalrevenue/TotalOrders 
    END as AvgOrderRevenue,
    -- Compute Average monthly revenue
    CASE 
        WHEN lifespan = 0 THEN Totalrevenue
        ELSE Totalrevenue/Lifespan
    END as Avgmonthlyrevenue,
    -- Compute the gross profit 
    Totalrevenue - (cost*TotalQuantitySold) as Grossprofit
FROM product_aggregation