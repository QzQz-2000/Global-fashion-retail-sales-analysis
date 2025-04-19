{{ config(materialized='table') }}

-- Staging table for products
select
    Product_ID as product_id,
    Category as category,
    Sub_Category as sub_category,
    Description_PT as description_pt,
    Description_DE as description_de,
    Description_FR as description_fr,
    Description_ES as description_es,
    Description_EN as description_en,
    Description_ZH as description_zh,
    coalesce(`Color`, 'Unkown') as color,
    Sizes as size,
    Production_Cost as production_cost
from {{ source('staging', 'products_salesdata_external_table') }}
