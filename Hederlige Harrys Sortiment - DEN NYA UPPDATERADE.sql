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
SET @HashedPassword = HASHBYTES('SHA2_256', @Password);

INSERT INTO Users (Email,PasswordHash, SALT, FirstName,LastName,Address,PostalCode,City,Country,Role,PhoneNumber,IsLocked)
VALUES (@Email,@HashedPassword,@SALT,@FirstName,@LastName,@Address,@PostalCode,@City,@Country,DEFAULT,@PhoneNumber,0);

DECLARE @UserID INT = SCOPE_IDENTITY();

UPDATE EmailVerification
SET IsVerified = 0
WHERE UserID = @UserID;

DECLARE @VerificationCode NVARCHAR(255) = NEWID();
DECLARE @VerificationLink NVARCHAR(500) = 'https://HederligeHarrysSortiment.se/verifycode:' + @VerificationCode;

INSERT INTO EmailVerification (UserID, VerificationCode, ExpiryTime, IsVerified)
VALUES (@UserID, @VerificationCode, DATEADD(HOUR, 24, GETDATE()), 0);


DECLARE @Emailmsg NVARCHAR(MAX);
SET @Emailmsg = 'Hello ' + @FirstName + 
                 ', please verify your account by clicking on the following link: ' + @VerificationLink;

EXEC msdb.dbo.sp_send_dbmail
@profile_name = 'Thomas', -- Byt till din emailprofil som du skapade.
@recipients = @Email,
@subject = 'Verify Your Account',
@body = @Emailmsg,
@body_format = 'HTML';

SET @ResultCode = 0;
PRINT 'Account created and verification email sent successfully';
END;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Aktivera emailfuktion
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Database Mail XPs', 1;
RECONFIGURE;
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
PRINT 'Your account is locked. Please email us at HederligeHarry@HarrysSortiment.se for more information regarding the lockout.';
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

DECLARE @Emailmsg NVARCHAR(500)
SET @Emailmsg = 'Hello, please click on the link and follow the instructions to reset your password.' + @ResetLink;


EXEC msdb.dbo.sp_send_dbmail
@profile_name = 'Thomas', -- Byt till din emailprofil som du skapade
@recipients = @Email,
@subject = 'Reset Your Password',
@body = @Emailmsg,
@body_format = 'HTML';

SET @ResultCode = 0;
PRINT 'Email with resetcode sent succesfully';
END;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
---------------------------------------------LAGRA ALLA INLOGGNIGSFÖRSÖK---------------------------------------------------------------------------------------------------------------------------------
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
DECLARE @IsLocked BIT;
DECLARE @IsVerified BIT;
DECLARE @IpAddress VARCHAR(50) = '123.456.19.7'
DECLARE @IsSuccessful BIT;

    -- Hämta användardata
SELECT @UserID = u.UserID,
@PasswordHash = u.PasswordHash,
@IsLocked = u.IsLocked,
@IsVerified = ev.IsVerified,
@Email = u.Email
FROM Users u
INNER JOIN EmailVerification ev ON u.UserID = ev.UserID
WHERE u.Email = @Email;

    -- Kontrollera om användaren existerar
IF @UserID IS NULL
BEGIN
SET @ResultCode = 1;
PRINT 'User does not exist';

        -- Logga misslyckat försök
SET @IsSuccessful = 0;
INSERT INTO LoginAttempts (UserID, Email, IpAddress, IsSuccessful, AttemptTime)
VALUES (@UserID, @Email, @IpAddress, @IsSuccessful, GETDATE());
RETURN;
END;

    -- Kontrollera om kontot är låst
IF @IsLocked = 1
BEGIN
SET @ResultCode = 1;
PRINT 'Your account is locked. Please email us at HederligeHarry@HarrysSortiment.se for more information regarding the lockout.';

        -- Logga misslyckat försök
SET @IsSuccessful = 0;
INSERT INTO LoginAttempts (UserID, Email, IpAddress, IsSuccessful, AttemptTime)
VALUES (@UserID, @Email, @IpAddress, @IsSuccessful, GETDATE());
RETURN;
END;

    -- Kontrollera om kontot är verifierat
IF @IsVerified = 0
BEGIN
SET @ResultCode = 1;
PRINT 'Your account is not verified. Please check your email inbox and follow the instructions to verify your account.';

        -- Logga misslyckat försök
SET @IsSuccessful = 0;
INSERT INTO LoginAttempts (UserID, Email, IpAddress, IsSuccessful, AttemptTime)
VALUES (@UserID, @Email, @IpAddress, @IsSuccessful, GETDATE());
RETURN;
END;

    -- Verifiera lösenord (exempel på hashning)
