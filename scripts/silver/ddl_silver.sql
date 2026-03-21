/*
===============================================================================
DDL Script: Create silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables
    if they already exist.

    The silverlayer stores raw data extracted from source systems
    without transformations.

    Run this script to re-define the DDL structure of 'silver' tables.
===============================================================================
*/

-- =============================================
-- Pedidos
-- =============================================

IF OBJECT_ID('silver.pedidos', 'U') IS NOT NULL
    DROP TABLE silver.pedidos;
GO

CREATE TABLE silver.pedidos (
    pedido_id        INT,
    cliente_id       NVARCHAR(50),
    paqueteria_id    NVARCHAR(50),
    creado_en        DATETIME,
    valor_pedido     DECIMAL(18,2),
    
    ingestion_date DATETIME DEFAULT GETDATE()
);
GO


-- =============================================
-- Pool de Crédito
-- =============================================

IF OBJECT_ID('silver.pedidos_pool', 'U') IS NOT NULL
    DROP TABLE silver.pedidos_pool;
GO

CREATE TABLE silver.pedidos_pool (
    pool_id          INT,
    pedido_id        INT,
    estatus_id       INT,
    motivo_id        INT,
    usuario_libero_id NVARCHAR(50),
    fecha_resolucion DATETIME,
    valor_pedido     DECIMAL(18,2),
    horas_en_pool    INT,
    minutos_en_pool  INT,
    
    ingestion_date DATETIME DEFAULT GETDATE()
);
GO


-- =============================================
-- Facturas
-- =============================================

IF OBJECT_ID('silver.facturas', 'U') IS NOT NULL
    DROP TABLE silver.facturas;
GO

CREATE TABLE silver.facturas (
    factura_id        INT,
    pedido_id         INT,
    estatus_id        INT,
    fecha_factura     DATETIME,
    fecha_vencimiento DATETIME,
    monto_factura     DECIMAL(18,2),
    
    ingestion_date DATETIME DEFAULT GETDATE()
);
GO


-- =============================================
-- Pagos
-- =============================================

IF OBJECT_ID('silver.pagos', 'U') IS NOT NULL
    DROP TABLE silver.pagos;
GO

CREATE TABLE silver.pagos (
    pago_id       INT,
    cliente_id    NVARCHAR(50),
    fecha_pago    DATETIME,
    monto_pago    DECIMAL(18,2),
    metodo_pago   NVARCHAR(50),
    
    ingestion_date DATETIME DEFAULT GETDATE()
);
GO


-- =============================================
-- Notas de Crédito
-- =============================================

IF OBJECT_ID('silver.notas_credito', 'U') IS NOT NULL
    DROP TABLE silver.notas_credito;
GO

CREATE TABLE silver.notas_credito (
    nota_id        INT,
    factura_id     INT,
    fecha_nota     DATETIME,
    monto_nota     DECIMAL(18,2),
    motivo         NVARCHAR(255),
    
    ingestion_date DATETIME DEFAULT GETDATE()
);
GO


-- =============================================
-- Clientes
-- =============================================

IF OBJECT_ID('silver.clientes', 'U') IS NOT NULL
    DROP TABLE silver.clientes;
GO

CREATE TABLE silver.clientes (

    cliente_id NVARCHAR(50),
    nombre NVARCHAR(255),
    rfc NVARCHAR(50),
    contacto NVARCHAR(255),
    domicilio NVARCHAR(255),

    limite_credito DECIMAL(18,2),
    plazo_dias INT,

    fecha_modificacion DATETIME,
    
    ingestion_date DATETIME DEFAULT GETDATE()

);
GO


-- =============================================
-- Paqueterías
-- =============================================

IF OBJECT_ID('silver.paqueterias', 'U') IS NOT NULL
    DROP TABLE silver.paqueterias;
GO

CREATE TABLE silver.paqueterias (
    paqueteria_id   NVARCHAR(50),
    nombre_paqueteria NVARCHAR(255),
    tipo_servicio   NVARCHAR(100),

    ingestion_date DATETIME DEFAULT GETDATE()
);
GO


-- =============================================
-- Rutas
-- =============================================

IF OBJECT_ID('silver.rutas', 'U') IS NOT NULL
    DROP TABLE silver.rutas;
