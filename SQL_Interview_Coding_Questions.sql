USE [TSQLV4]
GO

-- 1- How many customers does each employee  who is employed after 2014 have in total?
SELECT  firstname, lastname, HR.Employees.empid, COUNT(Sales.Orders.custid)  as NumberofCustomers 
FROM
HR.Employees JOIN Sales.Orders ON HR.Employees.empid = Sales.Orders.empid
WHERE YEAR(hiredate) >= 2014
GROUP BY HR.Employees.empid,firstname, lastname
ORDER BY NumberofCustomers DESC


GO
-- 2- How much do the American, Francian, and German customers purchased in total after 2007?
SELECT SUM (Sales.OrderDetails.qty * (Sales.OrderDetails.unitprice * (1 - Sales.OrderDetails.discount))) AS TotalAmount
FROM [Sales].[OrderDetails] JOIN [Sales].[Orders] ON Sales.OrderDetails.orderid = Sales.Orders.orderid
WHERE shipcountry IN ('France', 'Germany', 'USA') AND YEAR(orderdate) >= 2007

GO
-- 3- What countries have purchased over 40000 USD?
SELECT shipcountry, SUM (Sales.OrderDetails.qty * (Sales.OrderDetails.unitprice * (1 - Sales.OrderDetails.discount))) AS TotalAmount
FROM [Sales].[OrderDetails] JOIN [Sales].[Orders] ON Sales.OrderDetails.orderid = Sales.Orders.orderid
GROUP BY shipcountry
HAVING SUM (Sales.OrderDetails.qty * (Sales.OrderDetails.unitprice * (1 - Sales.OrderDetails.discount)))>= 40000
ORDER BY TotalAmount
GO
-- 4- What are the Average, Count, and Summation of sales for each customer who bought beverage and seafood products and exported by shippers #2 AND #3 to the US?  
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

-- 5- What is the maximum order date for each cutomers?
SELECT custid , MAX(orderdate) as MaxOrderDate FROM [Sales].[Orders]
GROUP BY custid
GO

-- 6- What is the ranking of the cutomers by sales? mention in a separate column
SELECT custid,
SUM (Sales.OrderDetails.qty * (Sales.OrderDetails.unitprice * (1 - Sales.OrderDetails.discount))) AS TotalAmount,
RANK() OVER(ORDER BY SUM (Sales.OrderDetails.qty * (Sales.OrderDetails.unitprice * (1 - Sales.OrderDetails.discount))) DESC) AS Rank
FROM [Sales].[OrderDetails] JOIN [Sales].[Orders] ON Sales.OrderDetails.orderid = Sales.Orders.orderid
GROUP BY custid

