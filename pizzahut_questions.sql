use pizzahut ;

-- Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS totel_orders
FROM
    orders;

-- Calculate the total revenue generated from pizza sales.
select * from order_details;
select* from pizzas;

SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS totel_revenue
FROM
    order_details od
        INNER JOIN
    pizzas p ON od.pizza_id = p.pizza_id; 


-- Identify the highest-priced pizza.

select * from pizza_types;

SELECT 
    pt.name, p.price AS highest_price
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1; 

-- Identify the most common pizza size ordered.
 
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

select* from order_details;

select quantity, count(order_details_id)
from order_details group by quantity;

-- List the top 5 most ordered pizza types along with their quantities.
 
SELECT 
    p.pizza_type_id, pt.name, SUM(od.quantity) AS total
FROM
    pizzas p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od USING (pizza_id)
GROUP BY p.pizza_type_id , pt.name
ORDER BY total DESC
LIMIT 5;


-- Intermediate:

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category, SUM(od.quantity) AS totel_quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY totel_quantity DESC;

-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

#138 ordered pizza /day 

SELECT 
    ROUND(AVG(pizza_quantity), 0) as avg_pizza_ordered_pr_day
FROM
   ( SELECT 
        o.order_date, SUM(od.quantity) AS pizza_quantity
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS order_quantity ;

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pt.name, SUM(od.quantity * p.price) AS revenue
FROM
    pizzas p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3; 



-- Advanced:

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.category,
    ROUND(SUM(od.quantity * p.price) / (SELECT 
                    SUM(od.quantity * p.price) AS totel_revenue
                FROM
                    order_details od
                        JOIN
                    pizzas p ON p.pizza_id = od.pizza_id) * 100,
            2) AS totel_revenue_percentage
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY totel_revenue_percentage DESC;

-- Analyze the cumulative revenue generated over time.

select order_date,
sum(revenue) over(order by order_date)as cumulative_revenue 
from
(select o.order_date,
round(sum(od.quantity*p.price),2) as revenue
from order_details od join pizzas p on od.pizza_id = p.pizza_id
join orders o on o.order_id = od.order_id
group by o.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, revenue from 
(select category , name, revenue,
rank() over(partition by category order by revenue desc) as ranks
from
(select pt.category, pt.name, 
sum((od.quantity) * p.price) as revenue
from pizza_types pt join pizzas p 
on pt.pizza_type_id = p.pizza_type_id
join order_details od
on od.pizza_id = p.pizza_id
group by pt.category, pt.name) as sales) as b
where ranks <= 3;