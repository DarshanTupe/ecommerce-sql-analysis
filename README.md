Ecommerce SQL Data Analysis
Project Overview

This project analyzes an ecommerce dataset using PostgreSQL to extract business insights related to customer behavior, revenue trends, product performance, and delivery efficiency.

The analysis focuses on answering key business questions such as:

How much revenue does the business generate?

How does revenue change over time?

Which customers generate the most revenue?

What percentage of customers are repeat buyers?

Which product categories perform best?

How efficient is the delivery process?

The goal of this project is to practice SQL for business analysis using joins, aggregations, CTEs, and window functions.

Database Schema

The dataset contains the following tables:

Customers

Customer location and identification information.

Orders

Information about each order including purchase time and delivery status.

Payments

Payment details for each order.

Order Items

Individual items purchased in each order.

Products

Product details and category information.

SQL Concepts Used

This project demonstrates the following SQL skills:

Joins

Aggregations (SUM, COUNT, AVG)

Date Functions

CASE Statements

Common Table Expressions (CTEs)

Window Functions

Ranking Functions

LAG for time series analysis

Filtering and grouping

Business Questions Answered
Business Performance

Overall revenue, total orders, and total customers.

Top 5 months with the highest number of orders.

Average Order Value (AOV).

Total spending by each customer.

Revenue Analysis

Monthly revenue trends.

Month-over-month revenue growth.

Revenue contribution of top customers.

Customer Behavior

Percentage of repeat customers.

One-time vs repeat buyers.

Number of new customers per month.

Customer ranking by total spending.

Delivery Performance

Average delivery time.

Order delivery classification (on-time vs late).

Percentage of late deliveries.

Product Performance

Average order value by product category.

Month-over-month revenue growth by category.

Products with the highest number of units sold.

Geographic Analysis

Revenue and order volume by customer state.

Customer Segmentation

RFM (Recency, Frequency, Monetary) analysis to segment customers.

Key Analysis Highlights

Some insights derived from the analysis include:

Identification of the top revenue generating months

Understanding customer purchase behavior

Measuring repeat customer percentage

Evaluating delivery efficiency

Finding top revenue contributing customers

Determining best performing product categories

Project Structure
ecommerce-sql-analysis
│
├── README.md
└── ecommerce_analysis.sql

Tools Used :
PostgreSQL
SQL
