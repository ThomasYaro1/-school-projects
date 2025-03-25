USE master

IF EXISTS(SELECT * FROM sys.databases WHERE name = 'Hederlige Harrys Sortiment')
   BEGIN
      ALTER DATABASE [Hederlige Harrys Sortiment] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
      DROP DATABASE [Hederlige Harrys Sortiment]
   END

         CREATE DATABASE [Hederlige Harrys Sortiment];
         GO

         USE [Hederlige Harrys Sortiment]
		 GO 


CREATE TABLE Users (
UserID INT NOT NULL IDENTITY (1, 1) PRIMARY KEY,
Email VARCHAR(254) NOT NULL UNIQUE,
PasswordHash VARCHAR(255) NOT NULL,
SALT NVARCHAR(50) NOT NULL,
FirstName VARCHAR(50) NOT NULL,
LastName VARCHAR(50) NOT NULL,
Address VARCHAR(255) NOT NULL,
PostalCode VARCHAR(20) NOT NULL,
City VARCHAR(50) NOT NULL,
Country VARCHAR(50) NOT NULL,
Role VARCHAR(10) DEFAULT 'Customer' CHECK (Role IN ('Customer', 'Admin')),
PhoneNumber VARCHAR(20) NOT NULL,
ValidTo DATETIME NOT NULL DEFAULT DATEADD(YEAR, 1, GETDATE()),
IsLocked BIT NOT NULL DEFAULT 0
);

