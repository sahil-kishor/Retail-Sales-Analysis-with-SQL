# **Retail Sales Analysis with SQL**

## Project Overview

**Project Title**: Retail Sales Analysis  
**Database**: `SQL - Retail Sales Analysis_utf .csv`

This project is designed to showcase SQL proficiency and techniques commonly employed by data analysts to explore, clean and analyze retail sales data. The project entails setting up a retail sales database, conducting exploratory data analysis (EDA) and addressing specific business questions using SQL queries. The analysis answers various business-related queries, providing insights into sales trends, customer behavior and product performance.

## Objectives

1. **Database Setup:** Create and populate a retail sales database using the provided sales data.

2. **Data Cleaning:** Detect and eliminate any records with missing or null values.

3. **Exploratory Data Analysis (EDA):** Perform basic EDA to gain an understanding of the dataset.

4. **Business Analysis:** Utilize SQL to answer key business questions and extract actionable insights from the sales data.

## Project Structure

**The repository is organized as follows:**

/Retail_Sales_Analysis

│

├── /data

│   └── retail_sales_data.csv  # The raw data file

│

├── /queries

│   ├── data_cleaning.sql      # SQL queries for cleaning the data

│   ├── exploratory_analysis.sql # SQL queries for EDA

│   └── business_analysis.sql  # SQL queries answering business questions

│

├── /reports

│   ├── sales_summary_report.md    # Detailed sales summary

│   ├── trend_analysis_report.md   # Monthly sales trends

│   └── customer_insights_report.md # Top customers and customer segmentation

│

└── README.md                  # Project overview, setup instructions, and results



### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `Retail Sales Analysis with SQL`.
- **Table Creation**: A table named `retail_sales` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
CREATE DATABASE Retail_Sales_Analysis_with_SQL;

CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,	
    sale_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
);
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.

```sql
SELECT COUNT(*) FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;

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

```
### 3. Exploring Dataset

```sql
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

```

### 4. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Query to retrieve all columns for sales made on '2022-11-05'**:
```sql
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';
```

2. **Query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of 'Nov-2022'**:
```sql
SELECT *
FROM retail_sales
WHERE category = 'Clothing' 
	  AND
	  TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
	  AND
	  quantity >= 4
```

3. **Query to calculate the total sales (total_sale) for each category.**:
```sql
SELECT category, 
	   SUM(quantity) AS quantity_sold, 
	   COUNT(*) AS total_orders, 
	   SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY category
ORDER BY total_sales DESC;
```

4. **Query to find the average age of customers who purchased items from the 'Beauty' category.**:
```sql
SELECT ROUND(AVG(age), 2) AS average_customer_age
FROM retail_sales
WHERE category = 'Beauty'
```

5. **Query to find all transactions where the total_sale is greater than 1000.**:
```sql
SELECT *
FROM retail_sales
WHERE total_sale > 1000;
```

6. **Query to find the total number of transactions (transaction_id) made by each gender in each category.**:
```sql
SELECT category, 
	   gender, 
	   COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY total_transactions DESC;
```

7. **Query to calculate the average sale for each month. Find out best selling month in each year**:
```sql
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
```

8. **Query to find the top 5 customers based on the highest total sales **:
```sql
SELECT
	customer_id,
	SUM(total_sale) AS total_sale
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sale DESC
LIMIT 5;
```

9. **Query to find the number of unique customers who purchased items from each category.**:
```sql
SELECT
	category,
	COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category
ORDER BY unique_customers DESC;
```

10. **Query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)**:
```sql
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
```
## Below are some questions that explore the data for some advance business queries:

11. **Find the number of unique customers who have purchased items from all three specified categories (e.g., 'Category1', 'Category2', and 'Category3') in the retail_sales table.**
```sql
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
```

12. **Calculate the total sales and the average number of purchases per customer to identify the top 10 customers with the highest lifetime value (CLV).**
```sql
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
```

