/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/

-- Determine the first and last order date and the total duration in months

select 
	min(order_date) FirstOrder,
	max(order_date) LastOrder,
	Datediff(year, min(order_date), max(order_date)) OrderRangeYr,
	Datediff(month, min(order_date), max(order_date)) OrderRangeMth
from gold.fact_sales


-- Find the youngest and oldest customer based on birthdate

select 
min(birthdate) OldestCust,
datediff(year,min(birthdate),getdate()) OldestCustomerAge, 
max(birthdate) YoungestCust,
datediff(year,max(birthdate),getdate()) YoungestCustomerAge
From gold.dim_customers