CREATE TABLE LoginAttempts (
AttemptID INT PRIMARY KEY IDENTITY(1,1),
UserID INT,
Email VARCHAR(254),
IpAddress VARCHAR(50),
IsSuccessful BIT NOT NULL,
AttemptTime DATETIME DEFAULT GETDATE(),
FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE TABLE PasswordReset (
ResetID INT PRIMARY KEY IDENTITY(1,1),
UserID INT,
ResetCode VARCHAR(255) NOT NULL,
ExpiryTime DATETIME,
Expired BIT NOT NULL DEFAULT 0,
FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE TABLE EmailVerification (
VerificationID INT PRIMARY KEY IDENTITY(1,1),
UserID INT,
VerificationCode VARCHAR(255) NOT NULL,
ExpiryTime DATETIME,
IsVerified BIT DEFAULT 0,
FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

----------------------------------------------------------------------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE CreateAccount
@Email VARCHAR(254),
@Password VARCHAR(255),
@FirstName NVARCHAR(50), 
@LastName VARCHAR(50),
@Address VARCHAR(255),
@PostalCode VARCHAR(20), 
@City VARCHAR(50),
@Country VARCHAR(50), 
@PhoneNumber VARCHAR(20),
@ResultCode BIT OUTPUT

AS
BEGIN
SET NOCOUNT ON;

IF EXISTS (SELECT 1 FROM Users WHERE Email = @Email)
BEGIN
SET @ResultCode = 1
PRINT 'Email already exists';
RETURN
END; 

IF LEN(@Password) < 8 OR
@Password NOT LIKE '%[A-Z]%' OR
@Password NOT LIKE '%[a-z]%' OR 
@Password NOT LIKE '%[0-9]%' OR
@Password NOT LIKE '%[!@#$%^&*()]%'
BEGIN
SET @ResultCode = 1;
PRINT 'Weak password, the password must contain at least eight characters, one uppercase letter, one lowercase letter, one digit and one special character (!@#$%^&*()).';
RETURN;
END;

DECLARE @SALT NVARCHAR(50) = CONVERT(NVARCHAR(50), NEWID());
DECLARE @HashedPassword VARBINARY(64);
SET @HashedPassword = HASHBYTES('SHA2_256', @Password + @SALT);

INSERT INTO Users (Email,PasswordHash,SALT,FirstName,LastName,Address,PostalCode,City,Country,Role,PhoneNumber,ValidTo,IsLocked)
VALUES (@Email,@HashedPassword,@SALT,@FirstName,@LastName,@Address,@PostalCode,@City,@Country,DEFAULT,@PhoneNumber,DEFAULT,0);

DECLARE @UserID INT = SCOPE_IDENTITY();

UPDATE EmailVerification
SET IsVerified = 0
WHERE UserID = @UserID;

DECLARE @VerificationCode NVARCHAR(255) = NEWID();
DECLARE @VerificationLink NVARCHAR(500) = 'https://HederligeHarrysSortiment.se/verifycode:' + @VerificationCode;

INSERT INTO EmailVerification (UserID, VerificationCode, ExpiryTime, IsVerified)
VALUES (@UserID, @VerificationCode, DATEADD(HOUR, 24, GETDATE()), 0);


SET @ResultCode = 0;
PRINT 'Account created and verification email sent successfully. please click on the link to verify your account.' + @VerificationLink;
END;

-----------------------------------------------------------------------------------------------------------------------------------------------------

GO
CREATE OR ALTER PROCEDURE ResetPassword
@Email VARCHAR(254),
@ResultCode BIT OUTPUT
AS 
BEGIN
SET NOCOUNT ON;

DECLARE @UserID INT;
DECLARE @IsVerified BIT;
DECLARE @IsLocked BIT;

SELECT @UserID = u.UserID,
@IsVerified = ev.IsVerified,
@IsLocked = Islocked
FROM Users u
INNER JOIN EmailVerification ev ON u.UserID = ev.UserID
WHERE u.Email = @Email;


IF @UserID IS NULL
BEGIN
SET @ResultCode = 1;
PRINT 'User does not exist';
RETURN;
END;

IF @IsVerified = 0
BEGIN
SET @ResultCode = 1;
PRINT 'Your account is not verified. Please check your email inbox and follow the instructions to verify your account.';
RETURN;
END;


IF @IsLocked = 1
BEGIN
SET @ResultCode = 1;
PRINT 'Your account is locked. Contact Support.';
RETURN;
END;


DECLARE @ResetCode NVARCHAR(255) = NEWID();
DECLARE @ExpiryTime DATETIME = DATEADD(HOUR, 24, GETDATE());

UPDATE PasswordReset
SET Expired = 1
WHERE UserID = @UserID AND ExpiryTime < GETDATE();

INSERT INTO PasswordReset (UserID, ResetCode, ExpiryTime)
VALUES				  (@UserID, @ResetCode, @ExpiryTime);	
	


DECLARE @ResetLink NVARCHAR(500)
SET @ResetLink = 'https://HederligeHarrysSortiment.se/resetpasswordcode:' + @ResetCode;


SET @ResultCode = 0;
PRINT 'Email with resetcode sent succesfully. please click on the link and follow the instructions to reset your password.' + @ResetLink;
END;

-----------------------------------------------------------------------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE SetForgottenPassword
@Email NVARCHAR(255),
@Password NVARCHAR(255),
@ResetCode NVARCHAR(255),
@ResultCode BIT OUTPUT
AS
BEGIN
SET NOCOUNT ON;

DECLARE @UserId INT;
DECLARE @CodeExpiry DATETIME;
DECLARE @CurrentTime DATETIME = GETDATE();

SELECT 
@UserId = users.UserID,
@CodeExpiry = pr.ExpiryTime
FROM Users
INNER JOIN PasswordReset pr ON Users.UserID = pr.UserID
WHERE Email = @Email AND ResetCode = @ResetCode;

IF @UserId IS NULL
BEGIN
SET @ResultCode = 1;
PRINT 'User does not exist or reset code is invalid';
RETURN;
END

IF @CodeExpiry IS NULL OR @CodeExpiry < @CurrentTime
BEGIN
SET @ResultCode = 1;
PRINT 'Reset code has expired';
RETURN;
END

DECLARE @SALT NVARCHAR(50) = CONVERT(NVARCHAR(50), NEWID());
DECLARE @HashedPassword VARBINARY(64);
SET @HashedPassword = HASHBYTES('SHA2_256', @Password + @SALT);

UPDATE Users
SET PasswordHash = @HashedPassword, SALT = @SALT
WHERE UserId = @UserId;

UPDATE PasswordReset
SET Expired = 1, ExpiryTime = GETDATE()
WHERE UserId = @UserId;

SET @ResultCode = 0;
PRINT 'Password has been changed';
END;

-----------------------------------------------------------------------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE LockAccount
@UserID INT
AS
BEGIN
UPDATE Users
SET IsLocked = 1
WHERE UserID = @UserID;
PRINT 'Account is Locked'
END;
--------------------------------------------------------------------------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE UnLockAccount
@UserID INT
AS
BEGIN
UPDATE Users
SET Islocked = 0
WHERE UserID = @UserID
PRINT 'Account is Unlocked'
END;
---------------------------------------------LAGRA ALLA INLOGGNIGSFÖRSÖK----------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE LoginAttempt
@Email VARCHAR(254),
@Password VARCHAR(255),
@ResultCode BIT OUTPUT
AS
BEGIN
SET NOCOUNT ON;

DECLARE @UserID INT;
DECLARE @PasswordHash VARCHAR(255);
DECLARE @Salt NVARCHAR(50);
DECLARE @IsLocked BIT;
DECLARE @IsVerified BIT;
DECLARE @IpAddress VARCHAR(50) = '123.456.19.7'
DECLARE @IsSuccessful BIT;
DECLARE @ValidTo DATETIME;

SELECT @UserID = u.UserID,
@PasswordHash = u.PasswordHash,
@Salt = u.SALT,
@IsLocked = u.IsLocked,
@IsVerified = ev.IsVerified,
@Email = u.Email,
@ValidTo = u.ValidTo
FROM Users u
INNER JOIN EmailVerification ev ON u.UserID = ev.UserID
WHERE u.Email = @Email;

IF @UserID IS NULL
BEGIN
SET @ResultCode = 1;
PRINT 'User does not exist';

SET @IsSuccessful = 0;
INSERT INTO LoginAttempts (UserID, Email, IpAddress, IsSuccessful, AttemptTime)
VALUES (@UserID, @Email, @IpAddress, @IsSuccessful, GETDATE());
RETURN;
END;

IF @IsLocked = 1
BEGIN
SET @ResultCode = 1;
PRINT 'Your account is locked. Contact Support.';

SET @IsSuccessful = 0;
INSERT INTO LoginAttempts (UserID, Email, IpAddress, IsSuccessful, AttemptTime)
VALUES (@UserID, @Email, @IpAddress, @IsSuccessful, GETDATE());
RETURN;
END;

IF EXISTS (
SELECT 1
FROM LoginAttempts
WHERE UserID = @UserID
AND IsSuccessful = 0
AND AttemptTime > DATEADD(MINUTE, -15, GETDATE())
GROUP BY UserID
HAVING COUNT(*) >= 3
)
BEGIN

UPDATE Users
SET IsLocked = 1
WHERE UserID = @UserID;

SET @ResultCode = 1;
PRINT 'Too many failed login attempts. Your account has been locked.';
END

IF @IsVerified = 0
BEGIN
SET @ResultCode = 1;
PRINT 'Your account is not verified. Please check your email inbox and follow the instructions to verify your account.';

SET @IsSuccessful = 0;
INSERT INTO LoginAttempts (UserID, Email, IpAddress, IsSuccessful, AttemptTime)
VALUES (@UserID, @Email, @IpAddress, @IsSuccessful, GETDATE());
RETURN;
END;

DECLARE @HashedPassword VARCHAR(255);
SET @HashedPassword = HASHBYTES('SHA2_256', @Password + @Salt);

IF @PasswordHash <> @HashedPassword
BEGIN
SET @ResultCode = 1;
PRINT 'Incorrect password.';

SET @IsSuccessful = 0;
INSERT INTO LoginAttempts (UserID, Email, IpAddress, IsSuccessful, AttemptTime)
VALUES (@UserID, @Email, @IpAddress, @IsSuccessful, GETDATE());
RETURN;
END;

IF @ValidTo < GETDATE()
BEGIN
SET @ResultCode = 1;
PRINT 'Your account has expired.';

SET @IsSuccessful = 0;
INSERT INTO LoginAttempts (UserID, Email, IpAddress, IsSuccessful, AttemptTime)
VALUES (@UserID, @Email, @IpAddress, @IsSuccessful, GETDATE());
RETURN;
END;

SET @ValidTo = DATEADD(YEAR, 1, GETDATE());

UPDATE Users
SET ValidTo = @ValidTo
WHERE UserID = @UserID;

SET @ResultCode = 0;
PRINT 'Login successful';

SET @IsSuccessful = 1;
INSERT INTO LoginAttempts (UserID, Email, IpAddress, IsSuccessful, AttemptTime)
VALUES (@UserID, @Email, @IpAddress, @IsSuccessful, GETDATE());
END;
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR ALTER VIEW LoginAttemptinfo AS
WITH AttemptInfo AS (
SELECT u.Email AS Email, u.Firstname AS FirstName, u.LastName AS LastName, la.AttemptTime AS AttemptTime, la.IsSuccessFul AS IsSuccessFul,
ROW_NUMBER() OVER (PARTITION BY u.UserID, la.IsSuccessFul ORDER BY la.AttemptTime DESC) AS Row
FROM Users u
INNER JOIN LoginAttempts la ON u.UserID = la.UserID
)
SELECT Email, FirstName, LastName, 
AttemptTime, IsSuccessFul
FROM AttemptInfo
WHERE Row = 1

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
GO
CREATE OR ALTER VIEW AttemptsPerIpAddress AS
SELECT IpAddress, AttemptTime,
COUNT(*) OVER (PARTITION BY IpAddress) AS TotalAttempts,
COUNT(CASE WHEN IsSuccessFul = 1 THEN 1 END) OVER (PARTITION BY IpAddress) AS SuccessfulAttempts,
COUNT(CASE WHEN IsSuccessFul = 0 THEN 1 END) OVER (PARTITION BY IpAddress) AS FailedAttempts,
AVG(CASE WHEN IsSuccessFul = 1 THEN 1.0 ELSE 0.0 END) OVER (PARTITION BY IpAddress) AS AvgSuccessRate 
FROM LoginAttempts;
GO

--------------------------------------------------------------------------------------------------------------------------------------------------
GO
CREATE OR ALTER PROCEDURE UpdateUserRole
@AdminID INT,
@UserID INT,
@NewRole VARCHAR(10)
AS
BEGIN
SET NOCOUNT ON;

IF NOT EXISTS (
SELECT 1
FROM Users
WHERE UserID = @AdminID AND Role = 'Admin'
)
BEGIN
PRINT 'Permission denied: Only admins can update user roles.';
RETURN;
END;

IF @NewRole NOT IN ('Customer', 'Admin')
BEGIN
PRINT 'Invalid role. Allowed roles are Customer or Admin.';
RETURN;
END;

UPDATE Users
SET Role = @NewRole
WHERE UserID = @UserID;
PRINT 'User role updated'
END;
GO
---------------------------------------------------------TESTAR SP-----------------------------------------------------------------------

-----------------------------------------------------------ADMIN-------------------------------------------------------------------------
GO
DECLARE @ResultCode BIT;
EXEC CreateAccount
    @Email = 'yarothomas@gmail.com',
    @Password = 'Värstingkod1!',
    @FirstName = 'Thomas',
    @LastName = 'Yaro',
    @Address = 'StövarGatan 24',
    @PostalCode = '12461',
    @City = 'Stockholm',
    @Country = 'Sweden',
    @PhoneNumber = '0731436274',
    @ResultCode = @ResultCode OUTPUT;
GO
UPDATE Users
SET Role = 'Admin'
WHERE UserID = 1;

UPDATE emailverification
SET isverified = 1
WHERE UserID = 1;

---------------------------------------------------------------VERIFIERAD MEN LOCKEDOUT-----------------------------------------------------------------------------------------------
GO
DECLARE @ResultCode BIT;
EXEC CreateAccount
    @Email = 'HejSan@gmail.com',
    @Password = 'JättesvårKod123!',
    @FirstName = 'Hej',
    @LastName = 'San',
    @Address = 'BäverdamsGränd 4',
    @PostalCode = '12465',
    @City = 'Stockholm',
    @Country = 'Sweden',
    @PhoneNumber = '0735697463',
    @ResultCode = @ResultCode OUTPUT;
GO
UPDATE emailverification
SET isverified = 1
WHERE UserID = 2;
GO
EXEC LockAccount @userid = 2;

--FÖR ATT UNLOCKA
--EXEC UnLockAccount @userid = 2

---------------------------------------------VERIFIERAT KONTO---------------------------------------------------------------------------------------------------------------------------
GO
DECLARE @ResultCode BIT;
EXEC CreateAccount
    @Email = 'Henry23@gmail.com',
    @Password = 'Enkelkod1234!#',
    @FirstName = 'Henry',
    @LastName = 'Lind',
    @Address = 'Lurstigen 14',
    @PostalCode = '12468',
    @City = 'Stockholm',
    @Country = 'Sweden',
    @PhoneNumber = '0738467835',
    @ResultCode = @ResultCode OUTPUT;
GO
UPDATE emailverification
SET isverified = 1
WHERE UserID = 3;

----------------------------------------------------NYTT SKAPAD KONTO BEHÖVER VERIFIERING---------------------------------------------------------------------------------------------------
GO
DECLARE @ResultCode BIT;
EXEC CreateAccount
    @Email = 'Daniel33@gmail.com',
    @Password = 'Enklarekodddd1717!!',
    @FirstName = 'Daniel',
    @LastName = 'Danielson',
    @Address = 'GillerBacken 11',
    @PostalCode = '12469',
    @City = 'Stockholm',
    @Country = 'Sweden',
    @PhoneNumber = '0738464447',
    @ResultCode = @ResultCode OUTPUT;

----------------------------------------------------GLÖMT LÖSSENORD---------------------------------------------------------------------------------------------------
GO
DECLARE @ResultCode BIT;
EXEC CreateAccount
    @Email = 'DavidB@gmail.com',
    @Password = 'Daviddbb123!',
    @FirstName = 'David',
    @LastName = 'Beckham',
    @Address = 'BjusätraGatan 57',
    @PostalCode = '12471',
    @City = 'Stockholm',
    @Country = 'Sweden',
    @PhoneNumber = '0738474656',
    @ResultCode = @ResultCode OUTPUT;
GO
UPDATE emailverification
SET isverified = 1
WHERE UserID = 5;
GO
DECLARE @ResultCode BIT;
EXEC ResetPassword
    @Email = 'DavidB@gmail.com',
    @ResultCode = @ResultCode OUTPUT;

----------------------------------------------------SÄTT NYTT LÖSSENORD---------------------------------------------------------------------------------------------------
--SELECT * FROM PasswordReset  -- TA FRAM DEN NYA RESETKODEN, KOPIERA OCH KLISTRA IN I FÄLTET @RESETCODE
--GO
--	DECLARE @ResultCode BIT;
--EXEC SetForgottenPassword
--    @Email = 'DavidB@gmail.com',
--   @Password = 'Dennyastekoden1233',
--    @ResetCode = 'DD71681D-83E4-43E6-8DD0-F852EE420FDC',  -- < < < < <----------
--   @ResultCode = @ResultCode OUTPUT;
----------------------------------------------------ETT INLOGGNINGSFÖRSÖK AV ADMIN---------------------------------------------------------------------------------------------------
GO
DECLARE @ResultCode BIT;
EXEC LoginAttempt
    @Email = 'Yarothomas@gmail.com',
    @Password = 'Värstingkod1!',
    @ResultCode = @ResultCode OUTPUT;

----------------------------------------------------ETT MISSLYCKAD INLOGGNINGSFÖRSÖK---------------------------------------------------------------------------------------------------
GO
DECLARE @ResultCode BIT;
EXEC LoginAttempt
    @Email = 'Daniel33@gmail.com',
    @Password = 'Enklarekodddd1717!!',
    @ResultCode = @ResultCode OUTPUT;

----------------------------------------------------GÖR EN CUSTOMER TILL ADMIN---------------------------------------------------------------------------------------------------
--GO
--EXEC UpdateUserRole @AdminID = 1, @UserID = 2, @NewRole = 'Admin';

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------DEMONSTRERAR VIEWS----------------------------------------------------------------------------------------------------------------------
SELECT *
FROM LoginAttemptinfo;

SELECT *
FROM AttemptsPerIpAddress
