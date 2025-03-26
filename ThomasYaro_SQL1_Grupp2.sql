USE master

IF EXISTS(SELECT * FROM sys.databases WHERE name = 'Testk�ping Kommun')
   BEGIN
      ALTER DATABASE [Testk�ping Kommun] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
      DROP DATABASE [Testk�ping Kommun]
   END

         CREATE DATABASE [Testk�ping kommun];
         GO

         USE [Testk�ping kommun]
		 GO 

		 CREATE SCHEMA People;
		 GO

		 CREATE SCHEMA House;
		 GO

		 CREATE TABLE House.HouseHold (
		 HouseHoldID INT NOT NULL IDENTITY (1, 1) PRIMARY KEY,
		 TotalPeople INT NOT NULL,
		 Address NVARCHAR (50) NOT NULL,
		 City CHAR (10) NOT NULL,
		 Country CHAR (7) NOT NULL,
		 TotalIncome DECIMAL(16,2) NOT NULL
		 
		 );

		 GO

         CREATE TABLE People.Person ( 
         PersonID INT NOT NULL IDENTITY (1, 1) PRIMARY KEY, 
         HouseHoldID INT FOREIGN KEY REFERENCES House.Household(HouseHoldID),
         Name NVARCHAR(50) NOT NULL,
		 Gender NVARCHAR (10) NOT NULL,
		 BirthDate DATE NOT NULL,
		 MomID INT NULL,
		 DadID INT NULL,
		 Address NVARCHAR(50) NOT NULL, 
		 EmploymentStatus NVARCHAR(20) NOT NULL,
		 Salary DECIMAL(16,2) NULL,
		 CONSTRAINT FK_MomID FOREIGN KEY (MomID) REFERENCES People.Person(PersonID),
         CONSTRAINT FK_DadID FOREIGN KEY (DadID) REFERENCES People.Person(PersonID)

         );

		 
-- Skapa hush�ll
INSERT INTO House.HouseHold (TotalPeople, Address, City, Country, TotalIncome)
VALUES 
(4, 'Bl�b�rsv�gen 12', 'Testk�ping', 'Sverige', 75000),
(5, 'K�rsb�rsgatan 5', 'Testk�ping', 'Sverige', 97000),
(3, '�ppelv�gen 9', 'Testk�ping', 'Sverige', 25000),
(4, 'Granstigen 4', 'Testk�ping', 'Sverige', 70000),   
(2, 'Tallgatan 8', 'Testk�ping', 'Sverige', 20000),
(3, 'Lingonv�gen 10', 'Testk�ping', 'Sverige', 55000),
(3, 'Hasselv�gen 3', 'Testk�ping', 'Sverige', 60000), 
(5, 'Ekorrstigen 7', 'Testk�ping', 'Sverige', 95000),
(4, 'Bj�rkall�n 15', 'Testk�ping', 'Sverige', 72000),
(3, 'R�nnstigen 18', 'Testk�ping', 'Sverige', 56000),
(6, 'Hallonv�gen 5', 'Testk�ping', 'Sverige', 122000), 
(4, 'Orkid�v�gen 9', 'Testk�ping', 'Sverige', 87000),
(5, 'Solrosv�gen 14', 'Testk�ping', 'Sverige', 95000), 
(3, 'Vitsippsv�gen 8', 'Testk�ping', 'Sverige', 70000), 
(4, 'Regnb�gsv�gen 22', 'Testk�ping', 'Sverige', 85000), 
(2, 'Nyponv�gen 6', 'Testk�ping', 'Sverige', 45000), 
(3, 'Talgoxestigen 12', 'Testk�ping', 'Sverige', 55000),
(4, 'Vinterv�gen 16', 'Testk�ping', 'Sverige', 82000),
(2, 'Dr�mv�gen 4', 'Testk�ping', 'Sverige', 40000),
(5, 'Himlav�gen 11', 'Testk�ping', 'Sverige', 42000), 
(6, 'Stj�rnstigen 19', 'Testk�ping', 'Sverige', 50000),
(4, 'Blomstergatan 20', 'Testk�ping', 'Sverige', 89000),
(2, 'S�lgstigen 7', 'Testk�ping', 'Sverige', 72000), 
(4, 'Forsv�gen 10', 'Testk�ping', 'Sverige', 82000), 
(2, 'Hasselstigen 13', 'Testk�ping', 'Sverige', 60000), 
(5, 'Lingonv�gen 25', 'Testk�ping', 'Sverige', 97000),
(4, 'Solv�gen 8', 'Testk�ping', 'Sverige', 88000),
(3, 'Regnv�gen 6', 'Testk�ping', 'Sverige', 50000), 
(4, 'Furustigen 3', 'Testk�ping', 'Sverige', 87000), 
(4, 'Granatv�gen 21', 'Testk�ping', 'Sverige', 89000),
(3, 'Apelsinv�gen 4', 'Testk�ping', 'Sverige', 88000);






