USE [TSQLV4]
GO

-- 1. Total customers for each employee hired after 2014
-- This query selects the first name, last name, employee ID, and the number of distinct customers for each employee hired after 2014.
-- It joins the Employees and Orders tables on empid, uses LEFT JOIN to include employees with no orders, groups by employee details, and orders the result by the number of customers in descending order.
SELECT e.firstname, e.lastname, e.empid, COUNT(o.custid) AS NumberofCustomers 
FROM HR.Employees e
LEFT JOIN Sales.Orders o ON e.empid = o.empid
WHERE YEAR(e.hiredate) >= 2014
GROUP BY e.empid, e.firstname, e.lastname
ORDER BY NumberofCustomers DESC;

-- 2. Total purchase amount by American, French, and German customers after 2007
-- This query selects the shipping country and the total purchase amount for orders from American, French, and German customers after 2007.
-- It joins the OrderDetails and Orders tables on orderid, filters by shipcountry and orderdate, groups by shipcountry, and orders the result by the total amount in descending order.
SELECT o.shipcountry, SUM(od.qty * (od.unitprice * (1 - od.discount))) AS TotalAmount
FROM Sales.OrderDetails od
JOIN Sales.Orders o ON od.orderid = o.orderid
WHERE o.shipcountry IN ('France', 'Germany', 'USA') AND YEAR(o.orderdate) >= 2007
GROUP BY o.shipcountry
ORDER BY TotalAmount DESC;

-- 3. Countries with purchases exceeding 40,000 USD
-- This query selects the shipping country and the total purchase amount for each country where the total amount exceeds 40,000 USD.
-- It joins the OrderDetails and Orders tables on orderid, groups by shipcountry, filters by the total amount, and orders the result by the total amount in descending order.
SELECT o.shipcountry, SUM(od.qty * (od.unitprice * (1 - od.discount))) AS TotalAmount
FROM Sales.OrderDetails od
JOIN Sales.Orders o ON od.orderid = o.orderid
GROUP BY o.shipcountry
HAVING SUM(od.qty * (od.unitprice * (1 - od.discount))) >= 40000
ORDER BY TotalAmount DESC;

-- 4. Sales statistics for customers purchasing beverages and seafood products exported by specific shippers to the US
-- This query selects the customer ID, category name, average amount, total amount, and the number of orders for customers purchasing beverages and seafood products exported by specific shippers to the US.
-- It joins the Categories, Products, Suppliers, OrderDetails, and Orders tables on relevant keys, filters by shipcountry, categoryid, and shipperid, groups by customer ID and category name, and orders the result by the total amount in descending order.
SELECT 
    o.custid,
    c.categoryname,
    AVG(od.qty * (od.unitprice * (1 - od.discount))) AS AverageAmount,
    SUM(od.qty * (od.unitprice * (1 - od.discount))) AS TotalAmount,
    COUNT(*) AS NumberOfOrder
FROM Production.Categories c
JOIN Production.Products p ON c.categoryid = p.categoryid
JOIN Sales.OrderDetails od ON p.productid = od.productid
JOIN Sales.Orders o ON od.orderid = o.orderid
WHERE o.shipcountry = 'USA' AND c.categoryid IN (1, 8) AND o.shipperid IN (2, 3)
GROUP BY o.custid, c.categoryname
ORDER BY TotalAmount DESC;

-- 5. Latest order date for each customer
-- This query selects the customer ID and the latest order date for each customer.
-- It groups the Orders table by customer ID and orders the result by the latest order date in descending order.
SELECT o.custid, MAX(o.orderdate) AS MaxOrderDate 
FROM Sales.Orders o
GROUP BY o.custid
ORDER BY MaxOrderDate DESC;

-- 6. Sales ranking of each customer
-- This query selects the customer ID, total purchase amount, and sales rank for each customer.
-- It joins the OrderDetails and Orders tables on orderid, groups by customer ID, calculates the total amount, ranks customers by the total amount in descending order, and orders the result by rank.
SELECT o.custid,
    SUM(od.qty * (od.unitprice * (1 - od.discount))) AS TotalAmount,
    RANK() OVER(ORDER BY SUM(od.qty * (od.unitprice * (1 - od.discount))) DESC) AS Rank
FROM Sales.OrderDetails od
JOIN Sales.Orders o ON od.orderid = o.orderid
GROUP BY o.custid
ORDER BY Rank;
