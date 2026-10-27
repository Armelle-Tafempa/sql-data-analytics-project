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
-- Method 1 : Subquery 
select 
	Orderyear,
	Productname,
	CurrentSales,
	avg(CurrentSales) over(partition by Productname) AvgSales,
	CurrentSales - avg(CurrentSales) over(partition by Productname) DiffAvg,
	CASE 
		WHEN CurrentSales - avg(CurrentSales) over(partition by Productname) > 0 THEN 'Above Avg'
		WHEN CurrentSales - avg(CurrentSales) over(partition by Productname) < 0 THEN 'Below Avg'
		ELSE 'Avg'
	END Avgchange,
	-- year-over-year analysis 
	lag(CurrentSales) over(partition by Productname order by Orderyear) PrevSales,
	CurrentSales - lag(CurrentSales) over(partition by Productname order by Orderyear) Prevyearsales,
	CASE 
		WHEN CurrentSales - lag(CurrentSales) over(partition by Productname order by Orderyear) > 0 then 'Increase'
		WHEN CurrentSales - lag(CurrentSales) over(partition by Productname order by Orderyear) < 0 THEN 'Decrease'
		ELSE 'No Change'
	END prevyrchange
from 
(
	SELECT 
		year(s.order_date) as Orderyear,
		p.product_name as Productname,
		sum(s.sales_amount) as CurrentSales
	FROM gold.fact_sales s
	left join gold.dim_products p
	on s.product_key = p.product_key
	where s.order_date is not null
	group by year(s.order_date),p.product_name
)t
order by Productname, Orderyear;

-- Method 2: CTE 
WITH Yearly_pdts_sales as 
(
SELECT 
	year(s.order_date) as Orderyear,
	p.product_name as Productname,
	sum(s.sales_amount) as CurrentSales
FROM gold.fact_sales s
left join gold.dim_products p
on s.product_key = p.product_key
where s.order_date is not null
group by year(s.order_date),p.product_name
)
select 
	Orderyear,
	Productname,
	CurrentSales,
	avg(CurrentSales) over(partition by Productname) AvgSales,
	CurrentSales - avg(CurrentSales) over(partition by Productname) DiffAvg,
	CASE 
		WHEN CurrentSales - avg(CurrentSales) over(partition by Productname) > 0 THEN 'Above Avg'
		WHEN CurrentSales - avg(CurrentSales) over(partition by Productname) < 0 THEN 'Below Avg'
		ELSE 'Avg'
	END Avgchange,
	-- year-over-year analysis 
	lag(CurrentSales) over(partition by Productname order by Orderyear) PrevSales,
	CurrentSales - lag(CurrentSales) over(partition by Productname order by Orderyear) Prevyearsales,
	CASE 
		WHEN CurrentSales - lag(CurrentSales) over(partition by Productname order by Orderyear) > 0 then 'Increase'
		WHEN CurrentSales - lag(CurrentSales) over(partition by Productname order by Orderyear) < 0 THEN 'Decrease'
		ELSE 'No Change'
	END prevyrchange
from  Yearly_pdts_sales