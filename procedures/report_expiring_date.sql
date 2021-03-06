USE [Pharmacy]
GO
/****** Object:  StoredProcedure [dbo].[REPORT_EXPIRING_DRUGS]    Script Date: 7/5/2020 5:45:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AmirHossein Ebrahimi
-- Create date: 2020/07/04
-- Description:	generate new bill
-- =============================================
ALTER PROCEDURE [dbo].[REPORT_EXPIRING_DRUGS]
AS
BEGIN
	PRINT N'ALL DRUGS EXPIRING IN NEXT 60 DAYS.';
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-- Insert statements for procedure here

DECLARE @drug_name nvarchar(255),
			@drug_batchNumber int,
			@drug_manufacture nvarchar(255),
			@drug_stock_quantity int, 
			@drug_exp_date date;

DECLARE MY_CURSOR CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
FOR
SELECT
	[name],
	[batchNumber],
	[manufacture],
	[stockQuantity],
	[ExpDate]
FROM [dbo].[Drug]
WHERE DATEDIFF(day, GETDATE(), [ExpDate]) < 60

OPEN MY_CURSOR
FETCH NEXT FROM MY_CURSOR 
		INTO @drug_name, 
			 @drug_batchNumber, 
			 @drug_manufacture, 
			 @drug_stock_quantity, 
			 @drug_exp_date
WHILE @@FETCH_STATUS = 0
	BEGIN
	PRINT N'Out dated drug (' + @drug_name + N') with LOT ' +
		  CONVERT(varchar, @drug_batchNumber) + N' from ' + @drug_manufacture + 
		  N' company.There are ' + CONVERT(varchar, @drug_stock_quantity) + 
		  N' Left and its expiration date is at ' + CONVERT(varchar(10), @drug_exp_date) + N'.';
	FETCH NEXT FROM MY_CURSOR 
			INTO @drug_name, 
				 @drug_batchNumber, 
				 @drug_manufacture, 
				 @drug_stock_quantity, 
				 @drug_exp_date
END
CLOSE MY_CURSOR;
DEALLOCATE MY_CURSOR;

END
