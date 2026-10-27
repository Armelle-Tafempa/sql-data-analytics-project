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

CREATE VIEW gold.report_customers AS 

WITH base_query as 
(
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------*/
	SELECT 
		s.order_number,
		s.product_key,
		s.order_date,
		s.sales_amount,
		s.quantity,
		c.customer_key,
		c.customer_number,
		concat(c.first_name,' ',c.last_name) Customername,
		datediff(year,c.birthdate,GETDATE()) Age
	FROM gold.fact_sales s
	left join gold.dim_customers c
	on s.customer_key = c.customer_key
	where order_date is not null
)
, Customer_Aggregation as 
(
/*---------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
---------------------------------------------------------------------------*/
select
	Customer_key, 
	Customer_number,
	Customername,
	Age,
	count(distinct order_number) as TotalOrders,
	sum(sales_amount) as TotalSales,
	sum(quantity) as TotalQuantity,
	count(distinct product_key) as TotalProducts,
	max(order_date) as LastOrder,
	datediff(month,min(order_date),max(order_date)) as Lifespan
from base_query
group by 
	Customer_key, 
	Customer_number,
	Customername,
	Age
)
select
	Customer_key, 
	Customer_number,
	Customername,
	Age,
	CASE 
		WHEN Age < 20 THEN 'Under 20'
		WHEN Age between 20 and 29 then '20-29'
		WHEN Age between 30 and 39 then '30-39'
		WHEN Age between 40 and 49 then '40-49'
		ELSE '50 and above'
	END Age_group,
	lifespan,
	CASE 
		WHEN Lifespan >= 12 AND TotalSales > 5000 then 'VIP'
		WHEN Lifespan >= 12 AND TotalSales <= 5000 then 'Regular'
		ELSE 'New'
	END as Customer_segment,
	LastOrder,
	datediff(month,LastOrder,getdate()) AS Recency,
	TotalOrders,
	TotalSales,
	TotalQuantity,
	TotalProducts,
	-- Compute average order value (AvgOrd)
	CASE WHEN TotalOrders = 0 then 0
		 ELSE TotalSales/TotalOrders
	END AS AvgOrderValue,
	-- Compute average monthly spend 
	CASE WHEN Lifespan = 0 then TotalSales
		 ELSE TotalSales/lifespan
	END AS AvgMonthlySpend
from Customer_Aggregation