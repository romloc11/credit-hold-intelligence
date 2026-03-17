-- =========================================
-- DATA QUALITY CHECKS
-- =========================================

-- Duplicados
SELECT pedido, COUNT(*)
FROM dbo.fact_pool_credito
GROUP BY pedido
HAVING COUNT(*) > 1;

-- Nulos críticos
SELECT *
FROM dbo.fact_pool_credito
WHERE pedido IS NULL;

-- Tiempos negativos
SELECT *
FROM dbo.fact_pool_credito
WHERE minutos_liberacion < 0;