-- Skapa personer
INSERT INTO People.Person (HouseHoldID, Name, Gender, BirthDate, MomID, DadID, Address, EmploymentStatus, Salary)
VALUES

(1, 'Anna Svensson', 'Female', '1987-04-15', NULL, NULL, 'Bl�b�rsv�gen 12', 'Employed', 40000),
(1, 'Johan Svensson', 'Male', '1985-02-10', NULL, NULL, 'Bl�b�rsv�gen 12', 'Employed', 35000),
(1, 'Emma Svensson', 'Female', '2014-08-12', 1, 2, 'Bl�b�rsv�gen 12', 'Unemployed', NULL),
(1, 'Erik Svensson', 'Male', '2016-06-20', 1, 2, 'Bl�b�rsv�gen 12', 'Unemployed', NULL),

(2, 'Fatima Al Hakim', 'Female', '1983-03-25', NULL, NULL, 'K�rsb�rsgatan 5', 'Employed', 50000),
(2, 'Ali Al Hakim', 'Male', '1981-07-10', NULL, NULL, 'K�rsb�rsgatan 5', 'Employed', 47000),
(2, 'Sara Al Hakim', 'Female', '2012-04-18', 5, 6, 'K�rsb�rsgatan 5', 'Unemployed', NULL),
(2, 'Omar Al Hakim', 'Male', '2015-11-01', 5, 6, 'K�rsb�rsgatan 5', 'Unemployed', NULL),
(2, 'Layla Al Hakim', 'Female', '2018-09-05', 5, 6, 'K�rsb�rsgatan 5', 'Unemployed', NULL),

(3, 'Lena Karlsson', 'Female', '1990-11-20', NULL, NULL, '�ppelv�gen 9', 'Employed', 25000),
(3, 'William Karlsson', 'Male', '2011-03-15', 10, NULL, '�ppelv�gen 9', 'Unemployed', NULL),
(3, 'Elin Karlsson', 'Female', '2014-08-05', 10, NULL, '�ppelv�gen 9', 'Unemployed', NULL),

(4, 'Maria Lind', 'Female', '1985-05-30', NULL, NULL, 'Granstigen 4', 'Employed', 35000),
(4, 'Peter Lind', 'Male', '1982-12-10', NULL, NULL, 'Granstigen 4', 'Employed', 35000),
(4, 'Lucas Lind', 'Male', '2015-03-20', 13, 14, 'Granstigen 4', 'Unemployed', NULL),
(4, 'Ella Lind', 'Female', '2018-07-25', 13, 14, 'Granstigen 4', 'Unemployed', NULL),

(5, 'Karin Persson', 'Female', '1995-10-15', NULL, NULL, 'Tallgatan 8', 'Employed', 20000),
(5, 'Maja Persson', 'Female', '2020-01-05', 17, NULL, 'Tallgatan 8', 'Unemployed', NULL),

(6, 'Sandra Eriksson', 'Female', '1989-06-30', NULL, NULL, 'Lingonv�gen 10', 'Employed', 30000),
(6, 'Mats Eriksson', 'Male', '1987-03-05', NULL, NULL, 'Lingonv�gen 10', 'Employed', 25000),
(6, 'Linnea Eriksson', 'Female', '2013-12-11', 19, 20, 'Lingonv�gen 10', 'Unemployed', NULL),

