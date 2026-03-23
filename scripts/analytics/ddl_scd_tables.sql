/* ============================================================================
Script: ddl_scd_tables.sql
Layer: Analytics

Description:
This script creates Slowly Changing Dimension (SCD) tables used to store
historical relationships between business entities.

Currently it creates the table:
    analytics.bridge_cliente_empleado

Purpose:
The table tracks historical relationships between customers and employees
(interlocutors) such as sales representatives, sales managers, credit
executives, and telemarketing agents.

Usage:
The table is populated by the procedure:
    analytics.proc_load_bridge_cliente_empleado

This table serves as the historical foundation for the Gold layer view:
    gold.bridge_interlocutores
============================================================================ */

CREATE SCHEMA analytics;
GO
    
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
