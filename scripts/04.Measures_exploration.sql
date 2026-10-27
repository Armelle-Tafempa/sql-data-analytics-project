/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/

-- Find the Total Sales
select 
	sum(price) TotalRevenue
from gold.fact_sales

-- Find how many items are sold
select 
  sum(quantity) TotalQuantity_sold
from gold.fact_sales s

-- Find the average selling price
   -- Method 1
select 
  sum(price)/sum(quantity) Avg_sellingprice
from gold.fact_sales

   -- Method 2
select 
  AVG(price) Avg_sellingprice
from gold.fact_sales

-- Find the Total number of Orders
SELECT 
	count(order_number) as TotalOrders,
	count(distinct order_number) as TotalOrders2 
from gold.fact_sales

-- Find the total number of products
SELECT 
	count(product_key) as TotalProducts
from gold.dim_products

-- Find the total number of customers
SELECT 
	count(customer_key) as TotalCustomers
from gold.dim_customers

-- Find the total number of customers that has placed an order
select
	count(distinct customer_key) as TotalCustomers2
from gold.fact_sales


-- Generate a report that shows all key metrics of the business
select 
	'Total Sales' as measure_name, 
	sum(price) measure_value
from gold.fact_sales
UNION ALL 
select 
	'Total Quantity' as measure_name,
	sum(quantity) TotalQuantity
from gold.fact_sales
union all 
select 
	'Total Quantity',
	AVG(price) Avg_sellingprice
from gold.fact_sales
union all
SELECT 
	'Total Nr. Orders',
	count(distinct order_number) as TotalOrders 
from gold.fact_sales
union all 
SELECT 'Total Nr. Products',
	count(product_key) as TotalProducts
from gold.dim_products
union all
SELECT 'Total Nr. Customers',
	count(customer_key) as TotalCustomers
from gold.dim_customers
union all
select 'Total Nr. Customers with orders',
	count(distinct customer_key) as TotalCustomers2
from gold.fact_sales