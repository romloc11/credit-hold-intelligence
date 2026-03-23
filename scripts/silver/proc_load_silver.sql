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
   CIOSACOM PEDIDOS
========================================================== */

SET @start_time = GETDATE();

PRINT '>> Loading silver.ciosacom_pedidos';

TRUNCATE TABLE silver.ciosacom_pedidos;

INSERT INTO silver.ciosacom_pedidos
SELECT DISTINCT

    pedido_id,

    UPPER(LTRIM(RTRIM(cliente_id))) AS cliente_id,

    UPPER(LTRIM(RTRIM(paqueteria_id))) AS paqueteria_id,

    creado_en,

    valor_pedido

FROM bronze.ciosacom_pedidos

WHERE pedido_id IS NOT NULL;

SET @end_time = GETDATE();
PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR);



/* ==========================================================
   PEDIDOS POOL
========================================================== */

SET @start_time = GETDATE();

PRINT '>> Loading silver.ciosacom_pedidos_pool';

TRUNCATE TABLE silver.ciosacom_pedidos_pool;

INSERT INTO silver.ciosacom_pedidos_pool
SELECT DISTINCT

    pool_id,
    pedido_id,
    estatus_id,
    motivo_id,

    UPPER(LTRIM(RTRIM(usuario_libero_id))),

    fecha_resolucion,

    valor_pedido,

    horas_en_pool,

    minutos_en_pool

FROM bronze.ciosacom_pedidos_pool

WHERE pool_id IS NOT NULL;

SET @end_time = GETDATE();
PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR);



/* ==========================================================
   USUARIO LIBERO
========================================================== */

SET @start_time = GETDATE();

PRINT '>> Loading silver.ciosacom_usuario_libero';

TRUNCATE TABLE silver.ciosacom_usuario_libero;

INSERT INTO silver.ciosacom_usuario_libero
SELECT DISTINCT

    UPPER(LTRIM(RTRIM(usuario_libero_id))),

    UPPER(LTRIM(RTRIM(nombre)))

FROM bronze.ciosacom_usuario_libero

WHERE usuario_libero_id IS NOT NULL;

SET @end_time = GETDATE();
PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR);



/* ==========================================================
   MOTIVOS POOL
========================================================== */

SET @start_time = GETDATE();

PRINT '>> Loading silver.ciosacom_motivos_pool';

TRUNCATE TABLE silver.ciosacom_motivos_pool;

INSERT INTO silver.ciosacom_motivos_pool
SELECT DISTINCT

    motivo_id,

    UPPER(LTRIM(RTRIM(motivo)))

FROM bronze.ciosacom_motivos_pool

WHERE motivo_id IS NOT NULL;

SET @end_time = GETDATE();
PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR);



/* ==========================================================
   ESTATUS POOL
========================================================== */

SET @start_time = GETDATE();

PRINT '>> Loading silver.ciosacom_estatus_pool';

TRUNCATE TABLE silver.ciosacom_estatus_pool;

INSERT INTO silver.ciosacom_estatus_pool
SELECT DISTINCT

    estatus_id,

    UPPER(LTRIM(RTRIM(estatus)))

FROM bronze.ciosacom_estatus_pool

WHERE estatus_id IS NOT NULL;

SET @end_time = GETDATE();
PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR);



/* ==========================================================
   ERP VBRK
========================================================== */

SET @start_time = GETDATE();

PRINT '>> Loading silver.erp_vbrk';

TRUNCATE TABLE silver.erp_vbrk;

INSERT INTO silver.erp_vbrk
SELECT DISTINCT

    UPPER(LTRIM(RTRIM(VBELN))),
    FKDAT,
    UPPER(LTRIM(RTRIM(KUNAG))),
    NETWR,
    UPPER(LTRIM(RTRIM(WAERK))),
    UPPER(LTRIM(RTRIM(FKSTK)))

FROM bronze.erp_vbrk

WHERE VBELN IS NOT NULL;

SET @end_time = GETDATE();
PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR);



/* ==========================================================
   ERP VBRP
========================================================== */

SET @start_time = GETDATE();

PRINT '>> Loading silver.erp_vbrp';

TRUNCATE TABLE silver.erp_vbrp;

INSERT INTO silver.erp_vbrp
SELECT DISTINCT

    UPPER(LTRIM(RTRIM(VBELN))),
    UPPER(LTRIM(RTRIM(POSNR))),
    UPPER(LTRIM(RTRIM(VGBEL))),
    NETWR

