import os
import duckdb
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Environment variables
path_to_local_home = os.environ.get("AIRFLOW_HOME", "/opt/airflow")

customers_definition = {
    'Customer ID': 'INTEGER',
    'Name': 'VARCHAR',
    'Email': 'VARCHAR',
    'Telephone': 'VARCHAR',
    'City': 'VARCHAR',
    'Country': 'VARCHAR',
    'Gender': 'CHAR',
    'Date of birth': 'DATE',
    'Job Title': 'VARCHAR'
}

products_definition = {
    'Product ID': 'INTEGER',
    'Category': 'VARCHAR',
    'Sub Category': 'VARCHAR',
    'Description PT': 'TEXT',
    'Description DE': 'TEXT',
    'Description FR': 'TEXT',
    'Description ES': 'TEXT',
    'Description EN': 'TEXT',
    'Description ZH': 'TEXT',
    'Color': 'VARCHAR',
    'Sizes': 'VARCHAR',
    'Production Cost': 'FLOAT'
}

transactions_definition = {
    'Invoice ID': 'VARCHAR',
    'Line': 'INTEGER',
    'Customer ID': 'INTEGER',
    'Product ID': 'VARCHAR',
    'Size': 'VARCHAR',
    'Color': 'VARCHAR',
    'Unit Price': 'FLOAT',
    'Quantity': 'INTEGER',
    'Date': 'TIMESTAMP',
    'Discount': 'FLOAT',
    'Line Total': 'FLOAT',
    'Store ID': 'INTEGER',
    'Employee ID': 'INTEGER',
    'Currency': 'VARCHAR',
    'Currency Symbol': 'VARCHAR',
    'SKU': 'VARCHAR',
    'Transaction Type': 'VARCHAR',
    'Payment Method': 'VARCHAR',
    'Invoice Total': 'FLOAT'
}


def convert_csv_to_parquet(input_path_prefix, output_path_prefix, csv_file, schema):
    input_csv_path = os.path.join(input_path_prefix, csv_file)
    if not os.path.exists(input_csv_path):
        raise FileNotFoundError(f"CSV file not found: {input_csv_path}")

    if not os.path.exists(output_path_prefix):
            os.makedirs(output_path_prefix)
            logger.info(f"Created directory: {output_path_prefix}")
    
    output_csv_path = os.path.join(output_path_prefix, csv_file.replace('.csv', '.parquet'))

    try:
        duckdb.query(f"""
            COPY (
                SELECT * FROM read_csv('{input_csv_path}', delim=',', header=True, columns={schema})
            )
            TO '{output_csv_path}' (FORMAT 'PARQUET', CODEC 'ZSTD');
        """)
        logger.info(f"Converted: {input_csv_path} -> {output_csv_path}")
    except Exception as e:
        logger.error(f"Failed to convert {input_csv_path}: {e}")
        raise

input_path_prefix = os.path.join(path_to_local_home, "data/raw")
output_path_prefix = os.path.join(path_to_local_home, "data/parquet")

files_and_definitions = [
    ("customers.csv", customers_definition),
    ("products.csv", products_definition),
    ("transactions.csv", transactions_definition)
]

for file_name, schema in files_and_definitions:
    convert_csv_to_parquet(
        input_path_prefix,
        output_path_prefix,
        file_name,
        schema
    )