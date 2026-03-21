/*
====================================
Quality Checks
====================================
Script Purpose:
  This script performs various quality chacks for data consistency, accuracy and standardization 
  across the silver tables.
*/


-- Check duplicates or NULL order IDs
-- Expectation: No results
SELECT
    pedido_id,
    COUNT(*) AS duplicates
FROM silver.pedidos
GROUP BY pedido_id
HAVING COUNT(*) > 1
   OR pedido_id IS NULL;


-- Check invalid order amounts
-- Expectation: No results
SELECT *
FROM silver.pedidos
WHERE valor_pedido <= 0
   OR valor_pedido IS NULL;


-- Check orders without client
-- Expectation: No results
SELECT *
FROM silver.pedidos
WHERE cliente_id IS NULL;


-- Check duplicate invoices
-- Expectation: No results
SELECT
    factura_id,
    COUNT(*) duplicates
FROM silver.facturas
GROUP BY factura_id
HAVING COUNT(*) > 1;


-- Check invalid invoice dates
-- Expectation: No results
SELECT *
FROM silver.facturas
WHERE fecha_factura > GETDATE()
   OR fecha_vencimiento < fecha_factura;


-- Check invalid payments
-- Expectation: No results
SELECT *
FROM silver.pagos
WHERE monto_pago <= 0
   OR monto_pago IS NULL;


-- Check duplicate credit notes
-- Expectation: No results
SELECT
    nota_id,
    COUNT(*) duplicates
FROM silver.notas_credito
GROUP BY nota_id
HAVING COUNT(*) > 1;


-- Check invalid credit note amounts
-- Expectation: No results
SELECT *
FROM silver.notas_credito
WHERE monto_nota <= 0;


-- Check duplicate clients
-- Expectation: No results
SELECT
    cliente_id,
    COUNT(*) duplicates
FROM silver.clientes
GROUP BY cliente_id
HAVING COUNT(*) > 1;


-- Check clients without name
-- Expectation: No results
SELECT *
FROM silver.clientes
WHERE nombre IS NULL
   OR LTRIM(RTRIM(nombre)) = '';


-- Check orders referencing non-existing clients
-- Expectation: No results
SELECT p.*
FROM silver.pedidos p
LEFT JOIN silver.clientes c
    ON p.cliente_id = c.cliente_id
WHERE c.cliente_id IS NULL;


-- Check invoices referencing non-existing orders
-- Expectation: No results
SELECT f.*
FROM silver.facturas f
LEFT JOIN silver.pedidos p
    ON f.pedido_id = p.pedido_id
WHERE p.pedido_id IS NULL;


-- Check ingestion date
-- Expectation: No NULL values
SELECT *
FROM silver.pedidos
WHERE ingestion_date IS NULL;
