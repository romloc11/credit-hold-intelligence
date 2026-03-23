CREATE SCHEMA analytics;
GO

CREATE TABLE analytics.bridge_cliente_empleado (

    bridge_id INT IDENTITY(1,1) PRIMARY KEY,

    cliente_id INT NOT NULL,

    empleado_id INT NOT NULL,

    rol VARCHAR(50) NOT NULL,

    fecha_inicio DATETIME NOT NULL,

    fecha_fin DATETIME NULL,

    es_actual BIT NOT NULL

);