(7, 'Sara Larsson', 'Female', '1987-08-22', NULL, NULL, 'Hasselv�gen 3', 'Employed', 30000),
(7, 'Erik Larsson', 'Male', '1986-05-15', NULL, NULL, 'Hasselv�gen 3', 'Employed', 30000),
(7, 'Elias Larsson', 'Male', '2018-02-10', 22, 23, 'Hasselv�gen 3', 'Unemployed', NULL),

(8, 'Fatima Ibrahim', 'Female', '1985-10-10', NULL, NULL, 'Ekorrstigen 7', 'Employed', 45000),
(8, 'Omar Ibrahim', 'Male', '1983-07-14', NULL, NULL, 'Ekorrstigen 7', 'Employed', 50000),
(8, 'Ayaan Ibrahim', 'Female', '2013-05-18', 25, 26, 'Ekorrstigen 7', 'Unemployed', NULL),
(8, 'Ali Ibrahim', 'Male', '2016-08-30', 25, 26, 'Ekorrstigen 7', 'Unemployed', NULL),
(8, 'Layla Ibrahim', 'Female', '2019-11-02', 25, 26, 'Ekorrstigen 7', 'Unemployed', NULL),

(9, 'Anna Nilsson', 'Female', '1990-02-17', NULL, NULL, 'Bj�rkall�n 15', 'Employed', 36000),
(9, 'Johan Nilsson', 'Male', '1988-11-05', NULL, NULL, 'Bj�rkall�n 15', 'Employed', 36000),
(9, 'Emil Nilsson', 'Male', '2014-06-15', 30, 31, 'Bj�rkall�n 15', 'Unemployed', NULL),
(9, 'Sara Nilsson', 'Female', '2017-03-10', 30, 31, 'Bj�rkall�n 15', 'Unemployed', NULL),

(10, 'Leyla Ali', 'Female', '1984-12-10', NULL, NULL, 'R�nnstigen 18', 'Employed', 28000),
(10, 'Hassan Ali', 'Male', '1982-09-25', NULL, NULL, 'R�nnstigen 18', 'Employed', 28000),
(10, 'Khalid Ali', 'Male', '2018-10-05', 34, 35, 'R�nnstigen 18', 'Unemployed', NULL),

(11, 'Zara Osman', 'Female', '1982-06-15', NULL, NULL, 'Hallonv�gen 5', 'Employed', 61000),
(11, 'Ali Osman', 'Male', '1980-04-20', NULL, NULL, 'Hallonv�gen 5', 'Employed', 61000),
(11, 'Ahmed Osman', 'Male', '2009-02-17', 37, 38, 'Hallonv�gen 5', 'Unemployed', NULL),
(11, 'Samira Osman', 'Female', '2013-11-12', 37, 38, 'Hallonv�gen 5', 'Unemployed', NULL),
(11, 'Omar Osman', 'Male', '2016-07-20', 37, 38, 'Hallonv�gen 5', 'Unemployed', NULL),
(11, 'Layla Osman', 'Female', '2019-01-08', 37, 38, 'Hallonv�gen 5', 'Unemployed', NULL),

(12, 'Fatima Ahmed', 'Female', '1987-03-15', NULL, NULL, 'Orkid�v�gen 9', 'Employed', 44000),
(12, 'Yusuf Ahmed', 'Male', '1985-01-22', NULL, NULL, 'Orkid�v�gen 9', 'Employed', 43000),
(12, 'Ayan Ahmed', 'Female', '2012-09-03', 43, 44, 'Orkid�v�gen 9', 'Unemployed', NULL),
(12, 'Hassan Ahmed', 'Male', '2015-05-28', 43, 44, 'Orkid�v�gen 9', 'Unemployed', NULL),

