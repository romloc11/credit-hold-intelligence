# Data Catalog - Gold Layer

## Overview

The Gold layer contains curated, business-ready data structured using a star schema.  
It is designed to support reporting, analytics, and decision-making processes.

Data in this layer is derived from the Silver layer and includes standardized fields, calculated metrics, and business logic.

This layer exposes **analytical views** that power reporting tools such as Power BI.

---

# Tables / Views

---

## 1. gold.fact_pedidos

**Purpose**  
Fact view containing order-level information.  
Used to analyze order volume, revenue trends, and customer purchasing behavior.

**Columns**

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| pedido_id | INT | Unique order identifier |
| cliente_id | VARCHAR | Customer identifier |
| paqueteria_id | VARCHAR | Shipping provider identifier |
| fecha_pedido | DATE | Date the order was created |
| valor_pedido | DECIMAL | Total monetary value of the order |

---

## 2. gold.fact_pedidos_pool

**Purpose**  
Fact view containing orders that entered the credit pool.  
Used to analyze operational delays and credit approval performance.

**Columns**

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| pool_id | INT | Unique identifier of the pool record |
| pedido_id | INT | Order identifier |
| estatus_id | INT | Credit pool status |
| motivo_id | INT | Reason for entering the pool |
| usuario_libero_id | VARCHAR | User who resolved the pool case |
| fecha_resolucion | DATE | Date when the order left the pool |
| valor_pedido | DECIMAL | Order value |
| horas_en_pool | INT | Hours spent in the credit pool |
| minutos_en_pool | INT | Minutes spent in the credit pool |

---

## 3. gold.fact_facturas

**Purpose**  
Fact view containing invoice information derived from the ERP system.

This view enables analysis of invoicing activity and revenue recognition.

**Columns**

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| factura_id | VARCHAR | Unique invoice identifier |
| pedido_id | INT | Related order identifier |
| cliente_id | VARCHAR | Customer identifier |
| estatus_id | VARCHAR | Invoice status |
| fecha_factura | DATE | Invoice creation date |
| monto_factura | DECIMAL | Invoice total amount |

---

## 4. gold.fact_pagos

**Purpose**  
Fact view containing payment transactions applied to customer accounts.

Used to analyze customer payment behavior and cash flow.

**Columns**

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| pago_id | VARCHAR | Payment document identifier |
| cliente_id | VARCHAR | Customer identifier |
| fecha_pago | DATE | Payment posting date |
| monto_pago | DECIMAL | Payment amount |

---

## 5. gold.fact_aplicaciones_pago

**Purpose**  
Fact view linking payments to invoices.  
Allows analysis of how payments are applied to outstanding invoices.

**Columns**

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| aplicacion_id | VARCHAR | Unique identifier for payment application |
| pago_id | VARCHAR | Payment identifier |
| factura_id | VARCHAR | Invoice identifier |
| monto_aplicado | DECIMAL | Amount applied to invoice |
| fecha_aplicacion | DATE | Date when payment was applied |

---

## 6. gold.fact_notas_credito

**Purpose**  
Fact view containing credit note transactions.

Used to analyze adjustments, returns, and revenue corrections.

**Columns**

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| nota_id | VARCHAR | Credit note identifier |
| cliente_id | VARCHAR | Customer identifier |
| fecha_nota | DATE | Credit note posting date |
| monto_nota | DECIMAL | Credit note amount |

---

## 7. gold.dim_cliente

**Purpose**  
Dimension view containing customer master data.

Used to enrich sales and financial metrics with customer attributes.

**Columns**

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| cliente_id | INT | Unique customer identifier |
| nombre | VARCHAR | Customer name |
| rfc | VARCHAR | Tax identification number |
| direccion | VARCHAR | Street address |
| city | VARCHAR | City |
| credit_limit | DECIMAL | Approved credit limit |

---

## 9. gold.dim_usuario_libero

**Purpose**  
Dimension view containing users responsible for releasing orders from the credit pool.

**Columns**

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| usuario_libero_id | VARCHAR | User identifier |
| nombre | VARCHAR | User name |

---

## 10. gold.dim_motivo_pool

**Purpose**  
Dimension view containing reasons why orders enter the credit pool.

**Columns**

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| motivo_id | INT | Pool reason identifier |
| motivo | VARCHAR | Reason description |

---

## 11. gold.dim_estatus_pool

**Purpose**  
Dimension view describing credit pool status codes.

**Columns**

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| estatus_id | INT | Pool status identifier |
| estatus | VARCHAR | Status description |

---

## 12. gold.dim_estatus_factura

**Purpose**  
Dimension view defining invoice status values from the ERP system.

**Columns**

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| estatus_id | VARCHAR | Invoice status code |
| estatus | VARCHAR | Invoice status description |

---

## 13. gold.dim_empleado

**Purpose**  
Dimension view containing employee information used for commercial and operational roles.

**Columns**

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| empleado_id | INT | Unique employee identifier |
| nombre | VARCHAR | Employee name |
| work_email | VARCHAR | Employee email address |
| usuario | VARCHAR | System login |

---

## 14. gold.bridge_interlocutores

**Purpose**  
Bridge view linking customers with employees who interact with them.

Supports many-to-many relationships and historical role tracking.

**Columns**

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| cliente_id | INT | Customer identifier |
| empleado_id | INT | Employee identifier |
| rol | VARCHAR | Role of the employee |
| fecha_inicio | DATETIME | Start date of relationship |
| fecha_fin | DATETIME | End date of relationship |
