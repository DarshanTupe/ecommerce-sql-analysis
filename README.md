📊 Ecommerce SQL Data Analysis

SQL analysis of an ecommerce dataset using PostgreSQL to uncover insights about revenue, customer behavior, delivery performance, and product trends.

📌 Project Overview

This project explores an ecommerce dataset to answer key business questions such as:
How much revenue does the business generate?
What are the monthly revenue trends?
Who are the highest spending customers?
What percentage of customers are repeat buyers?
Which products sell the most units?
The goal is to practice SQL-based business analysis using PostgreSQL.

🗄️ Database Schema

The project uses the following tables:
Table	Description
customers :	Customer location and identification data
orders:	Order information and timestamps
payments:	Payment information for each order
order_items:	Items included in each order
products:	Product details and categories

🧠 SQL Skills Demonstrated"

This project uses several important SQL techniques:
JOIN operations
Aggregations (SUM, COUNT, AVG)
Window Functions (RANK, LAG)
Common Table Expressions (CTEs)
Date functions (date_trunc)
CASE statements
Filtering and grouping

📈 Key Analyses Performed:
Business Performance
Total revenue
Total orders
Total customers
Average order value
Customer Behavior
Repeat vs one-time customers
Customer spending analysis
Customer ranking by revenue
Revenue Analysis
Monthly revenue trends
Month-over-month growth
Delivery Performance=
Average delivery time
Late vs on-time deliveries
Product Analysis
Best selling products
Revenue by product category
Customer Segmentation
RFM (Recency, Frequency, Monetary) analysis

🗂️ Project Structure
ecommerce-sql-analysis
│
├── README.md
└── ecommerce_analysis.sql
🛠️ Tools Used

SQL

PostgreSQL
