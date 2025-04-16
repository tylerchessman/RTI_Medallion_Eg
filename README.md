# RTI_Medallion_Eg
Example implementation of a Medallion architecture in Fabric RTI - using Azure SQL DB CDC Events as a source

## Summary
Building a multi-layer, medallion architecture using Fabric Real-Time Intelligence (RTI) requires a different approach compared to traditional data warehousing techniques.  But even transactional source systems can be effectively processed in RTI.   To demonstrate, we’ll look at how sales orders (created in a relational database) can be continuously ingested and transformed.

## Pre-Requisites
To implement this example in your own environment, get started by creating the AdventureWorksLT sample database in Azure.  See [here](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver16&tabs=ssms#deploy-to-azure-sql-database) for information on how to install the sample database.  Then, enable Change Data Capture (CDC).  The 00_CDCSetup_AdWorksLT.sql script (located in the CDCSetup folder) can be used to enable and configure CDC.

You’ll also need access to a [workspace](https://learn.microsoft.com/en-us/fabric/fundamentals/workspaces) associated to a Fabric-enabled capacity.  Depending on your environment, you may be able to use a [trial](https://learn.microsoft.com/en-us/fabric/fundamentals/fabric-trial) if an existing capacity is not available.

## Walkthrough
The rest of the documentation is located in the file RTI_MedallionArch_TransactionData.pdf.
