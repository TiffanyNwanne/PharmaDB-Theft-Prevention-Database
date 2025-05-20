# PharmaDB: Theft Prevention Database

[![](https://github.com/TiffanyNwanne/PharmaDB-Theft-Prevention-Database/blob/main/images/PharmaDB%20ERD.png)](https://github.com/TiffanyNwanne/PharmaDB-Theft-Prevention-Database/blob/main/images/PharmaDB%20ERD.png)


### **Purpose**

The `PharmaDB` database is designed to help prevent and detect **theft or unauthorized material usage** within a pharmaceutical production environment. It provides **real-time tracking**, **auditing**, and **alerts** for suspicious inventory transactions, especially those involving large deductions of raw materials.

[![Preview Image](https://github.com/TiffanyNwanne/PharmaDB-Theft-Prevention-Database/blob/main/images/all%20queries.PNG))](https://github.com/TiffanyNwanne/PharmaDB-Theft-Prevention-Database/blob/main/images/all%20queries.PNG)

---

### **Core Tables**

### **1. Inventory**

Tracks all items in storage or production with current quantities.

- `ItemID` (Primary Key)
- `ItemName`
- `Quantity`
- `Location`

### **2. Transactions**

Logs every material movement — usage, transfer, shrinkage.

- `TransactionID` (Auto-incrementing Primary Key)
- `ItemID` (Foreign Key → Inventory.ItemID)
- `QuantityChange` (Negative values indicate removal)
- `UserID`
- `Timestamp` (Defaults to current date/time)

---

### **Audit & Monitoring Components**

### **Trigger: `trg_theftAlert`**

[![Preview Image](https://github.com/TiffanyNwanne/PharmaDB-Theft-Prevention-Database/blob/main/images/alert%20test.PNG))](https://github.com/TiffanyNwanne/PharmaDB-Theft-Prevention-Database/blob/main/images/alert%20test.PNG)

Monitors inserted transactions for suspicious deductions. If a deduction is greater than `200` units, it logs an alert message.

```sql
IF EXISTS (
    SELECT 1 FROM inserted WHERE QuantityChange < -200
)
```

### **View: `vw_TheftAttempts`**

[![Preview Image](https://github.com/TiffanyNwanne/PharmaDB-Theft-Prevention-Database/blob/main/images/view%20theft%20attempts.PNG))](https://github.com/TiffanyNwanne/PharmaDB-Theft-Prevention-Database/blob/main/images/view%20theft%20attempts.PNG)

Displays all suspicious transactions joined with item details for easy investigation.

```sql
CREATE VIEW vw_TheftAttempts AS
SELECT ...
FROM Transactions T
JOIN Inventory I ON T.ItemID = I.ItemID
WHERE T.QuantityChange < -200;
```

### **Stored Procedure: `sp_GetTheftAttempts`**

A callable procedure to fetch flagged transactions (theft attempts).

```sql
CREATE PROCEDURE sp_GetTheftAttempts
AS
BEGIN
    SELECT ...
    FROM Transactions T
    JOIN Inventory I ON T.ItemID = I.ItemID
    WHERE T.QuantityChange < -200;
END
```

---

### **Testing and Sample Data**

- **Inventory Sample:** 100 items with random quantities and locations
- **Transactions Sample:** 100 records, with 10+ transactions flagged as potential theft

These were imported via `.csv` using the SQL Server Import Wizard.

---

### **Security and Integrity**

- Access is role-based (`Operators`, `Supervisors`, `Auditors`)
- Data changes are traceable via audit triggers
- Inventory balances can be automatically adjusted (optional enhancement)