(13, 'Zahra Saleh', 'Female', '1985-04-25', NULL, NULL, 'Solrosv�gen 14', 'Employed', 45000),
(13, 'Mohammed Saleh', 'Male', '1983-07-15', NULL, NULL, 'Solrosv�gen 14', 'Employed', 50000),
(13, 'Ayaan Saleh', 'Female', '2014-10-18', 47, 48, 'Solrosv�gen 14', 'Unemployed', NULL),
(13, 'Samir Saleh', 'Male', '2017-07-09', 47, 48, 'Solrosv�gen 14', 'Unemployed', NULL),
(13, 'Khalid Saleh', 'Male', '2019-12-03', 47, 48, 'Solrosv�gen 14', 'Unemployed', NULL),

(14, 'Anna Persson', 'Female', '1988-02-19', NULL, NULL, 'Vitsippsv�gen 8', 'Employed', 35000),
(14, 'Johan Persson', 'Male', '1986-08-22', NULL, NULL, 'Vitsippsv�gen 8', 'Employed', 35000),
(14, 'Sofia Persson', 'Female', '2020-11-15', 52, 53, 'Vitsippsv�gen 8', 'Unemployed', NULL),

(15, 'Leila Yusuf', 'Female', '1982-06-10', NULL, NULL, 'Regnb�gsv�gen 22', 'Employed', 43000),
(15, 'Ahmed Yusuf', 'Male', '1980-09-25', NULL, NULL, 'Regnb�gsv�gen 22', 'Employed', 42000),
(15, 'Sara Yusuf', 'Female', '2014-04-12', 55, 56, 'Regnb�gsv�gen 22', 'Unemployed', NULL),
(15, 'Yusuf Yusuf', 'Male', '2017-02-18', 55, 56, 'Regnb�gsv�gen 22', 'Unemployed', NULL),

(16, 'Eva Karlsson', 'Female', '1991-07-22', NULL, NULL, 'Nyponv�gen 6', 'Employed', 25000),
(16, 'Erik Karlsson', 'Male', '1990-01-15', NULL, NULL, 'Nyponv�gen 6', 'Employed', 20000),

(17, 'Leyla Noor', 'Female', '1987-05-23', NULL, NULL, 'Talgoxestigen 12', 'Employed', 25000),
(17, 'Ahmed Noor', 'Male', '1985-02-12', NULL, NULL, 'Talgoxestigen 12', 'Employed', 30000),
(17, 'Ayan Noor', 'Female', '2015-07-18', 61, 62, 'Talgoxestigen 12', 'Unemployed', NULL),

(18, 'Anna Ekstr�m', 'Female', '1982-01-11', NULL, NULL, 'Vinterv�gen 16', 'Employed', 40000),
(18, 'Peter Ekstr�m', 'Male', '1980-03-27', NULL, NULL, 'Vinterv�gen 16', 'Employed', 42000),
(18, 'Lisa Ekstr�m', 'Female', '2013-06-10', 64, 65, 'Vinterv�gen 16', 'Unemployed', NULL),
(18, 'Erik Ekstr�m', 'Male', '2015-09-25', 64, 65, 'Vinterv�gen 16', 'Unemployed', NULL),

(19, 'Eva Larsson', 'Female', '1990-11-05', NULL, NULL, 'Dr�mv�gen 4', 'Employed', 20000),
(19, 'Lars Larsson', 'Male', '1989-08-14', NULL, NULL, 'Dr�mv�gen 4', 'Employed', 20000),

(20, 'Samira Hassan', 'Female', '1983-12-11', NULL, NULL, 'Himlav�gen 11', 'Employed', 20000),
(20, 'Ali Hassan', 'Male', '1981-04-21', NULL, NULL, 'Himlav�gen 11', 'Employed', 22000),
(20, 'Yasmin Hassan', 'Female', '2012-03-15', 70, 71, 'Himlav�gen 11', 'Unemployed', NULL),
(20, 'Omar Hassan', 'Male', '2014-07-12', 70, 71, 'Himlav�gen 11', 'Unemployed', NULL),
(20, 'Adam Hassan', 'Male', '2017-11-19', 70, 71, 'Himlav�gen 11', 'Unemployed', NULL),

