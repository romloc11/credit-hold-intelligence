CREATE OR ALTER PROCEDURE analytics.proc_load_bridge_cliente_empleado
AS
BEGIN

SET NOCOUNT ON;


WITH interlocutores_actuales AS (

-- VENDEDOR

SELECT

    p.id AS cliente_id,
    e.id AS empleado_id,
    'VENDEDOR' AS rol

FROM silver.odoo_res_partner p

LEFT JOIN silver.odoo_res_users u
    ON p.user_id = u.id

LEFT JOIN silver.odoo_hr_employee e
    ON u.id = e.user_id

WHERE p.company_type = 'COMPANY'


UNION ALL


-- GERENTE DE VENTAS

SELECT

    p.id AS cliente_id,
    e.id AS empleado_id,
    'GERENTE_VENTA' AS rol

FROM silver.odoo_res_partner p

LEFT JOIN silver.odoo_res_users u
    ON p.sales_manager_id = u.id

LEFT JOIN silver.odoo_hr_employee e
    ON u.id = e.user_id

WHERE p.company_type = 'COMPANY'


UNION ALL


-- TELEMARKETING

SELECT

    p.id AS cliente_id,
    e.id AS empleado_id,
    'TELEMARKETING' AS rol

FROM silver.odoo_res_partner p

LEFT JOIN silver.odoo_res_users u
    ON p.telemarketing_user_id = u.id

LEFT JOIN silver.odoo_hr_employee e
    ON u.id = e.user_id

WHERE p.company_type = 'COMPANY'

UNION ALL


-- EJECUTIVO CREDITO

SELECT

    p.id AS cliente_id,
    e.id AS empleado_id,
    'EJECUTIVO CREDITO' AS rol

FROM silver.odoo_res_partner p

LEFT JOIN silver.odoo_res_users u
    ON p.user_id = u.id

LEFT JOIN silver.odoo_hr_employee e
    ON u.id = e.user_id

WHERE p.company_type = 'COMPANY'


UNION ALL


-- GERENTE REGIONAL

SELECT

    p.id AS cliente_id,
    e.id AS empleado_id,
    'GERENTE REGIONAL' AS rol

FROM silver.odoo_res_partner p

LEFT JOIN silver.odoo_res_users u
    ON p.user_id = u.id

LEFT JOIN silver.odoo_hr_employee e
    ON u.id = e.user_id

WHERE p.company_type = 'COMPANY'

)

UPDATE b
SET

    fecha_fin = GETDATE(),
    es_actual = 0

FROM analytics.bridge_cliente_empleado b

JOIN interlocutores_actuales s
    ON b.cliente_id = s.cliente_id
    AND b.rol = s.rol

WHERE b.es_actual = 1
AND b.empleado_id <> s.empleado_id;


-- insertar nuevos registros

INSERT INTO analytics.bridge_cliente_empleado
(
    cliente_id,
    empleado_id,
    rol,
    fecha_inicio,
    fecha_fin,
    es_actual
)

SELECT

    s.cliente_id,
    s.empleado_id,
    s.rol,
    GETDATE(),
    NULL,
    1

FROM interlocutores_actuales s

LEFT JOIN analytics.bridge_cliente_empleado b
    ON s.cliente_id = b.cliente_id
    AND s.rol = b.rol
    AND b.es_actual = 1

WHERE b.cliente_id IS NULL
OR b.empleado_id <> s.empleado_id;

END


