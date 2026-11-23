select *
from customer_analysis.customer_shopping_behavior_clean;

-- Q1. what is the total_amount purchased but male vs female
select
gender,
SUM(purchase_amount) as total_purchase_amount
from customer_analysis.customer_shopping_behavior_clean
group by gender;

-- Q2. which customer used discount but still paid more than the average price
select 
customer_id,
purchase_amount
from customer_analysis.customer_shopping_behavior_clean
where discount_applied='Yes' and purchase_amount>(select
AVG(purchase_amount)
from customer_analysis.customer_shopping_behavior_clean
);

-- Q3. which are the top 5 products with the hightest avg review rating
select
item_purchased,
round(avg(review_rating),2) as 'Average_product_review'
from customer_analysis.customer_shopping_behavior_clean
group by item_purchased
order by avg(review_rating) desc
limit 5;

-- Q4. compare the avg purchase amount between standard and express shipping.
select
shipping_type,
avg(purchase_amount) as 'Avg_shipping'
from customer_analysis.customer_shopping_behavior_clean
where shipping_type='Express' or shipping_type='Standard'
group by shipping_type;


-- Q5. compare the avg spend and total_revenue between subscribers and non-subscribers.
select
subscription_status,
count(customer_id) as 'total_customers',
avg(purchase_amount) as 'Average Spend',
sum(purchase_amount) as 'Total revenue'
from customer_analysis.customer_shopping_behavior_clean
group by subscription_status;

-- Q6.which five product have highest percentage of purchases with discount applied?

select 
item_purchased,
round(sum(case when discount_applied='Yes' then 1 else 0 end)/count(*) *100,2) as percent_purchase
from customer_analysis.customer_shopping_behavior_clean
group by item_purchased
order by percent_purchase desc
limit 5;



-- Q7. classify the customers into new,returning,loyal based on thier total no. of previous purchases.show the count of each segment
with customer_Type as
(
	select customer_id, previous_purchases,
    case when previous_purchases=1 then 'New'
    when previous_purchases between 2 and 10 then 'Returning'
    else 'loyal'
    end as customer_segment
    from customer_analysis.customer_shopping_behavior_clean
)
select
customer_segment,
count(*) as 'Customer_count'
from customer_type
group by customer_segment;

-- Q8. what are the top 3 most purchased products within each category?

with item_count as
(
	select category,
    item_purchased,
    count(customer_id) as total_orders,
    row_number() over(partition by category order by count(customer_id)) as item_rank
    from customer_analysis.customer_shopping_behavior_clean
    group by category,item_purchased
)
select item_rank,category, item_purchased,total_orders
from item_count
where item_rank<=3;

-- Q9. are repeat customers subscribers also?
select 
subscription_status,
count(customer_id) as repeat_cust
from customer_analysis.customer_shopping_behavior_clean
where previous_purchases>5
group by subscription_status;

-- Q10. revenue contribution of each age group

with revenue as
(
	select 
    age_group,
    sum(purchase_amount) as revenue_per_age
    from customer_analysis.customer_shopping_behavior_clean
    group by age_group
)
select
age_group,
ROUND(revenue_per_age * 100.0 / SUM(revenue_per_age) OVER(), 2) AS revenue_contri
from revenue
ORDER BY revenue_contri DESC;