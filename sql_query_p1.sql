-- SQL Retail Sales Analysis - P1
CREATE DATABASE sql_project_p1;

USE sql_project_p1;

-- CREATE TABLE 	
CREATE TABLE retail_sales
		(
			transactions_id INT PRIMARY KEY,
			sale_date DATE,
			sale_time TIME,
			customer_id	INT,
			gender VARCHAR(15),
			age	INT,
			category VARCHAR(15),	
			quantiy INT,
			price_per_unit FLOAT,	
			cogs FLOAT,
			total_sale FLOAT
		);

-- ALTER COLUMN NAME
ALTER TABLE retail_sales RENAME COLUMN quantiy to quantity;

-- Data Exploration & Cleaning
SELECT * FROM retail_sales
LIMIT 10; 

SELECT count(*) as total_sales
FROM retail_sales;

-- How many unique customers we have?
SELECT count(DISTINCT customer_id) as total_customers
FROM retail_sales;

SELECT DISTINCT category 
FROM retail_sales;

SELECT * FROM retail_sales
WHERE
	transactions_id IS NULL
    OR
    sale_date IS NULL
    OR
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantiy IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;
    
DELETE FROM retail_sales
WHERE 
	transactions_id IS NULL
    OR
    sale_date IS NULL
    OR
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantiy IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;
    
-- Data Analysis & Business Key Problems & Answers
-- The following SQL queries were developed to answer specific business questions:

-- Q1 WAQ to retrieve all columns for sales made on '2022-11-05' 
SELECT * FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Q2 WAQ retrieve all transactions where the category is 'clothing' and the quantity sold is more than 4 in the month of Nov-2022
SELECT *
FROM retail_sales
WHERE category = 'clothing' 
	AND quantity >= 4
    AND sale_date >= '2022-11-01'
    AND sale_date <= '2022-11-30';
    
-- Q3 WAQ to calculate the total sales (total_sale) for each category
SELECT category, sum(total_sale) as net_sale, count(*) as total_orders
FROM retail_sales
GROUP BY category;

-- Q4 WAQ to find the qverage age of customers who purchased items from the 'Beauty' category
SELECT ROUND(AVG(age),2) as avg_age 
FROM retail_sales 
WHERE category = 'beauty';

-- Q5 WAQ to find all transactions where the total_sale is greater than 1000
SELECT * FROM retail_sales
WHERE total_sale > 1000;

-- Q6 WAQ to find the total numbers of transactions (transaction_id) made by each gender in each category 
SELECT count(*) as total_trans_id, gender, category
FROM retail_sales
GROUP BY gender, category
ORDER BY category;

-- Q7 WAQ to calculate the average sale for each month. Find out best selling month in each year
SELECT year, month, avg_sale 
FROM
(
SELECT extract(year FROM sale_date) as year, extract(month FROM sale_date) as month, round(avg(total_sale),2) as avg_sale,
RANK() OVER(partition by extract(year FROM sale_date) ORDER BY avg(total_sale) DESC) as rnk
FROM retail_sales
GROUP BY year, month
) as t1
WHERE rnk = 1;

-- Q8 WAQ to find the top 5 customers based on the highest total sales
SELECT customer_id, SUM(total_sale) as highest_sale
FROM retail_sales 
GROUP BY customer_id
ORDER BY highest_sale DESC
LIMIT 5;

-- Q9 WAQ to find the number of unique customers who puchased items from each category
SELECT category, COUNT(DISTINCT customer_id) as unique_cust
FROM retail_sales
GROUP BY category;

-- Q10 WAQ to create each shift and number of orders (Example Morning <= 12, Afternoon between 12 & 17, Evening > 17)
WITH hourly_sale
as
(
SELECT *,
	CASE 
		WHEN EXTRACT(hour FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(hour FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
	END as shift
FROM retail_sales
)
SELECT shift, COUNT(*) as total_orders
FROM hourly_sale
GROUP BY shift