GO

CREATE TABLE silver.rutas (
    ruta_id     NVARCHAR(50),
    ruta        NVARCHAR(255),
    zona        NVARCHAR(100),

    ingestion_date DATETIME DEFAULT GETDATE()
);
GO


-- =============================================
-- Vendedores
-- =============================================

IF OBJECT_ID('silver.vendedores', 'U') IS NOT NULL
    DROP TABLE silver.vendedores;
GO

CREATE TABLE silver.vendedores (
    vendedor_id NVARCHAR(50),
    ruta_id     NVARCHAR(50),
    nombre      NVARCHAR(255),
    contacto    NVARCHAR(255),

    ingestion_date DATETIME DEFAULT GETDATE()
);
GO


-- =============================================
-- Gerente de venta
-- =============================================

IF OBJECT_ID('silver.gerente_venta', 'U') IS NOT NULL
    DROP TABLE silver.gerente_venta;
GO

CREATE TABLE silver.gerente_venta (
    gerente_venta_id NVARCHAR(50),
    nombre      NVARCHAR(255),
    contacto    NVARCHAR(255),

    ingestion_date DATETIME DEFAULT GETDATE()
);
GO


-- =============================================
-- Ejecutivo de credito
-- =============================================
IF OBJECT_ID('silver.ejecutivo_credito', 'U') IS NOT NULL
    DROP TABLE silver.gerente_venta;
GO

CREATE TABLE silver.ejecutivo_credito (
    ejecutivo_credito_id NVARCHAR(50),
    nombre      NVARCHAR(255),
    contacto    NVARCHAR(255),

    ingestion_date DATETIME DEFAULT GETDATE()
);
GO


-- =============================================
-- Telemarketing
-- =============================================
IF OBJECT_ID('silver.telemarketing', 'U') IS NOT NULL
    DROP TABLE silver.telemarketing;
GO

CREATE TABLE silver.telemarketing (
    telemarketing_id NVARCHAR(50),
    nombre      NVARCHAR(255),
    contacto    NVARCHAR(255),

    ingestion_date DATETIME DEFAULT GETDATE()
);
GO


-- =============================================
-- Gerente regional
-- =============================================
IF OBJECT_ID('silver.gerente_regional', 'U') IS NOT NULL
    DROP TABLE silver.gerente_regional;
GO

CREATE TABLE silver.gerente_regional (
    gerente_regional_id NVARCHAR(50),
    nombre      NVARCHAR(255),
    contacto    NVARCHAR(255),

    ingestion_date DATETIME DEFAULT GETDATE()
);
GO
    


-- =============================================
-- Usuarios liberación de crédito
-- =============================================

IF OBJECT_ID('silver.usuario_libero', 'U') IS NOT NULL
    DROP TABLE silver.usuario_credito;
GO

CREATE TABLE silver.usuario_libero (
    usuario_libero_id NVARCHAR(50),
    nombre            NVARCHAR(255),

    ingestion_date DATETIME DEFAULT GETDATE()
);
GO


-- =============================================
-- Motivos de Pool
-- =============================================

IF OBJECT_ID('silver.motivos_pool', 'U') IS NOT NULL
    DROP TABLE silver.motivos_pool;
GO

CREATE TABLE silver.motivos_pool (
    motivo_id   INT,
    motivo      NVARCHAR(255),

    ingestion_date DATETIME DEFAULT GETDATE()
);
GO


-- =============================================
-- Estatus Pool
-- =============================================

IF OBJECT_ID('silver.estatus_pool', 'U') IS NOT NULL
    DROP TABLE silver.estatus_pool;
GO

CREATE TABLE silver.estatus_pool (
    estatus_id   INT,
    estatus      NVARCHAR(100),

    ingestion_date DATETIME DEFAULT GETDATE()
);
GO


-- =============================================
-- Estatus Factura
-- =============================================

IF OBJECT_ID('silver.estatus_factura', 'U') IS NOT NULL
    DROP TABLE silver.estatus_factura;
GO

CREATE TABLE silver.estatus_factura (
    estatus_id   INT,
    estatus      NVARCHAR(100),

    ingestion_date DATETIME DEFAULT GETDATE()
);
GO
