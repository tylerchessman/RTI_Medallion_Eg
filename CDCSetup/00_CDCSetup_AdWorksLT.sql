--- This script can be used to setup Change Data Capture (CDC) in the AdventureWorksLT Sample database
--  To learn how to install the AdventureWorksLT Sample, see https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver16&tabs=ssms#deploy-to-azure-sql-database
--  To learn more about CDC in general, refer to https://learn.microsoft.com/en-us/azure/azure-sql/database/change-data-capture-overview?view=azuresql

-- CDC is first enabled at a database level (run this command in the AdventureWorkLT database)
EXEC sys.sp_cdc_enable_db;
GO

-- Confirm cdc is enabled...
SELECT name, is_cdc_enabled
FROM sys.databases;

-- CDC is then enabled for one or more tables.
--  First, we will create a role that will have access to change data
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'db_cdcfab' AND type = 'R')
BEGIN
    EXEC sp_addrole 'db_cdcfab';
END
--  We will also create a login/user that can be used to connect to the database from a Fabric eventstream
--		(Note: as of April, 2025 Fabric evenstreams supports only Basic authentication.  Check here to
--			get the latest info, https://learn.microsoft.com/en-us/fabric/real-time-hub/add-source-azure-sql-database-cdc)
CREATE LOGIN CDCAcct WITH PASSWORD = 'YOUR_PWD_HERE';
CREATE USER  CDCAcct FOR LOGIN CDCAcct;
ALTER  ROLE  db_cdcfab ADD MEMBER CDCAcct;


-- Now, we will enable CDC on 2 tables - SalesOrderHeader and SalesOrderDetail
-- EXEC sys.sp_cdc_disable_table  @source_schema = N'SalesLT', @source_name = N'SalesOrderHeader', @capture_instance=N'all';
EXEC sys.sp_cdc_enable_table
    @source_schema = N'SalesLT',
    @source_name = N'SalesOrderHeader',
    @role_name = N'db_cdcfab';

-- EXEC sys.sp_cdc_disable_table  @source_schema = N'SalesLT', @source_name = N'SalesOrderDetail', @capture_instance=N'all';
EXEC sys.sp_cdc_enable_table
    @source_schema = N'SalesLT',
    @source_name = N'SalesOrderDetail',
    @role_name = N'db_cdcfab';

-- CDC is now enabled and ready to go.  The other script (01_NewOrders.sql) can be used to create new records
--   Note that while the Fabric Eventstream is going to do the actual work of reading in cdc rows, 
--		it is useful to know what is going on behind the scenes.
--		After CDC has been enabled on a table, a system table (e.g., cdc.SalesLT_SalesOrderHeader_CT) is created to store events
SELECT TOP(10) * FROM cdc.SalesLT_SalesOrderHeader_CT;
--		Rather than querying the table itself, wrapper functions are typically used e.g.,
DECLARE @from_lsn AS BINARY (10), @to_lsn AS BINARY (10);
SET @from_lsn = sys.fn_cdc_get_min_lsn('SalesLT_SalesOrderHeader');
SET @to_lsn = sys.fn_cdc_get_max_lsn();
SELECT * FROM cdc.fn_cdc_get_all_changes_SalesLT_SalesOrderHeader(@from_lsn, @to_lsn, N'all');