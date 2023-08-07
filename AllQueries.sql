-- USE ITI_System --

----------------------------------------------------------------------------------------------------------------------------------------------------------------
---Simple Querires 
---JOINS
---DB Constraints and DDLs


-- Display all the employees Data.
select *
from Employee

-- Display the Department id, name and id and the first name of its manager
SELECT d.Dep_ID, d.Dep_Name, m.FirstName as manager_firstname
FROM Department d
INNER JOIN Employee m
ON d.ManagerID = m.Emp_ID;

-- Display the full data about all the dependence associated with the name (first ,last) as "EmployeeFullName" of the employee they depend on him/her.
SELECT em.FirstName + ' ' + em.LastName AS EmployeeFullName, dp.*
FROM Employee em
INNER JOIN Dependant dp
ON em.Emp_ID = dp.Emp_ID;

-- Display the Id, name and address of the employess in Cairo or Alex city.
SELECT Emp_ID, CONCAT(FirstName ,' ', LastName) AS FullName, Address  
FROM Employee
WHERE Address in ('Cairo', 'Alex');

-- Display the employees full data with a name starts with "a" letter. 
SELECT * FROM Employee WHERE FirstName like 'a%'
-- Another solution way
SELECT * FROM Employee WHERE LEFT(FirstName,1) = 'a'

-- Retrieve a list of all employees, including those who are assigned to a department and those who are not. 
SELECT em.*, dp.*
FROM Employee em
LEFT JOIN Department dp
ON em.Dep_ID = dp.Dep_ID;

-- Insert your personal data to the employee table as a new employee in department number 10, SSN = 1000, manager id = 1, salary=3000. 
INSERT INTO Employee (FirstName, MiddleName, LastName, Dep_ID, SSN, Manager_ID, Salary)
VALUES ('Mohamed', 'Medhat', 'Mohamed', 10, 1000, 1, 3000);

-- Insert another employee with personal data your friend as new employee in department number 10, SSN = 1010, but don’t enter any value for salary or supervisor number to him. 
INSERT INTO Employee (FirstName, MiddleName, LastName, Dep_ID, SSN)
VALUES ('Mazen', 'Mohamed', 'Hassan', 10, 1010);


-- Upgrade your salary by 20 % of its last value. 
UPDATE Employee
SET Salary = Salary + (Salary*0.2)
WHERE SSN = 1000 AND MiddleName = 'Medhat';

-- Create Instructor table with its constrains
CREATE TABLE Instructor (
	ID INT PRIMARY KEY IDENTITY(1,1),
	Fname varchar(10),
	Lname varchar(10),
	DB Datetime,
	Age AS Year(getdate()) - Year(DB),
	Salary INT CHECK (salary >= 1000 AND salary <= 5000),
	Overtime INT,
	Netsalary AS Salary + Overtime,
	HireDate Date DEFAULT GETDATE(),
	Address varchar(5) CHECK (Address IN ('Cairo', 'Alex')),
	UNIQUE (Overtime)

)


----------------------------------------------------------------------------------------------------------------------------------------------------------------
---Subqueries 
---Agregation Functinons
---GROUP BY - HAVING
---Transactions


-- List the course name and average Hour_Rate for each course, but only if Hour_Rate is not NULL.
SELECT c.Crs_Name, AVG(inc.HourRate)  AS Average_of_Hour_Rate
FROM Course c
JOIN Instructor_Course inc
ON c.Crs_ID = inc.Crs_ID
WHERE inc.HourRate IS NOT NULL
GROUP BY c.Crs_Name


-- Retrieve the department name, maximum, minimum, and average salary of its employees, and the number of employees in each department.
SELECT d.Dep_Name, MIN(e.Salary) minEmployeesSalary, MAX(e.Salary) maxEmployeesSalary, AVG(e.Salary) avgSalaries, COUNT(e.Emp_ID) TotalEmployees
FROM Department d
JOIN Employee e
ON d.Dep_ID = e.Dep_ID
GROUP BY d.Dep_Name


-- Retrieve the total salaries for employees over 50 years old in a department, but only if the total salaries exceed 3,500.
SELECT SUM(salary)
FROM Employee
WHERE age > 50 
Group by dep_id 
Having AVG(Salary) > 3500


-- Display all employee data if their salary is less than the average salary of all employees.
SELECT * 
FROM Employee
WHERE Salary < (SELECT AVG(Salary) from Employee)


