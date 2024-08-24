CREATE PROCEDURE GetEmployeesByDepartment
    @DepartmentID INT
AS
BEGIN
    -- Select employee details for the given Department ID
    SELECT 
        EmployeeID,
        FirstName,
        LastName,
        JobTitle,
        HireDate
    FROM 
        Employees
    WHERE 
        DepartmentID = @DepartmentID;
END;
EXEC GetEmployeesByDepartment @DepartmentID = 5;

CREATE PROCEDURE CalculateMonthlySales
@Month INT,
@Year INT
AS
BEGIN
    SELECT CategoryName, SUM(SalesAmount) AS TotalSales
    FROM Sales
    WHERE MONTH(SaleDate) = @Month AND YEAR(SaleDate) = @Year
    GROUP BY CategoryName;
END;
CREATE PROCEDURE UpdateEmployeeSalary
@EmployeeID INT,
@PercentageIncrease DECIMAL(5, 2)
AS
BEGIN
    UPDATE Employees
    SET Salary = Salary * (1 + @PercentageIncrease / 100)
    WHERE EmployeeID = @EmployeeID;
END;
CREATE PROCEDURE CheckRestock
AS
BEGIN
    SELECT ProductName, StockLevel, ReorderLevel
    FROM Products
    WHERE StockLevel < ReorderLevel;
END;
CREATE PROCEDURE AddNewCustomer
@FirstName NVARCHAR(50),
@LastName NVARCHAR(50),
@Email NVARCHAR(100),
@Phone NVARCHAR(20)
AS
BEGIN
    INSERT INTO Customers (FirstName, LastName, Email, Phone)
    VALUES (@FirstName, @LastName, @Email, @Phone);
END;
CREATE PROCEDURE GetPatientDetails
@PatientID INT
AS
BEGIN
    SELECT FirstName, LastName, DateOfBirth, MedicalHistory
    FROM Patients
    WHERE PatientID = @PatientID;
END;
