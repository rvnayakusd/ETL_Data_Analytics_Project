select * from df_order;

-- Top 10 highest revenue generating products
select top 10 product_id, sum(sales_price) as revenue
from df_order
group by product_id
order by revenue desc;


--Top 5 highest selling products in each region
with cte as (
select  region, product_id, sum(sales_price) as sales
from df_order
group by region, product_id

)

select * from (
select *
	,ROW_NUMBER() over(partition by region order by sales desc) as rn 
from cte 
) A
where rn <= 5;


--Find month over month growth comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023
with cte as (
select year(order_date) as order_year, MONTH(order_date) as order_month, SUM(sales_price) as growth 
from df_order
group by year(order_date), MONTH(order_date) 
--order by order_month
) 

select order_month, 
	sum(case when order_year=2022 then growth else 0 end) as sales_2022
	,sum(case when order_year=2023 then growth else 0 end) as sales_2023
from cte 
group by order_month;


--for each category which month had a highest sales 
with cte as(
select category, FORMAT(order_date, 'yyyyMM') as order_year_month, sum(sales_price) as sales
from df_order
group by category, FORMAT(order_date, 'yyyyMM')
--order by category, FORMAT(order_date, 'yyyyMM')
)
select * from (
select *,
	ROW_NUMBER() over(partition by category order by sales desc) as rn
from cte) a
where rn = 1



--which sub category had highest growth by profit in 2023 compare to 2022
with cte as(
select sub_category, year(order_date) as order_year, sum(sales_price) as sales
from df_order
group by sub_category, year(order_date)
--order by category, FORMAT(order_date, 'yyyyMM')
)

, cte2 as(
select sub_category, 
	sum(case when order_year=2022 then sales else 0 end) as sales_2022
	,sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by sub_category)

select top 1 *,
	(sales_2023 - sales_2022)*100/sales_2022 as diff
from cte2
order by (sales_2023 - sales_2022)*100/sales_2022 desc