-- Display employee addresses where the average salary for that address is less than the average salary for all employees. 
SELECT Address 
FROM Employee
GROUP BY Address
HAVING AVG(Salary) < (SELECT AVG(Salary) from Employee)


-- Insert employees’ data with valid and invalid department IDs, and handle any errors that occur during the transaction. The data should be logged in the Employee Table, and all errors should be displayed.
BEGIN TRY 
	BEGIN TRAN
		INSERT INTO Employee(Emp_ID,FirstName,LastName,Dep_ID) VALUES (100,'Mohamed','Medhat',10)--VALID
		INSERT INTO Employee(Emp_ID,FirstName,LastName,Dep_ID) VALUES (101,'Mohamed','Medhat',10)--VALID
		COMMIT
END TRY
BEGIN CATCH
		SELECT ERROR_MESSAGE()
		ROLLBACK
END CATCH

BEGIN TRY 
	BEGIN TRAN
		INSERT INTO Employee(FirstName,LastName,Dep_ID) VALUES ('Mohamed','Medhat',10)--INVALID
		INSERT INTO Employee(FirstName,LastName,Dep_ID) VALUES ('Mohamed','Medhat',10)--INVALID
		COMMIT
END TRY
BEGIN CATCH 
		SELECT ERROR_MESSAGE()
		ROLLBACK
END CATCH

-- Combine salary data for employees and instructors over 25 years old 
-- a. Union, 
SELECT Salary
FROM Employee
WHERE Age > 25
UNION
SELECT Salary
FROM Employee
WHERE Age > 25

-- b. Union All, 
SELECT Salary
FROM Employee
WHERE Age > 25
UNION ALL
SELECT Salary
FROM instructor
WHERE Age > 25

-- c. Intersect, 
SELECT Salary
FROM Employee
WHERE Age > 25
INTERSECT
SELECT Salary
FROM instructor
WHERE Age > 25

-- d. except.
SELECT Salary
FROM Employee
WHERE Age > 25
EXCEPT
SELECT Salary
FROM instructor
WHERE Age > 25


----------------------------------------------------------------------------------------------------------------------------------------------------------------
---Ranking Functions
---CTEs (Common Table Expression)
---CASE statement - IIF 


-- Retrieve the rank of each employee based on their salary, with ties given the same rank and no gaps in the ranking. (Display Emp_Id, Names , Salaries)
SELECT Emp_ID, FirstName + ' ' + LastName AS FullName, Salary, DENSE_RANK() OVER(order by salary) AS Ranks
FROM Employee


-- Retrieve the rank of each employee based on their salary, with ties given the same rank and no gaps in the ranking portioned by Department id  (Display Emp_Id, Names , Salaries, Dep_Id)
SELECT Emp_ID, FirstName + ' ' + LastName AS FullName, Salary, Dep_ID, DENSE_RANK() OVER(partition by Dep_ID order by salary) AS Ranks 
FROM Employee


-- Retrieve the rank of each employee based on their age, with sequential/Serial rank in the ranking. (Display Emp_Id, Names , age)
SELECT Emp_ID, FirstName + ' ' + LastName AS FullName, age, ROW_NUMBER() OVER(order by age)
FROM Employee


-- Retrieve the rank of each employee based on their age, with sequential/Serial rank in the ranking portioned by Address (Display Emp_Id, Names , age, Address)
SELECT Emp_ID, FirstName + ' ' + LastName AS FullName, age, address, ROW_NUMBER() OVER(partition by address order by age)
FROM Employee

-- Retrieve the grouping of each employee based on their department id, into 3 Groups (Display Emp_Id, Names , Dep_Id)
SELECT Emp_ID, FirstName + ' ' + LastName AS FullName, Dep_ID, NTILE(3) OVER(order by dep_id)
FROM Employee


-- From Query(3) Try to delete actual last employee ranked and make sure that table actually affected.
with CTE_Top AS 
(
SELECT Emp_ID, FirstName + ' ' + LastName AS FullName, age, 
ROW_NUMBER() OVER(order by age desc) as ranked
FROM Employee 
) 
DELETE FROM CTE_Top where ranked = 1


---another solution
DELETE FROM Employee 
WHERE Emp_ID = 
(SELECT TOP(1) Emp_ID, FirstName + ' ' + LastName AS FullName, age, 
ROW_NUMBER() OVER(order by age DESC) FROM Employee )

