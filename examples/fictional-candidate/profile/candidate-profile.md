# Candidate Profile — Alex Rivera (FICTIONAL)

> **This is a worked example, not a real person.** Every company, name, and
> figure below is invented to demonstrate the format. Copy this file to start
> your own — the instructions in `.opencode/context/candidate-profile.template.md`
> explain each field.

## Identity & Contact

| Field | Value |
| ----- | ----- |
| Full name | Alex Rivera |
| Target title | Data Engineer |
| Phone | +44 20 7946 0000 |
| Email | alex.rivera@example.com |
| LinkedIn | https://www.linkedin.com/in/alex-rivera-example |
| GitHub / Portfolio | https://example.com/alex-rivera |

## Professional Summary

Data Engineer with 6+ years of experience designing batch and streaming
pipelines for analytics platforms. Migrated a legacy warehouse to a lakehouse
architecture, cut pipeline runtime by more than half, and owned ingestion for
petabyte-scale event data. Comfortable owning a pipeline end to end: schema,
orchestration, data quality, and the dashboards downstream teams depend on.

## Work History

### Northwind Analytics — Senior Data Engineer — Mar 2022 – Present

- **What you did:** Own the ingestion platform feeding 40+ internal dashboards and
  3 external customer-facing reports. Rebuilt a 6-hour nightly batch job as an
  incremental pipeline, and introduced schema contracts so upstream teams could
  ship changes without silently breaking downstream consumers.
- **Numbers:** nightly batch 6h → 25min; 40+ dashboards; 3 customer reports;
  team of 6; ~2 petabytes/month.
- **Tech you used:** Python, Apache Spark, Airflow, dbt, Snowflake, Kafka, Terraform, AWS

### Hallfield Logistics — Data Engineer — Aug 2019 – Feb 2022

- **What you did:** Built the fleet-telemetry pipeline for a delivery firm,
  handling live GPS pings and arrival events. Replaced a nightly CSV hand-off with
  a streaming ingest, and built the data-quality checks that caught bad vehicle
  records before they reached operations.
- **Numbers:** 1.2M events/day; 12 vehicles → 900+ vehicles onboarded; support
  tickets for missing data −60%.
- **Tech you used:** Python, Kafka, PostgreSQL, Docker, Grafana

### Brookline Analytics — Junior Data Analyst — Sep 2018 – Jul 2019

- **What you did:** Reporting and analysis for retail clients. Automated the
  weekly margin report, which had previously been assembled by hand.
- **Numbers:** 4 reports automated; ~8 hours/week saved.
- **Tech you used:** SQL, Excel, Power BI

## Technical Skills

- **Languages:** Python, SQL, Scala, Bash
- **Orchestration & Streaming:** Apache Airflow, Kafka, Spark, dbt
- **Storage & Warehousing:** Snowflake, BigQuery, Postgres, Parquet, Delta Lake
- **Cloud & Infrastructure:** AWS (S3, Glue, Redshift), Terraform, Docker, GitHub Actions
- **Quality & Observability:** Great Expectations, dbt tests, Grafana, Prometheus

## Projects

| Project | What it is | Your role | Link |
| ------- | ---------- | --------- | ---- |
| Pipeline Cost Monitor | Spend and runtime tracking for 200+ scheduled jobs | Sole author | https://example.com/portfolio/pipeline-cost-monitor |
| OpenETL | Small open-source Python library for testable extract-transform-load steps | Maintainer | https://example.com/portfolio/openetl |

## Education

- **BSc (Hons) Computer Science** — University of Bristol — Oct 2015 – Jun 2018

## Languages

- English (Native)
- Spanish (Professional)

## NEVER CLAIM

- Nothing confidential. This is a synthetic profile.

## Notes for the assistant

- Target roles are mid-level Data Engineer in London or fully remote UK/EU.
- Mornings are for high-volume; evenings for pipeline debugging.
