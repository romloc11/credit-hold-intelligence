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

        PRINT'---------------------------------------'
        PRINT 'Loading CIOSACOM Bronze Tables'
        PRINT'---------------------------------------'
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
           USUARIO LIBERACION
        ========================================================== */
        
        SET @start_time = GETDATE();
        
        PRINT '>> Truncating Table: bronze.usuario_libero';
        
        TRUNCATE TABLE bronze.usuario_libero;
        
        PRINT '>> Inserting Data Into: bronze.usuario_libero';
        
        INSERT INTO bronze.usuario_libero
        (
            usuario_libero_id,
            nombre
        )
        SELECT
            usuario_libero_id,
            nombre
        FROM OPENQUERY(CiosaCOM, '
            SELECT
                usuario_libero_id,
                nombre
            FROM usuario_libero
        ');
        
        SET @end_time = GETDATE();
        
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '---------------------------------------------------------------------------------------------';


        /* ==========================================================
           MOTIVOS POOL
        ========================================================== */
        
        SET @start_time = GETDATE();
        
        PRINT '>> Truncating Table: bronze.motivos_pool';
        
        TRUNCATE TABLE bronze.motivos_pool;
        
        PRINT '>> Inserting Data Into: bronze.motivos_pool';
        
        INSERT INTO bronze.motivos_pool
        (
            motivo_id,
            motivo
        )
        SELECT
            motivo_id,
            motivo
        FROM OPENQUERY(CiosaCOM, '
            SELECT
                motivo_id,
                motivo
            FROM motivos_pool
        ');
        
        SET @end_time = GETDATE();
        
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '---------------------------------------------------------------------------------------------';


        /* ==========================================================
           ESTATUS POOL
        ========================================================== */
        
        SET @start_time = GETDATE();
        
        PRINT '>> Truncating Table: bronze.estatus_pool';
        
        TRUNCATE TABLE bronze.estatus_pool;
        
        PRINT '>> Inserting Data Into: bronze.estatus_pool';
        
        INSERT INTO bronze.estatus_pool
        (
            estatus_id,
            estatus
        )
        SELECT
            estatus_id,
            estatus
        FROM OPENQUERY(CiosaCOM, '
            SELECT
                estatus_id,
                estatus
            FROM estatus_pool
        ');
        
        SET @end_time = GETDATE();
        
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '---------------------------------------------------------------------------------------------';


        PRINT'---------------------------------------'
        PRINT 'Loading ERP Bronze Tables'
        PRINT'---------------------------------------'
        /* ==========================================================
           FACTURAS
        ========================================================== */
        
        SET @start_time = GETDATE();
        
        PRINT '>> Loading Table: bronze.facturas';
        
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
        FROM ERP.dbo.facturas f
        WHERE NOT EXISTS (
            SELECT 1
            FROM bronze.facturas b
            WHERE b.factura_id = f.factura_id
        );
        
        SET @end_time = GETDATE();
        
        PRINT '>> Load Duration: ' 
            + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';
        
        PRINT '---------------------------------------------------------------------------------------------';



        /* ==========================================================
           PAGOS
        ========================================================== */
        
        SET @start_time = GETDATE();
        
        PRINT '>> Loading Table: bronze.pagos';
        
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
        FROM ERP.dbo.pagos p
        WHERE NOT EXISTS (
            SELECT 1
            FROM bronze.pagos b
            WHERE b.pago_id = p.pago_id
        );
        
        SET @end_time = GETDATE();
        
        PRINT '>> Load Duration: ' 
            + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';
        
        PRINT '---------------------------------------------------------------------------------------------';


        /* ==========================================================
           NOTAS DE CREDITO
        ========================================================== */
        
        SET @start_time = GETDATE();
        
        PRINT '>> Loading Table: bronze.notas_credito';
        
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
        FROM ERP.dbo.notas_credito n
        WHERE NOT EXISTS (
            SELECT 1
            FROM bronze.notas_credito b
            WHERE b.nota_id = n.nota_id
        );
        
        SET @end_time = GETDATE();
        
        PRINT '>> Load Duration: ' 
            + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';
        
        PRINT '---------------------------------------------------------------------------------------------';


        /* ==========================================================
           ESTATUS FACTURA
        ========================================================== */
        
        SET @start_time = GETDATE();
        
        PRINT '>> Truncating Table: bronze.estatus_factura';
        
        TRUNCATE TABLE bronze.estatus_factura;
        
        PRINT '>> Inserting Data Into: bronze.estatus_factura';
        
        INSERT INTO bronze.estatus_factura
        (
            estatus_id,
            estatus
        )
        SELECT
            estatus_id,
            estatus
        FROM ERP.dbo.estatus_factura;
        
        SET @end_time = GETDATE();
        
        PRINT '>> Load Duration: ' 
            + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';
        
        PRINT '---------------------------------------------------------------------------------------------';


        PRINT'---------------------------------------'
        PRINT 'Loading CRM Bronze Tables'
        PRINT'---------------------------------------'
        /* ==========================================================
        CLIENTES
        ========================================================== */
        
        SET @start_time = GETDATE();
        
        PRINT '>> Truncating Table: bronze.clientes';
        
        TRUNCATE TABLE bronze.clientes;
        
        PRINT '>> Inserting Data Into: bronze.clientes';
        
        INSERT INTO bronze.clientes
        (
            cliente_id,
            nombre,
            rfc,
            contacto,
            domicilio,
            limite_credito,
            plazo_dias,
            fecha_modificacion
        )
        SELECT
            cliente_id,
            nombre,
            rfc,
            contacto,
            domicilio,
            limite_credito,
            plazo_dias,
            fecha_modificacion
        FROM OPENQUERY(CiosaCOM, '
            SELECT
                cliente_id,
                nombre,
                rfc,
                contacto,
                domicilio,
                limite_credito,
                plazo_dias,
                fecha_modificacion
            FROM clientes
        ');
        
        SET @end_time = GETDATE();
        
        PRINT '>> Load Duration: ' 
            + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';
        
        PRINT '---------------------------------------------------------------------------------------------';


        /* ==========================================================
           PAQUETERIAS
        ========================================================== */
        
        SET @start_time = GETDATE();
        
        PRINT '>> Truncating Table: bronze.paqueterias';
        
        TRUNCATE TABLE bronze.paqueterias;
        
        PRINT '>> Inserting Data Into: bronze.paqueterias';
        
        INSERT INTO bronze.paqueterias
        (
            paqueteria_id,
            nombre_paqueteria,
            tipo_servicio
        )
        SELECT
            paqueteria_id,
            nombre_paqueteria,
            tipo_servicio
        FROM OPENQUERY(CiosaCOM, '
            SELECT
                paqueteria_id,
                nombre_paqueteria,
                tipo_servicio
            FROM paqueterias
        ');
        
        SET @end_time = GETDATE();
        
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '---------------------------------------------------------------------------------------------';


        /* ==========================================================
           RUTAS
        ========================================================== */
        
        SET @start_time = GETDATE();
        
        PRINT '>> Truncating Table: bronze.rutas';
        
        TRUNCATE TABLE bronze.rutas;
        
        PRINT '>> Inserting Data Into: bronze.rutas';
        
        INSERT INTO bronze.rutas
        (
            ruta_id,
            ruta,
            zona
        )
        SELECT
            ruta_id,
            ruta,
            zona
        FROM OPENQUERY(CiosaCOM, '
            SELECT
                ruta_id,
                ruta,
                zona
            FROM rutas
        ');
        
        SET @end_time = GETDATE();
        
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '---------------------------------------------------------------------------------------------';


        /* ==========================================================
           VENDEDORES
        ========================================================== */
        
        SET @start_time = GETDATE();
        
        PRINT '>> Truncating Table: bronze.vendedores';
        
        TRUNCATE TABLE bronze.vendedores;
        
        PRINT '>> Inserting Data Into: bronze.vendedores';
        
        INSERT INTO bronze.vendedores
        (
            vendedor_id,
            ruta_id,
            nombre,
            contacto
        )
        SELECT
            vendedor_id,
            ruta_id,
            nombre,
            contacto
        FROM OPENQUERY(CiosaCOM, '
            SELECT
                vendedor_id,
                ruta_id,
                nombre,
                contacto
            FROM vendedores
        ');
        
        SET @end_time = GETDATE();
        
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '---------------------------------------------------------------------------------------------';

        
        /* ==========================================================
           GERENTE VENTA
        ========================================================== */
        
        SET @start_time = GETDATE();
        
        PRINT '>> Truncating Table: bronze.gerente_venta';
        
        TRUNCATE TABLE bronze.gerente_venta;
        
        PRINT '>> Inserting Data Into: bronze.gerente_venta';
        
        INSERT INTO bronze.gerente_venta
        (
            gerente_venta_id,
            nombre,
            contacto
        )
        SELECT
            gerente_venta_id,
            nombre,
            contacto
        FROM OPENQUERY(CiosaCOM, '
            SELECT
                gerente_venta_id,
                nombre,
                contacto
            FROM gerente_venta
        ');
        
        SET @end_time = GETDATE();
        
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '---------------------------------------------------------------------------------------------';

        
        /* ==========================================================
           EJECUTIVO CREDITO
        ========================================================== */
        
        SET @start_time = GETDATE();
        
        PRINT '>> Truncating Table: bronze.ejecutivo_credito';
        
        TRUNCATE TABLE bronze.ejecutivo_credito;
        
        PRINT '>> Inserting Data Into: bronze.ejecutivo_credito';
        
        INSERT INTO bronze.ejecutivo_credito
        (
            ejecutivo_credito_id,
            nombre,
            contacto
        )
        SELECT
            ejecutivo_credito_id,
            nombre,
            contacto
        FROM OPENQUERY(CiosaCOM, '
            SELECT
                ejecutivo_credito_id,
                nombre,
                contacto
            FROM ejecutivo_credito
        ');
        
        SET @end_time = GETDATE();
        
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '---------------------------------------------------------------------------------------------';


        /* ==========================================================
           TELEMARKETING
        ========================================================== */
        
        SET @start_time = GETDATE();
        
        PRINT '>> Truncating Table: bronze.telemarketing';
        
        TRUNCATE TABLE bronze.telemarketing;
        
        PRINT '>> Inserting Data Into: bronze.telemarketing';
        
        INSERT INTO bronze.telemarketing
        (
            telemarketing_id,
            nombre,
            contacto
        )
        SELECT
            telemarketing_id,
            nombre,
            contacto
        FROM OPENQUERY(CiosaCOM, '
            SELECT
                telemarketing_id,
                nombre,
                contacto
            FROM telemarketing
        ');
        
        SET @end_time = GETDATE();
        
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '---------------------------------------------------------------------------------------------';


        /* ==========================================================
           GERENTE REGIONAL
        ========================================================== */
        
        SET @start_time = GETDATE();
        
        PRINT '>> Truncating Table: bronze.gerente_regional';
        
        TRUNCATE TABLE bronze.gerente_regional;
        
        PRINT '>> Inserting Data Into: bronze.gerente_regional';
        
        INSERT INTO bronze.gerente_regional
        (
            gerente_regional_id,
            nombre,
            contacto
        )
        SELECT
            gerente_regional_id,
            nombre,
            contacto
        FROM OPENQUERY(CiosaCOM, '
            SELECT
                gerente_regional_id,
                nombre,
                contacto
            FROM gerente_regional
        ');
        
        SET @end_time = GETDATE();
        
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '---------------------------------------------------------------------------------------------';





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
