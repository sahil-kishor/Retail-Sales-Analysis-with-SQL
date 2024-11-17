---Retail Sales Analysis with SQL

-- Creating TABLE

CREATE TABLE retail_sales
			(
			transactions_id INT PRIMARY KEY,
			sale_date DATE,
			sale_time TIME,
			customer_id INT,
			gender VARCHAR(15),
			age INT,
			category VARCHAR(15),
			quantiy INT,
			price_per_unit FLOAT,
			cogs FLOAT ,
			total_sale FLOAT
			)
---DataSet overview

SELECT *  FROM retail_sales
LIMIT 10

---

SELECT COUNT(*) FROM retail_sales
---
---Checking for null values 

SELECT * FROM retail_sales
WHERE 
	transactions_id  IS NULL
	or
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR 
	age IS NULL
	OR
	category IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;

--- Handling Null Values by ermoving the rows with less number of null values

DELETE FROM retail_sales
WHERE 
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;

---

SELECT COUNT(*) 
FROM retail_sales

--- Imuting null values in the 'age' column with Median
-- calculate the median value

WITH MedianCTE AS(			
	SELECT
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY age) AS median_age
	FROM retail_sales
	WHERE age IS NOT NULL		
)								--CTE for calculating Median

-- updating the null values

UPDATE retail_sales
SET age = (SELECT median_age FROM MedianCTE LIMIT 1)
WHERE age IS NULL;

--- Cheking the Updated Data

SELECT COUNT(*)
FROM retail_sales
---
SELECT * FROM retail_sales
WHERE age IS NULL

--- Data Exploration

---  Total Number of sales?
SELECT COUNT(*) AS total_sales
FROM retail_sales

--- How many unique/distinct customers we have

SELECT COUNT(DISTINCT customer_id) AS total_sale
FROM retail_sales

--- Differnt types of category

SELECT category, COUNT(*) AS total_count
FROM retail_sales
GROUP BY category
ORDER BY total_count DESC

-- Renaming the Quantity Column with the corect name

ALTER TABLE retail_sales 
RENAME COLUMN quantiy TO quantity

--- Data Analysis & Business Key Problems

-- 1. Write a SQL query to retrieve all columns for sales made on '2022-11-05':

SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- 2. Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold 
--	  is more or equal to 4  in the month of Nov-2022:

SELECT *
FROM retail_sales
WHERE category = 'Clothing' 
	  AND
	  TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
	  AND
	  quantity >= 4

-- Q3. Write a SQL query to calculate the total sales (total_sale) for each category.:

SELECT category, 
	   SUM(quantity) AS quantity_sold, 
	   COUNT(*) AS total_orders, 
	   SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY category
ORDER BY total_sales DESC;

-- Q4. Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.:

SELECT ROUND(AVG(age), 2) AS average_customer_age
FROM retail_sales
WHERE category = 'Beauty'

-- Q5. Write a SQL query to find all transactions where the total_sale is greater than 1000.:

SELECT *
FROM retail_sales
WHERE total_sale > 1000;

-- Q6. Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.:

SELECT category, 
	   gender, 
	   COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY total_transactions DESC;

-- Q7. Write a SQL query to calculate the average sale for each month. Find out best selling month in each year:

WITH avg_sales AS (			--- CTE to rank the sales according to year
	SELECT
		EXTRACT(YEAR FROM sale_date) AS sale_year,
		EXTRACT(MONTH FROM sale_date) AS sale_month,
		ROUND(CAST(AVG(total_sale)AS numeric),2) AS average_sale,
		RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS RANK -- Windows function to rank sales
	FROM retail_sales
	GROUP BY 1, 2
	)
	
---Query to show the month with Highest sales
SELECT 
	sale_year,
	sale_month,
	average_sale
FROM avg_sales
WHERE rank = 1;

-- Q8. Write a SQL query to find the top 5 customers based on the highest total sales:

SELECT
	customer_id,
	SUM(total_sale) AS total_sale
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sale DESC
LIMIT 5;

-- Q9. Write a SQL query to find the number of unique customers who purchased items from each category.:

SELECT
	category,
	COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category
ORDER BY unique_customers DESC;

-- Q10. Write a SQL query to create each shift and number of orders (Example Morning <12, 
--      Afternoon Between 12 & 17, Evening >17):

WITH hourly_sales AS (			--- CTE to segment the sale according to time(shift)
	SELECT *,
		CASE
			WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
			WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
			ELSE 'Evening'
		END AS shift
	FROM retail_sales
	)

SELECT
	shift,
	COUNT(*) AS total_orders
FROM hourly_sales
GROUP BY shift;

-- Q11. Write a SQL query to find the number of unique customers who have purchased items from all three specified 
--      categories (e.g., 'Category1', 'Category2', and 'Category3') in the retail_sales table.

SELECT
	COUNT(*) AS unique_customers
FROM (
	SELECT 
		customer_id
	FROM
		retail_sales
	GROUP BY 
		customer_id
	HAVING
		COUNT(DISTINCT category) = (
									SELECT
									COUNT(DISTINCT category)
									FROM retail_sales
									)
	) AS subquery;

