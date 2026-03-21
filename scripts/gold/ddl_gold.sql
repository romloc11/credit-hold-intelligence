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

-- =============================================================================
-- Create Fact Table: gold.fact_pedidos
-- =============================================================================

IF OBJECT_ID('gold.fact_pedidos','V') IS NOT NULL
DROP VIEW gold.fact_pedidos;
GO

CREATE VIEW gold.fact_pedidos AS
SELECT
    p.pedido_id,
    dc.cliente_key,
    dp.paqueteria_key,
    p.creado_en,
    p.valor_pedido
FROM silver.pedidos p
LEFT JOIN gold.dim_cliente dc
    ON p.cliente_id = dc.cliente_id
LEFT JOIN gold.dim_paqueteria dp
    ON p.paqueteria_id = dp.paqueteria_id;
GO


	-- =============================================================================
-- Create Fact Table: gold.fact_facturas
-- =============================================================================

IF OBJECT_ID('gold.fact_facturas','V') IS NOT NULL
DROP VIEW gold.fact_facturas;
GO

CREATE VIEW gold.fact_facturas AS
SELECT
    f.factura_id,
    fp.pedido_id,
    de.estatus_key,
    f.fecha_factura,
    f.fecha_vencimiento,
    f.monto_factura
FROM silver.facturas f
LEFT JOIN gold.fact_pedidos fp
    ON f.pedido_id = fp.pedido_id
LEFT JOIN gold.dim_estatus_factura de
    ON f.estatus_id = de.estatus_id;
GO



-- =============================================================================
-- Create Fact Table: gold.fact_pagos
-- =============================================================================

IF OBJECT_ID('gold.fact_pagos','V') IS NOT NULL
DROP VIEW gold.fact_pagos;
GO

CREATE VIEW gold.fact_pagos AS
SELECT
    pago_id,
    dc.cliente_key,
    fecha_pago,
    monto_pago,
    metodo_pago
FROM silver.pagos p
LEFT JOIN gold.dim_cliente dc
    ON p.cliente_id = dc.cliente_id;
GO



-- =============================================================================
-- Create Fact Table: gold.fact_notas_credito
-- =============================================================================

IF OBJECT_ID('gold.fact_notas_credito','V') IS NOT NULL
DROP VIEW gold.fact_notas_credito;
GO

CREATE VIEW gold.fact_notas_credito AS
SELECT
    nota_id,
    factura_id,
    fecha_nota,
    monto_nota,
    motivo
FROM silver.notas_credito;
GO





-- =============================================================================
-- Create Fact Table: gold.fact_pedidos_pool
-- =============================================================================

IF OBJECT_ID('gold.fact_pedidos_pool','V') IS NOT NULL
DROP VIEW gold.fact_pedidos_pool;
GO

CREATE VIEW gold.fact_pedidos_pool AS
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
FROM silver.pedidos_pool;
GO



-- =============================================================================
-- Create Dimension: gold.dim_cliente
-- =============================================================================

IF OBJECT_ID('gold.dim_cliente','V') IS NOT NULL
DROP VIEW gold.dim_cliente;
GO

CREATE VIEW gold.dim_cliente AS
SELECT
    ROW_NUMBER() OVER (ORDER BY cliente_id) AS cliente_key, -- Surrogate key
    cliente_id,
    nombre,
    rfc,
    contacto,
    domicilio,
    limite_credito,
    plazo_dias
FROM silver.clientes;
GO

	
-- =============================================================================
-- Create Bridge: gold.bridge_cliente_paqueteria
-- =============================================================================

IF OBJECT_ID('gold.bridge_cliente_paqueteria','V') IS NOT NULL
DROP VIEW gold.bridge_cliente_paqueteria;
GO

CREATE VIEW gold.bridge_cliente_paqueteria AS
SELECT DISTINCT
    cliente_id,
    paqueteria_id
FROM silver.pedidos;
GO


-- =============================================================================
-- Create Dimension: gold.dim_paqueteria
-- =============================================================================

