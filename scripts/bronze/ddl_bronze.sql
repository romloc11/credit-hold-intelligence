/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables
    if they already exist.

    The bronze layer stores raw data extracted from source systems
    without transformations.

    Run this script to re-define the DDL structure of 'bronze' tables.
===============================================================================
*/

-- =============================================
-- Pedidos
-- =============================================

IF OBJECT_ID('bronze.pedidos', 'U') IS NOT NULL
    DROP TABLE bronze.pedidos;
GO

CREATE TABLE bronze.pedidos (
    pedido_id        INT,
    cliente_id       NVARCHAR(50),
    paqueteria_id    NVARCHAR(50),
    creado_en        DATETIME,
    valor_pedido     DECIMAL(18,2)
);
GO


-- =============================================
-- Pool de Crédito
-- =============================================

IF OBJECT_ID('bronze.pedidos_pool', 'U') IS NOT NULL
    DROP TABLE bronze.pedidos_pool;
GO

CREATE TABLE bronze.pedidos_pool (
    pool_id          INT,
    pedido_id        INT,
    estatus_id       INT,
    motivo_id        INT,
    usuario_libero_id NVARCHAR(50),
    fecha_resolucion DATETIME,
    valor_pedido     DECIMAL(18,2),
    horas_en_pool    INT,
    minutos_en_pool  INT
);
GO


-- =============================================
-- Facturas
-- =============================================

IF OBJECT_ID('bronze.facturas', 'U') IS NOT NULL
    DROP TABLE bronze.facturas;
GO

CREATE TABLE bronze.facturas (
    factura_id        INT,
    pedido_id         INT,
    estatus_id        INT,
    fecha_factura     DATETIME,
    fecha_vencimiento DATETIME,
    monto_factura     DECIMAL(18,2)
);
GO


-- =============================================
-- Pagos
-- =============================================

IF OBJECT_ID('bronze.pagos', 'U') IS NOT NULL
    DROP TABLE bronze.pagos;
GO

CREATE TABLE bronze.pagos (
    pago_id       INT,
    cliente_id    NVARCHAR(50),
    fecha_pago    DATETIME,
    monto_pago    DECIMAL(18,2),
    metodo_pago   NVARCHAR(50)
);
GO


-- =============================================
-- Notas de Crédito
-- =============================================

IF OBJECT_ID('bronze.notas_credito', 'U') IS NOT NULL
    DROP TABLE bronze.notas_credito;
GO

CREATE TABLE bronze.notas_credito (
    nota_id        INT,
    factura_id     INT,
    fecha_nota     DATETIME,
    monto_nota     DECIMAL(18,2),
    motivo         NVARCHAR(255)
);
GO


-- =============================================
-- Clientes
-- =============================================

IF OBJECT_ID('bronze.clientes', 'U') IS NOT NULL
    DROP TABLE bronze.clientes;
GO

CREATE TABLE bronze.clientes (

    cliente_id NVARCHAR(50),
    nombre NVARCHAR(255),
    rfc NVARCHAR(50),
    contacto NVARCHAR(255),
    domicilio NVARCHAR(255),

    limite_credito DECIMAL(18,2),
    plazo_dias INT,

    fecha_modificacion DATETIME DEFAULT GETDATE()

);
GO


-- =============================================
-- Paqueterías
-- =============================================

IF OBJECT_ID('bronze.paqueterias', 'U') IS NOT NULL
    DROP TABLE bronze.paqueterias;
GO

CREATE TABLE bronze.paqueterias (
    paqueteria_id   NVARCHAR(50),
    nombre_paqueteria NVARCHAR(255),
    tipo_servicio   NVARCHAR(100)
);
GO


-- =============================================
-- Rutas
-- =============================================

IF OBJECT_ID('bronze.rutas', 'U') IS NOT NULL
    DROP TABLE bronze.rutas;
GO

CREATE TABLE bronze.rutas (
    ruta_id     NVARCHAR(50),
    ruta        NVARCHAR(255),
    zona        NVARCHAR(100)
);
GO


-- =============================================
-- Vendedores
-- =============================================

IF OBJECT_ID('bronze.vendedores', 'U') IS NOT NULL
    DROP TABLE bronze.vendedores;
GO

CREATE TABLE bronze.vendedores (
    vendedor_id NVARCHAR(50),
    ruta_id     NVARCHAR(50),
    nombre      NVARCHAR(255),
    contacto    NVARCHAR(255)
);
GO


-- =============================================
-- Gerente de venta
-- =============================================

IF OBJECT_ID('bronze.gerente_venta', 'U') IS NOT NULL
    DROP TABLE bronze.gerente_venta;
GO

CREATE TABLE bronze.gerente_venta (
    gerente_venta_id NVARCHAR(50),
    nombre      NVARCHAR(255),
    contacto    NVARCHAR(255)
);
GO


-- =============================================
-- Ejecutivo de credito
-- =============================================
IF OBJECT_ID('bronze.ejecutivo_credito', 'U') IS NOT NULL
    DROP TABLE bronze.gerente_venta;
GO

CREATE TABLE bronze.ejecutivo_credito (
    ejecutivo_credito_id NVARCHAR(50),
    nombre      NVARCHAR(255),
    contacto    NVARCHAR(255)
);
GO


-- =============================================
-- Telemarketing
-- =============================================
IF OBJECT_ID('bronze.telemarketing', 'U') IS NOT NULL
    DROP TABLE bronze.telemarketing;
GO

CREATE TABLE bronze.telemarketing (
    telemarketing_id NVARCHAR(50),
    nombre      NVARCHAR(255),
    contacto    NVARCHAR(255)
);
GO


-- =============================================
-- Gerente regional
-- =============================================
IF OBJECT_ID('bronze.gerente_regional', 'U') IS NOT NULL
    DROP TABLE bronze.gerente_regional;
GO

CREATE TABLE bronze.gerente_regional (
    gerente_regional_id NVARCHAR(50),
    nombre      NVARCHAR(255),
    contacto    NVARCHAR(255)
);
GO
    


-- =============================================
-- Usuarios liberación de crédito
-- =============================================

IF OBJECT_ID('bronze.usuario_libero', 'U') IS NOT NULL
    DROP TABLE bronze.usuario_credito;
GO

CREATE TABLE bronze.usuario_libero (
    usuario_libero_id NVARCHAR(50),
    nombre            NVARCHAR(255)
);
GO


-- =============================================
-- Motivos de Pool
-- =============================================

IF OBJECT_ID('bronze.motivos_pool', 'U') IS NOT NULL
    DROP TABLE bronze.motivos_pool;
GO

CREATE TABLE bronze.motivos_pool (
    motivo_id   INT,
    motivo      NVARCHAR(255)
);
GO


-- =============================================
-- Estatus Pool
-- =============================================

IF OBJECT_ID('bronze.estatus_pool', 'U') IS NOT NULL
    DROP TABLE bronze.estatus_pool;
GO

CREATE TABLE bronze.estatus_pool (
    estatus_id   INT,
    estatus      NVARCHAR(100)
);
GO


-- =============================================
-- Estatus Factura
-- =============================================

IF OBJECT_ID('bronze.estatus_factura', 'U') IS NOT NULL
    DROP TABLE bronze.estatus_factura;
GO

CREATE TABLE bronze.estatus_factura (
    estatus_id   INT,
    estatus      NVARCHAR(100)
);
GO
