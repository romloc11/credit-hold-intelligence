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

Design:
This table implements a Slowly Changing Dimension Type 2 (SCD Type 2) pattern,
allowing the system to preserve the history of changes in customer ownership
and commercial team assignments.

Key Fields:
    cliente_id   → Customer identifier
    empleado_id  → Employee identifier
    rol          → Role of the employee relative to the customer
    fecha_inicio → Start date of the relationship
    fecha_fin    → End date of the relationship
    es_actual    → Flag indicating the current active relationship

Usage:
The table is populated by the procedure:
    analytics.proc_load_bridge_cliente_empleado

This table serves as the historical foundation for the Gold layer view:
    gold.bridge_interlocutores
============================================================================ */

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
