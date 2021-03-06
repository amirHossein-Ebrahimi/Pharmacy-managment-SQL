USE [Pharmacy]
GO
/****** Object:  StoredProcedure [dbo].[ADD_DRUG_TO_ORDER]    Script Date: 7/7/2020 1:48:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AmirHossein Ebrahimi
-- Create date: 2020/07/04
-- Description:	generate new bill
-- =============================================
ALTER PROCEDURE [dbo].[ADD_DRUG_TO_ORDER]
	-- Add the parameters for the stored procedure here
	(
	@orderID int,
	@drug_name [nvarchar](255),
	@quantity int
)
AS
BEGIN
	DECLARE @insufficent_quantity bit = 0,
			@selected_drug_name nvarchar(255),
			@selected_LOT int,
			@selected_price int,
			@selected_quantity int;

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-- Insert statements for procedure here

	-- get total amount for prices
	SELECT 
		@selected_drug_name = [name], 
		@selected_LOT = [batchNumber],
		@selected_price = [price],
		@selected_quantity = [stockQuantity]
	FROM [dbo].[Drug]
	WHERE [name] = @drug_name;

	IF @selected_quantity < @quantity 
		SET @insufficent_quantity = 1;
	ELSE BEGIN
		INSERT INTO [dbo].[OrderedDrugs]
			(orderID, drugName, orderedQuantity, price, batchNumber)
		VALUES
			(@orderID,  @selected_drug_name, @quantity, @quantity * @selected_price, @selected_LOT);
		PRINT @selected_drug_name + N' successfully added to the order!';
	END
	
	IF @insufficent_quantity = 1 
	PRINT N'Request for ' + @drug_name + N' has been terminated, duo to MaximumOrderPossibility. Check Drug db for more info.';
END
