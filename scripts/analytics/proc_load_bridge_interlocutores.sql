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
