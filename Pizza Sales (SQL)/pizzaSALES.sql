-- creating databse
CREATE DATABASE pizzahut;

-- using databse
USE pizzahut;

-- creating pizzas table and importing data
CREATE TABLE pizzas(
	pizza_id VARCHAR(150),
    pizza_type_id VARCHAR(200),
    size VARCHAR(10),
    price DOUBLE);
    
SELECT * FROM pizzas;

-- creating pizza_types table and importing data
CREATE TABLE pizza_types(
	pizza_type_id VARCHAR(200),
    name VARCHAR(100),
    category VARCHAR(100),
    ingredients VARCHAR(500));

SELECT * FROM pizza_types;

-- creating orders table and importing data
CREATE TABLE orders(
	order_id INT NOT NULL PRIMARY KEY,
    date DATE,
    time TIME );

SELECT * FROM orders;

-- creating order_details table and importing data
CREATE TABLE order_details(
	order_detail_id INT NOT NULL PRIMARY KEY,
    order_id INT,
    pizza_id VARCHAR(100),
    quantity INT);

SELECT * FROM order_details;



-- Retrieving the total no. of order placed
SELECT COUNT(order_id) AS total_orders FROM orders;

-- calculating the total revanue generated from the pizza sales
SELECT ROUND(SUM(od.quantity * p.price) ,2)
	FROM order_details od
    JOIN pizzas p
    ON od.pizza_id = p.pizza_id;

-- identifying the hieghest priced pizza
SELECT * FROM pizzas 
	ORDER BY price DESC LIMIT 1;

SELECT p.pizza_id, pt.name, p.price
	FROM pizza_types pt
    JOIN pizzas p 
    ON pt.pizza_type_id = p.pizza_type_id
    ORDER BY p.price DESC LIMIT 1;

-- identifying the most common pizza size ordered
SELECT p.size, COUNT(od.order_detail_id) AS total_orders
	FROM order_details od
    JOIN pizzas p 
    ON od.pizza_id = p.pizza_id
    GROUP BY p.size
    ORDER BY total_orders DESC LIMIT 1;

-- listing top 5 most ordered pizza types along with there quentities
SELECT pt.name, SUM(od.quantity) AS quantity
	FROM pizza_types pt
    JOIN pizzas p
    ON pt.pizza_type_id = p.pizza_type_id
    JOIN order_details od
    ON od.pizza_id = p.pizza_id
    GROUP BY pt.name
    ORDER BY quantity DESC LIMIT 5;

-- joining the necessary tables to find the total quantity each pizza ordered
SELECT  pt.name, SUM(od.quantity) AS quantity
	FROM pizza_types pt
    JOIN pizzas p
    ON pt.pizza_type_id = p.pizza_type_id
    JOIN order_details od
    ON od.pizza_id = p.pizza_id
    GROUP BY pt.name;

-- joining the necessary tables to find the total quantity each pizza category ordered
SELECT pt.category, SUM(od.quantity)
	FROM pizza_types pt
    JOIN pizzas p
	ON pt.pizza_type_id = p.pizza_type_id
    JOIN order_details od
    ON od.pizza_id = p.pizza_id
    GROUP BY pt.category;

-- determining the distribution of orders by hour of the day
SELECT HOUR(time) AS hours, COUNT(order_id) AS order_counts
	FROM orders
    GROUP BY hours;

-- joining relevent table to find the category-wise distribution of pizzas
SELECT category, COUNT(name) FROM pizza_types
	GROUP BY category;

-- grouping the orders by date and calculate the average number of pizza ordered per day
SELECT ROUND(AVG(quantity), 0) AS avg_sale_per_day FROM 
	(SELECT o.date, SUM(od.quantity) AS quantity
		FROM orders o
		JOIN
		order_details od
		ON o.order_id = od.order_id
		GROUP BY o.date) AS order_quantity;

-- determining the top 3 most ordered pizza types based on revenue
SELECT pt.name AS name, SUM(od.quantity * p.price) AS revenue
	FROM pizza_types pt
    JOIN
    pizzas p
    ON p.pizza_type_id = pt.pizza_type_id
    JOIN
    order_details od
    ON p.pizza_id = od.pizza_id
    GROUP BY name
    ORDER BY revenue DESC LIMIT 3;

-- calculating the percentage contribution of each pizza type to total revenue
SELECT pt.category, ROUND(SUM(od.quantity * p.price) / 
	(SELECT ROUND(SUM(od.quantity * p.price), 2)AS total_revenue
    FROM order_details od
    JOIN pizzas p
    ON od.pizza_id = p.pizza_id) * 100, 2) as revenue_per_category
    FROM pizza_types pt
    JOIN pizzas p 
    ON p.pizza_type_id = pt.pizza_type_id
    JOIN order_details od
    ON od.pizza_id = p.pizza_id
    GROUP BY pt.category;
    
-- analysing the cumulative revenue generated over time
SELECT date, SUM(revenue) OVER(ORDER BY date) AS cum_revenue
	FROM
    (SELECT o.date, SUM(od.quantity * p.price) AS revenue
    FROM order_details od
    JOIN
    pizzas p 
    ON p.pizza_id = od.pizza_id
    JOIN
    orders o
    ON o.order_id = od.order_id
    GROUP BY o.date) AS sales;

-- determining the top 3 most ordered pizza types based on revenue for each pizza category
SELECT category, name, revenue
	FROM
	(SELECT category, name, revenue,
		RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn
		FROM
		(SELECT pt.category, pt.name, SUM(od.quantity * p.price) AS revenue
			FROM pizza_types pt
			JOIN
			pizzas p
			ON p.pizza_type_id = pt.pizza_type_id
			JOIN
			order_details od
			ON od.pizza_id = p.pizza_id
			GROUP BY pt.category, pt.name) AS a) AS b
			WHERE rn <= 3;