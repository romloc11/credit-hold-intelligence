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

/* ==========================================================
   CIOSACOM
========================================================== */

IF OBJECT_ID('silver.ciosacom_pedidos','U') IS NOT NULL
DROP TABLE silver.ciosacom_pedidos;
GO

CREATE TABLE silver.ciosacom_pedidos (

    pedido_id INT,
    cliente_id NVARCHAR(50),
    paqueteria_id NVARCHAR(50),
    creado_en DATETIME,
    valor_pedido DECIMAL(18,2)

);
GO


IF OBJECT_ID('silver.ciosacom_pedidos_pool','U') IS NOT NULL
DROP TABLE silver.ciosacom_pedidos_pool;
GO

CREATE TABLE silver.ciosacom_pedidos_pool (

    pool_id INT,
    pedido_id INT,
    estatus_id INT,
    motivo_id INT,
    usuario_libero_id NVARCHAR(50),
    fecha_resolucion DATETIME,
    valor_pedido DECIMAL(18,2),
    horas_en_pool INT,
    minutos_en_pool INT

);
GO


IF OBJECT_ID('silver.ciosacom_usuario_libero','U') IS NOT NULL
DROP TABLE silver.ciosacom_usuario_libero;
GO

CREATE TABLE silver.ciosacom_usuario_libero (

    usuario_libero_id NVARCHAR(50),
    nombre NVARCHAR(255)

);
GO


IF OBJECT_ID('silver.ciosacom_motivos_pool','U') IS NOT NULL
DROP TABLE silver.ciosacom_motivos_pool;
GO

CREATE TABLE silver.ciosacom_motivos_pool (

    motivo_id INT,
    motivo NVARCHAR(255)

);
GO


IF OBJECT_ID('silver.ciosacom_estatus_pool','U') IS NOT NULL
DROP TABLE silver.ciosacom_estatus_pool;
GO

CREATE TABLE silver.ciosacom_estatus_pool (

    estatus_id INT,
    estatus NVARCHAR(100)

);
GO


/* ==========================================================
   ERP (SAP)
========================================================== */

IF OBJECT_ID('silver.erp_vbrk','U') IS NOT NULL
DROP TABLE silver.erp_vbrk;
GO

CREATE TABLE silver.erp_vbrk (

    VBELN NVARCHAR(20),
    FKDAT DATE,
    KUNAG NVARCHAR(20),
    NETWR DECIMAL(18,2),
    WAERK NVARCHAR(10),
    FKSTK NVARCHAR(5)

);
GO


IF OBJECT_ID('silver.erp_vbrp','U') IS NOT NULL
DROP TABLE silver.erp_vbrp;
GO

CREATE TABLE silver.erp_vbrp (

    VBELN NVARCHAR(20),
    POSNR NVARCHAR(10),
    VGBEL NVARCHAR(20),
    NETWR DECIMAL(18,2)

);
GO


IF OBJECT_ID('silver.erp_bkpf','U') IS NOT NULL
DROP TABLE silver.erp_bkpf;
GO

CREATE TABLE silver.erp_bkpf (

    BELNR NVARCHAR(20),
    BUKRS NVARCHAR(10),
    GJAHR NVARCHAR(4),
    BLART NVARCHAR(5),
    BUDAT DATE,
    BLDAT DATE

);
GO


IF OBJECT_ID('silver.erp_bseg','U') IS NOT NULL
DROP TABLE silver.erp_bseg;
GO

CREATE TABLE silver.erp_bseg (

    BELNR NVARCHAR(20),
    BUZEI NVARCHAR(10),
    BUKRS NVARCHAR(10),
    GJAHR NVARCHAR(4),
    KUNNR NVARCHAR(20),

    DMBTR DECIMAL(18,2),
    WRBTR DECIMAL(18,2),

    AUGBL NVARCHAR(20),
    AUGDT DATE,

    BUDAT DATE

);
GO


IF OBJECT_ID('silver.erp_bsad','U') IS NOT NULL
DROP TABLE silver.erp_bsad;
GO

CREATE TABLE silver.erp_bsad (

    BELNR NVARCHAR(20),
    BUZEI NVARCHAR(10),
    BUKRS NVARCHAR(10),
    GJAHR NVARCHAR(4),

    KUNNR NVARCHAR(20),

    AUGBL NVARCHAR(20),
    AUGDT DATE,

    DMBTR DECIMAL(18,2),
    BUDAT DATE

);
GO


/* ==========================================================
   ODOO (CRM)
========================================================== */

IF OBJECT_ID('silver.odoo_res_partner','U') IS NOT NULL
DROP TABLE silver.odoo_res_partner;
GO

CREATE TABLE silver.odoo_res_partner (

    id INT,
    name NVARCHAR(255),
    parent_id INT,
    company_type NVARCHAR(50),

    street NVARCHAR(255),
    city NVARCHAR(100),
    country_id INT,

    vat NVARCHAR(50),

    credit_limit DECIMAL(18,2),

    create_date DATETIME,
    write_date DATETIME

);
GO


IF OBJECT_ID('silver.odoo_res_users','U') IS NOT NULL
DROP TABLE silver.odoo_res_users;
GO

CREATE TABLE silver.odoo_res_users (

    id INT,
    partner_id INT,
    login NVARCHAR(100),
    active BIT,

    create_date DATETIME

);
GO


IF OBJECT_ID('silver.odoo_hr_employee','U') IS NOT NULL
DROP TABLE silver.odoo_hr_employee;
GO

CREATE TABLE silver.odoo_hr_employee (

    id INT,
    name NVARCHAR(255),
    user_id INT,

    work_email NVARCHAR(255),

    create_date DATETIME

);
GO
