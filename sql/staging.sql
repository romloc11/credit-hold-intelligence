-- =========================================
-- STAGING TABLE
-- =========================================

IF OBJECT_ID('dbo.stg_pool_credito') IS NOT NULL
    DROP TABLE dbo.stg_pool_credito;

CREATE TABLE dbo.stg_pool_credito (
    pedido VARCHAR(50),
    cliente VARCHAR(20),
    valor_pedido DECIMAL(15,2),
    estatus INT,
    bsap INT,
    bvs INT,
    belx INT,
    creado_en DATETIME,
    liberado_fecha DATETIME,
    cancelado_fecha DATETIME,
    usuario_libero VARCHAR(100)
);

-- =========================================
-- LOAD STAGING FROM SOURCE (MySQL)
-- =========================================

TRUNCATE TABLE dbo.stg_pool_credito;

INSERT INTO dbo.stg_pool_credito
SELECT *
FROM OPENQUERY(CiosaCOM, '
SELECT
    ppc.pedido,
    ppc.cliente,
    ppc.valor_pedido,
    ppc.estatus,
    ppc.bsap,
    ppc.bvs,
    ppc.belx,
    ppc.creado_en,
    ppc.liberado_fecha,
    ppc.cancelado_fecha,
    v.nombre
FROM pedidos_pool_clientes ppc
LEFT JOIN vendedores v
    ON v.usuario = ppc.usuario_libero
WHERE ppc.creado_en >= ''2026-03-10''
');
