-- =========================================
-- CORE TABLE
-- =========================================

IF OBJECT_ID('dbo.fact_pool_credito') IS NULL
BEGIN
    CREATE TABLE dbo.fact_pool_credito (
        pedido VARCHAR(50),
        cliente VARCHAR(20),
        valor_pedido DECIMAL(15,2),
        motivo_pool VARCHAR(50),
        estatus VARCHAR(50),
        creado_en DATETIME,
        liberado_fecha DATETIME,
        cancelado_fecha DATETIME,
        usuario_libero VARCHAR(100),
        indicador_liberado INT,
        indicador_cancelado INT,
        indicador_en_pool INT,
        minutos_liberacion INT,
        minutos_cancelacion INT,
        fecha_carga DATETIME DEFAULT GETDATE()
    );
END;

-- =========================================
-- LOAD CORE FROM STAGING
-- =========================================

INSERT INTO dbo.fact_pool_credito
SELECT
    pedido,
    cliente,
    valor_pedido,

    CASE
        WHEN bsap = 1 THEN 'Bloqueo SAP'
        WHEN bvs = 1 THEN 'Saldo vencido'
        WHEN belx = 1 THEN 'Límite excedido'
        ELSE 'Otro'
    END,

    CASE
        WHEN estatus = 0 THEN 'Retenido'
        WHEN estatus = 1 THEN 'Liberado'
        WHEN estatus = 2 THEN 'Retenido'
        WHEN estatus = 3 THEN 'Cancelado'
    END,

    creado_en,
    liberado_fecha,
    cancelado_fecha,

    LOWER(TRIM(ISNULL(usuario_libero, 'Sistema'))),

    CASE WHEN liberado_fecha IS NOT NULL THEN 1 ELSE 0 END,
    CASE WHEN cancelado_fecha IS NOT NULL THEN 1 ELSE 0 END,
    CASE WHEN liberado_fecha IS NULL AND cancelado_fecha IS NULL THEN 1 ELSE 0 END,

    DATEDIFF(MINUTE, creado_en, liberado_fecha),
    DATEDIFF(MINUTE, creado_en, cancelado_fecha),

    GETDATE()

FROM dbo.stg_pool_credito;
