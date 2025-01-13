-- Pizza Sales Analysis
-- SQL Project

-- Database Schema
-- Create Database

create database pizza_sales_analysis;
use pizza_sales_analysis;


-- Import data into tables from the csv files

-- Now we will analyze the Pizza Sales data
-- We will try to answer the following questions for analysis


-- Q1 --> Retrieve the total number of orders placed
select count(order_id) from orders;


-- Q2 --> Calculate the total revenue generated from pizza sales
select round(sum(order_details.quantity * pizzas.price), 2) as Total_Sales from order_details
join pizzas
on order_details.pizza_id = pizzas.pizza_id;


-- Q3 --> Identify the highest-priced pizza
select pizza_types.name, pizzas.size from pizzas
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc
limit 1;


-- Q4 --> Identify the most common pizza size ordered
select pizzas.size, count(pizzas.size) from pizzas
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
order by count(pizzas.size) desc;


-- Q5 --> List the top 5 most ordered pizza types along with their quantities
select pizza_types.name, sum(order_details.quantity) from order_details
join pizzas
on order_details.pizza_id = pizzas.pizza_id
join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by pizza_types.name
order by sum(order_details.quantity) desc
limit 5;


-- Q6 --> Join the necessary tables to find the total quantity of each pizza category ordered
select pizza_types.category, sum(order_details.quantity) from order_details
join pizzas
on order_details.pizza_id = pizzas.pizza_id
join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by pizza_types.category;


-- Q7 --> Determine the distribution of orders by hour of the day
select hour(order_time) as Hour, count(order_id) as Order_count from orders
group by hour(order_time)
order by hour(order_time) asc;


-- Q8 --> Join relevant tables to find the category-wise distribution of pizzas
select category, count(name) from pizza_types
group by category;


-- Q9 --> Group the orders by date and calculate the average number of pizzas ordered per day
select avg(quantity) as Orders_per_day from 
(select orders.order_date, sum(order_details.quantity) as quantity
from order_details
join orders
on orders.order_id = order_details.order_id
group by order_date) as total_orders_per_day;


-- Q10 --> Determine the top 3 most ordered pizza types based on revenue
select pizza_types.name, sum(pizzas.price * order_details.quantity) as revenue from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.name
order by revenue desc
limit 3;


-- Q11 --> Calculate the percentage contribution of each pizza type to total revenue
select pizza_types.category, 
(sum(pizzas.price * order_details.quantity) / 
(select sum(pizzas.price * order_details.quantity) from order_details
join pizzas
on order_details.pizza_id = pizzas.pizza_id)) * 100

as revenue from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category;


-- Q12 --> Analyze the cumulative revenue generated over time
select order_date, sum(revenue) over(order by order_date) from 
(select orders.order_date, sum(order_details.quantity * pizzas.price) as revenue
from order_details
join orders
on orders.order_id = order_details.order_id 
join pizzas
on order_details.pizza_id = pizzas.pizza_id
group by orders.order_date) as total_sales;


-- Q13 --> Determine the top 3 most ordered pizza types based on revenue for each pizza category
select * from 
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as ranking
from  

(select pizza_types.category, pizza_types.name, sum(pizzas.price * order_details.quantity) as revenue
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category, pizza_types.name
order by category, revenue desc) as a) as b
where ranking <= 3;


