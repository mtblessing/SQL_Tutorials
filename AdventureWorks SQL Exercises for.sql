-- AdventureWorks 2022 SQL Exercises for Data Analysts

--Section 1: Data Cleaning and Preparation

-- 1.1: Identify and Correct Missing Values 
--Task:Identify rows in the `Person.EmailAddress` table where the email address is missing (`NULL`). Replace `NULL` values with "unknown@example.com".


-- Identify missing values
SELECT * 
FROM Person.EmailAddress
WHERE EmailAddress IS NULL;

-- Update missing values
UPDATE Person.EmailAddress
SET EmailAddress = 'unknown@example.com'
WHERE EmailAddress IS NULL;

--Expected Output:** Rows with missing email addresses are updated with "unknown@example.com".

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*1.2: Standardize Data Formats
Task:Convert all dates in the `Sales.SalesOrderHeader` table to the `YYYY-MM-DD` format and display the updated values.*/
-------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Select and format order dates
SELECT SalesOrderID, CONVERT(VARCHAR, OrderDate, 23) AS FormattedOrderDate
FROM Sales.SalesOrderHeader;

--Expected Output:** A list of sales orders with dates in `YYYY-MM-DD` format.

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

--1.3: Detect Outliers in Sales
--Task:Identify outliers in the `Sales.SalesOrderDetail` table where `LineTotal` exceeds 3 standard deviations from the mean.

-- Calculate mean and standard deviation
WITH Stats AS (
    SELECT AVG(LineTotal) AS Mean, 
           STDEV(LineTotal) AS StdDev
    FROM Sales.SalesOrderDetail
)
-- Identify outliers
SELECT sod.SalesOrderID, sod.LineTotal
FROM Sales.SalesOrderDetail sod
CROSS JOIN Stats
WHERE ABS(sod.LineTotal - Stats.Mean) > 3 * Stats.StdDev;

--Expected Output:** A list of outliers in sales orders based on `LineTotal`.

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Data Exploration and Visualization
 2.1: Analyze Sales Trends Over Time
Task: Calculate monthly sales totals for the past two years.*/
-----------------------------------------------------------------------------------------------------------------------------------------------

-- Summarize sales by month
SELECT FORMAT(OrderDate, 'yyyy-MM') AS SalesMonth, 
       SUM(TotalDue) AS MonthlySales
FROM Sales.SalesOrderHeader
WHERE OrderDate >= DATEADD(YEAR, -2, GETDATE())
GROUP BY FORMAT(OrderDate, 'yyyy-MM')
ORDER BY SalesMonth;

--Expected Output:** A table of monthly sales totals for the past two years.

-----------------------------------------------------------------------------------------------------------------------------------------------
/*2.2: Identify Top-Selling Product Categories
Task:Find the top 5 product categories by total sales revenue.*/
-----------------------------------------------------------------------------------------------------------------------------------------------
-- Top product categories by revenue
SELECT pc.Name AS ProductCategory, 
       SUM(sod.LineTotal) AS TotalRevenue
FROM Production.ProductCategory pc
JOIN Production.ProductSubcategory psc ON pc.ProductCategoryID = psc.ProductCategoryID
JOIN Production.Product p ON psc.ProductSubcategoryID = p.ProductSubcategoryID
JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
GROUP BY pc.Name
ORDER BY TotalRevenue DESC
FETCH FIRST 5 ROWS ONLY;

--Expected Output:** A table listing the top 5 product categories and their sales revenue.

-----------------------------------------------------------------------------------------------------------------------------------------------
/*2.3: Visualize Customer Demographics
Task:Group customers by state and count the number of customers in each state.*/
-----------------------------------------------------------------------------------------------------------------------------------------------
-- Count customers by state
SELECT Address.StateProvinceID, COUNT(*) AS CustomerCount
FROM Person.Address
JOIN Sales.CustomerAddress ON Person.Address.AddressID = Sales.CustomerAddress.AddressID
GROUP BY Address.StateProvinceID
ORDER BY CustomerCount DESC;

--Expected Output:** A table showing customer counts by state.

-----------------------------------------------------------------------------------------------------------------------------------------------
/*3: Easy to Advanced SQL Queries
 3.1: Use Window Functions for Running Totals
Task: Calculate the running total of sales revenue for each customer in the `Sales.SalesOrderHeader` table.*/
-----------------------------------------------------------------------------------------------------------------------------------------------

-- Running total of sales by customer
SELECT CustomerID, SalesOrderID, OrderDate, TotalDue,
       SUM(TotalDue) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS RunningTotal
FROM Sales.SalesOrderHeader;