FROM bronze.erp_vbrp

WHERE VBELN IS NOT NULL;

SET @end_time = GETDATE();
PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR);



/* ==========================================================
   ERP BKPF
========================================================== */

SET @start_time = GETDATE();

PRINT '>> Loading silver.erp_bkpf';

TRUNCATE TABLE silver.erp_bkpf;

INSERT INTO silver.erp_bkpf
SELECT DISTINCT

    UPPER(LTRIM(RTRIM(BELNR))),
    UPPER(LTRIM(RTRIM(BUKRS))),
    UPPER(LTRIM(RTRIM(GJAHR))),
    UPPER(LTRIM(RTRIM(BLART))),
    BUDAT,
    BLDAT

FROM bronze.erp_bkpf

WHERE BELNR IS NOT NULL;

SET @end_time = GETDATE();
PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR);



/* ==========================================================
   ERP BSEG
========================================================== */

SET @start_time = GETDATE();

PRINT '>> Loading silver.erp_bseg';

TRUNCATE TABLE silver.erp_bseg;

INSERT INTO silver.erp_bseg
SELECT DISTINCT

    UPPER(LTRIM(RTRIM(BELNR))),
    UPPER(LTRIM(RTRIM(BUZEI))),
    UPPER(LTRIM(RTRIM(BUKRS))),
    UPPER(LTRIM(RTRIM(GJAHR))),
    UPPER(LTRIM(RTRIM(KUNNR))),

    DMBTR,
    WRBTR,

    UPPER(LTRIM(RTRIM(AUGBL))),
    AUGDT,

    BUDAT

FROM bronze.erp_bseg

WHERE BELNR IS NOT NULL;

SET @end_time = GETDATE();
PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR);



/* ==========================================================
   ERP BSAD
========================================================== */

SET @start_time = GETDATE();

PRINT '>> Loading silver.erp_bsad';

TRUNCATE TABLE silver.erp_bsad;

INSERT INTO silver.erp_bsad
SELECT DISTINCT

    UPPER(LTRIM(RTRIM(BELNR))),
    UPPER(LTRIM(RTRIM(BUZEI))),
    UPPER(LTRIM(RTRIM(BUKRS))),
    UPPER(LTRIM(RTRIM(GJAHR))),
    UPPER(LTRIM(RTRIM(KUNNR))),

    UPPER(LTRIM(RTRIM(AUGBL))),
    AUGDT,

    DMBTR,
    BUDAT

FROM bronze.erp_bsad

WHERE BELNR IS NOT NULL;

SET @end_time = GETDATE();
PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR);



/* ==========================================================
   ODOO RES PARTNER
========================================================== */

SET @start_time = GETDATE();

PRINT '>> Loading silver.odoo_res_partner';

TRUNCATE TABLE silver.odoo_res_partner;

INSERT INTO silver.odoo_res_partner
SELECT DISTINCT

    id,
    UPPER(LTRIM(RTRIM(name))),
    parent_id,
    UPPER(LTRIM(RTRIM(company_type))),

    UPPER(LTRIM(RTRIM(street))),
    UPPER(LTRIM(RTRIM(city))),
    country_id,

    UPPER(LTRIM(RTRIM(vat))),

    credit_limit,

    create_date,
    write_date

FROM bronze.odoo_res_partner

WHERE id IS NOT NULL;

SET @end_time = GETDATE();
PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR);



/* ==========================================================
   ODOO USERS
========================================================== */

SET @start_time = GETDATE();

PRINT '>> Loading silver.odoo_res_users';

TRUNCATE TABLE silver.odoo_res_users;

INSERT INTO silver.odoo_res_users
SELECT DISTINCT

    id,
    partner_id,
    UPPER(LTRIM(RTRIM(login))),
    active,
    create_date

FROM bronze.odoo_res_users

WHERE id IS NOT NULL;

SET @end_time = GETDATE();
PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR);



/* ==========================================================
   ODOO EMPLOYEE
========================================================== */

SET @start_time = GETDATE();

PRINT '>> Loading silver.odoo_hr_employee';

TRUNCATE TABLE silver.odoo_hr_employee;

INSERT INTO silver.odoo_hr_employee
SELECT DISTINCT

    id,
    UPPER(LTRIM(RTRIM(name))),
    user_id,
    UPPER(LTRIM(RTRIM(work_email))),
    create_date

FROM bronze.odoo_hr_employee

