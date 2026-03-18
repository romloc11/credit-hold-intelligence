--Check duplicates or nulls in number of order
--Expectetion: no results

SELECT
pedido,
COUNT(*)
FROM dbo.silver_pedidos_pool_clientes
GROUP BY pedido
HAVING COUNT(*) > 1 OR pedido IS NULL


SELECT
estatus,
COUNT(*)
FROM dbo.silver_estatus_pool
GROUP BY estatus
HAVING COUNT(*) > 1 OR estatus IS NULL

SELECT
estatus,
COUNT(*)
FROM dbo.silver_estatus_pool
GROUP BY estatus
HAVING COUNT(*) > 1 OR estatus IS NULL

--Check for unwanted spaces
--Expectation: no results
SELECT
nombre
FROM dbo.silver_vendedores
WHERE nombre != TRIM(nombre)

SELECT
cliente
FROM dbo.silver_pedidos_pool_clientes
WHERE cliente != TRIM(cliente)

--Data standardization
SELECT DISTINCT 
descripcion
FROM dbo.silver_estatus_pool

