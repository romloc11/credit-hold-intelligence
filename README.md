# Data Warehouse – Credit & Collections (Pedidos en Pool)

This project presents an end-to-end data warehouse solution focused on analyzing orders held in credit review (pool). It covers data ingestion, transformation, modeling, and analytical layer design using SQL Server.

The goal is to enable visibility into operational bottlenecks, resolution times, and credit risk indicators.

---

🏗️ Data Architecture  

The project follows a Medallion Architecture with three layers:

**Bronze Layer**  
Stores raw data extracted from the transactional system (CIOSA) via Linked Server. Data is ingested without transformations.

**Silver Layer**  
Applies data cleansing and transformation:
- Deduplication of orders
- Standardization of text fields
- Mapping of status codes
- Basic business rules

**Gold Layer**  
Provides a star schema optimized for analytics:
- Fact table for orders in pool
- Dimension tables for status and users (vendedores)

---

📖 Project Overview

This project includes:

**Data Architecture**  
Design of a layered data warehouse using Bronze, Silver, and Gold structure.

**ETL Pipelines**  
Development of SQL-based stored procedures to load and transform data across layers.

**Data Modeling**  
Implementation of a star schema to support scalable analytics use cases.

**Analytics Focus**  
Analysis of:
- Time spent in pool (SLA / operational efficiency)
- Reasons for credit holds (motivo_pool)
- Resolution status (liberado, cancelado, retenido)
- User involvement in resolution

---

## Key Use Cases

- Monitor operational performance in credit review
- Identify delays in order release
- Analyze main causes of credit blockage
- Support decision-making in credit and collections

---

## Tech Stack

- SQL Server
- T-SQL (Stored Procedures, Views)
- Linked Server (CIOSACOM)
- Draw.io (Data modeling and architecture diagrams)
- GitHub (Version control)

---

## Data Source

| Field        | Value                                    |
|--------------|------------------------------------------|
| Source       | CIOSA operational system                 |
| Object Type  | Relational database (transactional)      |
| Interface    | SQL Server Linked Server (CIOSACOM)      |

---

## Repository Structure 🏗️ 
IMAGEN


---

## Data Model (Gold Layer)

**Fact Table**
- `gold_fact_pedidos_pool`
  - Contains one record per order in pool
  - Includes metrics such as:
    - `horas_en_pool`
    - `minutos_en_pool`
    - `valor_pedido`

**Dimension Tables**
- `gold_dim_estatus_pool`
- `gold_dim_vendedores`

Designed to support future scalability with additional entities:
- clientes
- facturas
- pagos
- notas de crédito

---

## Project Requirements

**Objective**  
Build a data warehouse to analyze orders in credit hold and improve operational visibility.

**Scope**
- Focus on current operational data (no historization)
- Integrate data from a single transactional source
- Enable analytical queries through structured modeling

**Data Quality**
- Remove duplicates using latest record logic
- Normalize user and status fields
- Handle null values based on business rules

---

## Future Improvements

- Add dimension for client
- Expand fact table to include full order lifecycle
- Integrate invoices and payments
- Implement historization (Slowly Changing Dimensions)
- Connect to BI tools (Power BI / Tableau)

---


