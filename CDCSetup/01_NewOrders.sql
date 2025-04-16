-- This script can be used to create, and make changes to, a new Sales Order

-- We will use an existing Order (which contains 3 order detail line items) as our starting point
DECLARE @SalesOrderIDOrig int = 71923;

-- The first transaction creates a new SalesOrderHeader row - and 3 SalesOrderDetail rows
BEGIN TRAN;
		
	DECLARE @SalesOrderID int;
	SELECT  @SalesOrderID = MAX(SalesOrderID) + 1 FROM SalesLT.SalesOrderHeader;

	DECLARE @OrderDate datetime = getdate();

	INSERT INTO [SalesLT].[SalesOrderHeader]
			   ([SalesOrderID]
			   ,[RevisionNumber]
			   ,[OrderDate]
			   ,[DueDate]
			   ,[ShipDate]
			   ,[Status]
			   ,[OnlineOrderFlag]
			   --,[PurchaseOrderNumber],[AccountNumber]
			   ,[CustomerID]
			   ,[ShipToAddressID]
			   ,[BillToAddressID]
			   ,[ShipMethod]
			  -- ,[CreditCardApprovalCode]
			   ,[SubTotal]
			   ,[TaxAmt]
			   ,[Freight]
			   ,[Comment]
			   --,[rowguid]
			   ,[ModifiedDate])
	SELECT @SalesOrderID, 1,@OrderDate, DATEADD(day, 8, @OrderDate), DATEADD(day, 3, @OrderDate)
			   ,1, 1 -- Status and OnlineOrderFlag
			   --,<PurchaseOrderNumber, [dbo].[OrderNumber],>
			   --,<AccountNumber, [dbo].[AccountNumber],>
			   ,[CustomerID] ,[ShipToAddressID] ,[BillToAddressID],[ShipMethod]
			   ,[SubTotal],[TaxAmt],[Freight]
			   ,'New Order ' + CAST(@OrderDate AS varchar(20) )
			   ,@OrderDate
	FROM  [SalesLT].[SalesOrderHeader] WHERE SalesOrderID = @SalesOrderIDOrig;

	-- Copy over the Order Details...
	INSERT INTO SalesLT.SalesOrderDetail (SalesOrderID, OrderQty, ProductID, UnitPrice,
			UnitPriceDiscount, ModifiedDate)
	SELECT @SalesOrderID, OrderQty, ProductID, UnitPrice,
			UnitPriceDiscount, @OrderDate
	FROM   SalesLT.SalesOrderDetail WHERE SalesOrderID = @SalesOrderIDOrig;

	SELECT '----------------' AS NewSalesOrder;
	SELECT * FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @SalesOrderID;
	SELECT * FROM SalesLT.SalesOrderDetail WHERE SalesOrderID = @SalesOrderID;

COMMIT TRAN;


-- This next transaction will:
--		Delete a SalesOrderDetail row
--		Update a SalesOrderDetail row(adjust the Qty)
--		Insert a new SalesOrderDetail row
-- The SalesOrderHeader row will also be Updated (modified RevisionNumber, Status, and ModifiedDate)
BEGIN TRAN;
	WAITFOR DELAY '00:00:00:100';
	DELETE FROM SalesLT.SalesOrderDetail WHERE SalesOrderID = @SalesOrderID AND ProductID = 870;
	--
	WAITFOR DELAY '00:00:00:100';
	UPDATE SalesLT.SalesOrderDetail SET OrderQty = 5, ModifiedDate = getdate()
	WHERE SalesOrderID = @SalesOrderID AND ProductID = 874;
	--
	WAITFOR DELAY '00:00:00:100';
	SET @OrderDate = getdate();
	INSERT INTO SalesLT.SalesOrderDetail (SalesOrderID, OrderQty, ProductID, UnitPrice,
			UnitPriceDiscount, ModifiedDate)
	SELECT @SalesOrderID, OrderQty + 2, 872, 4.99,
			UnitPriceDiscount, getdate()
	FROM   SalesLT.SalesOrderDetail WHERE SalesOrderID = @SalesOrderIDOrig AND ProductID = 870;

	-- Now, lets Update the SalesOrderHeader itself - we can change the Revision=2 and Status=2
	WAITFOR DELAY '00:00:00:100';
	UPDATE SalesLT.SalesOrderHeader SET RevisionNumber=2, Status=2, ModifiedDate = getdate()
	WHERE SalesOrderID = @SalesOrderID;

	SELECT '----------------' AS UpdatedSalesOrder;

	SELECT * FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @SalesOrderID;
	SELECT * FROM SalesLT.SalesOrderDetail WHERE SalesOrderID = @SalesOrderID;

COMMIT TRAN;