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
-- Method 1: Subquery
select 
	Category,
	Totalrevenue,
	Sum(Totalrevenue) OVER () OverallTotal,
	concat(round((cast(Totalrevenue as float)/Sum(Totalrevenue) OVER () * 100),2),'%') as PercentageTotal
from (
	SELECT 
		p.category as Category,
		sum(s.sales_amount) as Totalrevenue
	FROM gold.fact_sales s
	left join gold.dim_products p
	on s.product_key = p.product_key
	group by p.category
	)t
order by Totalrevenue DESC;

-- Method 2: CTE
WITH Categorysales as 
(
	SELECT 
		p.category as Category,
		sum(s.sales_amount) as Totalrevenue
	FROM gold.fact_sales s
	left join gold.dim_products p
	on s.product_key = p.product_key
	group by p.category
)
select 
	Category,
	Totalrevenue,
	Sum(Totalrevenue) OVER () OverallTotal,
	concat(round((cast(Totalrevenue as float)/Sum(Totalrevenue) OVER () * 100),2),'%') as PercentageTotal
from Categorysales
order by Totalrevenue DESC