--- E-commerce Recommendation and User Behavior Analytics

--- Creating DATABASE

CREATE DATABASE ECOMMERCE;

--- Selecting the DATABASE

USE ECOMMERCE;

--- Creating the Users Table

CREATE TABLE Users(
    UserID INT PRIMARY KEY,
    Name NVARCHAR(100),
    Email NVARCHAR(100),
    JoinDate DATE
);

--- Creating the Products Table

CREATE TABLE Products(
    ProductID INT PRIMARY KEY,
    ProductName NVARCHAR (100),
    Category NVARCHAR (50),
    Price DECIMAL(10,2),
    Stock INT
);

--- Creating the Orders Table

CREATE TABLE Orders(
    OrderID INT PRIMARY KEY,
    UserID INT,
    OrderDate DATE,
    TotalAmount DECIMAL(10,2),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

--- Creating the OrderDetails Table

CREATE TABLE OrderDetails(
    OrderDetailID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    Subtotal DECIMAL(10,2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

--- Creating the ProductRecommendations Table

CREATE TABLE ProductRecommendations(
    RecommendationID INT PRIMARY KEY,
    UserID INT,
    ProductID INT,
    RecommendedDate DATE,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

--- Creating the RecommendationAudit Table

CREATE TABLE RecommendationAudit(
    AuditID INT PRIMARY KEY,
    UserID INT,
    ProductID INT,
    RecommendedDate DATE,
    AuditDate DATETIME,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- USER DATA
INSERT INTO Users (UserID, Name, Email, JoinDate) VALUES
(1, 'Alice', 'alice@example.com', '2024-01-15'),
(2, 'Bob', 'bob@example.com', '2024-03-22'),
(3, 'Charlie', 'charlie@example.com', '2024-05-10'),
(4, 'Diana', 'diana@example.com', '2024-06-01'),
(5, 'Eve', 'eve@example.com', '2024-07-12'),
(6, 'Frank', 'frank@example.com', '2024-08-15'),
(7, 'Grace', 'grace@example.com', '2024-09-10'),
(8, 'Hank', 'hank@example.com', '2024-10-01'),
(9, 'Ivy', 'ivy@example.com', '2024-11-05'),
(10, 'Jack', 'jack@example.com', '2024-12-01');


-- PRODUCTS DATA
INSERT INTO Products (ProductID, ProductName, Category, Price, Stock) VALUES
(101, 'Laptop', 'Electronics', 700.00, 50),
(102, 'Headphones', 'Electronics', 50.00, 200),
(103, 'Coffee Maker', 'Appliances', 80.00, 75),
(104, 'Smartphone', 'Electronics', 500.00, 120),
(105, 'Blender', 'Appliances', 60.00, 90),
(106, 'Tablet', 'Electronics', 300.00, 100),
(107, 'Microwave', 'Appliances', 150.00, 40),
(108, 'Gaming Console', 'Electronics', 400.00, 30),
(109, 'Vacuum Cleaner', 'Appliances', 120.00, 60),
(110, 'Smartwatch', 'Electronics', 200.00, 150);

-- ORDERS DATA
INSERT INTO Orders (OrderID, UserID, OrderDate, TotalAmount) VALUES
(1, 1, '2024-06-10', 750.00),
(2, 2, '2024-07-05', 80.00),
(3, 3, '2024-07-15', 900.00),
(4, 4, '2024-08-01', 120.00),
(5, 5, '2024-08-20', 650.00),
(6, 6, '2024-09-05', 400.00),
(7, 7, '2024-09-25', 150.00),
(8, 8, '2024-10-10', 1000.00),
(9, 9, '2024-10-25', 200.00),
(10, 10, '2024-11-10', 750.00);

-- ORDER DETAILS DATA
INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity, Subtotal) VALUES
(1, 1, 101, 1, 700.00),
(2, 1, 102, 1, 50.00),
(3, 2, 103, 1, 80.00),
(4, 3, 104, 1, 500.00),
(5, 3, 106, 2, 400.00),
(6, 4, 105, 2, 120.00),
(7, 5, 108, 1, 400.00),
(8, 5, 109, 2, 240.00),
(9, 6, 102, 8, 400.00),
(10, 7, 110, 1, 150.00);

-- PRODUCT RECOMMENDATION DATA
INSERT INTO ProductRecommendations (RecommendationID, UserID, ProductID, RecommendedDate) VALUES
(1, 1, 103, '2024-06-12'),
(2, 1, 104, '2024-06-15'),
(3, 2, 105, '2024-07-07'),
(4, 2, 106, '2024-07-09'),
(5, 3, 107, '2024-07-17'),
(6, 4, 108, '2024-08-05'),
(7, 5, 109, '2024-08-22'),
(8, 6, 110, '2024-09-07'),
(9, 7, 101, '2024-09-27'),
(10, 8, 102, '2024-10-12');

-- ## BASIC QUERY ## --

-- 1. Fetch all orders placed by users who joined before March 2024.

SELECT OrderID, O.UserID, Name, OrderDate, TotalAmount, JoinDate
FROM Orders O
INNER JOIN Users U
ON O.UserID = U.UserID
WHERE JoinDate < '2024-03-01';

-- 2. List all products under the "Electronics" category with price greater than $100.

SELECT *
FROM Products
WHERE Category = 'Electronics' AND Price >100;

-- ## FUNCTIONS ## -- 

-- 1. Scalar function to calculate total revenue from all orders.

GO
CREATE FUNCTION GetTotalRevenue()
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @TotalRevenue DECIMAL(10,2)
    SELECT @TotalRevenue = SUM(TotalAmount) FROM Orders;
    RETURN @TotalRevenue;
END;
GO

--- USAGE

SELECT DBO.GetTotalRevenue() AS 'Total Revenue';

-- 2. Function to return total products purchased by a specific user.

GO
CREATE FUNCTION GetTotalProductsPurchased(@UserID INT)
RETURNS INT
AS
BEGIN
    DECLARE @TotalProductsPurchased INT
    SELECT @TotalProductsPurchased = SUM(Quantity)
    FROM Orders O
    INNER JOIN OrderDetails OD
    ON O.OrderID = OD.OrderID
    WHERE UserID = @UserID;
    RETURN @TotalProductsPurchased;
END;
GO

---USAGE

SELECT DBO.GetTotalProductsPurchased(1) AS 'Total Products Purchased'

-- ## TRANSACTION ## --
-- 1. Transaction to place an order ensuring consistency.

BEGIN TRANSACTION;

BEGIN TRY
    -- Insert into Order
    INSERT INTO Orders
    VALUES (11, 5, '2024-12-09', 1500)

    -- Insert into OrderDetails
    INSERT INTO OrderDetails
    VALUES (11, 11, 108, 2, 3000)

    -- Update Products
    UPDATE Products
    SET Stock = Stock-2
    WHERE ProductID = 108

    COMMIT TRANSACTION;
END TRY

BEGIN CATCH
    ROLLBACK TRANSACTION;
    THROW;
END CATCH;

-- ## STORED PROCEDURE ## --
-- 1. Stored procedure to add a new user and recommend a random product.
GO
CREATE PROCEDURE AddUserAndRecommendProduct
    @UserID INT,
    @Name VARCHAR(100),
    @Email VARCHAR(100),
    @JoinDate DATE
AS
BEGIN
    -- Check if the userid is already available in the table
    IF EXISTS (SELECT 1 FROM Users WHERE UserID = @UserID)
    BEGIN
        PRINT 'Error: UserID already exists';
        RETURN;
    END;
    
    -- Insert the new user
    INSERT INTO Users
    VALUES (@UserID, @Name, @Email, @JoinDate);

    DECLARE @ProductID INT;
    DECLARE @RecommendationID INT;

    -- Generate the next RecommendataionID
    SELECT @RecommendationID = ISNULL(MAX(RecommendationID), 0)+1 FROM ProductRecommendations;

    -- Recommend a random Product
    SELECT TOP 1 @ProductID = ProductID FROM Products ORDER BY NEWID();

    -- Insert the recommendation with the genreated id
    INSERT INTO ProductRecommendations
    VALUES (@RecommendationID, @UserID, @ProductID, GETDATE());

    PRINT 'User and Recommendation are added successfully.'

END;

-- Adding user with ID 11

EXEC AddUserAndRecommendProduct
    @UserID = 11,
    @Name = 'Shabnas',
    @Email = 'shabnas@gmail.com',
    @JoinDate = '2023-01-16'

-- Adding user with ID 12

EXEC AddUserAndRecommendProduct
    @UserID = 12,
    @Name = 'Hashir',
    @Email = 'hashir@gmail.com',
    @JoinDate = '2023-05-27'

-- Verifying the results

-- User Table
SELECT * FROM Users WHERE UserID IN (11, 12);

-- ProductRecommendation Table
SELECT * FROM ProductRecommendations WHERE UserID IN (11, 12);

-- ## Analytical Questions ## --

-- 1. Fetch the total revenue grouped by product categories with max to min

SELECT Category, SUM(Subtotal) AS 'Revenue'
FROM OrderDetails OD
INNER JOIN Products P
ON P.ProductID = OD.ProductID
GROUP BY Category
ORDER BY 2 DESC;

-- 2. Identify the top 2 user Name, ID, total with the highest spending.

SELECT TOP 2 O.UserID, U.Name, SUM(TotalAmount) TotalSpend
FROM Orders O
INNER JOIN Users U
ON O.UserID = U.UserID
GROUP BY O.UserID, U.Name
ORDER BY 3 DESC;

-- 3. Suggest products not yet purchased by a specific user.

SELECT ProductID, ProductName, Category
FROM Products
WHERE ProductID NOT IN (SELECT ProductID
                        FROM Orders O
                        INNER JOIN OrderDetails OD
                        ON O.OrderID = OD.OrderID
                        WHERE UserID = 1)

--- FUNCTION

GO
CREATE FUNCTION GetProductsNotOrdered(@UserID INT)
RETURNS TABLE
AS
RETURN
(SELECT ProductID, ProductName, Category
FROM Products
WHERE ProductID NOT IN (SELECT ProductID
                        FROM Orders O
                        INNER JOIN OrderDetails OD
                        ON O.OrderID = OD.OrderID
                        WHERE UserID = 1));

--- Execution
SELECT * FROM DBO.GetProductsNotOrdered(7)