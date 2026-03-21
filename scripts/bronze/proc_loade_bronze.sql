/*
======================================================================
Procedure: bronze.load_bronze
Purpose: Incremental ingestion from source system to Bronze layer
======================================================================

This procedure extracts raw data from the CIOSACOM system using a 
Linked Server (OPENQUERY) and loads it into Bronze tables.

Key Characteristics:
- Incremental load strategy
- Raw data preservation
- Execution time tracking
- Error handling with TRY/CATCH
- Designed for Medallion Architecture

======================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN

    DECLARE @start_time DATETIME,
            @end_time DATETIME,
            @batch_start_time DATETIME,
            @batch_end_time DATETIME;

    BEGIN TRY

        SET @batch_start_time = GETDATE();

        PRINT '====================================';
        PRINT 'Loading Bronze Layer';
        PRINT '====================================';


        /* ==========================================================
           PEDIDOS
        ========================================================== */

        SET @start_time = GETDATE();

        DECLARE @last_pedido_fecha DATETIME

        SELECT @last_pedido_fecha = ISNULL(MAX(creado_en),'1900-01-01')
        FROM bronze.pedidos

        PRINT '>> Loading bronze.pedidos';

        INSERT INTO bronze.pedidos
        (
            pedido_id,
            cliente_id,
            paqueteria_id,
            creado_en,
            valor_pedido
        )
        SELECT
            pedido_id,
            cliente_id,
            paqueteria_id,
            creado_en,
            valor_pedido
        FROM OPENQUERY(CiosaCOM, '
            SELECT
                pedido_id,
                cliente_id,
                paqueteria_id,
                creado_en,
                valor_pedido
            FROM pedidos
        ') src
        WHERE src.creado_en > @last_pedido_fecha;

        SET @end_time = GETDATE();

        PRINT '>> Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '----------------------------------------------------------';



        /* ==========================================================
           FACTURAS
        ========================================================== */

        SET @start_time = GETDATE();

        DECLARE @last_factura_fecha DATETIME

        SELECT @last_factura_fecha = ISNULL(MAX(fecha_factura),'1900-01-01')
        FROM bronze.facturas

        PRINT '>> Loading bronze.facturas';

        INSERT INTO bronze.facturas
        (
            factura_id,
            pedido_id,
            estatus_id,
            fecha_factura,
            fecha_vencimiento,
            monto_factura
        )
        SELECT
            factura_id,
            pedido_id,
            estatus_id,
            fecha_factura,
            fecha_vencimiento,
            monto_factura
        FROM OPENQUERY(CiosaCOM, '
            SELECT
                factura_id,
                pedido_id,
                estatus_id,
                fecha_factura,
                fecha_vencimiento,
                monto_factura
            FROM facturas
        ') src
        WHERE src.fecha_factura > @last_factura_fecha;

        SET @end_time = GETDATE();

        PRINT '>> Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '----------------------------------------------------------';



        /* ==========================================================
           PAGOS
        ========================================================== */

        SET @start_time = GETDATE();

        DECLARE @last_pago_fecha DATETIME

        SELECT @last_pago_fecha = ISNULL(MAX(fecha_pago),'1900-01-01')
        FROM bronze.pagos

        PRINT '>> Loading bronze.pagos';

        INSERT INTO bronze.pagos
        (
            pago_id,
            cliente_id,
            fecha_pago,
            monto_pago,
            metodo_pago
        )
        SELECT
            pago_id,
            cliente_id,
            fecha_pago,
            monto_pago,
            metodo_pago
        FROM OPENQUERY(CiosaCOM, '
            SELECT
                pago_id,
                cliente_id,
                fecha_pago,
                monto_pago,
                metodo_pago
            FROM pagos
        ') src
        WHERE src.fecha_pago > @last_pago_fecha;

        SET @end_time = GETDATE();

        PRINT '>> Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '----------------------------------------------------------';

        /* ==========================================================
        NOTAS DE CREDITO
        ========================================================== */
        
        SET @start_time = GETDATE();
        
        DECLARE @last_fecha_nota DATETIME
        
        SELECT @last_fecha_nota = ISNULL(MAX(fecha_nota),'1900-01-01')
        FROM bronze.notas_credito
        
        PRINT '>> Loading bronze.notas_credito';
        
        INSERT INTO bronze.notas_credito
        (
            nota_id,
            factura_id,
            fecha_nota,
            monto_nota,
            motivo
        )
        SELECT
            nota_id,
            factura_id,
            fecha_nota,
            monto_nota,
            motivo
        FROM OPENQUERY(CiosaCOM, '
            SELECT
                nota_id,
                factura_id,
                fecha_nota,
                monto_nota,
                motivo
            FROM notas_credito
        ') src
        WHERE src.fecha_nota > @last_fecha_nota;
        
        SET @end_time = GETDATE();
        
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '---------------------------------------------------------------------------------------------';



        /* ==========================================================
           PEDIDOS POOL
        ========================================================== */
        
        SET @start_time = GETDATE();
        
        DECLARE @last_fecha_pool DATETIME
        
        SELECT @last_fecha_pool = ISNULL(MAX(fecha_resolucion),'1900-01-01')
        FROM bronze.pedidos_pool
        
        PRINT '>> Loading bronze.pedidos_pool';
        
        INSERT INTO bronze.pedidos_pool
        (
            pool_id,
            pedido_id,
            estatus_id,
            motivo_id,
            usuario_libero_id,
            fecha_resolucion,
            valor_pedido,
            horas_en_pool,
            minutos_en_pool
        )
        SELECT
            pool_id,
            pedido_id,
            estatus_id,
            motivo_id,
            usuario_libero_id,
            fecha_resolucion,
            valor_pedido,
            horas_en_pool,
            minutos_en_pool
        FROM OPENQUERY(CiosaCOM, '
            SELECT
                pool_id,
                pedido_id,
                estatus_id,
                motivo_id,
                usuario_libero_id,
                fecha_resolucion,
                valor_pedido,
                horas_en_pool,
                minutos_en_pool
            FROM pedidos_pool
        ') src
        WHERE src.fecha_resolucion > @last_fecha_pool;
        
        SET @end_time = GETDATE();
        
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '---------------------------------------------------------------------------------------------';


        /* ==========================================================
           CLIENTES (FULL LOAD - DIMENSION)
        ========================================================== */

        SET @start_time = GETDATE();

        PRINT '>> Refreshing bronze.clientes';

        TRUNCATE TABLE bronze.clientes;

        INSERT INTO bronze.clientes
        (
            cliente_id,
            nombre,
            rfc,
            contacto,
            domicilio
        )
        SELECT
            cliente_id,
            nombre,
            rfc,
            contacto,
            domicilio
        FROM OPENQUERY(CiosaCOM, '
            SELECT
                cliente_id,
                nombre,
                rfc,
                contacto,
                domicilio
            FROM clientes
        ');

        SET @end_time = GETDATE();

        PRINT '>> Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '----------------------------------------------------------';



        /* ==========================================================
           FIN DEL BATCH
        ========================================================== */

        SET @batch_end_time = GETDATE();

        PRINT '====================================';
        PRINT 'Bronze Load Completed';
        PRINT 'Total Duration: ' + CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '====================================';

    END TRY

    BEGIN CATCH

        PRINT '====================================';
        PRINT 'ERROR DURING BRONZE LOAD';
        PRINT 'Message: ' + ERROR_MESSAGE();
        PRINT 'Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '====================================';

        THROW;

    END CATCH

END
