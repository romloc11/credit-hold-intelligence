/*
===============================================================================
SILVER DATA QUALITY CHECKS
===============================================================================

Purpose:
    Validate data quality in Silver layer after ETL load.

Checks Included:
    - Row counts
    - Null primary keys
    - Duplicate keys
    - Invalid numeric values
    - Basic referential integrity

===============================================================================
*/

PRINT '====================================';
PRINT 'SILVER DATA QUALITY CHECKS';
PRINT '====================================';


/* ==========================================================
ROW COUNTS
========================================================== */

PRINT '--- Row Counts ---';

SELECT 'ciosacom_pedidos' AS table_name, COUNT(*) AS row_count FROM silver.ciosacom_pedidos
UNION ALL
SELECT 'ciosacom_pedidos_pool', COUNT(*) FROM silver.ciosacom_pedidos_pool
UNION ALL
SELECT 'ciosacom_usuario_libero', COUNT(*) FROM silver.ciosacom_usuario_libero
UNION ALL
SELECT 'ciosacom_motivos_pool', COUNT(*) FROM silver.ciosacom_motivos_pool
UNION ALL
SELECT 'ciosacom_estatus_pool', COUNT(*) FROM silver.ciosacom_estatus_pool
UNION ALL
SELECT 'erp_vbrk', COUNT(*) FROM silver.erp_vbrk
UNION ALL
SELECT 'erp_vbrp', COUNT(*) FROM silver.erp_vbrp
UNION ALL
SELECT 'erp_bkpf', COUNT(*) FROM silver.erp_bkpf
UNION ALL
SELECT 'erp_bseg', COUNT(*) FROM silver.erp_bseg
UNION ALL
SELECT 'erp_bsad', COUNT(*) FROM silver.erp_bsad
UNION ALL
SELECT 'odoo_res_partner', COUNT(*) FROM silver.odoo_res_partner
UNION ALL
SELECT 'odoo_res_users', COUNT(*) FROM silver.odoo_res_users
UNION ALL
SELECT 'odoo_hr_employee', COUNT(*) FROM silver.odoo_hr_employee;



/* ==========================================================
NULL CHECKS (PRIMARY KEYS)
========================================================== */

PRINT '--- Null Primary Keys ---';

SELECT 'ciosacom_pedidos' AS table_name, COUNT(*) AS null_keys
FROM silver.ciosacom_pedidos
WHERE pedido_id IS NULL

UNION ALL

SELECT 'erp_vbrk', COUNT(*)
FROM silver.erp_vbrk
WHERE VBELN IS NULL

UNION ALL

SELECT 'erp_bseg', COUNT(*)
FROM silver.erp_bseg
WHERE BELNR IS NULL

UNION ALL

SELECT 'odoo_res_partner', COUNT(*)
FROM silver.odoo_res_partner
WHERE id IS NULL;



/* ==========================================================
DUPLICATE CHECKS
========================================================== */

PRINT '--- Duplicate Keys ---';

SELECT
    'ciosacom_pedidos' AS table_name,
    pedido_id,
    COUNT(*) AS duplicates
FROM silver.ciosacom_pedidos
GROUP BY pedido_id
HAVING COUNT(*) > 1;


SELECT
    'erp_vbrk' AS table_name,
    VBELN,
    COUNT(*) AS duplicates
FROM silver.erp_vbrk
GROUP BY VBELN
HAVING COUNT(*) > 1;


SELECT
    'erp_bseg' AS table_name,
    BELNR,
    BUZEI,
    COUNT(*) AS duplicates
FROM silver.erp_bseg
GROUP BY BELNR, BUZEI
HAVING COUNT(*) > 1;



/* ==========================================================
NEGATIVE VALUES
========================================================== */

PRINT '--- Negative Amount Checks ---';

SELECT *
FROM silver.ciosacom_pedidos
WHERE valor_pedido < 0;


SELECT *
FROM silver.erp_vbrk
WHERE NETWR < 0;


SELECT *
FROM silver.erp_bseg
WHERE DMBTR < 0;



/* ==========================================================
REFERENTIAL CHECKS
========================================================== */

PRINT '--- Referential Integrity ---';


/* pedidos_pool -> pedidos */

SELECT
    p.pool_id,
    p.pedido_id
FROM silver.ciosacom_pedidos_pool p
LEFT JOIN silver.ciosacom_pedidos o
    ON p.pedido_id = o.pedido_id
WHERE o.pedido_id IS NULL;


/* facturas -> clientes */

SELECT
    v.VBELN,
    v.KUNAG
FROM silver.erp_vbrk v
LEFT JOIN silver.odoo_res_partner c
    ON v.KUNAG = c.id
WHERE c.id IS NULL;



/* ==========================================================
EMPTY TEXT VALUES
========================================================== */

PRINT '--- Empty String Checks ---';

SELECT *
FROM silver.ciosacom_usuario_libero
WHERE nombre = '';



PRINT '====================================';
PRINT 'DATA QUALITY CHECKS COMPLETED';
PRINT '====================================';
