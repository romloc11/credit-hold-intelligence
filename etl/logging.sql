CREATE TABLE dbo.etl_log (
    proceso VARCHAR(100),
    fecha_inicio DATETIME,
    fecha_fin DATETIME,
    filas_insertadas INT,
    estatus VARCHAR(20)
);
