/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

SQL Functions Used:
    - Date Functions: DATEPART(), DATETRUNC(), FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG()
===============================================================================
*/

-- Analyse sales performance over time
-- Quick Date Functions
select 
	year(order_date) as OrderYear,
	month(order_date) as OrderMonth,
	sum(sales_amount) as TotalRevenue,
	count(distinct customer_key) as TotalCustomers,
	sum(quantity) as TotalQuantity
from gold.fact_sales
where order_date is not null
group by year(order_date),month(order_date) 
order by year(order_date),month(order_date)


-- DATETRUNC()
select 
	Datetrunc(month,order_date) as OrderDate,
	sum(sales_amount) as TotalRevenue,
	count(distinct customer_key) as TotalCustomers,
	sum(quantity) as TotalQuantity
from gold.fact_sales
where order_date is not null
group by Datetrunc(month,order_date) 
order by Datetrunc(month,order_date)

-- FORMAT()
select 
	format(order_date,'YYYY-MMM') as OrderDate,
	sum(sales_amount) as TotalRevenue,
	count(distinct customer_key) as TotalCustomers,
	sum(quantity) as TotalQuantity
from gold.fact_sales
where order_date is not null
group by format(order_date,'YYYY-MMM')
order by format(order_date,'YYYY-MMM')
