-- ------------------------------------------------------------------------------------
-- Question 1: Achieving 1NF (First Normal Form) 🛠️
-- ------------------------------------------------------------------------------------
-- Task:
-- You are given the following table ProductDetail:
--
-- OrderID  | CustomerName | Products
-- ---------|--------------|--------------------------
-- 101      | John Doe     | Laptop, Mouse
-- 102      | Jane Smith   | Tablet, Keyboard, Mouse
-- 103      | Emily Clark  | Phone
--
-- In the table above, the Products column contains multiple values, which violates 1NF.
-- Write an SQL query to transform this table into 1NF, ensuring that each row
-- represents a single product for an order.
-- ------------------------------------------------------------------------------------

SELECT 101 AS OrderID, 'John Doe' AS CustomerName, 'Laptop' AS Product
UNION ALL
SELECT 101 AS OrderID, 'John Doe' AS CustomerName, 'Mouse' AS Product
UNION ALL
SELECT 102 AS OrderID, 'Jane Smith' AS CustomerName, 'Tablet' AS Product
UNION ALL
SELECT 102 AS OrderID, 'Jane Smith' AS CustomerName, 'Keyboard' AS Product
UNION ALL
SELECT 102 AS OrderID, 'Jane Smith' AS CustomerName, 'Mouse' AS Product
UNION ALL
SELECT 103 AS OrderID, 'Emily Clark' AS CustomerName, 'Phone' AS Product;

-- Explanation for 1NF:
-- The original 'Products' column contained multiple values (e.g., "Laptop, Mouse").
-- 1NF requires that each cell in a table must hold a single, atomic value.
-- The query above transforms the data so that each product for an order
-- is on a separate row, satisfying 1NF.
-- A possible table structure for this 1NF data could be:
/*
CREATE TABLE ProductDetail_1NF (
    OrderID INT,
    CustomerName VARCHAR(255),
    Product VARCHAR(255)
    -- A primary key for this table might be (OrderID, Product)
    -- assuming an order cannot have the same product listed twice.
    -- If it can (e.g. two separate line items for the same product),
    -- an additional OrderItemID or similar surrogate key would be needed.
);
*/

-- ------------------------------------------------------------------------------------
-- Question 2: Achieving 2NF (Second Normal Form) 🧩
-- ------------------------------------------------------------------------------------
-- Task:
-- You are given the following table OrderDetails, which is already in 1NF
-- but still contains partial dependencies:
--
-- OrderID  | CustomerName | Product  | Quantity
-- ---------|--------------|----------|----------
-- 101      | John Doe     | Laptop   | 2
-- 101      | John Doe     | Mouse    | 1
-- 102      | Jane Smith   | Tablet   | 3
-- 102      | Jane Smith   | Keyboard | 1
-- 102      | Jane Smith   | Mouse    | 2
-- 103      | Emily Clark  | Phone    | 1
--
-- In the table above, the CustomerName column depends on OrderID
-- (a partial dependency), which violates 2NF.
-- Write an SQL query to transform this table into 2NF by removing partial
-- dependencies. Ensure that each non-key column fully depends on the
-- entire primary key.
-- ------------------------------------------------------------------------------------

-- To achieve 2NF, we decompose the table into two new tables:
-- 1. Orders (OrderID PK, CustomerName)
-- 2. OrderItems (OrderID FK, Product, Quantity), with (OrderID, Product) as PK.

-- First,I will create and populate the original unnormalized (but 1NF) table
-- to demonstrate the transformation.
-- (Dropping tables if they exist to make the script re-runnable)
DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS OrderDetails_Pre2NF;

CREATE TABLE OrderDetails_Pre2NF (
    OrderID INT,
    CustomerName VARCHAR(255),
    Product VARCHAR(255),
    Quantity INT
    -- Implicit composite primary key for analysis: (OrderID, Product)
);

INSERT INTO OrderDetails_Pre2NF (OrderID, CustomerName, Product, Quantity) VALUES
(101, 'John Doe', 'Laptop', 2),
(101, 'John Doe', 'Mouse', 1),
(102, 'Jane Smith', 'Tablet', 3),
(102, 'Jane Smith', 'Keyboard', 1),
(102, 'Jane Smith', 'Mouse', 2),
(103, 'Emily Clark', 'Phone', 1);

-- SQL queries to transform OrderDetails_Pre2NF into 2NF:

-- 1. Create the 'Orders' table for information solely dependent on OrderID.
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(255)
);

-- Populate the 'Orders' table.
-- CustomerName fully depends on OrderID.
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails_Pre2NF;

-- 2. Create the 'OrderItems' table for information dependent on the composite key (OrderID, Product).
CREATE TABLE OrderItems (
    OrderID INT,
    Product VARCHAR(255),
    Quantity INT,
    PRIMARY KEY (OrderID, Product), -- Composite primary key
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Populate the 'OrderItems' table.
-- Quantity fully depends on the composite key (OrderID, Product).
INSERT INTO OrderItems (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails_Pre2NF;

-- Explanation for 2NF:
-- The original 'OrderDetails_Pre2NF' table had a partial dependency:
-- 'CustomerName' depended only on 'OrderID', which is only a part of the
-- candidate key (OrderID, Product).
-- By splitting the table:
-- - 'Orders' table now has 'OrderID' as its primary key, and 'CustomerName'
--   fully depends on it.
-- - 'OrderItems' table has a composite primary key (OrderID, Product), and
--   'Quantity' fully depends on this entire key.
-- Both new tables are in 2NF.
-- ------------------------------------------------------------------------------------
