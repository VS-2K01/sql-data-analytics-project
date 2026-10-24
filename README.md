# SQL Data Analytics Project

A collection of 12 SQL scripts demonstrating analytical SQL techniques — from basic exploration through window-function-based advanced analytics — run against a Gold-layer star schema, culminating in two reusable customer and product reporting views.

## Overview

A data warehouse is only useful once someone can actually ask it questions. This project is the analysis half of a two-part data engineering project: given a clean star schema (built in the companion [sql-data-warehouse-project](https://github.com/VS-2K01/sql-data-warehouse-project) repo), it works through a structured progression of SQL analysis techniques — exploring the data, quantifying it, ranking it, tracking it over time, segmenting it — and ends with two production-style reporting views that consolidate the most useful customer and product metrics into a single queryable object.

This is a learning project built by following Baraa Khatib Salkini's ("DataWithBaraa") free **Data Warehouse and Analytics Project** tutorial series. Every script here was written and run by me while working through it — see [Acknowledgments](#acknowledgments) below.

## Key features

- 12 standalone SQL scripts, each demonstrating a distinct analytical technique (exploration, magnitude, ranking, change-over-time, cumulative, performance, part-to-whole, segmentation)
- Two capstone reporting views — `gold.report_customers` and `gold.report_products` — that consolidate raw fact/dimension data into ready-to-query business metrics (customer segments, recency, average order value, product performance, etc.)
- Extensive use of SQL window functions (`RANK()`, `DENSE_RANK()`, `LAG()`, running `SUM() OVER()`, moving `AVG() OVER()`) rather than relying only on `GROUP BY`
- Each script documents its own purpose and the SQL functions it demonstrates in a header comment

## Demo

**Project roadmap — the 12-script progression this repo follows:**

![Roadmap showing Exploratory Data Analysis (database, dimensions, date, measures, magnitude, ranking) building to Advanced Analytics (change-over-time, cumulative, performance, part-to-whole, segmentation, reporting)](docs/project-roadmap.png)

## Architecture

```
gold.fact_sales ─┐
gold.dim_customers ─┼─▶ 12 analysis scripts ─▶ gold.report_customers
gold.dim_products ─┘                        └─▶ gold.report_products
```

Full script-by-script breakdown — what each one answers and which SQL techniques it uses — is in [`docs/architecture.md`](docs/architecture.md).

## Tech stack

- **SQL Server** (T-SQL) — window functions, CTEs, date functions, views

## Getting started

### Prerequisites

- The [sql-data-warehouse-project](https://github.com/VS-2K01/sql-data-warehouse-project) repo set up and loaded — this project queries its `gold.fact_sales`, `gold.dim_customers`, and `gold.dim_products` views directly, and doesn't load or clean any data itself.

### Running the scripts

Each script in `scripts/` is standalone — open it in SSMS or Azure Data Studio against the same database as the data warehouse project, and run it. A natural order to follow (matching the roadmap above):

```
1. db_exploration.sql
2. dim_exploration.sql
3. daterange_exploration.sql
4. measures_exploration.sql
5. magnitude_analysis.sql
6. ranking_analysis.sql
7. cot_analysis.sql
8. cumulative_analysis.sql
9. performance_analysis.sql
10. part_to_whole_analysis.sql
11. data_segmentation.sql
12. customer_report.sql, product_report.sql
```

The last two create views, so after running them you can query the results directly:

```sql
SELECT * FROM gold.report_customers;
SELECT * FROM gold.report_products;
```

## Project structure

```
sql-data-analytics-project/
├── docs/
│   ├── architecture.md
│   └── project-roadmap.png
├── scripts/
│   ├── db_exploration.sql
│   ├── dim_exploration.sql
│   ├── daterange_exploration.sql
│   ├── measures_exploration.sql
│   ├── magnitude_analysis.sql
│   ├── ranking_analysis.sql
│   ├── cot_analysis.sql
│   ├── cumulative_analysis.sql
│   ├── performance_analysis.sql
│   ├── part_to_whole_analysis.sql
│   ├── data_segmentation.sql
│   ├── customer_report.sql
│   └── product_report.sql
├── LICENSE
└── README.md
```

## Data

No data files in this repo — every script queries the Gold-layer views from [sql-data-warehouse-project](https://github.com/VS-2K01/sql-data-warehouse-project), which is itself built on Microsoft's public AdventureWorks sample dataset (synthetic, no real customer data).

## Testing

These are analytical queries, not application code, so there's no automated test suite — each script's output was checked by inspection against the underlying Gold-layer data for plausibility (e.g. ranking results sanity-checked against the raw aggregates, report view totals cross-checked against `measures_exploration.sql`'s headline numbers).

## Results

The two capstone views are the clearest proof the techniques work end-to-end: `gold.report_customers` turns three raw tables' worth of transaction history into one row per customer with a VIP/Regular/New segment, recency, and average spend already computed — the kind of view a BI tool or analyst would want to query directly rather than re-deriving every time.

## What I learned / skills gained

- **SQL window functions** — the difference between an aggregate `GROUP BY` and a window function that preserves row-level detail while adding a running total, rank, or lag comparison; when each is the right tool.
- **Structuring multi-stage queries with CTEs** instead of nested subqueries, so a complex aggregation (raw sales → per-customer aggregates → labeled business output) stays readable as separate, named stages.
- **Translating business questions into SQL** — "who are our VIP customers," "which products are trending down year-over-year," "what fraction of revenue does each category contribute" — and picking the right technique (segmentation, performance/LAG, part-to-whole) for each.
- **Designing views as reusable deliverables** rather than one-off scripts — `report_customers` and `report_products` are meant to be queried by someone else (a BI tool, another analyst) without needing to understand how they were built.
- **Reading a data model before querying it** — the exploration scripts (database, dimension, date, measures) exist specifically to understand the Gold-layer schema before writing analysis against it, rather than guessing at column meanings.

## Roadmap

- Parameterize the reporting views (e.g. a date range or region filter) rather than always computing over all history
- Add a Purity/segmentation accuracy check comparing the CASE-based customer segments against an independent clustering approach
- Build a lightweight BI dashboard (e.g. Power BI or a simple web chart) on top of `gold.report_customers` and `gold.report_products`

## My role

I built this by following Baraa Khatib Salkini's "Data Warehouse and Analytics Project" tutorial series hands-on in SQL Server — writing and running every script in this repository myself to practice window functions, CTEs, and business-oriented SQL reporting on top of the warehouse I built in the companion repo. See [Acknowledgments](#acknowledgments) for the original source.

## Acknowledgments

This project follows the structure and curriculum of [DataWithBaraa/sql-data-analytics-project](https://github.com/DataWithBaraa/sql-data-analytics-project) by Baraa Khatib Salkini, used under its MIT License. I built this repository by completing that tutorial end-to-end as a learning project.

## License and contact

Licensed under the [MIT License](LICENSE) (see license file for the original tutorial's attribution notice).

**Contact:** [github.com/VS-2K01](https://github.com/VS-2K01)