/*  Using Case Statement to update Instuctor salary data 
 	Whithin value salary less than 500  updated it by updated it by  10 %
  	salary Between 500 and 1000  updated it by updated it by  20 % others updated it by 30 %
*/
UPDATE Instructor SET Salary =
    CASE
        WHEN Salary < 500 THEN Salary * 1.10 
        WHEN Salary BETWEEN 500 AND 1000 THEN Salary * 1.20 
        ELSE Salary * 1.30  
    END;

-- Display Employee data , Genger in case of ‘M’ Display Male , ‘F’ Display Female.
SELECT *, IIF(gender = 'M', 'Male', 'Female') as gender
FROM Employee 


----------------------------------------------------------------------------------------------------------------------------------------------------------------
---Index
---View
---Functions


-- Create a non-clustered index on the "Dep_ID" column in the "Employee" table. Then, select Dep_ID from Employee. Trace the actual execution plan and mention the scanning type.
CREATE NONCLUSTERED INDEX clst_dep_id on Employee(dep_id)
--testing
SELECT Dep_ID FROM Employee

-- Create an encrypted view named “VW_EmployeeData” that displays "Employee" data for all columns except Salary.
CREATE VIEW VW_EmployeeData 
WITH ENCRYPTION
AS
SELECT Emp_ID, FirstName, LastName, Dep_ID, Age, Gender FROM Employee

-- Create a view named "VW_Department" that displays "Department" data and allows insert/update only for departments with "Dep_Code" values of "SD", "OS", or "BI".
CREATE VIEW VW_Department
AS
SELECT * FROM Department
WHERE Dep_Code IN ('SD', 'OS', 'BI')
--testing
SELECT * FROM VW_Department

-- Create a view named "VW_EmployeeDepartment" that retrieves a list of all employees, including those who are assigned to a department (dep_Name) and those who are not.
CREATE VIEW VW_EmployeeDepartment
AS
SELECT e.*, d.Dep_Name
FROM Employee e LEFT JOIN Department d
ON e.Dep_ID = d.Dep_ID
--testing
SELECT * FROM VW_EmployeeDepartment


-- Create a schema-bound and encrypted view named "VW_Student" for "Student" data, specifically columns "Id" and "Names". Then, create an Unique Clustered index on it (St_ID).
CREATE VIEW VW_Student
WITH SCHEMABINDING, ENCRYPTION
AS
SELECT St_ID, FirstName + ' ' +  LastName AS name
FROM dbo.Student

CREATE UNIQUE CLUSTERED INDEX clst_std on VW_Student(St_ID)

-- Create a user-defined scalar function that accepts two parameters: an employee’s “EmployeeID" and a "Percentage" increase. 
-- The function should calculate and return the new salary after the increase is applied.
CREATE FUNCTION newSalary(@id INT, @perc int)
RETURNS FLOAT
AS
BEGIN
	DECLARE @totalSal INT
	SET @totalSal = (SELECT Salary + Salary*(@perc /100) FROM Employee WHERE Emp_ID = @id)
	RETURN @totalSal
END
--testing
SELECT dbo.newSalary(Emp_ID, 20) FROM Employee WHERE Emp_ID = 1


-- Write an inline function in SQL Server that accepts a table-valued parameter and returns all rows where the gender column equals ‘m’ or ‘f’ (Parameter).
CREATE FUNCTION st_detail(@gender varchar(20))
RETURNS TABLE 
AS 
RETURN
(
	SELECT *
	FROM Employee WHERE gender IN(@gender)
)
--testing
SELECT * FROM st_detail('m') 


-- Create a multi-statement table-valued function in SQL Server that accepts an integer parameter called empId. The function should return a table with three columns: EmployeeId, EmployeeSalary, and StatusMessage. If EmployeeSalary is less than 2000, the StatusMessage should be 'Low'; otherwise, it should be 'High'.
CREATE FUNCTION empData(@empId int)
RETURNS @table TABLE (eid int, salary int, statusMessage varchar(5))
AS
BEGIN
	INSERT INTO @table (eid, salary, statusMessage)
	SELECT Emp_ID, Salary, IIF(Salary < 2000 ,'LOW', 'HIGH') AS statusMessage
	FROM Employee
	WHERE Emp_ID = @empId
	RETURN;
