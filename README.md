# Data Engineering Weekly Journey: From Analytics to Engineering

[![Python](https://img.shields.io/badge/Python-3.11+-blue.svg)](https://www.python.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-336791.svg)](https://www.postgresql.org/)
[![dbt](https://img.shields.io/badge/dbt-Core-orange.svg)](https://www.getdbt.com/)
[![Apache Airflow](https://img.shields.io/badge/Orchestration-Airflow-017CEE.svg)](https://airflow.apache.org/)
[![Apache Spark](https://img.shields.io/badge/Big%20Data-PySpark-E25A1C.svg)](https://spark.apache.org/)

An end-to-end, milestone-driven repository documenting a structured 12-week transition from Data Analyst to Data Engineer. This repository captures the progression from ad-hoc analysis scripts to modular, production-ready data pipelines, distributed computing, database warehousing, and orchestration.

---

## 🧭 Technical Paradigm Shift

| Focus Area | Analytics Baseline | Engineering Target |
| :--- | :--- | :--- |
| **Code Architecture** | Ad-hoc procedural scripts / Notebooks | Modular, Object-Oriented classes & clean architecture |
| **Pipeline Reliability** | Terminal `print()` debugging | Structured `logging` and defensive `try/except` handlers |
| **Transformations** | Power Query UI / In-memory Pandas | Version-controlled, modular SQL via **dbt** |
| **Scalability** | Single-node chunked Pandas processing | Distributed computing using **Apache Spark (PySpark)** |
| **Workflow Management** | Manual refreshes / OS task schedulers | Programmatic Directed Acyclic Graphs (DAGs) in **Airflow** |
| **Data Storage** | Local flat CSV / Excel exports | Relational **PostgreSQL** & Cloud Data Warehouses |

---

## 🗺️ 12-Week Roadmap & Execution Status

### Phase 1: Production-Grade Python (Weeks 1–3)
- [x] **Week 1: OOP & Code Structure**
  - Built modular `DataLoader` classes encapsulating ingestion and data validation.
  - Replaced script-level transformations with maintainable object-oriented patterns.
- [x] **Week 2: Exception Handling & Structured Logging**
  - Replaced terminal prints with the native `logging` module (`logging.basicConfig`, log rotation).
  - Implemented graceful degradation and explicit custom exception handling.
- [x] **Week 3: APIs & Relational Database Ingestion**
  - Ingested Formula 1 race telemetry using the Jolpica/Ergast REST API.
  - Flattened nested multi-layer JSON payloads via `pandas.json_normalize`.
  - Automated relational loads into local **PostgreSQL** using SQLAlchemy engines.

---

### Phase 2: Data Warehousing & Dimensional Modeling (Weeks 4–5)
- [ ] **Week 4: Dimensional Modeling Design**
  - Star Schema vs. Snowflake Schema architectural modeling.
  - Fact vs. Dimension boundaries, grain definition, surrogate keys, and SCD (Type 1 & 2) handling.
  - Deliverable: Normalized ERD and dimensional design mapped via `dbdiagram.io`.
- [ ] **Week 5: Cloud Data Warehousing (BigQuery / Snowflake)**
  - Storage design, partitioning, and clustering strategies for cost and query optimization.
  - Loading modeled historical datasets into the cloud warehouse environment.

---

### Phase 3: Analytical Engineering with dbt (Weeks 6–7)
- [ ] **Week 6: dbt Core Transformations**
  - Building modular data models (`staging`, `intermediate`, `marts`).
  - Leveraging Jinja templating, variables, and reusable macros.
- [ ] **Week 7: Data Quality Testing & Documentation**
  - Schema testing: `unique`, `not_null`, `relationships`, and custom data assertions.
  - Automated documentation catalog generation and Git version-control hygiene.

---

### Phase 4: Distributed Computing with PySpark (Weeks 8–9)
- [ ] **Week 8: PySpark DataFrame Operations**
  - SparkSession management, lazy evaluation, execution plans, and memory distribution.
  - Migrating high-volume workloads (7.4M+ row ultra-marathon dataset) out of Pandas memory limits.
- [ ] **Week 9: Spark SQL & Performance Benchmarking**
  - Optimization of wide vs. narrow transformations, shuffle tuning, and partitioning.
  - Quantified performance benchmark: Memory footprint and execution runtime vs. Pandas.

---

### Phase 5: Orchestration & End-to-End Capstone (Weeks 10–12)
- [ ] **Week 10: Workflow Orchestration with Apache Airflow**
  - Authoring DAGs, defining task dependencies (`>>`), retries, and execution schedules.
  - Automating the REST API $\rightarrow$ Database pipeline on an automated schedule.
- [ ] **Weeks 11–12: Unified Capstone Architecture**
  - End-to-end automated pipeline implementation:
    $$\text{Public API Ingestion} \longrightarrow \text{Cloud Warehouse} \longrightarrow \text{dbt Transformations} \longrightarrow \text{Airflow} \longrightarrow \text{Power BI}$$
  - Full project documentation, data lineage graphs, and pipeline observability.

---

