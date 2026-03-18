
/*
=====================================================================================
DDL Scripts: CREATE SILVER TABLES
=====================================================================================
Script Prupose:
    This script creates the silver tables in the dbo schema, dropping existing tables 
    if the already exist.
Run this script to redifine the DDL sctructure of 'silver' tables.
=====================================================================================
*/

IF OBJECT_ID ('dbo.silver_pedidos_pool_clientes', 'U') IS NOT NULL
    DROP TABLE dbo.silver_pedidos_pool_clientes

GO 

CREATE TABLE dbo.silver_pedidos_pool_clientes (
    pedido VARCHAR(50),
    cliente VARCHAR(20),
    valor_pedido DECIMAL(15,2),
    estatus INT,
    bsap INT,
    bvs INT,
    belx INT,
    creado_en DATETIME,
    liberado_fecha DATETIME,
    cancelado_fecha DATETIME,
    usuario_libero VARCHAR(100),
    load_datetime DATETIME2 DEFAULT GETDATE()
);


IF OBJECT_ID ('dbo.silver_vendedores', 'U') IS NOT NULL
    DROP TABLE dbo.silver_vendedores

GO

CREATE TABLE dbo.silver_vendedores (
    usuario VARCHAR(50),
    nombre VARCHAR(100),
    load_datetime DATETIME2 DEFAULT GETDATE()
); 


IF OBJECT_ID ('dbo.silver_estatus_pool', 'U') IS NOT NULL
    DROP TABLE dbo.silver_estatus_pool

GO

CREATE TABLE dbo.silver_estatus_pool (
    estatus INT,
    descripcion VARCHAR(255)
); 