(21, 'Fatima Ahmed', 'Female', '1980-02-18', NULL, NULL, 'Stj�rnstigen 19', 'Employed', 25000),
(21, 'Mohammed Ahmed', 'Male', '1978-09-09', NULL, NULL, 'Stj�rnstigen 19', 'Employed', 25000),
(21, 'Sara Ahmed', 'Female', '2010-04-10', 75, 76, 'Stj�rnstigen 19', 'Unemployed', NULL),
(21, 'Yusuf Ahmed', 'Male', '2012-11-03', 75, 76, 'Stj�rnstigen 19', 'Unemployed', NULL),
(21, 'Ayan Ahmed', 'Female', '2015-02-20', 75, 76, 'Stj�rnstigen 19', 'Unemployed', NULL),
(21, 'Omar Ahmed', 'Male', '2018-06-15', 75, 76, 'Stj�rnstigen 19', 'Unemployed', NULL),

(22, 'Karin Sj�berg', 'Female', '1985-07-11', NULL, NULL, 'Blomstergatan 20', 'Employed', 45000),
(22, 'Per Sj�berg', 'Male', '1983-03-19', NULL, NULL, 'Blomstergatan 20', 'Employed', 44000),
(22, 'Emil Sj�berg', 'Male', '2016-05-07', 81, 82, 'Blomstergatan 20', 'Unemployed', NULL),
(22, 'Sofia Sj�berg', 'Female', '2019-10-12', 81, 82, 'Blomstergatan 20', 'Unemployed', NULL),

(23, 'Mikael Persson', 'Male', '1988-05-25', NULL, NULL, 'S�lgstigen 7', 'Employed', 37000),
(23, 'Jenny Persson', 'Female', '1990-10-01', NULL, NULL, 'S�lgstigen 7', 'Employed', 35000),

(24, 'Nadia Hassan', 'Female', '1984-08-10', NULL, NULL, 'Forsv�gen 10', 'Employed', 41000),
(24, 'Ali Hassan', 'Male', '1982-12-04', NULL, NULL, 'Forsv�gen 10', 'Employed', 41000),
(24, 'Yasmin Hassan', 'Female', '2015-09-22', 87, 88, 'Forsv�gen 10', 'Unemployed', NULL),
(24, 'Omar Hassan', 'Male', '2018-03-09', 87, 88, 'Forsv�gen 10', 'Unemployed', NULL),

(25, 'Erik Lindberg', 'Male', '1986-09-12', NULL, NULL, 'Hasselstigen 13', 'Employed', 30000),
(25, 'Lisa Lindberg', 'Female', '1987-11-05', NULL, NULL, 'Hasselstigen 13', 'Employed', 30000),

(25, 'Layla Mohamud', 'Female', '1983-07-20', NULL, NULL, 'Lingonv�gen 25', 'Employed', 49000),
(25, 'Abdi Mohamud', 'Male', '1982-01-15', NULL, NULL, 'Lingonv�gen 25', 'Employed', 48000),
(25, 'Ayaan Mohamud', 'Female', '2010-11-22', 93, 94, 'Lingonv�gen 25', 'Unemployed', NULL),
(25, 'Khalid Mohamud', 'Male', '2013-05-18', 93, 94, 'Lingonv�gen 25', 'Unemployed', NULL),
(25, 'Sofia Mohamud', 'Female', '2016-02-12', 93, 94, 'Lingonv�gen 25', 'Unemployed', NULL),

(26, 'Maria Andersson', 'Female', '1984-03-10', NULL, NULL, 'Solv�gen 8', 'Employed', 44000),
(26, 'Anders Andersson', 'Male', '1982-07-15', NULL, NULL, 'Solv�gen 8', 'Employed', 44000),
(26, 'Sofia Andersson', 'Female', '2015-04-25', 98, 99, 'Solv�gen 8', 'Unemployed', NULL),
(26, 'Lukas Andersson', 'Male', '2018-09-12', 98, 99, 'Solv�gen 8', 'Unemployed', NULL),

(27, 'Leyla Ali', 'Female', '1989-11-30', NULL, NULL, 'Regnv�gen 6', 'Employed', 25000),
(27, 'Ahmed Ali', 'Male', '1987-02-25', NULL, NULL, 'Regnv�gen 6', 'Employed', 25000),
(27, 'Ayaan Ali', 'Female', '2020-06-15', 102, 103, 'Regnv�gen 6', 'Unemployed', NULL),