IF OBJECT_ID('gold.dim_paqueteria','V') IS NOT NULL
DROP VIEW gold.dim_paqueteria;
GO

CREATE VIEW gold.dim_paqueteria AS
SELECT
    ROW_NUMBER() OVER (ORDER BY paqueteria_id) AS paqueteria_key,
    paqueteria_id,
    nombre_paqueteria,
    tipo_servicio
FROM silver.paqueterias;
GO


-- =============================================================================
-- Create Dimension: gold.dim_ruta
-- =============================================================================

IF OBJECT_ID('gold.dim_ruta','V') IS NOT NULL
DROP VIEW gold.dim_ruta;
GO

CREATE VIEW gold.dim_ruta AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ruta_id) AS ruta_key,
    ruta_id,
    ruta,
    zona
FROM silver.rutas;
GO

	
-- =============================================================================
-- Create Bridge: gold.bridge_interlocutores
-- =============================================================================
WITH equipo_cliente AS (

SELECT

    c.cliente_id,

    v.vendedor_id,
    gv.gerente_venta_id,
    ec.ejecutivo_credito_id,
    tm.telemarketing_id,
    gr.gerente_regional_id,

    c.fecha_modificacion

FROM silver.clientes c

LEFT JOIN silver.vendedores v
    ON c.cliente_id = v.cliente_id

LEFT JOIN silver.gerente_venta gv
    ON v.vendedor_id = gv.vendedor_id

LEFT JOIN silver.ejecutivo_credito ec
    ON c.cliente_id = ec.cliente_id

LEFT JOIN silver.telemarketing tm
    ON c.cliente_id = tm.cliente_id

LEFT JOIN silver.gerente_regional gr
    ON gv.gerente_venta_id = gr.gerente_venta_id

)

IF OBJECT_ID('gold.bridge_interlocutores','V') IS NOT NULL
DROP VIEW gold.bridge_interlocutores;
GO

CREATE VIEW gold.bridge_interlocutores AS

WITH equipo_cliente AS (

SELECT

    c.cliente_id,

    v.vendedor_id,
    gv.gerente_venta_id,
    ec.ejecutivo_credito_id,
    tm.telemarketing_id,
    gr.gerente_regional_id,

    c.fecha_modificacion

FROM silver.clientes c

LEFT JOIN silver.vendedores v
    ON c.cliente_id = v.cliente_id

LEFT JOIN silver.gerente_venta gv
    ON v.vendedor_id = gv.vendedor_id

LEFT JOIN silver.ejecutivo_credito ec
    ON c.cliente_id = ec.cliente_id

LEFT JOIN silver.telemarketing tm
    ON c.cliente_id = tm.cliente_id

LEFT JOIN silver.gerente_regional gr
    ON gv.gerente_venta_id = gr.gerente_venta_id
)

SELECT

    ROW_NUMBER() OVER (
        ORDER BY cliente_id, fecha_modificacion
    ) AS interlocutor_key,

    cliente_id,

    vendedor_id,
    gerente_venta_id,
    ejecutivo_credito_id,
    telemarketing_id,
    gerente_regional_id,

    fecha_modificacion AS fecha_inicio,

    LEAD(fecha_modificacion) OVER (
        PARTITION BY cliente_id
        ORDER BY fecha_modificacion
    ) AS fecha_fin

FROM equipo_cliente;

GO


-- =============================================================================
-- Create Dimension: gold.dim_vendedores
-- =============================================================================

IF OBJECT_ID('gold.dim_vendedores','V') IS NOT NULL
DROP VIEW gold.dim_vendedores;
GO

CREATE VIEW gold.dim_vendedores AS
SELECT
    ROW_NUMBER() OVER (ORDER BY vendedor_id) AS vendedor_key,
    vendedor_id,
    nombre,
    contacto,
    ruta_id
FROM silver.vendedores;
GO


-- =============================================================================
-- Create Dimension: gold.dim_gerente_venta
-- =============================================================================

