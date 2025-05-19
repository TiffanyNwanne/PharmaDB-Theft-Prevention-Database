-- Creating Database
CREATE DATABASE PharmaDB;
GO

--Create Table Structure
CREATE TABLE Inventory (
             ItemID INT PRIMARY KEY,
			 ItemName NVARCHAR(100),
			 Quantity INT,
			 Location NVARCHAR(100),
			 LastUpdated DATETIME DEFAULT GETDATE());

CREATE TABLE Transactions (
             TransactionID INT IDENTITY(1,1) PRIMARY KEY,
			 ItemID INT FOREIGN KEY REFERENCES Inventory(ItemID),
			 QuantityChange INT,
			 Timestamp DATETIME DEFAULT GETDATE(),
			 UserID NVARCHAR(50)
			 );

-- Assign Roles
CREATE ROLE OperatorROLE;
CREATE ROLE SupervisorROLE;
CREATE ROLE AuditorROLE;

-- Allow only select/insert foroperator role
GRANT SELECT,INSERT ON Inventory TO OperatorROLE;

-- Create Sample Dataset For Testing
INSERT INTO Inventory (ItemID,ItemName, Quantity, Location)
VALUES
(1, 'Paracetamol Raw Powder', 1000, 'Warehouse A'),
(2, 'Ibuprofen Raw Powder', 800, 'Warehouse A'),
(3, 'Packaging Material -Blister Pack', 5000, 'Packaging Zone');

SELECT * FROM Inventory;

INSERT INTO Transactions (ItemID, QuantityChange, UserID)
VALUES
(1, -50, 'operator1'),
(2, -30, 'operator1'),
(3, -200, 'operator2'),
(1, -500, 'operator3');

SELECT * FROM Transactions;

-- Set Up Alerts
CREATE TRIGGER trg_theftAlert
ON Transactions
AFTER INSERT
AS
BEGIN
     SET NOCOUNT ON;
	 IF EXISTS(
	 SELECT 1 FROM inserted WHERE QuantityChange <-200
	 )
	 BEGIN
	 PRINT 'ALERT: Large quantity deduction detected!';
	 END
END;

--Test the Alert
INSERT INTO Transactions(itemID, QuantityChange, UserID)
VALUES(2,-500, 'operator4');

-- Review Suspicious Entries in Actual Table
SELECT *  FROM [PharmaDB].[dbo].[transactions_sample_100rows] WHERE QuantityChange <-200;

-- View recent Entries
SELECT TOP 10 * FROM  [PharmaDB].[dbo].[transactions_sample_100rows] ORDER BY Timestamp DESC;