(28, 'Nadia Hassan', 'Female', '1983-06-20', NULL, NULL, 'Furustigen 3', 'Employed', 45000),
(28, 'Yusuf Hassan', 'Male', '1981-08-12', NULL, NULL, 'Furustigen 3', 'Employed', 42000),
(28, 'Omar Hassan', 'Male', '2015-01-18', 105, 106, 'Furustigen 3', 'Unemployed', NULL),
(28, 'Layla Hassan', 'Female', '2018-03-09', 105, 106, 'Furustigen 3', 'Unemployed', NULL),

(29, 'Amina Mohammed', 'Female', '1987-03-05', NULL, NULL, 'Granatv�gen 21', 'Employed', 44000),
(29, 'Hassan Mohammed', 'Male', '1985-12-11', NULL, NULL, 'Granatv�gen 21', 'Employed', 45000),
(29, 'Khalid Mohammed', 'Male', '2014-07-17', 109, 110, 'Granatv�gen 21', 'Unemployed', NULL),
(29, 'Zara Mohammed', 'Female', '2017-11-22', 109, 110, 'Granatv�gen 21', 'Unemployed', NULL),

(30, 'Marie Davidsson', 'Female', '1989-04-01', NULL, NULL, 'Apelsinv�gen 4', 'Employed', 45000),
(30, 'Thomas Davidsson', 'Male', '1989-01-12', NULL, NULL, 'Apelsinv�gen 4', 'Emplyed', 43000),
(30, 'Kalle Davidsson', 'Male', '2002-02-14', 113, 114, 'Apelsinv�gen 4', 'Unemployed', NULL);







-- FR�G�R OCH SVAR

-- Hur m�nga pojkar och flickor kommer b�rja skolan �r 2025? (SQL Query) X = 2025

SELECT COUNT (Gender) AS Antal
FROM People.Person
WHERE YEAR(BirthDate) = 2025 - 6


-- Ta fram en lista p� deras f�r�ldrar s� man kan skicka ut post till dom (STORED PROC)

GO
CREATE OR ALTER PROCEDURE GetParentsListForSchool
AS
BEGIN
    SELECT 
     pp2.Name AS Mom, pp3.Name AS Dad, pp.Address
    FROM People.Person pp
    INNER JOIN House.HouseHold hh ON pp.HouseHoldID = hh.HouseHoldID
    INNER JOIN People.Person pp2 ON pp.MomID = pp2.PersonID
    INNER JOIN People.Person pp3 ON pp.DadID = pp3.PersonID
    WHERE YEAR(pp.BirthDate) = 2025 - 6
    ORDER BY pp.Name, pp.Address, hh.HouseHoldID;
END;
GO

EXEC GetParentsListForSchool


-- Ta fram lista p� alla som kommer bli �lderspension�rer (fylla 67) �r 2055 (SQL Query) X = 2055

SELECT Name, Gender, BirthDate, Address
FROM People.Person
WHERE YEAR(BirthDate) = 2055 - 67;



-- Hur m�nga hush�ll best�r av minst 6 personer (SQL Query) X = 6


SELECT COUNT (*) AS 'Hush�ll minst 6 Personer'
FROM House.HouseHold
WHERE TotalPeople >=6


-- Hur m�nga hush�ll har minst en medlem som �r arbetsl�s (VIEW)


GO
CREATE OR ALTER VIEW HushallMedArbetslosa AS
SELECT COUNT (DISTINCT h.HouseHoldID) AS 'Antal Arbetsl�sa'
FROM House.HouseHold h
INNER JOIN People.Person p
    ON h.HouseHoldID = p.HouseHoldID
WHERE p.EmploymentStatus = 'Unemployed'
GO

SELECT *
FROM HushallMedArbetslosa


-- Hur m�nga hush�ll tj�nar totalt mindre �n 25000 kronor, dvs. kan vara aktuella f�r socialbidrag X = 25000

SELECT COUNT (TotalIncome) AS 'Mindre �n 25000'
FROM House.HouseHold
WHERE TotalIncome <=25000
