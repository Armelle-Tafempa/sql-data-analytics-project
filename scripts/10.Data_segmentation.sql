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
WITH productsegment AS 
(
SELECT 
    product_key,
    product_name,
    cost,
case when cost < 100 then 'Below 100'
    when cost between 100  and 500 then '100 - 500'
    when cost between 500  and 1000 then '500 - 1 000'
    else 'Above 1 000'
end Costrange
FROM gold.dim_products
)
select 
    Costrange,
    count(product_key) as TotalProducts 
from productsegment
group by Costrange
order by TotalProducts DESC;

/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/
WITH Customerrange AS 
(
SELECT 
    c.customer_key,
    c.first_name,
    c.last_name,
    min(s.order_date) FirstOrder,
    max(s.order_date) LastOrder,
    datediff(month,min(s.order_date),max(s.order_date)) as Lifespan,
    sum(s.sales_amount) TotalSales,
    case 
        when  datediff(month,min(s.order_date),max(s.order_date)) >= 12 and sum(s.sales_amount) > 5000 then 'VIP'
        when  datediff(month,min(s.order_date),max(s.order_date)) >= 12 and sum(s.sales_amount) <= 5000 then 'Regular'
        else 'New'
    End CustRange
from gold.fact_sales s
left join gold.dim_customers c
on s.customer_key = c.customer_key
group by 
    c.customer_key,
    c.first_name,
    c.last_name
)
select
    CustRange,
    sum(TotalSales) TotalSales,
    count(customer_key) TotalCustomers
from Customerrange
group by CustRange 
order by TotalCustomers DESC