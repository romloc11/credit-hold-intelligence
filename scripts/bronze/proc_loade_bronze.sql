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

PRINT '---------------------------------------';
PRINT 'Loading CIOSACOM Bronze Tables';
PRINT '---------------------------------------';


/* ==========================================================
   PEDIDOS
========================================================== */

SET @start_time = GETDATE();

PRINT '>> Loading bronze.ciosacom_pedidos';

MERGE bronze.ciosacom_pedidos AS tgt
USING
(
    SELECT
        pedido_id,
        cliente_id,
        paqueteria_id,
        creado_en,
        valor_pedido
    FROM OPENQUERY(CiosaCOM,'
        SELECT
            pedido_id,
            cliente_id,
            paqueteria_id,
            creado_en,
            valor_pedido
        FROM pedidos
    ')
) src
ON tgt.pedido_id = src.pedido_id

WHEN MATCHED AND
(
    tgt.cliente_id <> src.cliente_id OR
    tgt.paqueteria_id <> src.paqueteria_id OR
    tgt.valor_pedido <> src.valor_pedido
)

THEN UPDATE SET
    cliente_id = src.cliente_id,
    paqueteria_id = src.paqueteria_id,
    creado_en = src.creado_en,
    valor_pedido = src.valor_pedido

WHEN NOT MATCHED THEN
INSERT
(
    pedido_id,
    cliente_id,
    paqueteria_id,
    creado_en,
    valor_pedido
)
VALUES
(
    src.pedido_id,
    src.cliente_id,
    src.paqueteria_id,
    src.creado_en,
    src.valor_pedido
);

SET @end_time = GETDATE();
PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';



/* ==========================================================
   PEDIDOS POOL
========================================================== */

SET @start_time = GETDATE();

PRINT '>> Loading bronze.ciosacom_pedidos_pool';

MERGE bronze.ciosacom_pedidos_pool tgt
USING
(
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
FROM OPENQUERY(CiosaCOM,'
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
')
) src

ON tgt.pool_id = src.pool_id

WHEN MATCHED THEN UPDATE SET

    pedido_id = src.pedido_id,
    estatus_id = src.estatus_id,
    motivo_id = src.motivo_id,
    usuario_libero_id = src.usuario_libero_id,
    fecha_resolucion = src.fecha_resolucion,
    valor_pedido = src.valor_pedido,
    horas_en_pool = src.horas_en_pool,
    minutos_en_pool = src.minutos_en_pool

WHEN NOT MATCHED THEN
INSERT
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
VALUES
(
    src.pool_id,
    src.pedido_id,
    src.estatus_id,
    src.motivo_id,
    src.usuario_libero_id,
    src.fecha_resolucion,
    src.valor_pedido,
    src.horas_en_pool,
    src.minutos_en_pool
);

SET @end_time = GETDATE();
PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';


/* ==========================================================
   USUARIO LIBERACIÓN
========================================================== */

SET @start_time = GETDATE();

PRINT '>> Loading bronze.ciosacom_usuario_libero';

TRUNCATE TABLE bronze.ciosacom_usuario_libero;

INSERT INTO bronze.ciosacom_usuario_libero
(
    usuario_libero_id,
    nombre
)
SELECT
    usuario_libero_id,
    nombre
FROM OPENQUERY(CiosaCOM,'
    SELECT
        usuario_libero_id,
        nombre
    FROM usuario_libero
');

SET @end_time = GETDATE();

PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';


/* ==========================================================
   MOTIVOS POOL
========================================================== */

SET @start_time = GETDATE();

PRINT '>> Loading bronze.ciosacom_motivos_pool';

TRUNCATE TABLE bronze.ciosacom_motivos_pool;

INSERT INTO bronze.ciosacom_motivos_pool
(
    motivo_id,
    motivo
)
SELECT
    motivo_id,
    motivo
FROM OPENQUERY(CiosaCOM,'
    SELECT
        motivo_id,
        motivo
    FROM motivos_pool
');

SET @end_time = GETDATE();

PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';


/* ==========================================================
   ESTATUS POOL
========================================================== */

SET @start_time = GETDATE();

PRINT '>> Loading bronze.ciosacom_estatus_pool';

TRUNCATE TABLE bronze.ciosacom_estatus_pool;

INSERT INTO bronze.ciosacom_estatus_pool
(
    estatus_id,
    estatus
)
SELECT
    estatus_id,
    estatus
FROM OPENQUERY(CiosaCOM,'
    SELECT
        estatus_id,
        estatus
    FROM estatus_pool
');

SET @end_time = GETDATE();

PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';


PRINT '---------------------------------------';
PRINT 'Loading ERP Bronze Tables';
PRINT '---------------------------------------';


/* ==========================================================
   VBRK
========================================================== */

SET @start_time = GETDATE();

PRINT '>> Loading bronze.erp_vbrk';

MERGE bronze.erp_vbrk tgt
USING
(
SELECT
    VBELN,
    FKDAT,
    KUNAG,
    NETWR,
    WAERK,
    FKSTK
FROM ERP.dbo.VBRK
) src

ON tgt.VBELN = src.VBELN

WHEN MATCHED THEN UPDATE SET

    FKDAT = src.FKDAT,
    KUNAG = src.KUNAG,
    NETWR = src.NETWR,
    WAERK = src.WAERK,
    FKSTK = src.FKSTK

WHEN NOT MATCHED THEN
INSERT
(
    VBELN,
    FKDAT,
    KUNAG,
    NETWR,
    WAERK,
    FKSTK
)
VALUES
(
    src.VBELN,
    src.FKDAT,
    src.KUNAG,
    src.NETWR,
    src.WAERK,
    src.FKSTK
);

SET @end_time = GETDATE();
PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';



/* ==========================================================
   VBRP
========================================================== */

SET @start_time = GETDATE();

PRINT '>> Loading bronze.erp_vbrp';

MERGE bronze.erp_vbrp tgt
USING
(
SELECT
    VBELN,
    POSNR,
    VGBEL,
    NETWR
FROM ERP.dbo.VBRP
) src

ON tgt.VBELN = src.VBELN
AND tgt.POSNR = src.POSNR

WHEN MATCHED THEN UPDATE SET

    VGBEL = src.VGBEL,
    NETWR = src.NETWR

WHEN NOT MATCHED THEN
INSERT
(
    VBELN,
    POSNR,
    VGBEL,
    NETWR
)
VALUES
(
    src.VBELN,
    src.POSNR,
    src.VGBEL,
    src.NETWR
);

SET @end_time = GETDATE();
PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';


/* ==========================================================
   BKPF
========================================================== */

SET @start_time = GETDATE();

PRINT '>> Loading bronze.erp_bkpf';

MERGE bronze.erp_bkpf tgt
USING
(
SELECT
    BELNR,
    BUKRS,
    GJAHR,
    BLART,
    BUDAT,
    BLDAT
FROM ERP.dbo.BKPF
) src

ON tgt.BELNR = src.BELNR
AND tgt.BUKRS = src.BUKRS
AND tgt.GJAHR = src.GJAHR

WHEN MATCHED THEN
UPDATE SET

    BLART = src.BLART,
    BUDAT = src.BUDAT,
    BLDAT = src.BLDAT

WHEN NOT MATCHED THEN
INSERT
(
    BELNR,
    BUKRS,
    GJAHR,
    BLART,
    BUDAT,
    BLDAT
)
VALUES
(
    src.BELNR,
    src.BUKRS,
    src.GJAHR,
    src.BLART,
    src.BUDAT,
    src.BLDAT
);

SET @end_time = GETDATE();

PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';


/* ==========================================================
   BSEG
========================================================== */

SET @start_time = GETDATE();

PRINT '>> Loading bronze.erp_bseg';

MERGE bronze.erp_bseg tgt
USING
(
SELECT
    BELNR,
    BUZEI,
    BUKRS,
    GJAHR,
    KUNNR,
    DMBTR,
    WRBTR,
    AUGBL,
    AUGDT,
    BUDAT
FROM ERP.dbo.BSEG
) src

ON tgt.BELNR = src.BELNR
AND tgt.BUZEI = src.BUZEI
AND tgt.GJAHR = src.GJAHR
AND tgt.BUKRS = src.BUKRS

WHEN MATCHED THEN UPDATE SET

    KUNNR = src.KUNNR,
    DMBTR = src.DMBTR,
    WRBTR = src.WRBTR,
    AUGBL = src.AUGBL,
    AUGDT = src.AUGDT,
    BUDAT = src.BUDAT

WHEN NOT MATCHED THEN
INSERT
(
    BELNR,
    BUZEI,
    BUKRS,
    GJAHR,
    KUNNR,
    DMBTR,
    WRBTR,
    AUGBL,
    AUGDT,
    BUDAT
)
VALUES
(
    src.BELNR,
    src.BUZEI,
    src.BUKRS,
    src.GJAHR,
    src.KUNNR,
    src.DMBTR,
    src.WRBTR,
    src.AUGBL,
    src.AUGDT,
    src.BUDAT
);

SET @end_time = GETDATE();
PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';


/* ==========================================================
   BSAD
========================================================== */

SET @start_time = GETDATE();

PRINT '>> Loading bronze.erp_bsad';

MERGE bronze.erp_bsad tgt
USING
(
SELECT
    BELNR,
    BUZEI,
    BUKRS,
    GJAHR,
    KUNNR,
    AUGBL,
    AUGDT,
    DMBTR,
    BUDAT
FROM ERP.dbo.BSAD
) src

ON tgt.BELNR = src.BELNR
AND tgt.BUZEI = src.BUZEI
AND tgt.BUKRS = src.BUKRS
AND tgt.GJAHR = src.GJAHR

WHEN MATCHED THEN
UPDATE SET

    KUNNR = src.KUNNR,
    AUGBL = src.AUGBL,
    AUGDT = src.AUGDT,
    DMBTR = src.DMBTR,
    BUDAT = src.BUDAT

WHEN NOT MATCHED THEN
INSERT
(
    BELNR,
    BUZEI,
    BUKRS,
    GJAHR,
    KUNNR,
    AUGBL,
    AUGDT,
    DMBTR,
    BUDAT
)
VALUES
(
    src.BELNR,
    src.BUZEI,
    src.BUKRS,
    src.GJAHR,
    src.KUNNR,
    src.AUGBL,
    src.AUGDT,
    src.DMBTR,
    src.BUDAT
);

SET @end_time = GETDATE();

PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';


PRINT '---------------------------------------';
PRINT 'Loading ODOO Bronze Tables';
PRINT '---------------------------------------';

/* ==========================================================
   ODOO RES PARTNER
========================================================== */

SET @start_time = GETDATE();

PRINT '>> Loading bronze.odoo_res_partner';

TRUNCATE TABLE bronze.odoo_res_partner;

INSERT INTO bronze.odoo_res_partner
(
    id,
    name,
    parent_id,
    company_type,
    street,
    city,
    country_id,
    vat,
    credit_limit,
    create_date,
    write_date
)

SELECT
    id,
    name,
    parent_id,
    company_type,
    street,
    city,
    country_id,
    vat,
    credit_limit,
    create_date,
    write_date

FROM ODOO.dbo.res_partner;

SET @end_time = GETDATE();

PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';



/* ==========================================================
   ODOO USERS
========================================================== */

SET @start_time = GETDATE();

PRINT '>> Loading bronze.odoo_res_users';

TRUNCATE TABLE bronze.odoo_res_users;

INSERT INTO bronze.odoo_res_users
(
    id,
    partner_id,
    login,
    active,
    create_date
)

SELECT
    id,
    partner_id,
    login,
    active,
    create_date

FROM ODOO.dbo.res_users;

SET @end_time = GETDATE();

PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';



/* ==========================================================
   ODOO EMPLOYEE
========================================================== */

SET @start_time = GETDATE();

PRINT '>> Loading bronze.odoo_hr_employee';

TRUNCATE TABLE bronze.odoo_hr_employee;

INSERT INTO bronze.odoo_hr_employee
(
    id,
    name,
    user_id,
    work_email,
    create_date
)

SELECT
    id,
    name,
    user_id,
    work_email,
    create_date

FROM ODOO.dbo.hr_employee;

SET @end_time = GETDATE();

PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';



SET @batch_end_time = GETDATE();

PRINT '====================================';
PRINT 'Bronze Load Completed';
PRINT 'Total Duration: '
+ CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS NVARCHAR)
+ ' seconds';
PRINT '====================================';


END TRY

BEGIN CATCH

PRINT '====================================';
PRINT 'ERROR DURING BRONZE LOAD';
PRINT ERROR_MESSAGE();
PRINT '====================================';

THROW;

END CATCH

END
