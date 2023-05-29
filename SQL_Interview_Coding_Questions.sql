USE [TSQLV4]
GO

-- 1- How many total customers does each employee hired after 2014 have?

SELECT  firstname, lastname, HR.Employees.empid, COUNT(Sales.Orders.custid)  as NumberofCustomers 
FROM
HR.Employees JOIN Sales.Orders ON HR.Employees.empid = Sales.Orders.empid
WHERE YEAR(hiredate) >= 2014
GROUP BY HR.Employees.empid,firstname, lastname
ORDER BY NumberofCustomers DESC


GO
-- 2- What is the total purchase amount by American, French, and German customers after 2007?

SELECT SUM (Sales.OrderDetails.qty * (Sales.OrderDetails.unitprice * (1 - Sales.OrderDetails.discount))) AS TotalAmount
FROM [Sales].[OrderDetails] JOIN [Sales].[Orders] ON Sales.OrderDetails.orderid = Sales.Orders.orderid
WHERE shipcountry IN ('France', 'Germany', 'USA') AND YEAR(orderdate) >= 2007

GO
-- 3- Which countries have made purchases exceeding 40,000 USD?

SELECT shipcountry, SUM (Sales.OrderDetails.qty * (Sales.OrderDetails.unitprice * (1 - Sales.OrderDetails.discount))) AS TotalAmount
FROM [Sales].[OrderDetails] JOIN [Sales].[Orders] ON Sales.OrderDetails.orderid = Sales.Orders.orderid
GROUP BY shipcountry
HAVING SUM (Sales.OrderDetails.qty * (Sales.OrderDetails.unitprice * (1 - Sales.OrderDetails.discount)))>= 40000
ORDER BY TotalAmount
GO
-- 4- What are the average, count, and sum of sales for each customer who purchased beverage and seafood products, and had them exported by shippers #2 and #3 to the US?
 
SELECT 
custid,
categoryname,
AVG(Sales.OrderDetails.qty * (Sales.OrderDetails.unitprice * (1 - Sales.OrderDetails.discount))) as AverageAmount,
SUM(Sales.OrderDetails.qty * (Sales.OrderDetails.unitprice * (1 - Sales.OrderDetails.discount))) as TotalAmount,
COUNT(*) AS NumberOfOrder

FROM Production.Categories
JOIN Production.Products ON Production.Categories.categoryid = Production.Products.categoryid
JOIN Production.Suppliers ON Production.Suppliers.supplierid = Production.Products.supplierid
JOIN [Sales].[OrderDetails] ON [Sales].[OrderDetails].productid = Production.Products.productid
JOIN [Sales].[Orders] ON Sales.OrderDetails.orderid = Sales.Orders.orderid
WHERE shipcountry = 'USA' AND Production.Categories.categoryid IN (1, 8) AND shipperid IN (2,3)
GROUP BY custid,categoryname

GO

-- 5- What is the latest order date for each customer?

SELECT custid , MAX(orderdate) as MaxOrderDate FROM [Sales].[Orders]
GROUP BY custid
GO

-- 6- What is the sales ranking of each customer? Please mention the ranking in a separate column.

SELECT custid,
SUM (Sales.OrderDetails.qty * (Sales.OrderDetails.unitprice * (1 - Sales.OrderDetails.discount))) AS TotalAmount,
RANK() OVER(ORDER BY SUM (Sales.OrderDetails.qty * (Sales.OrderDetails.unitprice * (1 - Sales.OrderDetails.discount))) DESC) AS Rank
FROM [Sales].[OrderDetails] JOIN [Sales].[Orders] ON Sales.OrderDetails.orderid = Sales.Orders.orderid
GROUP BY custid

