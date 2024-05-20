CREATE DATABASE IF NOT EXISTS walmartSales;
USE walmartSales;

-- CREATE THE SALES TABLE IF IT DOESN'T EXIST
CREATE TABLE IF NOT EXISTS Sales(
Invoice_ID VARCHAR(30) NOT NULL, 
Branch VARCHAR(5) NOT NULL, 
City VARCHAR(30) NOT NULL, 
Customer_type VARCHAR(30) NOT NULL, 
Gender VARCHAR(6) NOT NULL, 
Product_line VARCHAR(100) NOT NULL, 
Unit_price DECIMAL(10, 2) NOT NULL, 
Quantity INT NOT NULL, 
Tax DECIMAL(6, 4) NOT NULL, 
Total DECIMAL(12, 4) NOT NULL, 
Date DATE NOT NULL, 
Time TIME NOT NULL, -- Changed from DATETIME to TIME for storing time 
Payment_Method VARCHAR(15) NOT NULL, 
cogs DECIMAL(10, 2) NOT NULL, 
gross_margin_pct DECIMAL(11, 9) NOT NULL, 
gross_income DECIMAL(12, 4) NOT NULL, 
Rating DECIMAL(2, 1) NOT NULL 
);

-- LOAD THE WALMART SALES DATASET FROM KAGGLE INTO SALES TABLE 

-- Select all records from the sales table to verify the data load

SELECT * FROM Sales;

/* 1. Add a new column named `time_of_day` to give insight of sales in the Morning, 
Afternoon and Evening. This will help answer the question on which part of the day 
most sales are made.*/ 

SELECT
time,
(CASE
WHEN 'time' BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
WHEN 'time' BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
ELSE "Evening"
END) AS time_of_day
FROM sales;


ALTER TABLE Sales ADD COLUMN Time_of_day varchar(20);

UPDATE sales
SET time_of_day = (CASE
WHEN 'time' BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
WHEN 'time' BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
ELSE "Evening"
END);

/* 2. Add a new column named `day_name` that contains the extracted days of the week on 
which the given transaction took place (Mon, Tue, Wed, Thur, Fri). This will help answer 
the question on which week of the day each branch is busiest.*/

SELECT 
date,
DAYNAME(date)
from sales;

SELECT * FROM sales; 

ALTER TABLE sales ADD COLUMN day_name varchar(12);

UPDATE sales
SET day_name = DAYNAME(date);

/* 3. Add a new column named `month_name` that contains the extracted months of the 
year on which the given transaction took place (Jan, Feb, Mar). Help determine which 
month of the year has the most sales and profit.*/ 

SELECT 
date,
MONTHNAME(date)
from sales;

ALTER Table sales ADD COLUMN month_name varchar(12);

UPDATE sales
SET month_name = MONTHNAME(date);

SELECT * FROM sales;


-- FEW GENERAL QUESTIONS

-- 1.How many unique cities does the data have?
SELECT 
DISTINCT city
from sales;

-- 2. In which city is each branch?
SELECT DISTINCT city,branch
FROM sales;


-- PRODUCT ANALYSIS

-- 1.How many unique product lines does the data have?
SELECT COUNT(DISTINCT product_line)
from sales;

-- 2.What is the most selling product line
SELECT 
SUM(quantity) AS qty,
product_line
FROM sales
GROUP BY product_line
ORDER BY qty DESC;

/* CONCLUSION: Electronic Accessories has the most selling product whereas 
Health and Beauty has less selling */

-- 3.What is the total revenue by month
SELECT
sum(total) as total_revenue,
month_name as month
FROM sales
GROUP BY month
ORDER BY total_revenue DESC;

/* CONCLUSION: January month generate highest revenue whereas 
February has lowest revenue.*/

-- 4. Which month had the largest COGS?
SELECT month_name as month,
sum(cogs) AS cogs
FROM sales
GROUP BY month_name
ORDER BY cogs;

/* Conclusion: January month generate highest cogs whereas February has lowest cogs.*/

-- 5. what product line had the largest revenue?
SELECT 
product_line,
SUM(total) as total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

/* CONCLUSION:Food and Beverages has the highest revenue followed by Sports and Travel
Whereas Health and Beauty has Lowest.*/

-- 6. what is the city with the largest revenue?

SELECT branch,city,SUM(total) As total_revenue
FROM sales
GROUP BY city,branch
ORDER BY total_revenue;


-- 7. what product line had the largest tax?
SELECT 
product_line,
AVG(tax) as avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- CONCLUSION: Home and Lifestyle has the highest avg_tax  and
-- Fashion accessories has the lowest