DECLARE @HashedPassword VARCHAR(255);
SET @HashedPassword = HASHBYTES('SHA2_256', @Password); -- Anpassa om du använder en annan metod för lösenordshantering

IF @PasswordHash <> @HashedPassword
BEGIN
SET @ResultCode = 1;
PRINT 'Incorrect password.';

        -- Logga misslyckat försök
SET @IsSuccessful = 0;
INSERT INTO LoginAttempts (UserID, Email, IpAddress, IsSuccessful, AttemptTime)
VALUES (@UserID, @Email, @IpAddress, @IsSuccessful, GETDATE());
RETURN;
END;

    -- Om allt är korrekt
SET @ResultCode = 0;
PRINT 'Login successful';

    -- Logga lyckat försök
SET @IsSuccessful = 1;
INSERT INTO LoginAttempts (UserID, Email, IpAddress, IsSuccessful, AttemptTime)
VALUES (@UserID, @Email, @IpAddress, @IsSuccessful, GETDATE());
END;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
GO
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
WHERE Row = 1 -- Filtrera för att visa den senaste lyckade och misslyckade inloggningen
GO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 --8. Skapa en rapport(VIEW) som tar fram hur många inloggningsförsök som lyckats och inte lyckats per Ip-adress.
--Rapporten ska visa antal försök (total, lyckade och inte lyckade) 
--och genomsnittet av de lyckade försöken. 
--Samtliga kolumner ska sorteras kumulativt(ökande) på datum. 
--Se till att rapporten INTE tar bort detaljerad information från raderna; 
--det ska vara specifika sammanfattningar per rad(window function).
--Demonstrera er VIEW.  

GO
CREATE OR ALTER VIEW AttemptsPerIpAddress AS
SELECT IpAddress, AttemptTime,
COUNT(*) OVER (PARTITION BY IpAddress) AS TotalAttempts, -- Totalt antal försök per IP
COUNT(CASE WHEN IsSuccessFul = 1 THEN 1 END) OVER (PARTITION BY IpAddress) AS SuccessfulAttempts, -- Lyckade försök per IP
COUNT(CASE WHEN IsSuccessFul = 0 THEN 1 END) OVER (PARTITION BY IpAddress) AS FailedAttempts, -- Misslyckade försök per IP
AVG(CASE WHEN IsSuccessFul = 1 THEN 1.0 ELSE 0.0 END) OVER (PARTITION BY IpAddress) AS AvgSuccessRate -- Genomsnitt för lyckade försök
FROM LoginAttempts;
GO

--------------------------------------------------------------------------------------------------------------------------------------------------

GO
CREATE OR ALTER PROCEDURE UpdateUserRole
@AdminID INT,        -- ID för den som kör proceduren
@UserID INT,   -- ID för användaren vars roll ska uppdateras
@NewRole VARCHAR(10) -- Ny roll: 'Customer' eller 'Admin'
AS
BEGIN
SET NOCOUNT ON;

    -- Kontrollera att den som kör proceduren är en admin
IF NOT EXISTS (
SELECT 1
FROM Users
WHERE UserID = @AdminID AND Role = 'Admin'
)
BEGIN
PRINT 'Permission denied: Only admins can update user roles.';
RETURN;
END;

    -- Uppdatera användarens roll om den nya rollen är giltig
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
--------------------------------------------------------------------TESSSTTTTTTTTTAAAARRRRR-----------------------------------------------------------------------------------
EXEC UpdateUserRole @AdminID = 1, @UserID = 2, @NewRole = 'Admin';

EXEC LockAccount @userid = 1

EXEC UnLockAccount @userid = 1
 
DECLARE @ResultCode BIT;
EXEC CreateAccount
    @Email = 'yarothomas@gmaail.com',
    @Password = 'Värstingkod1!',
    @FirstName = 'Thomas',
    @LastName = 'Yaro',
    @Address = 'StövarGatan 24',
    @PostalCode = '12461',
    @City = 'Stockholm',
    @Country = 'Sweden',
    @PhoneNumber = '1234567890',
    @ResultCode = @ResultCode OUTPUT;

	SELECT * FROM Users
	SELECT * FROM Emailverification
	SELECT * FROM passwordreset
	SELECT * FROM loginattempts


	DECLARE @ResultCode BIT;
EXEC ResetPassword
    @Email = 'yarothomas@gmaail.com',
    @ResultCode = @ResultCode OUTPUT;


	UPDATE emailverification
	SET isverified = 1
	WHERE UserID = 1
	

	DECLARE @ResultCode BIT;
EXEC LoginAttempt
    @Email = 'yarothomas@gmaaail.com',
    @Password = 'Värstingkod1',
    @ResultCode = @ResultCode OUTPUT;

	UPDATE Users
	SET Role = 'Admin'
	WHERE UserID = 1