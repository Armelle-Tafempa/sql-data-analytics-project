/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

-- Calculate the total sales per month and the running total of sales over time 
-- Calculate the average price per month and the moving average price over time

select
	OrderDate,
	TotalRevenue,
	sum(TotalRevenue) over(partition by year(OrderDate) order by OrderDate) Running_TotalRevenue,
	AvgPrice,
	avg(AvgPrice) over(partition by year(OrderDate) order by year(OrderDate)) as MovingAvgPrice
	from
(
select 
	datetrunc(month,order_date) as OrderDate,
	sum(sales_amount) as TotalRevenue,
	avg(price) as AvgPrice
from gold.fact_sales
where order_date is not null
group by datetrunc(month,order_date)
)t