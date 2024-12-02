SELECT * 
FROM ElectronicsSales.electronicsales;

-- 1: Data Cleaning & Data Wrangling 
-- 1.1 Identify rows with missing values
SELECT * 
FROM ElectronicsSales.electronicsales
WHERE CustomerID IS NULL OR SKU IS NULL OR TotalPrice IS NULL;


-- 1.2 Finding duplicate records 
SELECT CustomerID, SKU, COUNT(*) AS DupCount
FROM ElectronicsSales.electronicsales
GROUP BY CustomerID, SKU, PurchaseDate
HAVING DupCount > 1;

-- 1.3 Handling Outliers 
SELECT *
FROM ElectronicsSales.electronicsales
WHERE UnitPrice > (SELECT AVG(UnitPrice) + 3 * STD(UnitPrice) FROM ElectronicsSales.electronicsales)
   OR UnitPrice < (SELECT AVG(UnitPrice) - 3 * STD(UnitPrice) FROM ElectronicsSales.electronicsales);
   
-- 1.5 Data Aggregation 
-- Calculating total reveune by product 
SELECT SKU, SUM(TotalPrice) AS TotalRevenue
FROM ElectronicsSales.electronicsales
GROUP BY SKU;
--  total revenue by month 
SELECT DATE_FORMAT(PurchaseDate, '%m-%d-%y') AS Month, SUM(TotalPrice) AS TotalRevenue
FROM ElectronicsSales.electronicsales
GROUP BY Month
ORDER BY Month;

-- 2. Exploratory Data Analysis 
-- 2.1 Total Revenue and Sales Trends 
SELECT DATE_FORMAT(PurchaseDate, '%m-%d-%y') AS Month, SUM(TotalPrice) AS TotalRevenue
FROM ElectronicsSales.electronicsales
GROUP BY Month
ORDER BY Month;
-- Daily sales trends 
SELECT PurchaseDate, SUM(TotalPrice) as DailyRevenue 
FROM ElectronicsSales.electronicsales
GROUP BY PurchaseDate
ORDER BY PurchaseDate; 

-- 2.2 Top-Selling Products 
-- Top-selling products by quantity 
SELECT ProductType, SUM(Quantity) AS TotalSold 
FROM ElectronicsSales.electronicsales
GROUP BY ProductType
ORDER BY TotalSold DESC; 

-- 2.3 Customer Segmentation by Loyalty 
-- Average spending by loyalty status 
Select LoyaltyMember, AVG(TotalPrice) AS AvgSpending
FROM ElectronicsSales.electronicsales
GROUP BY LoyaltyMember;


-- 2.4 Add-on Analysis and Upscale Opportunities 
-- Most popular add-ons and revenue generation 
SELECT AddonsDescription, COUNT(CustomerID) AS Frequency, 
SUM(AddonTotal) as TotalRevenue 
FROM ElectronicsSales.electronicsales
GROUP BY AddonsDescription 
ORDER BY TotalRevenue DESC; 
-- Opportunity for up-selling: total add-on revenue per order 
SELECT CustomerID, SUM(AddonTotal) AS TotalAddonRevenue 
FROM ElectronicsSales.electronicsales
GROUP BY CustomerID
HAVING TotalAddonRevenue > 0; 

-- 2.5 Age and Product Type Analysis 
-- Average age of customers by product type 
SELECT ProductType, SKU, CustomerID, AVG(Age) AS AverageAge 
FROM ElectronicsSales.electronicsales
GROUP BY ProductType, SKU, CustomerID 
ORDER BY AverageAge DESC; 

-- 2.6 Product Type and Rating 
-- Product ratings 
SELECT ProductType, AVG(Rating) AS AverageRating 
FROM ElectronicsSales.electronicsales
GROUP BY ProductType
ORDER BY AverageRating DESC; 

-- 2.7 Gender and Product Type Analysis 
-- Gender-based product type preferences 
SELECT SKU, Gender, ProductType, COUNT(CustomerID) AS NumberofOrders
FROM ElectronicsSales.electronicsales
GROUP BY Gender, ProductType, SKU 
ORDER BY NumberofOrders DESC;

-- 2.8 Product Type, Quantity, and Total Price 
-- Product type, quantity sold, and total revenue 
SELECT ProductType,SKU, SUM(Quantity) AS TotalQuantity, 
SUM(TotalPrice) AS TotalRevenue
FROM ElectronicsSales.electronicsales
GROUP BY ProductType, SKU 
ORDER BY TotalRevenue DESC; 