-- Q12.  Write a SQL query to calculate the total sales and the average number of purchases per customer to 
-- 		 identify the top 10 customers with the highest lifetime value (CLV).

SELECT
	customer_id,
	SUM(total_sale) AS total_sales,
	COUNT(*) AS number_of_purchases,
	ROUND(COUNT(*) :: numeric / COUNT(DISTINCT customer_id), 2) AS avg_number_of_purchase,
	ROUND(AVG(total_sale) :: numeric, 2) AS avg_purchase_amt
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 10;

-- Q13. Write a SQL query to classify customers into different segments based on their total number of purchases 
--		and average spending per transaction.

SELECT
	customer_id,
	COUNT(*) AS total_purchase,
	ROUND(AVG(total_sale):: numeric, 2) AS avg_amt_per_transaction, 
	SUM(total_sale) AS total_sales,
	CASE
		WHEN COUNT(*) > 10 AND AVG(total_sale) > 500 THEN 'High Spender & Frequent Buyer'
		WHEN COUNT(*) > 10 THEN 'Frequent Buyer'
		WHEN AVG(total_sale) > 500 THEN 'High Spender'
		ELSE 'Standard Customer'
	END AS customer_segment
FROM retail_sales
GROUP BY customer_id;

-- (Part 2) Q13. 1. Check the percentage of customer in each segment:

WITH segments AS (
	SELECT
		customer_id,
		COUNT(*) AS total_purchase,
		ROUND(AVG(total_sale):: numeric, 2) AS avg_amt_per_transaction, 
		SUM(total_sale) AS total_sales,
		CASE
			WHEN COUNT(*) > 10 AND AVG(total_sale) > 500 THEN 'High Spender & Frequent Buyer'
			WHEN COUNT(*) > 10 THEN 'Frequent Buyer'
			WHEN AVG(total_sale) > 500 THEN 'High Spender'
			ELSE 'Standard Customer'
		END AS customer_segment
	FROM retail_sales
	GROUP BY customer_id
	)
		
SELECT 
    customer_segment,
    COUNT(*) AS num_customers,
    ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()), 2) AS percentage_of_customers,
    ROUND(AVG(total_sales)::numeric, 2) AS avg_sales_per_segment
FROM 
    segments
GROUP BY
    customer_segment;

-- Q14. Write a SQL query to identify the best-selling product category in terms of both quantity sold 
--		and total sales revenue.

SELECT
	category,
	SUM(quantity) AS sale_quantity,
	SUM(total_sale) AS sales_revenue
FROM retail_sales
GROUP BY category
ORDER BY sale_quantity DESC, sales_revenue DESC

-- Q15. Write a SQL query to analyze monthly sales trends for the past 12 months and identify months with the 
--		highest sales growth rate compared to the previous month.

WITH monthly_sale AS (			--- CTE to calculate the monthly sale and extract the month(yearly)
		SELECT
			TO_CHAR(sale_date, 'YYYY-MM') AS month,
			SUM(total_sale)AS monthly_sales	
		FROM retail_sales
		GROUP BY TO_CHAR(sale_date, 'YYYY-MM')
		)

SELECT
	month,
	monthly_sales,
	LAG(monthly_sales, 1) OVER(ORDER BY month) AS previous_month_sales,
	 ROUND(
        ((monthly_sales - COALESCE(LAG(monthly_sales, 1) OVER (ORDER BY month), 0))::numeric / 
        COALESCE(LAG(monthly_sales, 1) OVER (ORDER BY month), 1)::numeric) * 100,
        2
    ) AS sales_growth_rate
FROM monthly_sale
ORDER BY month;

-- Q16. Write a SQL query to find the percentage of returning customers who made a purchase in a subsequent month 
--		after their first transaction.

WITH first_purchase  AS(			--- CTE to extract the data of 1st Purchase of any customer
		SELECT
			customer_id,
			MIN(sale_date) AS first_purchase_date
		FROM
			retail_sales
		GROUP BY
			customer_id
),

subsequent_purchase AS(		--- CTE to extract the data for the returning customers
		SELECT
			r.customer_id,
			r.sale_date,
			TO_CHAR(f.first_purchase_date, 'YYYY-MM') AS first_month
		FROM
			retail_sales r
		JOIN
			first_purchase f ON r.customer_id = f.customer_id
		WHERE
			r.sale_date > f.first_purchase_date
)

SELECT 
	first_month AS initial_month,
	COUNT(DISTINCT sp.customer_id) AS returning_customers,
	(COUNT(DISTINCT sp.customer_id) * 100.0 / (
							SELECT COUNT(DISTINCT f.customer_id)
							FROM first_purchase f
							WHERE TO_CHAR(f.first_purchase_date, 'YYYY-MM') = first_month
							)) AS retention_rate
FROM
	subsequent_purchase sp
GROUP BY
	first_month
ORDER BY 
	initial_month




----- END OF PROJECT -----