/*8. Fetch each product line and add a column to those product 
line showing "Good", "Bad". Good if its greater than average 
sales */

SELECT AVG(quantity) as avg_qnty
from sales;

SELECT 
product_line,
case when AVG(quantity) > 5.4995 then "Good"
else "Bad"
end as remark
FROM sales
GROUP BY product_line;


/* 9.Which branch sold more products than average product sold? */
SELECT branch,SUM(quantity) as qty
from sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) AS avg_quantity FROM sales);

-- CONCLUSION: BRANCH A sold more product than average product sold

-- 10. What is the most common product line by gender?
SELECT 
gender,product_line,COUNT(gender) as total_cnt
FROM sales
GROUP BY gender,product_line
ORDER BY total_cnt DESC;

-- Conclusion: The most common Product line by female is FASHION ACCESSORIES
-- BY MEN is HEALTH and KUSHI

-- 11. What is the average rating of each product line??

SELECT 
 ROUND(AVG(rating), 2) as avg_rating, 
 product_line 
FROM sales 
GROUP BY product_line 
ORDER BY avg_rating desc;

-- Conclusions :- Food and beverages has highest average Rating Home and Lifestyle has lowest.



#CUSTOMER ANALYSIS

#1. How many unique customer types does the data have?
SELECT DISTINCT customer_type
FROM sales;


#2. How many Unique payment methods does the data have?
SELECT DISTINCT payment_method
FROM sales;

#3.Which customer type buys the most?
SELECT CUSTOMER_TYPE,COUNT(*)
from sales
GROUP BY customer_type;

-- Conclusions :- There is not a big difference, approximately same.

#4. What is the gender of most of the customers?
SELECT gender,count(*) as gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;

-- Conclusions :- There is not a big difference, approximately same.

#5.What is the gender distribution per branch?
SELECT gender,COUNT(*) as gender_cnt
FROM sales
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_cnt DESC;

/*Conclusions :- Gender per branch is more or less the same hence, I don't think has an 
effect of the sales per branch and other factors.*/
 
#6. Which time of the day do customers give most ratings?
SELECT time_of_day,AVG(rating) as avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

/*Conclusion :- Looks like time of the day does not really affect the rating, its more or less the 
same rating each time of the day.*/ 

#7. Which time of the day do customers give most ratings per branch?

SELECT 
    time_of_day, branch, AVG(rating) AS avg_rating
FROM
    sales
WHERE
    branch IN ('A' , 'B', 'C')
GROUP BY time_of_day , branch
ORDER BY avg_rating DESC;

/*Conclusions:- Branch A and C are doing well in ratings, branch B needs to do a little more 
to get better ratings. */


#9. Which day fo the week has the best avg ratings?
select
day_name,
AVG(rating) as avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;

#Conclusions : Mon, Tue and Friday are the top best days for good ratings

#10. Which day of the week has the best average ratings per branch?
SELECT
day_name,
branch,Avg(rating) as ARB
FROM sales
WHERE branch in ("A","B","C")
GROUP BY day_name,branch
ORDER BY ARB DESC;

/* Conclusions :- In Branch B Monday has highest Rating and Wednesday has Lowest Rating.
 In Branch A Friday has highest Rating and Saturday has Lowest Rating. 
 In Branch C Friday has highest Rating and Thursday has Lowest Rating
 */
 
 # SALES ANALYSIS
 
 
 #1. NUMBER of sales made in each time odf the day pefr weekday
 Select time_of_day,
 COUNT(*) AS total_sales
 FROM sales
 WHERE day_name = "Sunday"
 group by time_of_day
 ORDER BY total_sales DESC;
 
/*Conclusions :- Evenings experience most sales, the stores are filled during 
the evening hours, followed by Afternoon and morning has less sales. */

#2. Which of the customer types brings the most revenue/
SELECT customer_type,
SUM(total) as total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue;

-- Conclusions :- Member type generated more revenue as compare to Normal type.

#3.WHich city hs the largest tax/vat percent?
SELECT city,ROUND(AVG(tax),2) as avg_tax_pct
FROM sales
GROUP by city
ORDER BY avg_tax_pct DESC;

-- Conclusion: Naypyitaw,mandalay,Yangon has the highest AVG_TAX percent.

#4. Which customer type pays the most in vat?
SELECT customer_type,
AVG(tax) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax

-- CONCLUSION: member pays more tax as Compared to Normal.
 
 
