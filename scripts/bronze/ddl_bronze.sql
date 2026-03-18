/*
=====================================================================================
DDL Scripts: CREATE BRONZE TABLES
=====================================================================================
Script Prupose:
    This script creates the bronze tables in the dbo schema, dropping existing tables 
    if the already exist.
Run this script to redifine the DDL sctructure of 'bronze' tables.
=====================================================================================
*/

IF OBJECT_ID ('dbo.bronze_pedidos_pool_clientes', 'U') IS NOT NULL
    DROP TABLE dbo.bronze_pedidos_pool_clientes

GO 

CREATE TABLE dbo.bronze_pedidos_pool_clientes (
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
    usuario_libero VARCHAR(100)
);


IF OBJECT_ID ('dbo.bronze_vendedores', 'U') IS NOT NULL
    DROP TABLE dbo.bronze_vendedores

GO

CREATE TABLE dbo.bronze_vendedores (
    usuario VARCHAR(50),
    nombre VARCHAR(100)
); 
