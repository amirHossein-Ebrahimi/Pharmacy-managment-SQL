USE [Pharmacy]
GO
/****** Object:  Trigger [dbo].[NewMember]    Script Date: 7/5/2020 2:40:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		AmirHossein Ebrahimi
-- Create date: 2020/07/04
-- Description:	Employee recruitment Validator
-- =============================================
ALTER TRIGGER [dbo].[NewMember]
   ON  [Pharmacy].[dbo].[Employee]
   AFTER INSERT,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	DECLARE @role varchar(15), 
			@license varchar(255);

	DECLARE MY_CURSOR CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
	FOR
	SELECT [role], [license] 
	FROM [dbo].[Employee]

	OPEN MY_CURSOR
	FETCH NEXT FROM MY_CURSOR INTO @role, @license
	WHILE @@FETCH_STATUS = 0
	BEGIN

	IF @role LIKE '%[A-Za-z]%' AND LOWER(@role) != 'cashier' AND LOWER(@role) != 'pharmacist' AND LOWER(@role) != 'cpht' AND LOWER(@role) != 'intern'
		THROW 51000, 'Invalid Role for Employee, role must be one of (Pharmacist|CPht|Intern|Cashier).[English character only]', 1;


	IF @role LIKE '%[A-Za-z]%' AND @license IS NULL AND LOWER(@role) != 'cashier'
		THROW 51001, 'Non Cashier employee must be certificated and register with license.', 1;

	FETCH NEXT FROM MY_CURSOR INTO @role, @license

	END
	CLOSE MY_CURSOR;
	DEALLOCATE MY_CURSOR;

END