--Expected Output:** A list of sales orders with a running total of revenue for each customer.

-----------------------------------------------------------------------------------------------------------------------------------------------
/*Exercise 3.2: Perform Complex Joins
  Task:** Join the `Sales.SalesOrderHeader`, `Sales.SalesOrderDetail`, and `Production.Product` tables to show 
  sales revenue per product for the top 10 products.*/
-----------------------------------------------------------------------------------------------------------------------------------------------

-- Join tables and calculate revenue per product
SELECT TOP 10 p.Name AS ProductName, 
              SUM(sod.LineTotal) AS Revenue
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY Revenue DESC;

--Expected Output:** A list of the top 10 products and their sales revenue.

-------------------------------------------------------------------------------------------------------------------
/* 3.3: Simplify Queries with Common Table Expressions (CTEs)
Task:** Use a CTE to find the average sales per customer and list customers who exceed the average.*/
-------------------------------------------------------------------------------------------------------------------
-- Calculate average sales per customer using a CTE
WITH CustomerSales AS (
    SELECT CustomerID, SUM(TotalDue) AS TotalSales
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
),
AverageSales AS (
    SELECT AVG(TotalSales) AS AvgSales FROM CustomerSales
)
SELECT cs.CustomerID, cs.TotalSales
FROM CustomerSales cs
CROSS JOIN AverageSales
WHERE cs.TotalSales > AverageSales.AvgSales;

--Expected Output:** A list of customers whose total sales exceed the average.
-------------------------------------------------------------------------------------------------------------------
/* 4: Additional Areas of Data Analysis

Exercise 4.1: Create Temporary Tables for Aggregation
Task:** Create a temporary table to store monthly sales totals and query it for high-sales months.*/
-------------------------------------------------------------------------------------------------------------------

-- Create temporary table
CREATE TABLE #MonthlySales (
    SalesMonth VARCHAR(7),
    MonthlyTotal MONEY
);
-------------------------------------------------------------------------------------------------------------------
 --Populate the table
INSERT INTO #MonthlySales (SalesMonth, MonthlyTotal)
SELECT FORMAT(OrderDate, 'yyyy-MM') AS SalesMonth, 
       SUM(TotalDue) AS MonthlyTotal
FROM Sales.SalesOrderHeader
GROUP BY FORMAT(OrderDate, 'yyyy-MM');

-- Query the temporary table
SELECT * 
FROM #MonthlySales
WHERE MonthlyTotal > 1000000;

--*Expected Output:** A list of months where sales exceeded $1,000,000.

-------------------------------------------------------------------------------------------------------------
/*Exercise 4.2: Perform Recursive Queries
Task:** Use a recursive query to display a hierarchy of product categories and subcategories.*/
-------------------------------------------------------------------------------------------------------------

-- Recursive query for product hierarchy
WITH ProductHierarchy AS (
    SELECT pc.ProductCategoryID, pc.Name AS CategoryName, NULL AS ParentCategory
    FROM Production.ProductCategory pc
    WHERE pc.ProductCategoryID NOT IN (
        SELECT ProductCategoryID FROM Production.ProductSubcategory
    )
    UNION ALL
    SELECT psc.ProductCategoryID, psc.Name, pc.Name
    FROM Production.ProductSubcategory psc
    JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
)
SELECT * 
FROM ProductHierarchy
ORDER BY ParentCategory;

--Expected Output:** A hierarchical list of product categories and subcategories.

-----------------------------------------------------------------------------------

--These exercises cover a wide range of SQL topics, providing a solid foundation in data analysis techniques.

-- Exercise 1: Identify missing values in the Customer table.
-- Question:
-- Write a query to find customers with missing email addresses.
SELECT CustomerID, FirstName, LastName, EmailAddress
FROM Person.Person
WHERE EmailAddress IS NULL;

-- Solution:
-- The query selects customer IDs, names, and email addresses, filtering rows where the email is NULL.

-- Justification:
-- Identifying missing email addresses is a common data cleaning task to ensure data completeness.

--------------------------------------------------------------------------------

-- Exercise 2: Standardize currency format in the SalesOrderHeader table.
-- Question:
-- Write a query to format TotalDue as currency for all orders.
SELECT SalesOrderID, CustomerID, FORMAT(TotalDue, 'C', 'en-US') AS TotalDueFormatted
FROM Sales.SalesOrderHeader;

-- Solution:
-- This query uses the FORMAT function to present TotalDue in a currency format.

-- Justification:
-- Standardizing formats ensures data consistency and improves readability for stakeholders.

--------------------------------------------------------------------------------

