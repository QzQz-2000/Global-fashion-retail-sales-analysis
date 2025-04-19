# dbt Setup

## Setup
1. Install `dbt-core` and `dbt-bigquery` locally. You can follow the the [dbt docs](https://docs.getdbt.com/docs/core/pip-install).

2. Set up the `profiles.yml`:
```yaml
fashion_retail_sales_project:
  outputs:
    dev:
      dataset: fashion_sales_dataset
      fixed_retries: 1
      keyfile: <path/to/your/google_credentials.json>
      location: EU
      method: service-account
      priority: interactive
      project: fashion-retail-sales-project
      threads: 1
      timeout_seconds: 300
      type: bigquery
  target: dev
```

3. Nagivate to the `fashion_retail_sales_project` and run the following commands:
```bash
# test connection
dbt debug

# Run models
dbt run
```