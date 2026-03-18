/*
======================================================================
Procedure: dbo.silver_load
Purpose: Data transformation from Bronze to Silver layer
======================================================================

This procedure transforms and cleans data from the Bronze layer into
the Silver layer by applying data standardization, deduplication,
and business-friendly mappings.

Key Characteristics:
- Full refresh load (TRUNCATE + INSERT)
- Data cleansing and normalization
- Deduplication using ROW_NUMBER()
- Basic business rule application
- Execution time tracking for performance monitoring

The Silver layer refines raw Bronze data into a structured and
cleaned dataset, making it suitable for analysis and ready for
downstream consumption in the Gold layer.

Error Handling is implemented using TRY/CATCH blocks to ensure pipeline 
reliability and proper error propagation.
======================================================================
*/

CREATE OR ALTER PROCEDURE dbo.silver_load AS
BEGIN
   DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
   BEGIN TRY
       SET @batch_start_time = GETDATE();
       PRINT '====================================';
       PRINT 'Loading Silver Layer';
       PRINT '====================================';
	   
		--PEDIDOS
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: dbo.silver_pedidos_pool_clientes'
		TRUNCATE TABLE dbo.silver_pedidos_pool_clientes
		PRINT '>> Inserting Data Into: dbo.silver_pedidos_pool_clientes'
		INSERT INTO dbo.silver_pedidos_pool_clientes (
			pedido,
			cliente,
			valor_pedido,
			estatus,
			bsap,
			bvs,
			belx,
			creado_en,
			liberado_fecha,
			cancelado_fecha,
			usuario_libero)
		SELECT 
		pedido,
		cliente,
		valor_pedido,
		estatus,
		bsap,
		bvs,
		belx,
		creado_en,
		liberado_fecha,
		cancelado_fecha,
		CASE 
			WHEN usuario_libero IS NULL 
				 AND estatus IN (1, 3) -- 1=Liberado, 3=Cancelado
				THEN 'sistema'
			ELSE usuario_libero
		END AS usuario_libero
		FROM (
			SELECT 
			*,
			ROW_NUMBER() OVER (PARTITION BY pedido ORDER BY creado_en DESC) flag_last
			FROM dbo.bronze_pedidos_pool_clientes)t WHERE flag_last = 1 -- Select the most recent record per order
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '---------------------------------------------------------------------------------------------';

		--VENDEDORES
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: dbo.silver_vendedores'
		TRUNCATE TABLE dbo.silver_vendedores
		PRINT '>> Inserting Data Into: dbo.silver_vendedores'
		INSERT INTO dbo.silver_vendedores (
		usuario,
		nombre)
		SELECT 
		usuario,
		LOWER(TRIM(nombre)) nombre --Removed unwanted spaces
		FROM dbo.bronze_vendedores
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '---------------------------------------------------------------------------------------------';

		--ESTATUS
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: dbo.silver_estatus_pool'
		TRUNCATE TABLE dbo.silver_estatus_pool
		PRINT '>> Inserting Data Into: dbo.silver_estatus_pool'
		INSERT INTO dbo.silver_estatus_pool (
		estatus,
		descripcion)
		SELECT 
		estatus,
		CASE 
			WHEN estatus IN (0,2) THEN 'Retenido'
			WHEN estatus = 1 THEN 'Liberado'
			WHEN estatus = 3 THEN 'Cancelado'
			ELSE 'Desconocido'
		END AS descripcion --Renamed descripcion for analysis 
		FROM dbo.bronze_estatus_pool
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '---------------------------------------------------------------------------------------------';


        SET @batch_end_time = GETDATE();
        PRINT '===========================================';
        PRINT 'Loading Silver Layer is Completed';
        PRINT '   - Total Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '==========================================='; 
	END TRY 

	BEGIN CATCH
        PRINT '===========================================';
        PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Message: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Message: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '===========================================';
        THROW;
    END CATCH
END