IF OBJECT_ID('gold.dim_gerente_venta','V') IS NOT NULL
DROP VIEW gold.dim_gerente_venta;
GO

CREATE VIEW gold.dim_gerente_venta AS
SELECT
    ROW_NUMBER() OVER (ORDER BY gerente_venta_id) AS gerente_venta_key,
    gerente_venta_id,
    nombre,
    contacto
FROM silver.gerente_venta;
GO


-- =============================================================================
-- Create Dimension: gold.dim_ejecutivo_credito
-- =============================================================================

IF OBJECT_ID('gold.dim_ejecutivo_credito','V') IS NOT NULL
DROP VIEW gold.dim_ejecutivo_credito;
GO

CREATE VIEW gold.dim_ejecutivo_credito AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ejecutivo_credito_id) AS ejecutivo_credito_key,
    ejecutivo_credito_id,
    nombre,
    contacto
FROM silver.ejecutivo_credito;
GO


-- =============================================================================
-- Create Dimension: gold.dim_telemarketing
-- =============================================================================

IF OBJECT_ID('gold.dim_telemarketing','V') IS NOT NULL
DROP VIEW gold.dim_telemarketing;
GO

CREATE VIEW gold.dim_telemarketing AS
SELECT
    ROW_NUMBER() OVER (ORDER BY telemarketing_id) AS telemarketing_key,
    telemarketing_id,
    nombre,
    contacto
FROM silver.telemarketing;
GO


-- =============================================================================
-- Create Dimension: gold.dim_gerente_regional
-- =============================================================================

IF OBJECT_ID('gold.dim_gerente_regional','V') IS NOT NULL
DROP VIEW gold.dim_gerente_regional;
GO

CREATE VIEW gold.dim_gerente_regional AS
SELECT
    ROW_NUMBER() OVER (ORDER BY gerente_regional_id) AS gerente_regional_key,
    gerente_regional_id,
    nombre,
    contacto
FROM silver.gerente_regional;
GO


-- =============================================================================
-- Create Dimension: gold.dim_usuario_liberacion
-- =============================================================================

IF OBJECT_ID('gold.dim_usuario_liberacion','V') IS NOT NULL
DROP VIEW gold.dim_usuario_liberacion;
GO

CREATE VIEW gold.dim_usuario_liberacion AS
SELECT
    ROW_NUMBER() OVER (ORDER BY usuario_libero_id) AS usuario_liberacion_key,
    usuario_libero_id,
    nombre
FROM silver.usuario_libero;
GO


-- =============================================================================
-- Create Dimension: gold.dim_motivo_pool
-- =============================================================================

IF OBJECT_ID('gold.dim_motivo_pool','V') IS NOT NULL
DROP VIEW gold.dim_motivo_pool;
GO

CREATE VIEW gold.dim_motivo_pool AS
SELECT
    ROW_NUMBER() OVER (ORDER BY motivo_id) AS motivo_pool_key,
    motivo_id,
    motivo
FROM silver.motivos_pool;
GO


-- =============================================================================
-- Create Dimension: gold.dim_estatus_factura
-- =============================================================================

IF OBJECT_ID('gold.dim_estatus_factura','V') IS NOT NULL
DROP VIEW gold.dim_estatus_factura;
GO

CREATE VIEW gold.dim_estatus_factura AS
SELECT
    ROW_NUMBER() OVER (ORDER BY estatus_id) AS estatus_key,
    estatus_id,
    estatus
FROM silver.estatus_factura;
GO


-- =============================================================================
-- Create Dimension: gold.dim_estatus_pool
-- =============================================================================

IF OBJECT_ID('gold.dim_estatus_pool','V') IS NOT NULL
DROP VIEW gold.dim_estatus_pool;
GO

CREATE VIEW gold.dim_estatus_pool AS
SELECT
    ROW_NUMBER() OVER (ORDER BY estatus_id) AS estatus_pool_key,
    estatus_id,
    estatus
FROM silver.estatus_pool;
GO


