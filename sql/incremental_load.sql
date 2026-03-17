-- =========================================
-- INCREMENTAL LOAD
-- =========================================

INSERT INTO dbo.fact_pool_credito
SELECT *
FROM (
    SELECT
        s.*,
        ROW_NUMBER() OVER (PARTITION BY pedido ORDER BY creado_en DESC) AS rn
    FROM dbo.stg_pool_credito s
) t
WHERE rn = 1
AND NOT EXISTS (
    SELECT 1
    FROM dbo.fact_pool_credito f
    WHERE f.pedido = t.pedido
);
