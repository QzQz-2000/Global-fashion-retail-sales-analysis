# Fashion Retail Sales Data Analysis

A data pipeline with dbt, Docker, Airflow, Terraform, BigQuery, and Looker Studio!

## Description

### Objective

The fashion retail industry is dynamic, with vast amounts of transaction, product, and customer data flowing daily. Analyzing this data is crucial for gaining insights into sales trends, customer preferences, and inventory management. This project aims to build an ELT pipeline to thoroughly analyze and model fashion retail sales data, creating a data mart that can power decision-making, optimize product offerings, and enhance the customer shopping experience.

The pipeline extracts, loads, and transforms data from various sources like transaction records, product data, employee details, and store information. The goal is to aggregate this data and provide a comprehensive analysis for the retail industry, helping stakeholders optimize sales strategies, manage inventory more effectively, and predict future sales trends.

### Dataset

The dataset for this project includes sales transactions from a fashion retail company, covering various customer, product, store, and employee details. It includes transaction-level data from different product categories, payment methods, discount details, and more.

We use the following data:

- **Transactions Data**: Contains details about each sale, including transaction IDs, customer IDs, product IDs, prices, quantities, and more.
- **Customer Data**: Information about customers, including names and demographics.
- **Product Data**: Includes details of products like product IDs, names, categories, colors, sizes, and prices.
- **Employee Data**: Data related to employees who processed the transactions.
- **Store Data**: Information about the retail stores, including store locations and employee assignments.

The pipeline builds out fact and dimension tables to model the data, providing a clear, analytical view of the sales performance and customer interactions.

**Data Schema**

![dataset](./images/dataset.png)

### Tools & Technologies

- Cloud - [**Google Cloud Platform**](https://cloud.google.com/)

- Infrastructure as Code tool - [**Terraform**](https://www.terraform.io/)
- Containerization - [**Docker**](https://www.docker.com/), [**Docker Compose**](https://docs.docker.com/compose/)

- Orchestration tool - [**Airflow**](https://airflow.apache.org/)

- Transformation - [**dbt**](https://www.getdbt.com/)

- Data Lake - [**Google Cloud Storage**](https://cloud.google.com/storage)

- Data Warehouse - [**BigQuery**](https://cloud.google.com/bigquery)
- Data Visualization - [**Looker Studio**](https://datastudio.google.com/overview)
- Programming Language - [**Python**](https://www.python.org/)
- Other tools - [**DuckDB**](https://duckdb.org/)

### Architecture

![archi](./images/archi.png)

### Final Dashboard
Click here to see the final report: [Global Fashion Retail Sales Report](https://lookerstudio.google.com/reporting/00949454-9e37-4db1-a51f-732a993c8556)


## Setup

- Google cloud platform environment - [Setup](./setup/GCP-setup.md)
- Create infra on GCP with Terraform - [Setup](./setup/Terraform-setup.md)
- Airflow orchestration - [Setup](./setup/Airflow-Setup.md)
