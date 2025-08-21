-- pizza table

drop table if exists pizza;

create table if not exists pizza
(
 pizza_id varchar(30),
 pizza_type_id varchar(30),
 size varchar(10),
 price money
);

select * from pizza;

-- pizza_category table

drop table if exists pizza_category;

create table if not exists pizza_category
(
pizza_type_id varchar(50) primary key,
name varchar(100) not null,
category varchar(100) not null,
ingredients varchar(300)
);

select * from pizza_category;


-- orders table

drop table if exists orders;

create table if not exists orders
(
order_id int primary key,
order_date date not null,
order_time TIME 
);

select * from orders;

-- orders_detail table

drop table if exists orders_detail;

create table if not exists orders_detail
(

order_details_id int not null,
order_id int,
pizza_id varchar(30),
quantity int
);

select * from orders_detail;


--Reterive the total numbers of order placed

SELECT
	COUNT(ORDER_ID)
FROM
	ORDERS;



--Calculated the total revenue generated from the pizza sale
SELECT
	SUM(P.PRICE * O.QUANTITY) AS TOTAL_REVENUE
FROM
	PIZZA P
	JOIN ORDERS_DETAIL O ON O.PIZZA_ID = P.PIZZA_ID;



-- identity the highest price of the pizza
SELECT
	P1.NAME,
	P2.PRICE
FROM
	PIZZA_CATEGORY P1
	JOIN PIZZA P2 ON P2.PIZZA_TYPE_ID = P1.PIZZA_TYPE_ID
ORDER BY
	P2.PRICE DESC LIMIT
	1;
	
-- Identify the most common pizza size ordered
SELECT
	P.SIZE,
	COUNT(O.ORDER_DETAILS_ID) AS MOSTLY_ORDERED
FROM
	PIZZA P
	JOIN ORDERS_DETAIL O ON P.PIZZA_ID = O.PIZZA_ID
GROUP BY
	P.SIZE
ORDER BY
	MOSTLY_ORDERED DESC LIMIT
	1;

--List the top 5 most ordered pizza types along with their quantities.

SELECT
	P2.NAME,
	SUM(O.QUANTITY) AS TOTAL
FROM
	PIZZA_CATEGORY P2
	JOIN PIZZA P1 ON P1.PIZZA_TYPE_ID = P2.PIZZA_TYPE_ID
	JOIN ORDERS_DETAIL O ON O.PIZZA_ID = P1.PIZZA_ID
GROUP BY
	P2.NAME
ORDER BY
	TOTAL DESC LIMIT
	5;

--Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT
	P1.CATEGORY,
	SUM(O.QUANTITY) AS TOTAL_SALE
FROM
	PIZZA_CATEGORY P1
	JOIN PIZZA P2 ON P1.PIZZA_TYPE_ID = P2.PIZZA_TYPE_ID
	JOIN ORDERS_DETAIL O ON P2.PIZZA_ID = O.PIZZA_ID
GROUP BY
	P1.CATEGORY
ORDER BY
	TOTAL_SALE DESC;

--Determine the distribution of orders by hour of the day.


SELECT
	HOUR (ORDER_TIME),
	COUNT(ORDER_ID) AS TOTAL_SALE
FROM
	ORDERS
GROUP BY
	HOUR (ORDER_TIME)
ORDER BY
	TOTAL_SALE DESC;



--Join relevant tables to find the category-wise distribution of pizzas.

SELECT
	CATEGORY,
	COUNT(NAME)
FROM
	PIZZA_CATEGORY
GROUP BY
	CATEGORY
ORDER BY
	COUNT DESC;

--Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT
	AVG(QUANTITY)::NUMERIC(10, 2)
FROM
	(
		SELECT
			O1.ORDER_DATE,
			SUM(O2.QUANTITY) AS QUANTITY
		FROM
			ORDERS O1
			JOIN ORDERS_DETAIL O2 ON O1.ORDER_ID = O2.ORDER_ID
		GROUP BY
			O1.ORDER_DATE
	) AS ORDER_QUANTITY;

--Determine the top 3 most ordered pizza types based on revenue.

SELECT
	P2.NAME,
	SUM(O.QUANTITY * P1.PRICE) AS REVENUE
FROM
	PIZZA_CATEGORY P2
	JOIN PIZZA P1 ON P1.PIZZA_TYPE_ID = P2.PIZZA_TYPE_ID
	JOIN ORDERS_DETAIL O ON P1.PIZZA_ID = O.PIZZA_ID
GROUP BY
	P2.NAME
ORDER BY
	REVENUE DESC LIMIT
	3;

--Calculate the percentage contribution of each pizza type to total revenue.

SELECT
	P2.category,
	(SUM(O.QUANTITY * P1.PRICE) / (SELECT
	SUM(P1.PRICE * O.QUANTITY) AS TOTAL_REVENUE
FROM
	PIZZA P1
	JOIN ORDERS_DETAIL O ON O.PIZZA_ID = P1.PIZZA_ID) *100)::numeric(10,2) as revenue
FROM
	PIZZA_CATEGORY P2
	JOIN PIZZA P1 ON P1.PIZZA_TYPE_ID = P2.PIZZA_TYPE_ID
	JOIN ORDERS_DETAIL O ON P1.PIZZA_ID = O.PIZZA_ID
GROUP BY
	P2.category
ORDER BY
	REVENUE DESC LIMIT
	3;

--Analyze the cumulative revenue generated over time.
SELECT
	ORDER_DATE,
	SUM(REVENUE) OVER (
		ORDER BY
			ORDER_DATE
	) AS CUM_REVENUE
FROM
	(
		SELECT
			O1.ORDER_DATE,
			SUM(O2.QUANTITY * P.PRICE) AS REVENUE
		FROM
			ORDERS_DETAIL O2
			JOIN PIZZA P ON O2.PIZZA_ID = P.PIZZA_ID
			JOIN ORDERS O1 ON O1.ORDER_ID = O2.ORDER_ID
		GROUP BY
			O1.ORDER_DATE
	) AS SALES;

--Determine the top 3 most ordered pizza types based on revenue for each pizza category.	
select category, name, revenue, rank
from
(SELECT CATEGORY,NAME,REVENUE,
	RANK() OVER (PARTITION BY CATEGORY ORDER BY REVENUE ) AS RANK
FROM
	(
		SELECT
			P2.CATEGORY,
			P2.NAME,
			SUM(O.QUANTITY * P1.PRICE) AS REVENUE
		FROM
			PIZZA_CATEGORY P2
			JOIN PIZZA P1 ON P1.PIZZA_TYPE_ID = P2.PIZZA_TYPE_ID
			JOIN ORDERS_DETAIL O ON O.PIZZA_ID = P1.PIZZA_ID
		GROUP BY
			P2,
			CATEGORY,
			P2.NAME) AS A) as B
			where rank <=3;
	












