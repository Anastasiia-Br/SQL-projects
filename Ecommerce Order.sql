-- combine the tables "orders", "customers", "items", "products", "payments" and display the columns necessary for analysis from all five tables

with main as(
select distinct orders.order_id  
	, orders.customer_id
	, orders.order_purchase_timestamp
	, orders.order_approved_at
	, orders.order_delivered_timestamp
	, date(orders.order_delivered_timestamp)-date(orders.order_purchase_timestamp) as execution_interval
	, customers.customer_city
	, items.product_id
	, items.price
	, items.shipping_charges
	, products.product_category_name
	, payments.payment_type
	, payments.payment_value
	, items.price+payments.payment_value+items.shipping_charges as total_price
from orders 
join customers on orders.customer_id = customers.customer_id
join items on orders.order_id = items.order_id
join products on items.product_id = products.product_id
join payments on orders.order_id = payments.order_id
)

--Display the top 5 cities with the largest number of orders, and how many orders were made in each of these cities

, top_cities as(
select distinct customer_city
	, count(*) over(partition by customer_city) as orders_city
from main
order by 2 desc
limit 5
)

--Which payment types are the most popular, what is the average payment amount for each type, and how many times each type was used

, payment_types as(
select distinct payment_type
	, round(avg(payment_value) over(partition by payment_type),2) as average_payment
	, count(payment_type) over(partition by payment_type) as number_of_uses
from main
order by 3 desc
)

--Which product categories are the most profitable, what is the maximum and minimum price in each category, and how many products have been sold in each category

, product_categories as(
select distinct product_category_name
	, sum(price) over(partition by product_category_name) as sum_of_sales
	, max(price) over(partition by product_category_name) as maximum_price
	, min(price) over(partition by product_category_name) as minimum_price
	, count(product_category_name) over(partition by product_category_name) as units_sold
from main
order by 2 desc
)

--How many orders were made in each month, sorted from highest to lowest

, orders_in_month as(
select distinct to_char(order_purchase_timestamp, 'Month') as month_name
	, count(*) over(partition by to_char(order_purchase_timestamp, 'Month')) as avg_orders
from main
order by 2 desc 
)

select *
from orders_in_month
