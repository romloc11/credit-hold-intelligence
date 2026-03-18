
/*
======================================================================
Procedure: dbo.bronze_load
Purpose: Data ingestion from source system to Bronze layer
======================================================================

This procedure extracts data from the CIOSACOM system using a Linked
Server (OPENQUERY) and loads it into Bronze tables.

Key Characteristics:
- Full refresh load (TRUNCATE + INSERT)
- Raw data preservation
- Ingestion timestamp added for auditability
- Execution time tracking for performance monitoring

The Bronze layer acts as the foundation of the Medallion architecture,
serving as the raw data source for downstream transformations in the
Silver layer.

Error handling is implemented using TRY/CATCH blocks to ensure
pipeline reliability.

Data quality filter: 
records prior to 2026-03-10 are excluded due to identified inconsistencies during initial system operation

======================================================================
*/



CREATE OR ALTER PROCEDURE dbo.bronze_load AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '====================================';
        PRINT 'Loading Bronze Layer';
        PRINT '====================================';
        -- PEDIDOS
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: dbo.bronze_pedidos_pool_clientes';
        TRUNCATE TABLE dbo.bronze_pedidos_pool_clientes;
        PRINT '>> Inserting Data Into: dbo.bronze_pedidos_pool_clientes';
        INSERT INTO dbo.bronze_pedidos_pool_clientes
        (
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
            usuario_libero
        )
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
            usuario_libero
        FROM OPENQUERY(CiosaCOM, '
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
                usuario_libero
            FROM pedidos_pool_clientes
            WHERE creado_en >= ''2026-03-11''
        ');
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '---------------------------------------------------------------------------------------------';

        -- VENDEDORES
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: dbo.bronze_vendedores';
        TRUNCATE TABLE dbo.bronze_vendedores;
        PRINT '>> Inserting Data Into: dbo.bronze_vendedores';
        INSERT INTO dbo.bronze_vendedores
        (
            usuario,
            nombre
        )
        SELECT
            usuario,
            nombre
        FROM OPENQUERY(CiosaCOM, '
            SELECT usuario, nombre
            FROM vendedores
        ');
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '---------------------------------------------------------------------------------------------';


        -- ESTATUS
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: dbo.bronze_estatus_pool';
        TRUNCATE TABLE dbo.bronze_estatus_pool;
        PRINT '>> Inserting Data Into: dbo.bronze_estatus_pool';
        INSERT INTO dbo.bronze_estatus_pool
        (
            estatus,
            descripcion
        )
        SELECT
            estatus,
            descripcion
        FROM OPENQUERY(CiosaCOM, '
            SELECT estatus, descripcion
            FROM estatus_pool
        ');
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '---------------------------------------------------------------------------------------------';


        SET @batch_end_time = GETDATE();
        PRINT '===========================================';
        PRINT 'Loading Bronze Layer is Completed';
        PRINT '   - Total Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '==========================================='; 
    END TRY
    BEGIN CATCH
        PRINT '===========================================';
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Message: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Message: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '===========================================';
        THROW;
    END CATCH
END

