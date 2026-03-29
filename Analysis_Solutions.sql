--Monday Coffee Data Analysis---

SELECT * FROM city;
SELECT * FROM products;
SELECT * FROM customers;
SELECT * FROM sales;


-- REPORTS AND DATA ANALYSIS---

--1.How many people in each city are estimated to consume coffee , given that 25% of the population does--
SELECT ci.city_id , ci.city_name  ,ROUND((population*0.25)/1000000,2) AS consumers_in_million
FROM city ci
LEFT JOIN customers c
ON ci.city_id = c.city_id
GROUP BY ci.city_id
ORDER BY consumers_in_million DESC;

--2.Total revenue generated from coffee sales across all cities in the last quarter of 2023
SELECT ci.city_name , SUM(s.TOTAL) AS city_revenue
FROM city ci
JOIN customers cs
ON ci.city_id = cs.city_id
JOIN sales s
ON cs.customer_id = s.customer_id
WHERE EXTRACT(YEAR FROM s.sale_date::DATE) = 2023 AND EXTRACT(MONTH FROM s.sale_date::DATE) IN(10,11,12)
GROUP BY ci.city_name ;

--3.How many units of each coffee product have been sold--

SELECT  p.product_id,p.product_name, COUNT(p.product_id) AS product_units
FROM products p
LEFT JOIN sales s
ON p.product_id = s.product_id
GROUP BY p.product_id
ORDER BY 1;

--4.Average sales amount per customer in each city --

SELECT ci.city_id , ci.city_name  ,
       COUNT(DISTINCT c.customer_id) AS customer_count_city,
	   ROUND(SUM(s.total)::NUMERIC,2) AS city_revenue_sum,
	   ROUND((SUM(s.total)/COUNT(DISTINCT c.customer_id))::NUMERIC,2) AS avg_cust_city
	   
FROM city ci
LEFT JOIN customers c
ON ci.city_id = c.city_id
LEFT JOIN sales s
ON c.customer_id = s.customer_id
GROUP BY ci.city_id
ORDER BY avg_cust_city DESC;


--5.Provide a list of cities along with their populations and estimated coffee consumers(25% of the population does)

SELECT ci.city_id , ci.city_name , 
       ROUND((population/1000000),2) AS popln_in_million ,
	   ROUND((population*0.25)/1000000,2) AS consumers_in_million ,
	   COUNT(DISTINCT(c.customer_id)) AS unique_consumers
FROM city ci
JOIN customers c
ON ci.city_id = c.city_id
INNER JOIN sales s
ON c.customer_id = s.customer_id
GROUP BY ci.city_id
ORDER BY unique_consumers DESC;


-- 6.Top 3 selling products in each city based on sales volume--

SELECT cit.city_name , p.product_name , COUNT(s.sale_id) AS total_orders
       , DENSE_RANK() OVER(PARTITION BY city_name ORDER BY COUNT(s.sale_id) DESC) AS rank
FROM products p
JOIN sales s
ON s.product_id = p.product_id
JOIN customers c
ON s.customer_id = s.customer_id
JOIN city cit
ON cit.city_id = c.city_id
GROUP BY 1,2;

SELECT * FROM 
(
SELECT cit.city_name , p.product_name , COUNT(s.sale_id) AS total_orders
       , DENSE_RANK() OVER(PARTITION BY city_name ORDER BY COUNT(s.sale_id) DESC) AS rank
FROM products p
JOIN sales s
ON s.product_id = p.product_id
JOIN customers c
ON s.customer_id = s.customer_id
JOIN city cit
ON cit.city_id = c.city_id
GROUP BY 1,2
) AS t1
WHERE rank<=3;


--7.How many unique customers are there in each city who have purchased coffee products--
SELECT ci.city_name , COUNT(DISTINCT c.customer_id) AS unique_customers
FROM city ci
LEFT JOIN customers c
ON ci.city_id = c.city_id
JOIN sales s
ON s.customer_id = c.customer_id
GROUP BY ci.city_name;

--8. Find each city and their average sale pr customer and avg rent per customer--


SELECT ci.city_name , 
       ROUND( (SUM(total)/COUNT(DISTINCT c.customer_id))::NUMERIC,2) AS per_cust_avgsale ,
	   ROUND(
	   (ci.estimated_rent/COUNT(DISTINCT c.customer_id ))::NUMERIC,
	   2) AS rent_per_cust
FROM city ci
LEFT JOIN customers c
ON c.city_id = ci.city_id
JOIN sales s
ON s.customer_id = c.customer_id
GROUP BY ci.estimated_rent,
         ci.city_name
ORDER BY 2 DESC , 3 DESC;


--9.Monthly sales growth
   -- sales growth rate : percentage growth or decline in sales over different time periods(monthly) for each city--
WITH 
monthly_sales
AS
(SELECT ci.city_name , 
       EXTRACT(YEAR FROM sale_date::DATE) AS YEAR,
       EXTRACT(MONTH FROM sale_date::DATE) AS MONTH,
	   SUM(total) AS month_sales
	   
FROM city ci
LEFT JOIN customers c
ON ci.city_id = c.city_id
JOIN sales s
ON c.customer_id = s.customer_id
GROUP BY year , month , ci.city_name
ORDER BY 1,2,3
),
growth_ratio
AS 
(
SELECT 
      city_name,
	  month,
	  year,
	  month_sales as cr_month_sale,
	  LAG(month_sales , 1) OVER(PARTITION BY city_name ORDER BY YEAR,MONTH)AS last_month_sale
	  
FROM monthly_sales
)
SELECT 
      city_name,
	  month,
	  year,
	  cr_month_sale,
	  last_month_sale,
	 ROUND(
	 (cr_month_sale-last_month_sale)::NUMERIC/last_month_sale::NUMERIC * 100
	 ,2
	 ) as growth_ratio
FROM growth_ratio
WHERE 
     last_month_sale IS NOT NULL;


--10.Market Potential Analysis
   --Identify top 3 city based on highest sales , return city name , total sale , total rent , total customers , estimated coffee consumer

	  

SELECT ci.city_name , 
       SUM(total) AS total_revenue,
       ROUND( (SUM(total)/COUNT(DISTINCT c.customer_id))::NUMERIC,2) AS per_cust_avgsale ,
	   estimated_rent AS total_rent,
	   ROUND(
	   (ci.estimated_rent/COUNT(DISTINCT c.customer_id ))::NUMERIC,
	   2) AS rent_per_cust,
	   COUNT(DISTINCT c.customer_id) AS unique_customers,
	   ROUND((ci.Population*0.25)::NUMERIC/1000000 ,2)AS estimated_coffee_consumers_in_millions
	   
	   
FROM city ci
LEFT JOIN customers c
ON c.city_id = ci.city_id
JOIN sales s
ON s.customer_id = c.customer_id
GROUP BY ci.estimated_rent,
         ci.population,
         ci.city_name
ORDER BY 2 DESC;

/*
--Recomendation
City 1 : Pune
    avg rent per customer is low
    highest total revenue
    avg sale per customer is also high

city 2 : Delhi
    highest estimated coffee consumers
    highest total costuemrs
    average rent per costumer low

city 3 : jaipur
    highest number of costuemrs 69
    avg rent per customer is less
    avg sale per customer is better which is at 11.6k



 
 