13. **Classify customers into different segments based on their total number of purchases and average spending per transaction.**
```sql
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
```

14. **Identify the best-selling product category in terms of both quantity sold and total sales revenue.**
```sql
SELECT
	category,
	SUM(quantity) AS sale_quantity,
	SUM(total_sale) AS sales_revenue
FROM retail_sales
GROUP BY category
ORDER BY sale_quantity DESC, sales_revenue DESC
```

15. **Analyze monthly sales trends for the past 12 months and identify months with the highest sales growth rate compared to the previous month.**
```sql
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
```

16. **Find the percentage of returning customers who made a purchase in a subsequent month after their first transaction.**
```sql
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
```


## Findings

- **Customer Demographics**:
  The dataset includes customers from various age groups, with significant sales distributed across categories such as Clothing and Beauty.
  
- **High-Value Transactions**:
  Several transactions had a total sale amount greater than $1,000, indicating premium purchases from a segment of high-value customers.
  
- **Sales Trends**:
  Monthly sales show fluctuations, helping to identify peak seasons and areas requiring attention in low-sales periods.
  
- **Customer Insights**:
      * The top-spending customers contribute significantly to revenue.
      * Customer segmentation reveals different purchasing behaviors, including frequent buyers, high spenders, and standard customers.

- **Customer Analysis**:
    * Total Unique Customers: 128 unique customers purchased items across all specified categories.
    * Business Implication: This group of customers represents a highly engaged segment, contributing to diversified category sales.

- **Top Customers by Lifetime Value**
    * Top 10 Customers: These customers have significantly high total sales, with the highest lifetime value being $38,440.
    * Key Insight: The top customers exhibit strong purchasing power, highlighting an opportunity for targeted marketing and loyalty programs to further engage them.

- Customer Segmentation
    * Frequent Buyer Segment: 45 customers (29.03%) with an average sales value of $7,556.56.
    * Standard Customer Segment: 48 customers (30.97%) with an average sales value of $2,385.94.
    * High Spender & Frequent Buyer: 30 customers (19.35%) with an average sales value of $10,394.67.
    * High Spender: 32 customers (20.65%) with an average sales value of $4,540.94.
    * Business Implication: These segments offer opportunities for tailored promotions or loyalty programs. High spenders and frequent buyers are key segments for customer retention.

- Best-Selling Product Categories
    * Clothing: 1,785 units sold, generating $311,070 in sales.
    * Electronics: 1,698 units sold, contributing $313,810 in sales revenue.
    * Beauty: 1,535 units sold, with total sales of $286,840.
    * Key Insight: Clothing and Electronics are the top-performing categories in terms of both units sold and revenue, representing key drivers for inventory and marketing strategies.

- Monthly Sales Growth Analysis
    * Sales Trends: A steady decline in monthly sales from January to December 2022, with no significant changes in the growth rate.
    * Growth Rate: The sales growth rate remained at 0% throughout the year, indicating stagnation in sales.
    * Business Implication: The lack of growth or stagnation in sales raises questions regarding possible reasons, such as external market factors or internal issues. Further investigation into marketing campaigns, product offerings, or external conditions is necessary.

## Reports


## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, focusing on the key aspects of database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. By applying SQL techniques to analyze retail sales data, several key findings were uncovered that could help drive strategic business decisions:

Customer Demographics and Behavior: The identification of different customer segments and their spending patterns provides valuable insights into targeting marketing campaigns and improving customer engagement.
High-Value Transactions: Premium purchases represent a significant segment, and recognizing this allows for the design of tailored loyalty or rewards programs.
Product Performance: Product categories like Clothing and Electronics emerged as top performers, helping guide decisions on inventory management and product promotions.
Sales Trends and Growth: Monthly analysis of sales trends revealed stagnation in growth, indicating a need for further analysis into potential external factors, and opportunities for more targeted sales initiatives.
The findings from this project not only enhance SQL proficiency but also provide actionable insights that can improve sales performance, marketing strategies, and customer retention efforts.
