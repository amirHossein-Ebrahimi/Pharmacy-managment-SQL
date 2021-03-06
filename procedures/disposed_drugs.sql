USE [Pharmacy]
GO
/****** Object:  StoredProcedure [dbo].[DISPOSE_DRUGS]    Script Date: 7/7/2020 11:53:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AmirHossein Ebrahimi
-- Create date: 2020/07/04
-- Description:	generate new bill
-- =============================================
ALTER PROCEDURE [dbo].[DISPOSE_DRUGS]
(
	@drug_name nvarchar(255),
	@batch_number int, 
	@employee_id tinyint,
	@quantity int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @drug_company nvarchar(255),
			@drug_quantity int;

	-- TODO: Be consistant replace with company
	SELECT 
		@drug_company = [manufacture], 
		@drug_quantity = [stockQuantity]
	FROM [dbo].[Drug]
	WHERE [name] = @drug_name AND [batchNumber] = @batch_number AND DATEDIFF(day, GETDATE(), [ExpDate]) >= 0;

	IF @drug_company IS NOT NULL BEGIN
		-- If wants to get more than expected!
		IF @drug_quantity < @quantity
			THROW 50006, 'Your quantity entry value is more than expected, please Check Drug DB.', 1;
		
		PRINT N'UPDATE DRUG TABLE for disposed drugs';
		UPDATE [dbo].[Drug]
		SET [stockQuantity] = @drug_quantity - @quantity
		WHERE [name] = @drug_name AND [batchNumber] = @batch_number AND DATEDIFF(day, GETDATE(), [ExpDate]) >= 0;
			
		PRINT N' INSERT INTO DiposedDrugs name='+@drug_name+', LOT='+CONVERT(varchar, @batch_number)+', quantity='+CONVERT(varchar, @quantity)+', company='+@drug_company;
		INSERT INTO [dbo].[DisposedDrugs]
			(drugName, batchNumber, quantity, company)
		VALUES
			(@drug_name, @batch_number, @quantity, @drug_company);

		PRINT N' INSERT INTO EmployeeDiposedDrugs employee.id='+CONVERT(varchar, @employee_id)+', LOT='+CONVERT(varchar, @batch_number)+', name='+@drug_name+', date='+CONVERT(varchar, GETDATE());
		INSERT INTO [dbo].[EmployeeDisposedDrugs]
			(employeeID, drugName, batchNumber, disposalDate)
		VALUES
			(@employee_id, @drug_name, @batch_number, GETDATE());



	END
	ELSE BEGIN
		PRINT N'Information for drug => name=' + @drug_name + N' AND LOT=' + CONVERT(varchar, @batch_number);
		THROW 50004, '
Cannot find your drug. Double check your drug name & batch number.
See Messages Tab For more info,
If they are correct, it may be cause of 2 reason:
	1) quantity of drug is 0. 
	2) This Drug is Expired, and you must not sell it.', 1;
	END

END
