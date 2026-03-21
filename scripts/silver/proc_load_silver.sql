/*
======================================================================
Procedure: silver.load_silver
Purpose: Data cleansing and standardization from Bronze to Silver
======================================================================

This procedure transforms raw Bronze data into clean Silver tables.

Key Transformations:
- Remove duplicates
- Trim whitespace
- Standardize text (UPPER)
- Remove invalid NULL records
- Data quality checks
- Add ingestion_date metadata

Silver layer represents trusted, cleaned operational data.

======================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN

    DECLARE @start_time DATETIME,
            @end_time DATETIME,
            @batch_start_time DATETIME,
            @batch_end_time DATETIME;

    BEGIN TRY

        SET @batch_start_time = GETDATE();

        PRINT '====================================';
        PRINT 'Loading Silver Layer';
        PRINT '====================================';


        /* ==========================================================
           PEDIDOS
        ========================================================== */

        SET @start_time = GETDATE();

        PRINT '>> Refreshing silver.pedidos';

        TRUNCATE TABLE silver.pedidos;

        INSERT INTO silver.pedidos
        (
            pedido_id,
            cliente_id,
            paqueteria_id,
            creado_en,
            valor_pedido,
            ingestion_date
        )
        SELECT
            pedido_id,
            TRIM(UPPER(cliente_id)),
            TRIM(UPPER(paqueteria_id)),
            creado_en,
            valor_pedido,
            GETDATE()
        FROM
        (
            SELECT *,
                ROW_NUMBER() OVER(
                    PARTITION BY pedido_id
                    ORDER BY creado_en DESC
                ) rn
            FROM bronze.pedidos
            WHERE pedido_id IS NOT NULL
            AND cliente_id IS NOT NULL
            AND valor_pedido > 0
        ) t
        WHERE rn = 1;

        SET @end_time = GETDATE();

        PRINT '>> Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '----------------------------------------------------------';


        /* ==========================================================
           PEDIDOS POOL
        ========================================================== */

        SET @start_time = GETDATE();

        PRINT '>> Refreshing silver.pedidos_pool';

        TRUNCATE TABLE silver.pedidos_pool;

        INSERT INTO silver.pedidos_pool
        SELECT
            pool_id,
            pedido_id,
            estatus_id,
            motivo_id,
            TRIM(UPPER(usuario_libero_id)),
            fecha_resolucion,
            valor_pedido,
            horas_en_pool,
            minutos_en_pool,
            GETDATE()
        FROM
        (
            SELECT *,
                ROW_NUMBER() OVER(
                    PARTITION BY pool_id
                    ORDER BY fecha_resolucion DESC
                ) rn
            FROM bronze.pedidos_pool
            WHERE pool_id IS NOT NULL
        ) t
        WHERE rn = 1;

        SET @end_time = GETDATE();

        PRINT '>> Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '----------------------------------------------------------';


        /* ==========================================================
           FACTURAS
        ========================================================== */

        SET @start_time = GETDATE();

        PRINT '>> Refreshing silver.facturas';

        TRUNCATE TABLE silver.facturas;

        INSERT INTO silver.facturas
        SELECT
            factura_id,
            pedido_id,
            estatus_id,
            fecha_factura,
            fecha_vencimiento,
            monto_factura,
            GETDATE()
        FROM
        (
            SELECT *,
                ROW_NUMBER() OVER(
                    PARTITION BY factura_id
                    ORDER BY fecha_factura DESC
                ) rn
            FROM bronze.facturas
            WHERE factura_id IS NOT NULL
            AND monto_factura >= 0
        ) t
        WHERE rn = 1;

        SET @end_time = GETDATE();

        PRINT '>> Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '----------------------------------------------------------';


        /* ==========================================================
           PAGOS
        ========================================================== */

        SET @start_time = GETDATE();

        PRINT '>> Refreshing silver.pagos';

        TRUNCATE TABLE silver.pagos;

        INSERT INTO silver.pagos
        SELECT
            pago_id,
            TRIM(UPPER(cliente_id)),
            fecha_pago,
            monto_pago,
            TRIM(UPPER(metodo_pago)),
            GETDATE()
        FROM
        (
            SELECT *,
                ROW_NUMBER() OVER(
                    PARTITION BY pago_id
                    ORDER BY fecha_pago DESC
                ) rn
            FROM bronze.pagos
            WHERE pago_id IS NOT NULL
            AND monto_pago > 0
        ) t
        WHERE rn = 1;

        SET @end_time = GETDATE();

        PRINT '>> Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '----------------------------------------------------------';


		/* ==========================================================
		   NOTAS DE CREDITO
		========================================================== */
		
		SET @start_time = GETDATE();
		
		PRINT '>> Loading silver.notas_credito';
		
		TRUNCATE TABLE silver.notas_credito;
		
		INSERT INTO silver.notas_credito
		(
		    nota_id,
		    factura_id,
		    fecha_nota,
		    monto_nota,
		    motivo,
		    ingestion_date
		)
		SELECT DISTINCT
		    nota_id,
		    factura_id,
		    fecha_nota,
		    monto_nota,
		    UPPER(LTRIM(RTRIM(motivo))),
		    GETDATE()
		FROM bronze.notas_credito
		WHERE nota_id IS NOT NULL
		    AND factura_id IS NOT NULL
		    AND fecha_nota IS NOT NULL
		    AND monto_nota > 0;
		
		SET @end_time = GETDATE();
		
		PRINT '>> Load Duration: '
		+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)
		+ ' seconds';
		
		PRINT '------------------------------------------------------';


        /* ==========================================================
           CLIENTES
        ========================================================== */

        SET @start_time = GETDATE();

        PRINT '>> Refreshing silver.clientes';

        TRUNCATE TABLE silver.clientes;

        INSERT INTO silver.clientes
        SELECT
            TRIM(UPPER(cliente_id)),
            TRIM(UPPER(nombre)),
            TRIM(UPPER(rfc)),
            TRIM(contacto),
            TRIM(domicilio),
            limite_credito,
            plazo_dias,
            fecha_modificacion,
            GETDATE()
        FROM
        (
            SELECT *,
                ROW_NUMBER() OVER(
                    PARTITION BY cliente_id
                    ORDER BY fecha_modificacion DESC
                ) rn
            FROM bronze.clientes
            WHERE cliente_id IS NOT NULL
        ) t
        WHERE rn = 1;

        SET @end_time = GETDATE();

        PRINT '>> Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '----------------------------------------------------------';


		/* ==========================================================
		   PAQUETERIAS
		========================================================== */
		
		SET @start_time = GETDATE();
		
		PRINT '>> Loading silver.paqueterias';
		
		TRUNCATE TABLE silver.paqueterias;
		
		INSERT INTO silver.paqueterias
		(
		    paqueteria_id,
		    nombre_paqueteria,
		    tipo_servicio,
		    ingestion_date
		)
		SELECT DISTINCT
		    paqueteria_id,
		    UPPER(LTRIM(RTRIM(nombre_paqueteria))),
		    UPPER(LTRIM(RTRIM(tipo_servicio))),
		    GETDATE()
		FROM bronze.paqueterias
		WHERE paqueteria_id IS NOT NULL;
		
		SET @end_time = GETDATE();
		
		PRINT '>> Load Duration: '
		+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)
		+ ' seconds';
		
		PRINT '------------------------------------------------------';


		/* ==========================================================
		   RUTAS
		========================================================== */
		
		SET @start_time = GETDATE();
		
		PRINT '>> Loading silver.rutas';
		
		TRUNCATE TABLE silver.rutas;
		
		INSERT INTO silver.rutas
		(
		    ruta_id,
		    ruta,
		    zona,
		    ingestion_date
		)
		SELECT DISTINCT
		    ruta_id,
		    UPPER(LTRIM(RTRIM(ruta))),
		    UPPER(LTRIM(RTRIM(zona))),
		    GETDATE()
		FROM bronze.rutas
		WHERE ruta_id IS NOT NULL;
		
		SET @end_time = GETDATE();
		
		PRINT '>> Load Duration: '
		+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)
		+ ' seconds';
		
		PRINT '------------------------------------------------------';


		/* ==========================================================
		   VENDEDORES
		========================================================== */
		
		SET @start_time = GETDATE();
		
		PRINT '>> Loading silver.vendedores';
		
		TRUNCATE TABLE silver.vendedores;
		
		INSERT INTO silver.vendedores
		(
		    vendedor_id,
		    ruta_id,
		    nombre,
		    contacto,
		    ingestion_date
		)
		SELECT DISTINCT
		    vendedor_id,
		    ruta_id,
		    UPPER(LTRIM(RTRIM(nombre))),
		    LTRIM(RTRIM(contacto)),
		    GETDATE()
		FROM bronze.vendedores
		WHERE vendedor_id IS NOT NULL;
		
		SET @end_time = GETDATE();
		
		PRINT '>> Load Duration: '
		+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)
		+ ' seconds';
		
		PRINT '------------------------------------------------------';


		/* ==========================================================
		   GERENTE VENTA
		========================================================== */
		
		SET @start_time = GETDATE();
		
		PRINT '>> Loading silver.gerente_venta';
		
		TRUNCATE TABLE silver.gerente_venta;
		
		INSERT INTO silver.gerente_venta
		(
		    gerente_venta_id,
		    nombre,
		    contacto,
		    ingestion_date
		)
		SELECT DISTINCT
		    gerente_venta_id,
		    UPPER(LTRIM(RTRIM(nombre))),
		    LTRIM(RTRIM(contacto)),
		    GETDATE()
		FROM bronze.gerente_venta
		WHERE gerente_venta_id IS NOT NULL;
		
		SET @end_time = GETDATE();
		
		PRINT '>> Load Duration: '
		+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)
		+ ' seconds';
		
		PRINT '------------------------------------------------------';


		/* ==========================================================
		   EJECUTIVO CREDITO
		========================================================== */
		
		SET @start_time = GETDATE();
		
		PRINT '>> Loading silver.ejecutivo_credito';
		
		TRUNCATE TABLE silver.ejecutivo_credito;
		
		INSERT INTO silver.ejecutivo_credito
		(
		    ejecutivo_credito_id,
		    nombre,
		    contacto,
		    ingestion_date
		)
		SELECT DISTINCT
		    ejecutivo_credito_id,
		    UPPER(LTRIM(RTRIM(nombre))),
		    LTRIM(RTRIM(contacto)),
		    GETDATE()
		FROM bronze.ejecutivo_credito
		WHERE ejecutivo_credito_id IS NOT NULL;
		
		SET @end_time = GETDATE();
		
		PRINT '>> Load Duration: '
		+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)
		+ ' seconds';
		
		PRINT '------------------------------------------------------';


		/* ==========================================================
		   TELEMARKETING
		========================================================== */
		
		SET @start_time = GETDATE();
		
		PRINT '>> Loading silver.telemarketing';
		
		TRUNCATE TABLE silver.telemarketing;
		
		INSERT INTO silver.telemarketing
		(
		    telemarketing_id,
		    nombre,
		    contacto,
		    ingestion_date
		)
		SELECT DISTINCT
		    telemarketing_id,
		    UPPER(LTRIM(RTRIM(nombre))),
		    LTRIM(RTRIM(contacto)),
		    GETDATE()
		FROM bronze.telemarketing
		WHERE telemarketing_id IS NOT NULL;
		
		SET @end_time = GETDATE();
		
		PRINT '>> Load Duration: '
		+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)
		+ ' seconds';
		
		PRINT '------------------------------------------------------';


		/* ==========================================================
		   GERENTE REGIONAL
		========================================================== */
		
		SET @start_time = GETDATE();
		
		PRINT '>> Loading silver.gerente_regional';
		
		TRUNCATE TABLE silver.gerente_regional;
		
		INSERT INTO silver.gerente_regional
		(
		    gerente_regional_id,
		    nombre,
		    contacto,
		    ingestion_date
		)
		SELECT DISTINCT
		    gerente_regional_id,
		    UPPER(LTRIM(RTRIM(nombre))),
		    LTRIM(RTRIM(contacto)),
		    GETDATE()
		FROM bronze.gerente_regional
		WHERE gerente_regional_id IS NOT NULL;
		
		SET @end_time = GETDATE();
		
		PRINT '>> Load Duration: '
		+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)
		+ ' seconds';
		
		PRINT '------------------------------------------------------';


		/* ==========================================================
		   USUARIO LIBERO
		========================================================== */
		
		SET @start_time = GETDATE();
		
		PRINT '>> Loading silver.usuario_libero';
		
		TRUNCATE TABLE silver.usuario_libero;
		
		INSERT INTO silver.usuario_libero
		(
		    usuario_libero_id,
		    nombre,
		    ingestion_date
		)
		SELECT DISTINCT
		    usuario_libero_id,
		    UPPER(LTRIM(RTRIM(nombre))),
		    GETDATE()
		FROM bronze.usuario_libero
		WHERE usuario_libero_id IS NOT NULL
		  AND nombre IS NOT NULL;
		
		SET @end_time = GETDATE();
		
		PRINT '>> Load Duration: '
		+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)
		+ ' seconds';
		
		PRINT '------------------------------------------------------';

		
		/* ==========================================================
		   MOTIVOS POOL
		========================================================== */
		
		SET @start_time = GETDATE();
		
		PRINT '>> Loading silver.motivos_pool';
		
		TRUNCATE TABLE silver.motivos_pool;
		
		INSERT INTO silver.motivos_pool
		(
		    motivo_id,
		    motivo,
		    ingestion_date
		)
		SELECT DISTINCT
		    motivo_id,
		    UPPER(LTRIM(RTRIM(motivo))),
		    GETDATE()
		FROM bronze.motivos_pool
		WHERE motivo_id IS NOT NULL
		  AND motivo IS NOT NULL;
		
		SET @end_time = GETDATE();
		
		PRINT '>> Load Duration: '
		+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)
		+ ' seconds';
		
		PRINT '------------------------------------------------------';


		/* ==========================================================
		   ESTATUS POOL
		========================================================== */
		
		SET @start_time = GETDATE();
		
		PRINT '>> Loading silver.estatus_pool';
		
		TRUNCATE TABLE silver.estatus_pool;
		
		INSERT INTO silver.estatus_pool
		(
		    estatus_id,
		    estatus,
		    ingestion_date
		)
		SELECT DISTINCT
		    estatus_id,
		    UPPER(LTRIM(RTRIM(estatus))),
		    GETDATE()
		FROM bronze.estatus_pool
		WHERE estatus_id IS NOT NULL
		  AND estatus IS NOT NULL;
		
		SET @end_time = GETDATE();
		
		PRINT '>> Load Duration: '
		+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)
		+ ' seconds';
		
		PRINT '------------------------------------------------------';


		/* ==========================================================
		   ESTATUS FACTURA
		========================================================== */
		
		SET @start_time = GETDATE();
		
		PRINT '>> Loading silver.estatus_factura';
		
		TRUNCATE TABLE silver.estatus_factura;
		
		INSERT INTO silver.estatus_factura
		(
		    estatus_id,
		    estatus,
		    ingestion_date
		)
		SELECT DISTINCT
		    estatus_id,
		    UPPER(LTRIM(RTRIM(estatus))),
		    GETDATE()
		FROM bronze.estatus_factura
		WHERE estatus_id IS NOT NULL
		  AND estatus IS NOT NULL;
		
		SET @end_time = GETDATE();
		
		PRINT '>> Load Duration: '
		+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)
		+ ' seconds';
		
		PRINT '------------------------------------------------------';



        /* ==========================================================
           FIN DEL BATCH
        ========================================================== */

        SET @batch_end_time = GETDATE();

        PRINT '====================================';
        PRINT 'Silver Load Completed';
        PRINT 'Total Duration: ' + CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '====================================';


    END TRY

    BEGIN CATCH

        PRINT '====================================';
        PRINT 'ERROR DURING SILVER LOAD';
        PRINT 'Message: ' + ERROR_MESSAGE();
        PRINT 'Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '====================================';

        THROW;

    END CATCH

END
