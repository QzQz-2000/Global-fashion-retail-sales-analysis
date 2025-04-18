import os
import logging
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta, timezone
from airflow.providers.google.cloud.operators.bigquery import BigQueryCreateExternalTableOperator, BigQueryInsertJobOperator
from google.cloud import storage

customers_definition = [
    {'name': 'Customer_ID', 'type': 'INTEGER'},
    {'name': 'Name', 'type': 'STRING'},
    {'name': 'Email', 'type': 'STRING'},
    {'name': 'Telephone', 'type': 'STRING'},
    {'name': 'City', 'type': 'STRING'},
    {'name': 'Country', 'type': 'STRING'},
    {'name': 'Gender', 'type': 'STRING'},
    {'name': 'Date_of_birth', 'type': 'DATE'},
    {'name': 'Job_Title', 'type': 'STRING'}
]

products_definition = [
    {'name': 'Product_ID', 'type': 'INTEGER'},
    {'name': 'Category', 'type': 'STRING'},
    {'name': 'Sub_Category', 'type': 'STRING'},
    {'name': 'Description_PT', 'type': 'STRING'},
    {'name': 'Description_DE', 'type': 'STRING'},
    {'name': 'Description_FR', 'type': 'STRING'},
    {'name': 'Description_ES', 'type': 'STRING'},
    {'name': 'Description_EN', 'type': 'STRING'},
    {'name': 'Description_ZH', 'type': 'STRING'},
    {'name': 'Color', 'type': 'STRING'},
    {'name': 'Sizes', 'type': 'STRING'},
    {'name': 'Production_Cost', 'type': 'FLOAT'}
]

transactions_definition = [
    {'name': 'Invoice_ID', 'type': 'STRING'},
    {'name': 'Line', 'type': 'INTEGER'},
    {'name': 'Customer_ID', 'type': 'INTEGER'},
    {'name': 'Product_ID', 'type': 'INTEGER'},
    {'name': 'Size', 'type': 'STRING'},
    {'name': 'Color', 'type': 'STRING'},
    {'name': 'Unit_Price', 'type': 'FLOAT'},
    {'name': 'Quantity', 'type': 'INTEGER'},
    {'name': 'Date', 'type': 'TIMESTAMP'},
    {'name': 'Discount', 'type': 'FLOAT'},
    {'name': 'Line_Total', 'type': 'FLOAT'},
    {'name': 'Store_ID', 'type': 'INTEGER'},
    {'name': 'Employee_ID', 'type': 'INTEGER'},
    {'name': 'Currency', 'type': 'STRING'},
    {'name': 'Currency_Symbol', 'type': 'STRING'},
    {'name': 'SKU', 'type': 'STRING'},
    {'name': 'Transaction_Type', 'type': 'STRING'},
    {'name': 'Payment_Method', 'type': 'STRING'},
    {'name': 'Invoice_Total', 'type': 'FLOAT'}
]

tables_and_definitions = [
    ("customers", customers_definition),
    ("products", products_definition),
    ("transactions", transactions_definition)
]

# Env variables
path_to_local_home = os.environ.get("AIRFLOW_HOME", "/opt/airflow")
PROJECT_ID = os.environ.get("GCP_PROJECT_ID")
BUCKET = os.environ.get("GCP_GCS_BUCKET")
BIGQUERY_DATASET = os.environ.get("BIGQUERY_DATASET", 'fashion_sales_dataset')
INPUT_FILETYPE = "parquet"
DATASET = "salesdata"
partition_table = "transactions"
date_col = "Date"

# Default arguments
default_args = {
    'owner': 'airflow',
    'retries': 0,
    'retry_delay': timedelta(minutes=5)
}

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


def upload_data_to_gcs(bucket_name, local_folder, gcs_prefix=" "):

    # Configure chunk sizes for large files
    storage.blob._MAX_MULTIPART_SIZE = 5 * 1024 * 1024  # 5 MB
    storage.blob._DEFAULT_CHUNKSIZE = 5 * 1024 * 1024  # 5 MB

    client = storage.Client()
    bucket = client.bucket(bucket_name)

    for root, dirs, files in os.walk(local_folder):
        for file in files:
            if file.endswith(".parquet"):
                local_path = os.path.join(root, file)
                relative_path = os.path.relpath(local_path, local_folder)
                gcs_path = os.path.join(gcs_prefix, relative_path).replace("\\", "/")
                blob = bucket.blob(gcs_path)
                try:
                    blob.upload_from_filename(local_path)
                    logger.info(f'File {local_path} uploaded to {gcs_path}.')
                except Exception as e:
                    logger.error(f'Failed to upload {local_path} to {gcs_path}: {e}')

with DAG(
    dag_id='data_ingestion',
    schedule_interval=None,  # Set to None to avoid automatic execution
    start_date=datetime(2025, 4, 13, tzinfo=timezone.utc),  # Use a fixed start date
    catchup=False,  # Don't catch up if the DAG is paused and resumed
    default_args=default_args,
    tags=['fashion-retail-sales-project']
) as dag:

    download_data_task = BashOperator(
        task_id='download_raw_data',
        bash_command=f"{path_to_local_home}/scripts/download_data.sh "
    )
      
    format_to_parquet_task = BashOperator(
        task_id='csv_data_to_parquet',
        bash_command=f'python {path_to_local_home}/scripts/csv_to_parquet_duckdb.py'
    )
        
    local_to_gcs_task = PythonOperator(
        task_id=f'local_data_to_gcs_task',
        python_callable=upload_data_to_gcs,
        op_kwargs={
            "bucket_name": BUCKET,
            "local_folder": f'{path_to_local_home}/data/parquet',
            "gcs_prefix": ""
        }
    )
    
    bq_external_tasks = []

    for table_name, definition in tables_and_definitions:
        bq_task = BigQueryCreateExternalTableOperator(
            task_id=f"bq_{table_name}_{DATASET}_external_table_task",
            table_resource={
                "tableReference": {
                    "projectId": PROJECT_ID,
                    "datasetId": BIGQUERY_DATASET,
                    "tableId": f"{table_name}_{DATASET}_external_table",
                },
                "externalDataConfiguration": {
                    "sourceFormat": f"{INPUT_FILETYPE.upper()}",
                    "sourceUris": [f'gs://{BUCKET}/{table_name}.parquet'],
                    'schema': {
                        'fields': definition
                    }
                }
            }
        )
        bq_external_tasks.append(bq_task)

    CREATE_BQ_TBL_QUERY = (
        f"CREATE OR REPLACE TABLE {BIGQUERY_DATASET}.{partition_table}_{DATASET} \
        PARTITION BY DATE({date_col}) \
        AS \
        SELECT * FROM {BIGQUERY_DATASET}.{partition_table}_{DATASET}_external_table;"
    )

    # Create a partitioned table from external table
    bq_create_partitioned_table_task = BigQueryInsertJobOperator(
        task_id=f"bq_create_{partition_table}_{DATASET}_partitioned_table_task",
        configuration={
            "query": {
                "query": CREATE_BQ_TBL_QUERY,
                "useLegacySql": False,
            }
        }
    )
       
    download_data_task >> format_to_parquet_task >> local_to_gcs_task >> bq_external_tasks >> bq_create_partitioned_table_task
