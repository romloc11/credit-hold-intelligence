/*
================================================================================
DDL Script: Create Gold Views
================================================================================
Script Purpose:
  This script creates views for the Gold layer.
  The Gold Layer represents the final dimention and fact tables (Star Schema)

  Each view performs transformations and to produce a clean, enriched and
  business-ready dataset.

Usage:
  - These views can be queried directly for analytics and reporting.
================================================================================
*/

-- ================================================================================
-- Create Fact: dbo.gold_fact_pedidos_pool
-- ================================================================================

CREATE VIEW dbo.gold_fact_pedidos_pool AS
    SELECT 
        pedido AS pedido_id,
        cliente AS cliente_id,
        usuario_libero AS usuario_id,
        estatus AS estatus_id,

        CASE
            WHEN bsap = 1 THEN 'bloqueo_sap'
            WHEN bvs = 1 THEN 'saldo_vencido'
            WHEN belx = 1 THEN 'limite_excedido'
            ELSE 'Otro'
        END AS motivo_pool,

        creado_en AS fecha_creacion,
        CASE 
            WHEN liberado_fecha IS NOT NULL THEN liberado_fecha
            WHEN cancelado_fecha IS NOT NULL THEN cancelado_fecha
        END AS fecha_resolucion,

        valor_pedido AS valor_pedido,

        DATEDIFF(HOUR, creado_en, 
                COALESCE(liberado_fecha, cancelado_fecha, GETDATE())) AS horas_en_pool,
        DATEDIFF(MINUTE, creado_en, 
                COALESCE(liberado_fecha, cancelado_fecha, GETDATE())) AS minutos_en_pool

    FROM dbo.silver_pedidos_pool_clientes

-- ================================================================================
-- Create Dimention: dbo.gold_dim_vendedores
-- ================================================================================
CREATE VIEW dbo.gold_dim_vendedores AS
	SELECT
	usuario AS usuario_id,
	nombre AS usuario_libero
	FROM dbo.silver_vendedores
  
-- ================================================================================
-- Create Dimention: dbo.gold_dim_estatus_pool
-- ================================================================================
CREATE VIEW dbo.gold_dim_estatus_pool AS
	SELECT
		estatus AS estatus_id,
		descripcion AS estatus
	FROM dbo.silver_estatus_pool
