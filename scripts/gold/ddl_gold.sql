/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse.

    The Gold layer represents the final dimension and fact tables (Star Schema)
    used for analytics and reporting.

    Each view transforms and combines data from the Silver layer to produce
    clean, enriched, and business-ready datasets.

Usage:
    These views are designed to be consumed by BI tools such as Power BI.
===============================================================================
*/


/* ==========================================================
DIMENSIONES
========================================================== */


CREATE OR ALTER VIEW gold.dim_cliente AS
SELECT

    id AS cliente_id,
    name AS nombre,
    vat AS rfc,
    street AS direccion,
    city,
    credit_limit

FROM silver.odoo_res_partner
WHERE company_type = 'COMPANY';




CREATE OR ALTER VIEW gold.dim_usuario_libero AS
SELECT

    usuario_libero_id,
    nombre

FROM silver.ciosacom_usuario_libero;




CREATE OR ALTER VIEW gold.dim_motivo_pool AS
SELECT

    motivo_id,
    motivo

FROM silver.ciosacom_motivos_pool;




CREATE OR ALTER VIEW gold.dim_estatus_pool AS
SELECT

    estatus_id,
    estatus

FROM silver.ciosacom_estatus_pool;




CREATE OR ALTER VIEW gold.dim_estatus_factura AS
SELECT DISTINCT

    FKSTK AS estatus_id,

    CASE
        WHEN FKSTK = 'C' THEN 'FACTURA CANCELADA'
        WHEN FKSTK = 'A' THEN 'FACTURA ABIERTA'
        WHEN FKSTK = 'B' THEN 'FACTURA PARCIAL'
        ELSE 'DESCONOCIDO'
    END AS estatus

FROM silver.erp_vbrk;




CREATE OR ALTER VIEW gold.dim_paqueteria AS
SELECT DISTINCT

    paqueteria_id

FROM silver.ciosacom_pedidos
WHERE paqueteria_id IS NOT NULL;




/* ==========================================================
INTERLOCUTORES
========================================================== */


CREATE OR ALTER VIEW gold.dim_empleado AS
SELECT

    e.id AS empleado_id,
    e.name AS nombre,
    e.work_email,
    u.login AS usuario

FROM silver.odoo_hr_employee e

LEFT JOIN silver.odoo_res_users u
    ON e.user_id = u.id;




CREATE OR ALTER VIEW gold.bridge_interlocutores AS
SELECT

    p.id AS cliente_id,

    e.id AS empleado_id,

    'VENDEDOR' AS rol,

    p.create_date AS fecha_inicio,

    NULL AS fecha_fin

FROM silver.odoo_res_partner p

LEFT JOIN silver.odoo_hr_employee e
    ON 1=1

WHERE p.company_type = 'COMPANY';



/* ==========================================================
FACT TABLES
========================================================== */


CREATE OR ALTER VIEW gold.fact_pedidos AS
SELECT

    pedido_id,
    cliente_id,
    paqueteria_id,
    CAST(creado_en AS DATE) AS fecha_pedido,
    valor_pedido

FROM silver.ciosacom_pedidos;




CREATE OR ALTER VIEW gold.fact_pedidos_pool AS
SELECT

    pool_id,
    pedido_id,
    estatus_id,
    motivo_id,
    usuario_libero_id,
    CAST(fecha_resolucion AS DATE) AS fecha_resolucion,
    valor_pedido,
    horas_en_pool,
    minutos_en_pool

FROM silver.ciosacom_pedidos_pool;




CREATE OR ALTER VIEW gold.fact_facturas AS
SELECT DISTINCT

    vbrk.VBELN AS factura_id,

    vbrp.VGBEL AS pedido_id,

    vbrk.KUNAG AS cliente_id,

    vbrk.FKSTK AS estatus_id,

    vbrk.FKDAT AS fecha_factura,

    vbrk.NETWR AS monto_factura

FROM silver.erp_vbrk vbrk

LEFT JOIN silver.erp_vbrp vbrp
    ON vbrk.VBELN = vbrp.VBELN;




CREATE OR ALTER VIEW gold.fact_pagos AS
SELECT

    BELNR AS pago_id,

    KUNNR AS cliente_id,

    BUDAT AS fecha_pago,

    DMBTR AS monto_pago

FROM silver.erp_bsad;




CREATE OR ALTER VIEW gold.fact_aplicaciones_pago AS
SELECT

    CONCAT(BELNR,'-',BUZEI) AS aplicacion_id,

    BELNR AS pago_id,

    AUGBL AS factura_id,

    DMBTR AS monto_aplicado,

    AUGDT AS fecha_aplicacion

FROM silver.erp_bseg

WHERE AUGBL IS NOT NULL;




CREATE OR ALTER VIEW gold.fact_notas_credito AS
SELECT

    BKPF.BELNR AS nota_id,

    BSEG.KUNNR AS cliente_id,

    BKPF.BUDAT AS fecha_nota,

    BSEG.DMBTR AS monto_nota

FROM silver.erp_bkpf BKPF

JOIN silver.erp_bseg BSEG
    ON BKPF.BELNR = BSEG.BELNR

WHERE BKPF.BLART = 'G2';
