/*
===============================================================================
DDL Script: Create analytics Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'analytics' schema, dropping existing tables
    if they already exist.

    This layer contains historical and analytical tables used to support
    advanced data modeling patterns such as Slowly Changing Dimensions (SCD).

    Run this script to re-define the DDL structure of 'analytics' tables.
===============================================================================
*/

    
IF OBJECT_ID('analytics.bridge_cliente_empleado','U') IS NOT NULL
DROP TABLE analytics.bridge_cliente_empleado;
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
