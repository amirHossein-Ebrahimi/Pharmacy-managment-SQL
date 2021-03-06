USE [Pharmacy]
GO
/****** Object:  StoredProcedure [dbo].[GEN_BILL]    Script Date: 7/7/2020 1:59:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AmirHossein Ebrahimi
-- Create date: 2020/07/03
-- Description:	generate new bill
-- =============================================
ALTER PROCEDURE [dbo].[GEN_BILL]
	-- Add the parameters for the stored procedure here
	(
	@nid [char](10),
	@insurance_id bigint,
	@orderID int
)
AS
BEGIN
	DECLARE @total_amount int = 0,
			@company_percentage NUMERIC(5,2),
			@insurance_payment int = 0,
			@customer_payment int = 0;

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-- Insert statements for procedure here

	-- get total amount for prices
	SELECT @total_amount = SUM([price])
	FROM [dbo].[OrderedDrugs]
	WHERE [orderID] = @orderID;

	IF @insurance_id IS NOT NULL BEGIN
		-- get amount of Coinsurance
		SELECT @company_percentage = [coinsurance]
		FROM [dbo].[Insurance]
		WHERE [id] = @insurance_id;

		-- Incsurance will pay
		SET @insurance_payment = CONVERT(INT, @total_amount * @company_percentage / 100);

		-- Customer will pay the rest
		SET @customer_payment = @total_amount - @insurance_payment;
	END
	ELSE BEGIN
		-- Incsurance will pay
		SET @insurance_payment = 0
		-- Customer will pay the rest
		SET @customer_payment = @total_amount;
	END

	INSERT INTO [dbo].[Bill]
		(orderID, customerNID, totalPayment, customerPayment, insurancePayment)
	VALUES
		(@orderID, @nid, @total_amount, @customer_payment, @insurance_payment)
END