END
--testing
SELECT * FROM empData(1)


----------------------------------------------------------------------------------------------------------------------------------------------------------------
---Stored Procedures
---Triggers
---window functions


-- Create a stored procedure that accepts an employee ID as input and returns the employee's manager data.
CREATE PROC emp_mng(@empID int)
AS
BEGIN
	SELECT mng.*
	FROM Employee e INNER JOIN Employee mng
	ON e.Manager_ID = mng.Emp_ID
	WHERE e.Emp_ID = @empID
END
--testing
emp_mng 8

-- Create a encrypted stored procedure named "GetInstructorCourses" that takes "instructorId" as a parameter and retrieves a list of courses taught by the instructor.
CREATE PROC GetInstructorCourses(@instructorId int)
WITH ENCRYPTION
AS
BEGIN 
	SELECT c.Crs_Name
	FROM Instructor i INNER JOIN Instructor_Course inc ON inc.Ins_ID = i.Ins_ID
	INNER JOIN Course c ON inc.Crs_ID = c.Crs_ID
	WHERE i.Ins_ID = @instructorId
END
--testing
GetInstructorCourses 4

-- Create a stored procedure named "AddNewDepartment" that inserts data into all columns of the "Department" table, handles any errors that occur during insertion, and displays an error message that reads "Error in data insertion in [exception error message]".
CREATE PROC AddNewDepartment (@dID int, @Dname varchar(25), @DepCode varchar(25), @Ddescrip varchar(20), @isAct int, @mngId int)
AS
BEGIN 
	BEGIN TRY
		INSERT INTO Department (Dep_ID, Dep_Name, Dep_Code, Dep_Description, IsActiveDep, ManagerID) VALUES (@dID, @Dname, @DepCode, @Ddescrip, @isAct, @mngId)
	END TRY 
	BEGIN CATCH
		SELECT 'Error in data insertion in' + ERROR_MESSAGE() 
	END CATCH
END
--testing
AddNewDepartment 10,'ui','code100','Learning',0,3    --invalid
AddNewDepartment 11,'data','code101','Learning',1,1  --valid

-- Group the "Sales" table by "Prod_ID" ,"SalesName" using the "Rollup" operator. (Display SalesName, Prod_Id , Sum(Qty)
SELECT SalesName, Prod_ID, SUM(Qty) AS 'TOTAL QUANTITY'
FROM Sales
GROUP BY ROLLUP(Prod_ID,SalesName)

-- Group the "Sales" table by "Prod_ID" and "SalesName" using the "Cube" operator.	(Display Prod_ID,SalesName,SUM(Qty))
SELECT SalesName, Prod_ID, SUM(Qty) AS 'TOTAL QUANTITY'
FROM Sales
GROUP BY CUBE(Prod_ID,SalesName)

-- Group the "Sales" table by "Prod_ID" and "SalesName" using the "Grouping Sets" operator. (Display Prod_ID,SalesName,SUM(Qty))
SELECT SalesName, Prod_ID, SUM(Qty) AS 'TOTAL QUANTITY'
FROM Sales
GROUP BY GROUPING SETS(Prod_ID,SalesName)

-- Retrieve pivoting data for employee’s quantities (Ahmed, Khalid, Ali)
SELECT *  FROM Sales PIVOT (SUM(Qty) FOR SalesName IN ([Ahmed],[Khalid],[Ali])) PVT 


-- Write a trigger that prevents insertion into the "Instructor" table.
Create Trigger PreventNegativeInstructor
On Instructor
INSTEAD OF INSERT 
AS
BEGIN
	RollBack	
END
--testing
Insert Into Instructor (Ins_ID,Salary) Values (105,100)

-- Design a trigger that captures changes made to the "Price" column of the "Course" table during an update and saves the changes to the "AuditHistory" table.
CREATE TRIGGER trigg_4
ON Course
AFTER UPDATE
AS
BEGIN
    -- Check if the "Price" column has been updated
    IF UPDATE(Price)
    BEGIN
        -- Insert the changes into the "AuditHistory" table
        INSERT INTO AuditHistory (UserName, Old_Value, New_Value , UpdatedColumn)
        Values( SUSER_SNAME(), (select price from deleted),(select price from inserted),'Course Price')
    END
END
--testing
UPDATE Course SET Price = 9 WHERE Crs_ID = 1;
