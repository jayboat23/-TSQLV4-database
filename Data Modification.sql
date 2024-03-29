---------------------------------------------------------------------
-- Microsoft SQL Server T-SQL Fundamentals
-- Chapter 08 - Data Modification
---------------------------------------------------------------------

-- 1
-- Run the following code to create the dbo.Customers table
-- in the TSQLV4 database
USE TSQLV4;

DROP TABLE IF EXISTS dbo.Customers;

CREATE TABLE dbo.Customers
(
  custid      INT          NOT NULL PRIMARY KEY,
  companyname NVARCHAR(40) NOT NULL,
  country     NVARCHAR(15) NOT NULL,
  region      NVARCHAR(15) NULL,
  city        NVARCHAR(15) NOT NULL  
);
GO

-- 1-1
-- Insert into the dbo.Customers table a row with:
-- custid:  100
-- companyname: Coho Winery
-- country:     USA
-- region:      WA
-- city:        Redmond

-- Solution:
INSERT INTO dbo.Customers(custid, companyname, country, region, city)
  VALUES(100, N'Coho Winery', N'USA', N'WA', N'Redmond');

-- 1-2
-- Insert into the dbo.Customers table 
-- all customers from Sales.Customers
-- who placed orders

-- Solution:
INSERT INTO dbo.Customers(custid, companyname, country, region, city)
  SELECT custid, companyname, country, region, city
  FROM Sales.Customers AS C
  WHERE EXISTS
    (SELECT * FROM Sales.Orders AS O
     WHERE O.custid = C.custid);

-- 1-3
-- Use a SELECT INTO statement to create and populate the dbo.Orders table
-- with orders from the Sales.Orders
-- that were placed in the years 2014 through 2016

-- Solution:
DROP TABLE IF EXISTS dbo.Orders;

SELECT *
INTO dbo.Orders
FROM Sales.Orders
WHERE orderdate >= '20140101'
  AND orderdate < '20170101';

-- 2
-- Delete from the dbo.Orders table
-- orders that were placed before August 2014
-- Use the OUTPUT clause to return the orderid and orderdate
-- of the deleted orders


-- Solution:
DELETE FROM dbo.Orders
  OUTPUT deleted.orderid, deleted.orderdate
WHERE orderdate < '20140801';

-- 3
-- Delete from the dbo.Orders table orders placed by customers from Brazil

-- Solution:
DELETE FROM dbo.Orders
WHERE EXISTS
  (SELECT *
   FROM dbo.Customers AS C
   WHERE dbo.Orders.custid = C.custid
     AND C.country = N'Brazil');
---Solution option 2:
DELETE FROM O
FROM dbo.Orders AS O
  INNER JOIN dbo.Customers AS C
    ON O.custid = C.custid
WHERE country = N'Brazil';
---Solution option 3:
MERGE INTO dbo.Orders AS O
USING (SELECT * FROM dbo.Customers WHERE country = N'Brazil') AS C
  ON O.custid = C.custid
WHEN MATCHED THEN DELETE;
-- 4
-- Run the following query against dbo.Customers,
-- and notice that some rows have a NULL in the region column
SELECT * FROM dbo.Customers;




-- Update the dbo.Customers table and change all NULL region values to '<None>'
-- Use the OUTPUT clause to show the custid, old region and new region



-- Solution:
UPDATE dbo.Customers
  SET region = '<None>'
OUTPUT
  deleted.custid,
  deleted.region AS oldregion,
  inserted.region AS newregion
WHERE region IS NULL;

-- 5
-- Update in the dbo.Orders table all orders placed by UK customers
-- and set their shipcountry, shipregion, shipcity values
-- to the country, region, city values of the corresponding customers from dbo.Customers


UPDATE O
  SET shipcountry = C.country,
      shipregion = C.region,
      shipcity = C.city
FROM dbo.Orders AS O
  INNER JOIN dbo.Customers AS C
    ON O.custid = C.custid
WHERE C.country = N'UK';

WITH CTE_UPD AS
(
  SELECT
    O.shipcountry AS ocountry, C.country AS ccountry,
    O.shipregion  AS oregion,  C.region  AS cregion,
    O.shipcity    AS ocity,    C.city    AS ccity
  FROM dbo.Orders AS O
    INNER JOIN dbo.Customers AS C
      ON O.custid = C.custid
  WHERE C.country = N'UK'
)
UPDATE CTE_UPD
  SET ocountry = ccountry, oregion = cregion, ocity = ccity;

MERGE INTO dbo.Orders AS O
USING (SELECT * FROM dbo.Customers WHERE country = N'UK') AS C
  ON O.custid = C.custid
WHEN MATCHED THEN
  UPDATE SET shipcountry = C.country,
             shipregion = C.region,
             shipcity = C.city;

-- 6
-- Run the following code to create the tables Orders and OrderDetails and populate them with data

USE TSQLV4;

DROP TABLE IF EXISTS dbo.OrderDetails, dbo.Orders;

CREATE TABLE dbo.Orders
(
  orderid        INT          NOT NULL,
  custid         INT          NULL,
  empid          INT          NOT NULL,
  orderdate      DATE         NOT NULL,
  requireddate   DATE         NOT NULL,
  shippeddate    DATE         NULL,
  shipperid      INT          NOT NULL,
  freight        MONEY        NOT NULL
    CONSTRAINT DFT_Orders_freight DEFAULT(0),
  shipname       NVARCHAR(40) NOT NULL,
  shipaddress    NVARCHAR(60) NOT NULL,
  shipcity       NVARCHAR(15) NOT NULL,
  shipregion     NVARCHAR(15) NULL,
  shippostalcode NVARCHAR(10) NULL,
  shipcountry    NVARCHAR(15) NOT NULL,
  CONSTRAINT PK_Orders PRIMARY KEY(orderid)
);

CREATE TABLE dbo.OrderDetails
(
  orderid   INT           NOT NULL,
  productid INT           NOT NULL,
  unitprice MONEY         NOT NULL
    CONSTRAINT DFT_OrderDetails_unitprice DEFAULT(0),
  qty       SMALLINT      NOT NULL
    CONSTRAINT DFT_OrderDetails_qty DEFAULT(1),
  discount  NUMERIC(4, 3) NOT NULL
    CONSTRAINT DFT_OrderDetails_discount DEFAULT(0),
  CONSTRAINT PK_OrderDetails PRIMARY KEY(orderid, productid),
  CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY(orderid)
    REFERENCES dbo.Orders(orderid),
  CONSTRAINT CHK_discount  CHECK (discount BETWEEN 0 AND 1),
  CONSTRAINT CHK_qty  CHECK (qty > 0),
  CONSTRAINT CHK_unitprice CHECK (unitprice >= 0)
);
GO

INSERT INTO dbo.Orders SELECT * FROM Sales.Orders;
INSERT INTO dbo.OrderDetails SELECT * FROM Sales.OrderDetails;

-- Write and test the T-SQL code that is required to truncate both tables,
-- and make sure that your code runs successfully

-- Solution
ALTER TABLE dbo.OrderDetails DROP CONSTRAINT FK_OrderDetails_Orders;

TRUNCATE TABLE dbo.OrderDetails;
TRUNCATE TABLE dbo.Orders;

ALTER TABLE dbo.OrderDetails ADD CONSTRAINT FK_OrderDetails_Orders
  FOREIGN KEY(orderid) REFERENCES dbo.Orders(orderid);


