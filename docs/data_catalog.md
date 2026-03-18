# Data Catalog - Gold Layer

## Overview

The Gold layer contains curated, business-ready data structured using a star schema.  
It is designed to support reporting, analytics, and decision-making processes.

Data in this layer is derived from the Silver layer and includes standardized fields, calculated metrics, and business logic.

---

## Tables

### 1. dbo.gold_fact_pedidos_pool

**Purpose**  
Main fact table containing one record per order in the credit pool.  
Used to analyze order lifecycle, resolution times, and operational performance.

**Columns**

| Column Name       | Data Type     | Description |
|------------------|--------------|------------|
| pedido_id        | VARCHAR / INT | Unique order identifier (business key) |
| cliente_id       | VARCHAR / INT | Customer identifier |
| usuario_id       | VARCHAR       | Identifier of the user who resolved the order |
| estatus_id       | INT           | Order status identifier |
| motivo_pool      | VARCHAR       | Reason for entering the credit pool |
| fecha_creacion   | DATETIME      | Order creation timestamp |
| fecha_resolucion | DATETIME      | Order resolution timestamp |
| valor_pedido     | DECIMAL       | Order monetary value |
| horas_en_pool    | INT           | Total hours in pool |
| minutos_en_pool  | INT           | Total minutes in pool |

---

### 2. dbo.gold_dim_vendedores

**Purpose**  
Dimension table containing user information related to order resolution.

**Columns**

| Column Name     | Data Type | Description |
|----------------|----------|------------|
| usuario_id     | VARCHAR  | Unique user identifier |
| usuario_libero | VARCHAR  | Name of the user |

---

### 3. dbo.gold_dim_estatus_pool

**Purpose**  
Dimension table defining order status descriptions.

**Columns**

| Column Name | Data Type | Description |
|------------|----------|------------|
| estatus_id | INT      | Status identifier |
| estatus    | VARCHAR  | Status description |

---

## Relationships

- gold_fact_pedidos_pool.usuario_id → gold_dim_vendedores.usuario_id  
- gold_fact_pedidos_pool.estatus_id → gold_dim_estatus_pool.estatus_id  

---
