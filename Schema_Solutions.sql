--Monday Coffee SCHEMA

DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS city;

CREATE TABLE city(
             city_id INT PRIMARY KEY,
			 city_name VARCHAR(15),
			 population BIGINT ,
			 estimated_rent FLOAT,
			 city_rank INT

);

CREATE TABLE customers(
             customer_id INT PRIMARY KEY,
			 customer_name VARCHAR(50),
			 city_id INT,
			 FOREIGN KEY(city_id)REFERENCES city(city_id) ON DELETE CASCADE

);

CREATE TABLE products(
             product_id INT PRIMARY KEY,
			 product_name VARCHAR(50),
			 price FLOAT
);

CREATE TABLE sales(
             sale_id INT PRIMARY KEY,
			 sale_date TEXT,
			 product_id INT,
			 customer_id INT,
			 total FLOAT,
			 rating INT,
			 FOREIGN KEY(product_id)REFERENCES products(product_id) ON DELETE CASCADE,
			 FOREIGN KEY(customer_id)REFERENCES customers(customer_id) ON DELETE CASCADE

);

--IMPORT RULES--
--1st import city file 
--2nd import products file
--3rd import customers file
--4th import sales file

--END OF SCHEMA---














