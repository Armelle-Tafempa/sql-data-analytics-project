/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/

-- Which 5 products Generating the Highest Revenue?
-- Method 1 : Simple Ranking

select top 5
	p.product_name,
	coalesce(sum(s.sales_amount),'') TotalRevenue_pdts
from gold.dim_products p
left join gold.fact_sales s
on p.product_key = s.product_key
group by p.product_name
order by TotalRevenue_pdts DESC


-- Method 2 : Complex but Flexibly Ranking Using Window Functions
select *
from (
	select
		p.product_name,
		sum(s.sales_amount) TotalRevenue_pdts,
		rank() over(order by sum(s.sales_amount) DESC) Rk_pdts
	from gold.dim_products p
	left join gold.fact_sales s
	on p.product_key = s.product_key
	group by p.product_name
	)t
where Rk_pdts <= 5

-- 5 Worst-performing products in terms of sales ?

select top 5
	p.product_name,
	coalesce(sum(s.sales_amount),0) TotalRevenue_pdts
from gold.dim_products p
left join gold.fact_sales s
on p.product_key = s.product_key
group by p.product_name
having coalesce(sum(s.sales_amount),0)>0
order by TotalRevenue_pdts 

-- Top 10 customers who have generated the highest revenue

select top 10
	concat(c.first_name,' ',c.last_name) CustomerName,
	sum(s.sales_amount) TotalRevenue_customer
from gold.dim_customers c
left join gold.fact_sales s
on c.customer_key = s.customer_key
group by concat(c.first_name,' ',c.last_name)
order by TotalRevenue_customer DESC

-- The 3 customers with the fewest orders placed 

select top 3
	concat(c.first_name,' ',c.last_name) CustomerName,
	count(distinct s.order_number) TotalOrders
from gold.dim_customers c
left join gold.fact_sales s
on c.customer_key = s.customer_key
group by concat(c.first_name,' ',c.last_name)
order by TotalOrders asc