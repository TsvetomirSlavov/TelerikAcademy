USE [master]
GO
/****** Object:  Database [InformationDB]    Script Date: 14.7.2013 г. 14:24:53 ч. ******/
CREATE DATABASE [InformationDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'InformationDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\InformationDB.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'InformationDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\InformationDB_log.ldf' , SIZE = 2048KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [InformationDB] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [InformationDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [InformationDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [InformationDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [InformationDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [InformationDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [InformationDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [InformationDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [InformationDB] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [InformationDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [InformationDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [InformationDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [InformationDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [InformationDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [InformationDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [InformationDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [InformationDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [InformationDB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [InformationDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [InformationDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [InformationDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [InformationDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [InformationDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [InformationDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [InformationDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [InformationDB] SET RECOVERY FULL 
GO
ALTER DATABASE [InformationDB] SET  MULTI_USER 
GO
ALTER DATABASE [InformationDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [InformationDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [InformationDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [InformationDB] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'InformationDB', N'ON'
GO
USE [InformationDB]
GO
/****** Object:  StoredProcedure [dbo].[usp_DepositMoney]    Script Date: 14.7.2013 г. 14:24:53 ч. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_DepositMoney](@AccountId int = 1, @Sum_Amount money) AS
	BEGIN TRAN
	DECLARE @CurrentAmaount money
	UPDATE Accounts
	SET Balance = Balance + @Sum_Amount,
	@CurrentAmaount = Balance + @Sum_Amount
	WHERE id = @AccountId

	IF(@CurrentAmaount < 0)
		ROLLBACK TRAN

GO
/****** Object:  StoredProcedure [dbo].[usp_GiveIntrest]    Script Date: 14.7.2013 г. 14:24:53 ч. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_GiveIntrest](@accId int = 0, @intrestRate float = 0) AS

  SELECT FirstName + ' ' + LastName as FullName, dbo.ufn_CalcIntrest(Balance, @intrestRate) 
  FROM Persons p
  JOIN Accounts a
	on p.id = a.PersonId
  WHERE a.id = @accId
   ORDER BY Balance

GO
/****** Object:  StoredProcedure [dbo].[usp_GiveIntrestForOneMonth]    Script Date: 14.7.2013 г. 14:24:53 ч. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_GiveIntrestForOneMonth](@accId int = 0, @intrestRate float = 0) AS
  SELECT dbo.ufn_CalcIntrestForMonths(Balance, @intrestRate, 1) 
  FROM Accounts 
  WHERE id = @accId

GO
/****** Object:  StoredProcedure [dbo].[usp_SelectAllAcountsWithGivenBalance]    Script Date: 14.7.2013 г. 14:24:53 ч. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_SelectAllAcountsWithGivenBalance](
  @minBalance int = 0) AS

  SELECT FirstName + ' ' + LastName as FullName, Balance 
  FROM Persons p
  JOIN Accounts a
	on p.id = a.PersonId
	
   WHERE a.Balance > @minBalance
   ORDER BY Balance


GO
/****** Object:  StoredProcedure [dbo].[usp_UpdateBalanceWithInterestForOneMonth]    Script Date: 14.7.2013 г. 14:24:53 ч. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_UpdateBalanceWithInterestForOneMonth](@accId int = 0, @intrestRate float = 0) AS
  UPDATE Accounts
  SET Balance = Balance + dbo.ufn_CalcIntrestForMonths(Balance, @intrestRate, 1)
  WHERE id = @accId

GO
/****** Object:  StoredProcedure [dbo].[usp_WithdrawMoney]    Script Date: 14.7.2013 г. 14:24:53 ч. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_WithdrawMoney](@AccountId int = 1, @Sum_Amount money) AS
	BEGIN TRAN
	DECLARE @CurrentAmaount money
	UPDATE Accounts
	SET Balance = Balance - @Sum_Amount,
	@CurrentAmaount = Balance - @Sum_Amount
	WHERE id = @AccountId

	IF(@CurrentAmaount < 0)
		ROLLBACK TRAN

GO
/****** Object:  UserDefinedFunction [dbo].[ufn_CalcBonus]    Script Date: 14.7.2013 г. 14:24:53 ч. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ufn_CalcBonus](@salary money)
  RETURNS money
AS
BEGIN
  IF (@salary < 10000)
    RETURN 1000
  ELSE IF (@salary BETWEEN 10000 and 30000)
    RETURN @salary / 20
  RETURN 3500
END


GO
/****** Object:  UserDefinedFunction [dbo].[ufn_CalcIntrest]    Script Date: 14.7.2013 г. 14:24:53 ч. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ufn_CalcIntrest](@balance money, @intrest float)
  RETURNS money
AS
BEGIN
	RETURN @balance * @intrest
END

GO
/****** Object:  UserDefinedFunction [dbo].[ufn_CalcIntrestForMonths]    Script Date: 14.7.2013 г. 14:24:53 ч. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ufn_CalcIntrestForMonths](@balance money, @intrest float, @months int)
  RETURNS money
AS
BEGIN
  RETURN @balance * @intrest * @months
END
GO
/****** Object:  Table [dbo].[Accounts]    Script Date: 14.7.2013 г. 14:24:53 ч. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Accounts](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[PersonId] [int] NOT NULL,
	[Balance] [money] NOT NULL,
 CONSTRAINT [PK_Accounts] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Logs]    Script Date: 14.7.2013 г. 14:24:53 ч. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Logs](
	[LogId] [int] IDENTITY(1,1) NOT NULL,
	[AccountID] [int] NOT NULL,
	[OldSum] [money] NOT NULL,
	[NewSum] [money] NOT NULL,
 CONSTRAINT [PK_Logs] PRIMARY KEY CLUSTERED 
(
	[LogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Persons]    Script Date: 14.7.2013 г. 14:24:53 ч. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Persons](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NULL,
	[SSN] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Persons] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[Accounts] ON 

INSERT [dbo].[Accounts] ([id], [PersonId], [Balance]) VALUES (1, 5, 726.0000)
INSERT [dbo].[Accounts] ([id], [PersonId], [Balance]) VALUES (2, 2, 955555.0000)
INSERT [dbo].[Accounts] ([id], [PersonId], [Balance]) VALUES (3, 1, 2645645.0000)
INSERT [dbo].[Accounts] ([id], [PersonId], [Balance]) VALUES (4, 2, 569999.0000)
INSERT [dbo].[Accounts] ([id], [PersonId], [Balance]) VALUES (5, 3, 55599.0000)
INSERT [dbo].[Accounts] ([id], [PersonId], [Balance]) VALUES (6, 4, 500.0000)
INSERT [dbo].[Accounts] ([id], [PersonId], [Balance]) VALUES (7, 5, 3695.0000)
INSERT [dbo].[Accounts] ([id], [PersonId], [Balance]) VALUES (8, 6, 59858.0000)
INSERT [dbo].[Accounts] ([id], [PersonId], [Balance]) VALUES (9, 7, 2654.0000)
INSERT [dbo].[Accounts] ([id], [PersonId], [Balance]) VALUES (10, 8, 6223.0000)
INSERT [dbo].[Accounts] ([id], [PersonId], [Balance]) VALUES (11, 9, 254.0000)
INSERT [dbo].[Accounts] ([id], [PersonId], [Balance]) VALUES (12, 10, 658.0000)
INSERT [dbo].[Accounts] ([id], [PersonId], [Balance]) VALUES (13, 9, 666.0000)
INSERT [dbo].[Accounts] ([id], [PersonId], [Balance]) VALUES (14, 8, 9226.0000)
INSERT [dbo].[Accounts] ([id], [PersonId], [Balance]) VALUES (15, 7, 885.0000)
INSERT [dbo].[Accounts] ([id], [PersonId], [Balance]) VALUES (17, 6, 51.0000)
INSERT [dbo].[Accounts] ([id], [PersonId], [Balance]) VALUES (18, 5, 888.0000)
INSERT [dbo].[Accounts] ([id], [PersonId], [Balance]) VALUES (19, 4, 956.0000)
INSERT [dbo].[Accounts] ([id], [PersonId], [Balance]) VALUES (20, 3, 85.0000)
INSERT [dbo].[Accounts] ([id], [PersonId], [Balance]) VALUES (21, 2, 365.0000)
INSERT [dbo].[Accounts] ([id], [PersonId], [Balance]) VALUES (22, 1, 6596.0000)
SET IDENTITY_INSERT [dbo].[Accounts] OFF
SET IDENTITY_INSERT [dbo].[Persons] ON 

INSERT [dbo].[Persons] ([id], [FirstName], [LastName], [SSN]) VALUES (1, N'Ivan', N'Ivaniv', N'12345655')
INSERT [dbo].[Persons] ([id], [FirstName], [LastName], [SSN]) VALUES (2, N'Stalin', N'Stalinov', N'52366545')
INSERT [dbo].[Persons] ([id], [FirstName], [LastName], [SSN]) VALUES (3, N'Pesho', N'Peshev', N'55665355')
INSERT [dbo].[Persons] ([id], [FirstName], [LastName], [SSN]) VALUES (4, N'Vun', N'Pun', N'12345678')
INSERT [dbo].[Persons] ([id], [FirstName], [LastName], [SSN]) VALUES (5, N'Hon', N'John', N'88555526')
INSERT [dbo].[Persons] ([id], [FirstName], [LastName], [SSN]) VALUES (6, N'Putin', N'Putev', N'59756319')
INSERT [dbo].[Persons] ([id], [FirstName], [LastName], [SSN]) VALUES (7, N'Gosho', N'Goshev', N'54946356')
INSERT [dbo].[Persons] ([id], [FirstName], [LastName], [SSN]) VALUES (8, N'Stamat', N'Stamatev', N'56666555')
INSERT [dbo].[Persons] ([id], [FirstName], [LastName], [SSN]) VALUES (9, N'Ilian', N'Iliev', N'89565365')
INSERT [dbo].[Persons] ([id], [FirstName], [LastName], [SSN]) VALUES (10, N'Hu', N'Du', N'56661239')
SET IDENTITY_INSERT [dbo].[Persons] OFF
ALTER TABLE [dbo].[Accounts]  WITH CHECK ADD  CONSTRAINT [FK_Accounts_Persons] FOREIGN KEY([PersonId])
REFERENCES [dbo].[Persons] ([id])
GO
ALTER TABLE [dbo].[Accounts] CHECK CONSTRAINT [FK_Accounts_Persons]
GO
ALTER TABLE [dbo].[Logs]  WITH CHECK ADD  CONSTRAINT [FK_Logs_Accounts] FOREIGN KEY([AccountID])
REFERENCES [dbo].[Accounts] ([id])
GO
ALTER TABLE [dbo].[Logs] CHECK CONSTRAINT [FK_Logs_Accounts]
GO
USE [master]
GO
ALTER DATABASE [InformationDB] SET  READ_WRITE 
GO