-- Exercise 3: Analyze monthly sales trends.
-- Question:
-- Write a query to calculate total sales per month in 2022.
SELECT FORMAT(OrderDate, 'yyyy-MM') AS OrderMonth, SUM(TotalDue) AS MonthlySales
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2022
GROUP BY FORMAT(OrderDate, 'yyyy-MM')
ORDER BY OrderMonth;

-- Solution:
-- This query groups data by month and calculates the total sales using SUM.

-- Justification:
-- Monthly sales trends provide insights into seasonal variations and performance.

--------------------------------------------------------------------------------

-- Exercise 4: Identify top-selling product categories.
-- Question:
-- Write a query to find the top 5 product categories by total sales.
SELECT TOP 5 ppc.Name AS Category, SUM(sod.LineTotal) AS TotalSales
FROM Production.ProductCategory ppc
JOIN Production.ProductSubcategory psc ON ppc.ProductCategoryID = psc.ProductCategoryID
JOIN Production.Product p ON psc.ProductSubcategoryID = p.ProductSubcategoryID
JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
GROUP BY ppc.Name
ORDER BY TotalSales DESC;

-- Solution:
-- The query joins product-related tables to calculate sales by category and retrieves the top 5.

-- Justification:
-- Understanding category-level performance aids in targeted marketing and inventory decisions.

--------------------------------------------------------------------------------

-- Exercise 5: Visualize customer demographics.
-- Question:
-- Write a query to count customers by territory.
SELECT t.Name AS Territory, COUNT(c.CustomerID) AS CustomerCount
FROM Sales.Customer c
JOIN Sales.SalesTerritory t ON c.TerritoryID = t.TerritoryID
GROUP BY t.Name
ORDER BY CustomerCount DESC;

-- Solution:
-- This query joins the Customer and SalesTerritory tables and counts customers by region.

-- Justification:
-- Analyzing demographics helps tailor strategies to regional preferences.

--------------------------------------------------------------------------------

-- Exercise 6: Calculate running totals for monthly sales.
-- Question:
-- Write a query to calculate a running total of sales in 2022.
WITH MonthlySales AS (
    SELECT FORMAT(OrderDate, 'yyyy-MM') AS OrderMonth, SUM(TotalDue) AS MonthlySales
    FROM Sales.SalesOrderHeader
    WHERE YEAR(OrderDate) = 2022
    GROUP BY FORMAT(OrderDate, 'yyyy-MM')
)
SELECT OrderMonth, MonthlySales,
       SUM(MonthlySales) OVER (ORDER BY OrderMonth) AS RunningTotal
FROM MonthlySales;

-- Solution:
-- A CTE is used for monthly sales, and a window function calculates the running total.

-- Justification:
-- Running totals help analyze cumulative trends over time.

--------------------------------------------------------------------------------

-- Exercise 7: Find customers with the highest average order value.
-- Question:
-- Write a query to find the top 5 customers by average order value.
SELECT TOP 5 c.CustomerID, p.FirstName, p.LastName, AVG(sod.LineTotal) AS AvgOrderValue
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY c.CustomerID, p.FirstName, p.LastName
ORDER BY AvgOrderValue DESC;

-- Solution:
-- The query calculates the average order value per customer and retrieves the top 5.

-- Justification:
-- Identifying high-value customers is crucial for retention and personalized marketing.

--------------------------------------------------------------------------------

-- Exercise 8: Combine data from multiple tables using complex joins.
-- Question:
-- Write a query to retrieve sales orders with product and customer details.
SELECT soh.SalesOrderID, p.FirstName, p.LastName, pr.Name AS Product, sod.OrderQty, sod.LineTotal
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID;

-- Solution:
-- The query combines data from multiple tables using joins to provide detailed sales information.

-- Justification:
-- Combining data from different sources is essential for comprehensive analysis.

--------------------------------------------------------------------------------

-- Exercise 9: Use a Common Table Expression (CTE) to simplify analysis.
-- Question:
-- Write a query to calculate the top 5 products by total revenue using a CTE.
WITH ProductRevenue AS (
    SELECT p.Name AS Product, SUM(sod.LineTotal) AS TotalRevenue
    FROM Sales.SalesOrderDetail sod
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    GROUP BY p.Name
)
SELECT TOP 5 Product, TotalRevenue
FROM ProductRevenue
ORDER BY TotalRevenue DESC;

-- Solution:
-- The CTE computes revenue for each product, and the final query retrieves the top 5.

-- Justification:
-- CTEs simplify complex queries, making them easier to read and maintain.

--------------------------------------------------------------------------------
