CREATE TABLE order_items (
    order_id TEXT,
    order_item_id INT,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TIMESTAMP,
    price NUMERIC,
    freight_value NUMERIC
);A
SELECT COUNT(*) FROM order_items;


SELECT COUNT(*),
FROM order_items oi
JOIN orders o
ON oi.order_id = o.order_id;

SELECT COUNT(*) 
FROM order_items
WHERE order_id IS NULL 
   OR product_id IS NULL;

SELECT *
FROM order_items
WHERE price < 0 OR freight_value < 0;

SELECT order_id, order_item_id, COUNT(*)
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;


CREATE TABLE products (
    product_id TEXT,
    product_category_name TEXT,
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);
select * from products;

select * from order_items;


SELECT COUNT(*) FROM products;

SELECT COUNT(*)
FROM products
WHERE product_id IS NULL;

SELECT COUNT(*)
FROM products
WHERE product_category_name IS NULL;

SELECT *
FROM products
WHERE product_weight_g < 0
   OR product_length_cm < 0
   OR product_height_cm < 0
   OR product_width_cm < 0;


   SELECT COUNT(*)
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id;


SELECT COUNT(*)
FROM order_items oi
LEFT JOIN products p
ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


--15) Product Category Revenue and Contribution Analysis
with category_revenue as(select p.product_category_name,sum(o.price) as total
from order_items o
join products p
	on o.product_id = p.product_id
group by p.product_category_name)

select product_category_name, total,
round((total / sum(total) over()) * 100,2) as category_contribution_per
from category_revenue
order by total desc;

--16) Which product categories generate the highest average order value?
select p.product_category_name, 
sum(o.price + o.freight_value) as total_revenue,
count(distinct o.order_id) as total_orders,
round(sum(o.price + o.freight_value) / nullif(count(distinct o.order_id),0),2)  as avg_order_value
from order_items o 
join products p  
	on o.product_id = p.product_id
join orders ord
    on ord.order_id = o.order_id
where ord.order_status = 'delivered'
group by p.product_category_name 
order by avg_order_value desc;


--17) Month-over-Month Revenue Growth by Product Category
with current_month_rev as(
select sum(price) as revenue, date_trunc('month',order_purchase_timestamp)as months,
product_category_name
from order_items o1
join orders o2 
	on o1.order_id = o2.order_id 
join products p
	on p.product_id = o1.product_id
	group by months, product_category_name),
prev_month_rev as(
select revenue, months, lag(revenue) over(partition by product_category_name order by months) as prev_month, product_category_name 
from current_month_rev
)
select revenue, months, product_category_name, prev_month, revenue-prev_month as revenue_change,
round(((revenue-prev_month)/prev_month)*100,2)
from prev_month_rev
WHERE prev_month IS NOT NULL
order by months;



-- with current_month_rev as(
-- select sum(price) as revenue, date_trunc('month',order_purchase_timestamp)as months,
-- product_category_name
-- from order_items o1
-- join orders o2 
-- 	on o1.order_id = o2.order_id 
-- join products p
-- 	on p.product_id = o1.product_id)
-- select revenue, lag(revenue) over (partition by product_category_name order by months) as prev_month, product_catrgory_name,
-- (revenue-prev_month)/prev_month * 100 as MoM_growth
-- from current_month_rev
-- order by months;


--18) How many orders did each customer make, and are they a one-time or repeat buyer?
select count(order_id) as total_orders, customer_unique_id, 
case 
	when 
		count(order_id) > 1 then 'repeated customer'
	when 
		count(order_id) = 1 then 'one time buyer'
	end as customer_type
from orders o
join customers c 
	on o.customer_id = c.customer_id 
group by customer_unique_id
order by total_orders desc;


-- select 
--     count(distinct customer_unique_id) as unique_customers,
--     count(*) as total_rows
-- from customers;


--      One-Time vs Repeat Customer Distribution
select 
	count(*) filter(where total_orders = 1) as one_time_buyers,
	count(*) filter(where total_orders > 1) as repeated_buyers
from
 (select customer_unique_id, count(order_id) as total_orders
from orders o
join customers c 
	on o.customer_id = c.customer_id
group by customer_unique_id) abc;


--19) Revenue and Order Volume by Customer State
select c.customer_state, count(distinct o1.order_id), sum(o2.price + o2.freight_value) as revenue 
from customers c 
join orders o1 
	on c.customer_id = o1.customer_id
join order_items o2
	on o1.order_id = o2.order_id 
group by c.customer_state
order by revenue desc;




--20)Perform RFM analysis to segment customers based on their purchasing behavior.
with RFM as(
select c.customer_unique_id, max(o.order_purchase_timestamp) as last_purchase,
count(distinct o.order_id) as Frequency,
sum(oi.price + oi.freight_value) as Monetary
from orders o
join customers c
	on c.customer_id = o.customer_id
join order_items oi
	on oi.order_id =  o.order_id
group by c.customer_unique_id
)
select customer_unique_id,
Frequency, Monetary,
(select max(order_purchase_timestamp)from orders)-
last_purchase as Recency
from RFM;


select p.product_id, count(*) as total_units_sold 
from  products p
join order_items o
	on p.product_id  = o.product_id
group by p.product_id
order by total_units_sold;