WHERE id IS NOT NULL;

SET @end_time = GETDATE();
PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR);



SET @start_time = GETDATE()

PRINT '>> Loading silver.bridge_cliente_empleado';

/* ==========================================================
   BUILD CURRENT SNAPSHOT
========================================================== */

WITH interlocutores_actuales AS (

/* ---------------- VENDEDOR ---------------- */

SELECT DISTINCT

    p.id AS cliente_id,
    e.id AS empleado_id,
    'VENDEDOR' AS rol

FROM silver.odoo_res_partner p

JOIN silver.odoo_res_users u
    ON p.user_id = u.id

JOIN silver.odoo_hr_employee e
    ON u.id = e.user_id

WHERE p.company_type = 'COMPANY'
AND e.id IS NOT NULL


UNION ALL


/* ---------------- GERENTE VENTA ---------------- */

SELECT DISTINCT

    p.id AS cliente_id,
    e.id AS empleado_id,
    'GERENTE_VENTA' AS rol

FROM silver.odoo_res_partner p

JOIN silver.odoo_res_users u
    ON p.sales_manager_id = u.id

JOIN silver.odoo_hr_employee e
    ON u.id = e.user_id

WHERE p.company_type = 'COMPANY'
AND e.id IS NOT NULL


UNION ALL


/* ---------------- TELEMARKETING ---------------- */

SELECT DISTINCT

    p.id AS cliente_id,
    e.id AS empleado_id,
    'TELEMARKETING' AS rol

FROM silver.odoo_res_partner p

JOIN silver.odoo_res_users u
    ON p.telemarketing_user_id = u.id

JOIN silver.odoo_hr_employee e
    ON u.id = e.user_id

WHERE p.company_type = 'COMPANY'
AND e.id IS NOT NULL


UNION ALL


/* ---------------- EJECUTIVO CREDITO ---------------- */

SELECT DISTINCT

    p.id AS cliente_id,
    e.id AS empleado_id,
    'EJECUTIVO_CREDITO' AS rol

FROM silver.odoo_res_partner p

JOIN silver.odoo_res_users u
    ON p.credit_user_id = u.id

JOIN silver.odoo_hr_employee e
    ON u.id = e.user_id

WHERE p.company_type = 'COMPANY'
AND e.id IS NOT NULL


UNION ALL


/* ---------------- GERENTE REGIONAL ---------------- */

SELECT DISTINCT

    p.id AS cliente_id,
    e.id AS empleado_id,
    'GERENTE_REGIONAL' AS rol

FROM silver.odoo_res_partner p

JOIN silver.odoo_res_users u
    ON p.regional_manager_id = u.id

JOIN silver.odoo_hr_employee e
    ON u.id = e.user_id

WHERE p.company_type = 'COMPANY'
AND e.id IS NOT NULL

)



/* ==========================================================
   CLOSE OLD RECORDS (SCD2)
========================================================== */

UPDATE b
SET
    fecha_fin = GETDATE(),
    es_actual = 0

FROM silver.bridge_cliente_empleado b

JOIN interlocutores_actuales s
    ON b.cliente_id = s.cliente_id
    AND b.rol = s.rol

WHERE b.es_actual = 1
AND b.empleado_id <> s.empleado_id



/* ==========================================================
   INSERT NEW RELATIONSHIPS
========================================================== */

INSERT INTO silver.bridge_cliente_empleado
(
    cliente_id,
    empleado_id,
    rol,
    fecha_inicio,
    fecha_fin,
    es_actual
)

SELECT

    s.cliente_id,
    s.empleado_id,
    s.rol,
    GETDATE(),
    NULL,
    1

FROM interlocutores_actuales s

LEFT JOIN silver.bridge_cliente_empleado b
    ON s.cliente_id = b.cliente_id
    AND s.rol = b.rol
    AND b.es_actual = 1

WHERE b.cliente_id IS NULL
OR b.empleado_id <> s.empleado_id



SET @end_time = GETDATE()

PRINT 'Duration: ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)
PRINT 'Bridge load completed'

        

SET @batch_end_time = GETDATE();

PRINT '====================================';
PRINT 'Silver Load Completed';
PRINT 'Total Duration: ' + CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS NVARCHAR);
PRINT '====================================';

END TRY

BEGIN CATCH

PRINT 'ERROR IN SILVER LOAD';
PRINT ERROR_MESSAGE();

THROW;

END CATCH

END
