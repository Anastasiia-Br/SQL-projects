--Showing the top 5 best selling products in "Coffee" category
select product_type 
	, product_detail 
	, sum(transaction_qty) as units_sold
from coffee_sales cs 
where product_category = 'Coffee'
group by 1, 2
order by 3 desc 
limit 5;


--Identification of the 2 most popular product types in each category
with top2 as (
  select product_category
    , product_type
    , count(*) as p_count
    , row_number() over (partition by product_category order by count(*) desc) as r_number
  from coffee_sales
  group by product_category, product_type
)
select product_category
  , product_type
from top2
where r_number <= 2
order by product_category, r_number;


--What are the 3 product categories that brought in the highest total revenue
select product_category 
	, sum(total_bill) 
from coffee_sales cs 
group by 1
order by 2 desc
limit 3;


--The top 3 days of the week with the highest number of sales
select distinct day_name
 	, sum(transaction_qty) as units_sold
from coffee_sales cs 
group by 1
order by 2 desc
limit 3;


--Average number of cups sold per store per month of each size, excluding records where cup size is not stated
with cup_size as(
select distinct size_cup
	, month_name
	, store_location
	, sum(transaction_qty) as sum_tran
from coffee_sales cs
where size_cup not like ('Not Defined')
group by size_cup, month_name, store_location
)
select distinct size_cup
	, round(avg(sum_tran),0) as sold_per_month
from cup_size
group by 1
order by 2 desc;


--Group the sales data into time intervals during the day and calculate the average number of items sold per day for a store for each of these time intervals
with time_int as(
select case when transaction_time between '06:00:00' and '09:59:59' then 'morning'
	when transaction_time between '10:00:00' and '13:59:59' then 'lunch'
	when transaction_time between '14:00:00' and '17:59:59' then 'afternoon'
	else 'evening' end as t_groups
	, transaction_date
	, store_location
	, sum(transaction_qty) as sum_t
from coffee_sales cs
group by t_groups, transaction_date, store_location
)
select distinct t_groups
	, round(avg(sum_t),0) as sold_per_day
from time_int
group by 1
order by 2 desc;


--Identification of the store with the highest total sales for the month of June
select distinct store_location 
	, sum(total_bill)
from coffee_sales cs 
where month_name = 'June'
group by 1 
order by 2 desc;


--For each store, identify the top 3 most popular products
with top3 as (
  select store_location
    , product_type
    , count(*) as p_count
    , row_number () over (partition by store_location order by sum(transaction_qty) desc) as row_num
  from coffee_sales
  group by store_location, product_type
)
select store_location
  , product_type
from top3
where row_num <= 3
order by store_location, row_num;


--Identify the days on which the total number of sales was less than 60% of the average for the whole period
with top4 as(
  select transaction_date
  	, sum(transaction_qty) s_tran
  from coffee_sales
  group by 1
)
, top5 as(
select round(avg(s_tran),2) avg_s_tran
FROM top4
)
select transaction_date
	, s_tran
from top4, top5
where s_tran < 0.6*avg_s_tran 
order by 1 asc
