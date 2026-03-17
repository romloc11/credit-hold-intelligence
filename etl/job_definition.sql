-- =========================================
-- ETL PROCESS
-- =========================================

DECLARE @inicio DATETIME = GETDATE();

INSERT INTO dbo.etl_log
VALUES ('Carga Pool Credito', @inicio, NULL, NULL, 'INICIO');

-- 1. Cargar staging
EXEC('sql/staging.sql');

-- 2. Cargar core
EXEC('sql/core.sql');

-- 3. Validaciones
EXEC('sql/data_quality.sql');

-- FIN

UPDATE dbo.etl_log
SET fecha_fin = GETDATE(),
    estatus = 'OK'
WHERE fecha_inicio = @inicio;
