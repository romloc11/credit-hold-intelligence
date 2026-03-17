🧾 Credit Hold Intelligence Dashboard
📌 Overview

This project delivers an end-to-end data solution to monitor and analyze credit holds in the Order-to-Cash process, enabling better decision-making in credit and collections.

⚙️ Tech Stack

SQL Server (Linked Server)

MySQL (source system)

Power BI

DAX

SQL Server Agent (proposed automation)

🏗️ Architecture
MySQL → SQL Server (OPENQUERY) → Data Model → Power BI Dashboard
🔍 Key Features

Identification of credit block reasons

Tracking order lifecycle (created → released → canceled)

User performance analysis

Time-to-resolution metrics

Daily trend monitoring

📊 Key Insights

Majority of blocks driven by saldo vencido

Clear visibility into user performance

Detection of bottlenecks in credit release process

🧠 Data Modeling

Fact table: pool_credito

Date dimension: Calendario

Star schema approach

⚡ Performance Optimization

Snapshot table to reduce load on source system

Pre-calculated indicators in SQL

Efficient DAX measures

🧪 Data Validation

Cross-check with source system counts

Null and edge-case validation

Business rule validation (status mapping)
