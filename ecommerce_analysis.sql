create table customers(
	customer_id	text	primary key,
	customer_unique_id	text	not null,
	customer_zip_code_prefix	text,	
	customer_city	text,	
	customer_state	text	
);		

CREATE TABLE orders (
    order_id TEXT PRIMARY KEY,
    customer_id TEXT NOT NULL,
    order_status TEXT NOT NULL,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE payments (
    order_id TEXT NOT NULL,
    payment_sequential INT,
    payment_type TEXT,
    payment_installments INT,
    payment_value NUMERIC,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE order_items (
    order_id TEXT,
    order_item_id INT,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TIMESTAMP,
    price NUMERIC,
    freight_value NUMERIC
);

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


-- 1) Overall Busieness Performance Sumary
select sum(p.payment_value) as total_revenue,
count(distinct o.order_id) as total_orders,
count(distinct c.customer_unique_id) as total_customers
from payments p 
join orders o on o.order_id = p.order_id
join customers c on c.customer_id = o.customer_id
where o.order_status = 'delivered';


-- 2) Identify the top 5 months with the highest number of orders
select 
date_trunc('month', o.order_purchase_timestamp) as months,
count(o.order_id) as total_orders
from orders o
where o.order_status = 'delivered'
group by months
order by total_orders desc
limit 5;


--  3) Calculate Average Order Value
select round(sum(p.payment_value)/count(distinct o.order_id ),2) as avg_order_value
from payments p
join orders o 
	on o.order_id = p.order_id
where o.order_status = 'delivered';


-- 4) Calculate total amount spent by each customer
select 
	c.customer_unique_id, 
	sum(p.payment_value) as total_spent 
from customers c 
join orders o 
	on o.customer_id = c.customer_id 
join payments p 
	on p.order_id = o.order_id 
where o.order_status = 'delivered'
group by c.customer_unique_id 
order by total_spent desc;


-- 5) What are the monthly revenue trends over time? 
select
    date_trunc('month', o.order_purchase_timestamp) as months,
    sum(payment_value) as revenue
from orders o
join payments p
    on p.order_id = o.order_id
where o.order_status = 'delivered'
group by months
order by months;

-- 6) Percentage of Repeat Customers
select round(100 * count(*) filter(where total_orders > 1)/ 
count(*),2) || '%' as repeat_customer_percentage
from
 	(select c.customer_unique_id, count(o.order_id) as total_orders
	from customers c
	join orders o 
		on o.customer_id = c.customer_id
	group by c.customer_unique_id
)abc;


-- 7)Calculate average delivery time for all orders
select 
	avg( order_delivered_customer_date - order_purchase_timestamp ) as delivery_time 
from orders
where order_delivered_customer_date is not null;

-- 8)Classify orders based on delivery performance 
select 
	order_id, 
	case 
		when order_status <> 'delivered' 
        then 'not delivered'
		when order_delivered_customer_date > 
		order_estimated_delivery_date 
		then 'late order' 
		else 'on time' 
	end 
	as delivery_status 
from orders;


-- 9)Count late deliveries 
select 
	count(order_id) as late_orders 
from orders 
where order_status='delivered' and
order_delivered_customer_date >
order_estimated_delivery_date;


-- 10) What Percentage of Orders Were Delivered Late? 
select 
	round( 
		100.0 * sum(
		   case 
		   	  when order_delivered_customer_date > 
		order_estimated_delivery_date then 1 
		      else 0 
			end
	)/ count(*), 
	2) as late_delivery_percentage 
from orders
where order_status = 'delivered';


--11) Number of New Customers per Month
with first_order as (
select c.customer_unique_id,
min(order_purchase_timestamp) as first_purchase
from customers c 
join orders o
	on o.customer_id = c.customer_id
group by c.customer_unique_id
)
select date_trunc('month', first_purchase) as months,
count(*) as new_customer
from first_order
group by months
order by months;


--12) Rank customers by toyal spending 
with customers_total as (
	select 
		c.customer_unique_id, 
		sum(p.payment_value) as total_spent 
    from payments p 
	join orders o 
		on o.order_id = p.order_id 
	join customers c
        on c.customer_id = o.customer_id
	group by c.customer_unique_id
) 
select 
	customer_unique_id,
	total_spent, 
	rank() over (order by total_spent desc )
from customers_total;


--13) Month-over-Month Revenue Growth Analysis
with monthly_revenue as (
   select
        date_trunc('month', order_purchase_timestamp) as months, 
        SUM(p.payment_value) as monthly_revenue
    from payments p 
    join orders o 
        on o.order_id = p.order_id 
    group by months
),
lag_revenue as (
    select 
        months, 
        monthly_revenue, 
        LAG(monthly_revenue) OVER (order by months) as previous_month_revenue
    from monthly_revenue
)
select
    months,
    monthly_revenue,
    previous_month_revenue,
round(
((monthly_revenue - previous_month_revenue)
/ nullif(previous_month_revenue,0)) * 100,2
) as growth_percentage
from lag_revenue;


--14) Top 10 Customers by Revenue Contribution
with customer_total as(select 
	c.customer_unique_id, sum(p.payment_value) as total_spent 
from payments p
join orders o
	on p.order_id = o.order_id
JOIN customers c
    ON c.customer_id = o.customer_id
	group by c.customer_unique_id),
	
ranked_revenue as (
select customer_unique_id,total_spent,
rank() over (order by total_spent desc) as spending_rank,
round((total_spent / sum(total_spent) over  ()) * 100,2)
    as contribution_percentage
from customer_total
)
select * from ranked_revenue 
where spending_rank<=10;


--15) Average Order Value by Product Category
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


--16) Month-over-Month Revenue Growth by Product Category
with current_month_rev as(
select sum(o1.price + o1.freight_value) as revenue, date_trunc('month',order_purchase_timestamp)as months,
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
round(((revenue-prev_month)/nullif(prev_month,0))*100,2)
from prev_month_rev
WHERE prev_month IS NOT NULL
order by months;


--17) How many orders did each customer make, and are they a one-time or repeat buyer?
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


--18) Revenue and Order Volume by Customer State
select c.customer_state, count(distinct o1.order_id) as total_orders, sum(o2.price + o2.freight_value) as revenue 
from customers c 
join orders o1 
	on c.customer_id = o1.customer_id
join order_items o2
	on o1.order_id = o2.order_id 
group by c.customer_state
order by revenue desc;


--19)Perform RFM analysis to segment customers based on their purchasing behavior.
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

--20) Which products sold the most units?
select p.product_id, count(*) as total_units_sold 
from  products p
join order_items o
	on p.product_id  = o.product_id
group by p.product_id
order by total_units_sold desc;



